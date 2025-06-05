#!/usr/bin/env zsh
# ==============================================================================
# Homebrew 管理函数集合 - 改进版
# 支持模块化管理、智能同步、环境检测等功能
# 版本: 2.0
# 加载方式：在 zsh/functions.zsh 中 source 此文件
# ==============================================================================

# 颜色定义
readonly BREW_RED='\033[0;31m'
readonly BREW_GREEN='\033[0;32m'
readonly BREW_YELLOW='\033[1;33m'
readonly BREW_BLUE='\033[0;34m'
readonly BREW_PURPLE='\033[0;35m'
readonly BREW_CYAN='\033[0;36m'
readonly BREW_NC='\033[0m'

# 输出函数
_brew_info() { echo -e "${BREW_BLUE}ℹ️  $1${BREW_NC}"; }
_brew_success() { echo -e "${BREW_GREEN}✅ $1${BREW_NC}"; }
_brew_warning() { echo -e "${BREW_YELLOW}⚠️  $1${BREW_NC}"; }
_brew_error() { echo -e "${BREW_RED}❌ $1${BREW_NC}"; }
_brew_header() { echo -e "${BREW_PURPLE}🍺 $1${BREW_NC}"; }

# ==============================================================================
# 统一路径管理
# ==============================================================================

# 获取 homebrew 目录路径（统一路径管理）
_get_homebrew_dir() {
    # 优先级: 环境变量 > 脚本检测 > 默认路径
    if [[ -n "$HOMEBREW_MODULE_DIR" ]] && [[ -d "$HOMEBREW_MODULE_DIR" ]]; then
        echo "$HOMEBREW_MODULE_DIR"
    elif [[ -n "$DOTFILES_HOME" ]] && [[ -d "$DOTFILES_HOME/homebrew" ]]; then
        echo "$DOTFILES_HOME/homebrew"
    else
        # 动态检测当前脚本所在目录
        local script_path="${${(%):-%x}:A}"  # zsh 获取当前脚本的绝对路径
        local script_dir="${script_path:h}"
        
        # 检查是否在 homebrew 目录中
        if [[ -f "$script_dir/Brewfile.essential" ]]; then
            echo "$script_dir"
        else
            # 默认路径
            echo "$HOME/dotfiles/homebrew"
        fi
    fi
}

# 验证 homebrew 目录
_validate_homebrew_dir() {
    local homebrew_dir="$(_get_homebrew_dir)"
    
    if [[ ! -d "$homebrew_dir" ]]; then
        _brew_error "Homebrew 目录不存在: $homebrew_dir"
        _brew_info "请设置环境变量 HOMEBREW_MODULE_DIR 或确保目录存在"
        return 1
    fi
    
    if [[ ! -f "$homebrew_dir/Brewfile.essential" ]]; then
        _brew_error "未找到必需的 Brewfile.essential"
        _brew_info "请确保在正确的目录中运行"
        return 1
    fi
    
    return 0
}

# ==============================================================================
# 改进的工具函数
# ==============================================================================

# 检查模块是否为空
_is_module_empty() {
    local brewfile="$1"
    
    if [[ ! -f "$brewfile" ]]; then
        return 0  # 文件不存在视为空
    fi
    
    # 计算实际安装条目（排除注释和空行）
    local package_count=$(grep -E "^(brew|cask|tap|file)" "$brewfile" | grep -v "^#" | wc -l | tr -d ' ')
    
    [[ $package_count -eq 0 ]]
}

# 获取模块统计信息
_get_module_stats() {
    local brewfile="$1"
    
    if [[ ! -f "$brewfile" ]]; then
        echo "0 0 0 0"
        return
    fi
    
    local brew_count=$(grep -c "^brew " "$brewfile" 2>/dev/null || echo "0")
    local cask_count=$(grep -c "^cask " "$brewfile" 2>/dev/null || echo "0")
    local tap_count=$(grep -c "^tap " "$brewfile" 2>/dev/null || echo "0")
    local file_count=$(grep -c "^file " "$brewfile" 2>/dev/null || echo "0")
    
    echo "$brew_count $cask_count $tap_count $file_count"
}

# 安全执行命令（带超时）
_safe_brew_command() {
    local timeout_duration="${1:-1800}"  # 默认30分钟
    shift
    local command=("$@")
    
    if command -v timeout >/dev/null 2>&1; then
        timeout "$timeout_duration" "${command[@]}"
    else
        # macOS 可能没有 timeout 命令，使用 brew 自带的超时处理
        "${command[@]}"
    fi
}

# ==============================================================================
# 核心模块管理函数
# ==============================================================================

# 列出所有可用模块
brew-list-modules() {
    # 确保环境正常
    if ! _brew_require_env; then
        return 1
    fi
    
    local homebrew_dir="$(_get_homebrew_dir)"
    
    _brew_header "可用的 Homebrew 模块"
    
    local modules=($(find "$homebrew_dir" -name "Brewfile.*" -exec basename {} \; | sed 's/Brewfile\.//' | sort))
    
    if [[ ${#modules[@]} -eq 0 ]]; then
        _brew_warning "未找到任何模块文件"
        return 1
    fi
    
    echo
    local total_packages=0
    
    for module in "${modules[@]}"; do
        local brewfile="$homebrew_dir/Brewfile.$module"
        local stats=($(_get_module_stats "$brewfile"))
        local brew_count=${stats[1]}
        local cask_count=${stats[2]}
        local tap_count=${stats[3]}
        local file_count=${stats[4]}
        
        local module_total=$((brew_count + cask_count))
        total_packages=$((total_packages + module_total))
        
        echo -e "  ${BREW_CYAN}$module${BREW_NC}"
        
        if _is_module_empty "$brewfile"; then
            echo -e "    ${BREW_YELLOW}📭 模块为空${BREW_NC}"
        else
            echo -e "    📦 $brew_count CLI工具  🖥️  $cask_count GUI应用  📁 $tap_count 仓库  📄 $file_count 子文件"
        fi
        
        # 显示文件大小
        local size=$(du -h "$brewfile" 2>/dev/null | cut -f1)
        echo -e "    💾 文件大小: $size"
        echo
    done
    
    _brew_info "总计: ${#modules[@]} 个模块，约 $total_packages 个软件包"
}

# 改进的模块验证
_validate_modules() {
    local modules=("$@")
    local homebrew_dir="$(_get_homebrew_dir)"
    local invalid_modules=()
    local empty_modules=()
    
    for module in "${modules[@]}"; do
        local brewfile="$homebrew_dir/Brewfile.$module"
        
        if [[ ! -f "$brewfile" ]]; then
            invalid_modules+=("$module")
        elif _is_module_empty "$brewfile"; then
            empty_modules+=("$module")
        fi
    done
    
    if [[ ${#invalid_modules[@]} -gt 0 ]]; then
        _brew_error "以下模块不存在: ${invalid_modules[*]}"
        _brew_info "可用模块: $(find "$homebrew_dir" -name "Brewfile.*" -exec basename {} \; | sed 's/Brewfile\.//' | sort | tr '\n' ' ')"
        return 1
    fi
    
    if [[ ${#empty_modules[@]} -gt 0 ]]; then
        _brew_warning "以下模块为空，将跳过: ${empty_modules[*]}"
        # 从模块列表中移除空模块
        for empty_mod in "${empty_modules[@]}"; do
            modules=("${modules[@]/$empty_mod}")
        done
        # 更新调用者的数组（这在zsh中比较复杂，建议在调用函数中处理）
    fi
    
    return 0
}

# 安装指定模块（带错误处理）
brew-install-module() {
    local module="$1"
    
    if [[ -z "$module" ]]; then
        _brew_error "用法: brew-install-module <模块名>"
        echo "示例: brew-install-module essential"
        echo "可用模块:"
        brew-list-modules 2>/dev/null | grep -E '^  [a-z]' | awk '{print "  " $1}' 2>/dev/null || echo "  运行 'brew-list-modules' 查看"
        return 1
    fi
    
    # 确保环境正常
    if ! _brew_require_env; then
        return 1
    fi
    
    local homebrew_dir="$(_get_homebrew_dir)"
    local brewfile="$homebrew_dir/Brewfile.$module"
    
    if [[ ! -f "$brewfile" ]]; then
        _brew_error "模块文件不存在: Brewfile.$module"
        _brew_info "运行 'brew-list-modules' 查看可用模块"
        return 1
    fi
    
    if _is_module_empty "$brewfile"; then
        _brew_warning "模块 $module 为空，跳过安装"
        return 0
    fi
    
    _brew_header "安装模块: $module"
    
    # 显示模块信息
    local stats=($(_get_module_stats "$brewfile"))
    local brew_count=${stats[1]}
    local cask_count=${stats[2]}
    _brew_info "包含 $brew_count 个CLI工具和 $cask_count 个GUI应用"
    
    # 检查 Homebrew 是否正常
    if ! command -v brew >/dev/null 2>&1; then
        _brew_error "Homebrew 未安装或不在 PATH 中"
        return 1
    fi
    
    # 执行安装（带超时）
    local start_time=$(date +%s)
    
    if _safe_brew_command 1800 brew bundle install --file="$brewfile"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        _brew_success "模块 $module 安装完成 (用时: ${duration}秒)"
        return 0
    else
        local exit_code=$?
        _brew_error "模块 $module 安装失败 (退出码: $exit_code)"
        
        # 提供故障排除建议
        echo
        _brew_info "故障排除建议:"
        echo "  1. 检查网络连接"
        echo "  2. 运行 'brew doctor' 检查问题"
        echo "  3. 更新 Homebrew: 'brew update'"
        echo "  4. 清理缓存: 'brew cleanup'"
        
        return 1
    fi
}

# 检查模块同步状态
brew-check-module() {
    local module="$1"
    
    if [[ -z "$module" ]]; then
        _brew_error "用法: brew-check-module <模块名>"
        echo "示例: brew-check-module essential"
        return 1
    fi
    
    if ! _validate_homebrew_dir; then
        return 1
    fi
    
    local homebrew_dir="$(_get_homebrew_dir)"
    local brewfile="$homebrew_dir/Brewfile.$module"
    
    if [[ ! -f "$brewfile" ]]; then
        _brew_error "模块文件不存在: Brewfile.$module"
        return 1
    fi
    
    if _is_module_empty "$brewfile"; then
        _brew_info "模块 $module 为空，跳过检查"
        return 0
    fi
    
    _brew_info "检查模块 $module 的同步状态..."
    
    if brew bundle check --file="$brewfile" --quiet; then
        _brew_success "模块 $module 已完全同步"
        return 0
    else
        _brew_warning "模块 $module 需要同步"
        echo
        
        # 显示缺失的包
        _brew_info "缺失的软件包:"
        brew bundle check --file="$brewfile" 2>/dev/null | grep -E "^(brew|cask)" || echo "  无法确定具体缺失的包"
        
        echo
        read -p "是否立即安装缺失的包? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            brew-install-module "$module"
        fi
        return 1
    fi
}

# 批量安装多个模块（改进版）
brew-install-modules() {
    if [[ $# -eq 0 ]]; then
        _brew_error "用法: brew-install-modules <模块1> [模块2] ..."
        echo "示例: brew-install-modules essential development fonts"
        return 1
    fi
    
    if ! _validate_homebrew_dir; then
        return 1
    fi
    
    local modules=("$@")
    local homebrew_dir="$(_get_homebrew_dir)"
    
    # 过滤掉空模块
    local valid_modules=()
    local empty_modules=()
    
    for module in "${modules[@]}"; do
        local brewfile="$homebrew_dir/Brewfile.$module"
        if [[ ! -f "$brewfile" ]]; then
            _brew_error "模块文件不存在: Brewfile.$module"
            return 1
        elif _is_module_empty "$brewfile"; then
            empty_modules+=("$module")
        else
            valid_modules+=("$module")
        fi
    done
    
    if [[ ${#empty_modules[@]} -gt 0 ]]; then
        _brew_warning "跳过空模块: ${empty_modules[*]}"
    fi
    
    if [[ ${#valid_modules[@]} -eq 0 ]]; then
        _brew_warning "没有有效的模块需要安装"
        return 0
    fi
    
    _brew_header "批量安装模块: ${valid_modules[*]}"
    
    # 显示安装计划
    local total_packages=0
    for module in "${valid_modules[@]}"; do
        local brewfile="$homebrew_dir/Brewfile.$module"
        local stats=($(_get_module_stats "$brewfile"))
        local count=$((${stats[1]} + ${stats[2]}))  # brew + cask
        total_packages=$((total_packages + count))
    done
    
    _brew_info "总计: ${#valid_modules[@]} 个模块，约 $total_packages 个软件包"
    _brew_info "预计时间: $((total_packages * 2)) 分钟"
    
    # 执行安装
    local failed_modules=()
    local start_time=$(date +%s)
    
    for i in "${!valid_modules[@]}"; do
        local module="${valid_modules[$i]}"
        _brew_info "进度: $((i+1))/${#valid_modules[@]} - $module"
        
        if ! brew-install-module "$module"; then
            failed_modules+=("$module")
            
            # 询问是否继续
            if [[ $((${#valid_modules[@]} - i - 1)) -gt 0 ]]; then
                echo
                read -p "模块 $module 安装失败，是否继续安装其余模块? (Y/n): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Nn]$ ]]; then
                    break
                fi
            fi
        fi
    done
    
    local end_time=$(date +%s)
    local total_duration=$((end_time - start_time))
    
    # 显示结果
    echo
    if [[ ${#failed_modules[@]} -eq 0 ]]; then
        _brew_success "所有模块安装完成！总用时: $((total_duration / 60))分钟"
    else
        _brew_warning "部分模块安装失败: ${failed_modules[*]}"
        return 1
    fi
}

# ==============================================================================
# 一键安装方案
# ==============================================================================

# 获取预定义方案的模块
_get_profile_modules() {
    local profile="$1"
    local homebrew_dir="$(_get_homebrew_dir)"
    local modules=()
    
    case "$profile" in
        "minimal")
            modules=("essential")
            ;;
        "developer")
            modules=("essential" "development" "fonts")
            ;;
        "server")
            modules=("essential" "development")
            ;;
        "full")
            # 动态获取所有非空模块
            local all_modules=($(find "$homebrew_dir" -name "Brewfile.*" -exec basename {} \; | sed 's/Brewfile\.//' | sort))
            for module in "${all_modules[@]}"; do
                if ! _is_module_empty "$homebrew_dir/Brewfile.$module"; then
                    modules+=("$module")
                fi
            done
            ;;
        *)
            _brew_error "未知方案: $profile"
            return 1
            ;;
    esac
    
    echo "${modules[@]}"
}

# 智能环境检测
brew-auto-setup() {
    if ! _validate_homebrew_dir; then
        return 1
    fi
    
    _brew_header "智能环境检测"
    
    # 检查是否为 SSH 连接
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        _brew_info "🖥️  检测到远程连接（服务器环境）"
        _brew_info "推荐安装: essential + development"
        echo
        read -p "是否使用服务器推荐配置? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            local modules=($(_get_profile_modules "server"))
            brew-install-modules "${modules[@]}"
        fi
    else
        _brew_info "💻 检测到本地环境"
        echo
        echo "请选择安装方案:"
        echo "  1) minimal   - 基础工具包 (essential)"
        echo "  2) developer - 开发环境 (essential + development + fonts)"  
        echo "  3) server    - 服务器环境 (essential + development)"
        echo "  4) full      - 完整环境 (所有非空模块)"
        echo "  5) custom    - 自定义选择模块"
        echo
        
        read -p "请选择 (1-5): " -n 1 -r choice
        echo
        
        case $choice in
            1) 
                local modules=($(_get_profile_modules "minimal"))
                brew-install-modules "${modules[@]}"
                ;;
            2) 
                local modules=($(_get_profile_modules "developer"))
                brew-install-modules "${modules[@]}"
                ;;
            3) 
                local modules=($(_get_profile_modules "server"))
                brew-install-modules "${modules[@]}"
                ;;
            4) 
                local modules=($(_get_profile_modules "full"))
                brew-install-modules "${modules[@]}"
                ;;
            5)
                brew-list-modules
                echo
                read -p "请输入要安装的模块 (空格分隔): " modules_input
                local selected_modules=(${=modules_input})  # zsh 分词
                brew-install-modules "${selected_modules[@]}"
                ;;
            *)
                _brew_warning "无效选择"
                return 1
                ;;
        esac
    fi
}

# 预定义安装方案
brew-install-minimal() {
    _brew_info "安装最小配置"
    local modules=($(_get_profile_modules "minimal"))
    brew-install-modules "${modules[@]}"
}

brew-install-developer() {
    _brew_info "安装开发者配置"
    local modules=($(_get_profile_modules "developer"))
    brew-install-modules "${modules[@]}"
}

brew-install-server() {
    _brew_info "安装服务器配置"
    local modules=($(_get_profile_modules "server"))
    brew-install-modules "${modules[@]}"
}

brew-install-full() {
    _brew_info "安装完整配置"
    local modules=($(_get_profile_modules "full"))
    brew-install-modules "${modules[@]}"
}

# ==============================================================================
# 改进的同步和维护函数
# ==============================================================================

# 智能同步 - 检测未记录的软件（改进版）
brew-sync() {
    if ! _validate_homebrew_dir; then
        return 1
    fi
    
    _brew_header "智能同步检查"
    
    local homebrew_dir="$(_get_homebrew_dir)"
    
    # 获取当前已安装的包
    _brew_info "获取当前安装的软件包..."
    local current_brews=($(brew list --formula 2>/dev/null | sort))
    local current_casks=($(brew list --cask 2>/dev/null | sort))
    
    # 获取所有 Brewfile 中记录的包
    _brew_info "分析 Brewfile 记录..."
    local recorded_brews=()
    local recorded_casks=()
    
    for brewfile in "$homebrew_dir"/Brewfile.*; do
        if [[ -f "$brewfile" ]] && ! _is_module_empty "$brewfile"; then
            # 使用更精确的解析
            local file_brews=($(grep "^brew " "$brewfile" | sed 's/^brew "\([^"]*\)".*/\1/' 2>/dev/null))
            local file_casks=($(grep "^cask " "$brewfile" | sed 's/^cask "\([^"]*\)".*/\1/' 2>/dev/null))
            
            recorded_brews+=("${file_brews[@]}")
            recorded_casks+=("${file_casks[@]}")
        fi
    done
    
    # 去重排序
    recorded_brews=($(printf '%s\n' "${recorded_brews[@]}" | sort -u))
    recorded_casks=($(printf '%s\n' "${recorded_casks[@]}" | sort -u))
    
    # 找出未记录的包
    local missing_brews=($(comm -23 <(printf '%s\n' "${current_brews[@]}") <(printf '%s\n' "${recorded_brews[@]}")))
    local missing_casks=($(comm -23 <(printf '%s\n' "${current_casks[@]}") <(printf '%s\n' "${recorded_casks[@]}")))
    
    if [[ ${#missing_brews[@]} -eq 0 ]] && [[ ${#missing_casks[@]} -eq 0 ]]; then
        _brew_success "环境已完全同步，没有未记录的软件包"
        return 0
    fi
    
    _brew_warning "发现 $((${#missing_brews[@]} + ${#missing_casks[@]})) 个未记录的软件包:"
    
    if [[ ${#missing_brews[@]} -gt 0 ]]; then
        echo -e "\n${BREW_YELLOW}CLI 工具 (${#missing_brews[@]} 个):${BREW_NC}"
        printf '  brew "%s"\n' "${missing_brews[@]}"
    fi
    
    if [[ ${#missing_casks[@]} -gt 0 ]]; then
        echo -e "\n${BREW_YELLOW}GUI 应用 (${#missing_casks[@]} 个):${BREW_NC}"
        printf '  cask "%s"\n' "${missing_casks[@]}"
    fi
    
    echo
    echo "请选择处理方式:"
    echo "  1) 添加到 Brewfile.optional"
    echo "  2) 生成添加命令（手动处理）"
    echo "  3) 忽略"
    
    read -p "请选择 (1-3): " -n 1 -r choice
    echo
    
    case $choice in
        1)
            local optional_file="$homebrew_dir/Brewfile.optional"
            
            # 确保文件存在且有基本结构
            if ! grep -q "^# Optional Tools" "$optional_file" 2>/dev/null; then
                cat > "$optional_file" << EOF
# ==============================================================================
# Optional Tools - 可选工具模块
# 包含：特定场景工具、娱乐工具、专业工具等
# 目标：根据个人需求和兴趣按需安装
# ==============================================================================

EOF
            fi
            
            echo "" >> "$optional_file"
            echo "# 自动同步添加 - $(date '+%Y-%m-%d %H:%M:%S')" >> "$optional_file"
            
            for pkg in "${missing_brews[@]}"; do
                echo "brew \"$pkg\"" >> "$optional_file"
            done
            
            for pkg in "${missing_casks[@]}"; do
                echo "cask \"$pkg\"" >> "$optional_file"
            done
            
            _brew_success "已将 $((${#missing_brews[@]} + ${#missing_casks[@]})) 个未记录的包添加到 Brewfile.optional"
            ;;
        2)
            echo -e "\n${BREW_CYAN}手动添加命令:${BREW_NC}"
            if [[ ${#missing_brews[@]} -gt 0 ]]; then
                echo "# CLI 工具:"
                for pkg in "${missing_brews[@]}"; do
                    echo "echo 'brew \"$pkg\"' >> $homebrew_dir/Brewfile.optional"
                done
            fi
            if [[ ${#missing_casks[@]} -gt 0 ]]; then
                echo "# GUI 应用:"
                for pkg in "${missing_casks[@]}"; do
                    echo "echo 'cask \"$pkg\"' >> $homebrew_dir/Brewfile.optional"
                done
            fi
            ;;
        3)
            _brew_info "已忽略未记录的软件包"
            ;;
        *)
            _brew_warning "无效选择"
            return 1
            ;;
    esac
}

# 全面健康检查（改进版）
brew-health-check() {
    if ! _validate_homebrew_dir; then
        return 1
    fi
    
    _brew_header "Homebrew 健康检查"
    
    # 1. 检查 Homebrew 本身
    _brew_info "检查 Homebrew 状态..."
    if ! brew doctor; then
        _brew_warning "Homebrew 检查发现问题，但可以继续"
    fi
    echo
    
    # 2. 检查各模块状态
    _brew_info "检查模块同步状态..."
    local homebrew_dir="$(_get_homebrew_dir)"
    local all_synced=true
    local total_modules=0
    local synced_modules=0
    
    for brewfile in "$homebrew_dir"/Brewfile.*; do
        if [[ -f "$brewfile" ]]; then
            local module=$(basename "$brewfile" | sed 's/Brewfile\.//')
            total_modules=$((total_modules + 1))
            
            if _is_module_empty "$brewfile"; then
                _brew_info "模块 $module: 空模块，跳过"
                synced_modules=$((synced_modules + 1))
            elif brew bundle check --file="$brewfile" --quiet 2>/dev/null; then
                _brew_success "模块 $module: 已同步"
                synced_modules=$((synced_modules + 1))
            else
                _brew_warning "模块 $module: 需要同步"
                all_synced=false
            fi
        fi
    done
    
    # 3. 显示统计信息
    echo
    _brew_info "系统统计信息:"
    local cli_count=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    local gui_count=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
    local cache_size=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "未知")
    local install_size=$(du -sh "$(brew --prefix)" 2>/dev/null | cut -f1 || echo "未知")
    
    echo "  已安装 CLI 工具: $cli_count"
    echo "  已安装 GUI 应用: $gui_count"
    echo "  模块同步状态: $synced_modules/$total_modules"
    echo "  缓存大小: $cache_size"
    echo "  安装大小: $install_size"
    
    # 4. 总体状态
    echo
    if [[ "$all_synced" == true ]]; then
        _brew_success "所有模块状态正常"
    else
        _brew_warning "部分模块需要同步，运行 'brew-sync' 检查详情"
    fi
    
    # 5. 维护建议
    local last_update=$(brew --repository)/.git/FETCH_HEAD
    if [[ -f "$last_update" ]]; then
        local days_since_update=$(( ($(date +%s) - $(date -r "$last_update" +%s)) / 86400 ))
        if [[ $days_since_update -gt 7 ]]; then
            _brew_warning "Homebrew 已 $days_since_update 天未更新，建议运行 'brew update'"
        fi
    fi
}

# 每周维护（改进版）
brew-weekly-maintenance() {
    if ! _validate_homebrew_dir; then
        return 1
    fi
    
    _brew_header "每周 Homebrew 维护"
    
    echo "开始维护任务..."
    echo
    
    local start_time=$(date +%s)
    local tasks_completed=0
    local total_tasks=5
    
    # 1. 更新 Homebrew
    _brew_info "[$((++tasks_completed))/$total_tasks] 更新 Homebrew..."
    if brew update; then
        _brew_success "Homebrew 更新完成"
    else
        _brew_warning "Homebrew 更新遇到问题，但继续执行其他任务"
    fi
    
    # 2. 升级软件包
    _brew_info "[$((++tasks_completed))/$total_tasks] 升级软件包..."
    local outdated_count=$(brew outdated | wc -l | tr -d ' ')
    if [[ $outdated_count -gt 0 ]]; then
        _brew_info "发现 $outdated_count 个可升级的软件包"
        echo
        read -p "是否升级所有软件包? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            if brew upgrade; then
                _brew_success "软件包升级完成"
            else
                _brew_warning "部分软件包升级失败"
            fi
        else
            _brew_info "跳过软件包升级"
        fi
    else
        _brew_success "所有软件包都是最新版本"
    fi
    
    # 3. 智能同步检查
    _brew_info "[$((++tasks_completed))/$total_tasks] 检查未记录软件..."
    brew-sync
    
    # 4. 清理缓存
    _brew_info "[$((++tasks_completed))/$total_tasks] 清理缓存..."
    local cache_before=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "未知")
    if brew cleanup; then
        local cache_after=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "未知")
        _brew_success "缓存清理完成 ($cache_before → $cache_after)"
    else
        _brew_warning "缓存清理遇到问题"
    fi
    
    # 5. 健康检查
    _brew_info "[$((++tasks_completed))/$total_tasks] 最终健康检查..."
    brew-health-check
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo
    _brew_success "每周维护完成，总用时: $((duration / 60))分钟"
    _brew_info "建议每周运行一次此维护任务"
}

# ==============================================================================
# 实用工具函数
# ==============================================================================

# 搜索增强（改进版）
brew-search-enhanced() {
    local query="$1"
    
    if [[ -z "$query" ]]; then
        _brew_error "用法: brew-search-enhanced <关键词>"
        echo "示例: brew-search-enhanced python"
        return 1
    fi
    
    _brew_info "搜索关键词: $query"
    echo
    
    # CLI 工具搜索
    echo -e "${BREW_CYAN}CLI 工具 (Formula):${BREW_NC}"
    local formula_results=($(brew search --formula "$query" 2>/dev/null | head -10))
    if [[ ${#formula_results[@]} -gt 0 ]]; then
        printf '  %s\n' "${formula_results[@]}"
    else
        echo "  未找到相关的 CLI 工具"
    fi
    
    echo
    # GUI 应用搜索
    echo -e "${BREW_CYAN}GUI 应用 (Cask):${BREW_NC}"
    local cask_results=($(brew search --cask "$query" 2>/dev/null | head -10))
    if [[ ${#cask_results[@]} -gt 0 ]]; then
        printf '  %s\n' "${cask_results[@]}"
    else
        echo "  未找到相关的 GUI 应用"
    fi
    
    echo
    _brew_info "显示前10个结果，使用 'brew search $query' 查看完整列表"
}

# 包信息增强（改进版）
brew-info-enhanced() {
    local package="$1"
    
    if [[ -z "$package" ]]; then
        _brew_error "用法: brew-info-enhanced <包名>"
        echo "示例: brew-info-enhanced python"
        return 1
    fi
    
    _brew_info "查询软件包: $package"
    echo
    
    # 尝试作为 formula 查询
    if brew info --formula "$package" >/dev/null 2>&1; then
        _brew_success "找到 CLI 工具: $package"
        brew info --formula "$package"
        return 0
    fi
    
    # 尝试作为 cask 查询
    if brew info --cask "$package" >/dev/null 2>&1; then
        _brew_success "找到 GUI 应用: $package"
        brew info --cask "$package"
        return 0
    fi
    
    # 都没找到，提供搜索建议
    _brew_warning "未找到软件包: $package"
    _brew_info "为您搜索相关结果..."
    brew-search-enhanced "$package"
}

# 模块内容预览
brew-preview-module() {
    local module="$1"
    
    if [[ -z "$module" ]]; then
        _brew_error "用法: brew-preview-module <模块名>"
        echo "示例: brew-preview-module essential"
        return 1
    fi
    
    if ! _validate_homebrew_dir; then
        return 1
    fi
    
    local homebrew_dir="$(_get_homebrew_dir)"
    local brewfile="$homebrew_dir/Brewfile.$module"
    
    if [[ ! -f "$brewfile" ]]; then
        _brew_error "模块文件不存在: Brewfile.$module"
        return 1
    fi
    
    _brew_header "模块预览: $module"
    
    if _is_module_empty "$brewfile"; then
        _brew_warning "模块为空"
        return 0
    fi
    
    # 显示统计信息
    local stats=($(_get_module_stats "$brewfile"))
    local brew_count=${stats[1]}
    local cask_count=${stats[2]}
    local tap_count=${stats[3]}
    local file_count=${stats[4]}
    
    echo "📊 统计信息:"
    echo "  CLI 工具: $brew_count 个"
    echo "  GUI 应用: $cask_count 个"
    echo "  软件仓库: $tap_count 个"
    echo "  子模块: $file_count 个"
    echo
    
    # 显示内容预览
    if [[ $tap_count -gt 0 ]]; then
        echo -e "${BREW_YELLOW}软件仓库:${BREW_NC}"
        grep "^tap " "$brewfile" | sed 's/^tap "/  /' | sed 's/".*$//'
        echo
    fi
    
    if [[ $brew_count -gt 0 ]]; then
        echo -e "${BREW_CYAN}CLI 工具:${BREW_NC}"
        grep "^brew " "$brewfile" | sed 's/^brew "/  /' | sed 's/".*$//' | head -10
        if [[ $brew_count -gt 10 ]]; then
            echo "  ... 还有 $((brew_count - 10)) 个"
        fi
        echo
    fi
    
    if [[ $cask_count -gt 0 ]]; then
        echo -e "${BREW_PURPLE}GUI 应用:${BREW_NC}"
        grep "^cask " "$brewfile" | sed 's/^cask "/  /' | sed 's/".*$//' | head -10
        if [[ $cask_count -gt 10 ]]; then
            echo "  ... 还有 $((cask_count - 10)) 个"
        fi
        echo
    fi
    
    if [[ $file_count -gt 0 ]]; then
        echo -e "${BREW_GREEN}子模块:${BREW_NC}"
        grep "^file " "$brewfile" | sed 's/^file "/  /' | sed 's/".*$//'
        echo
    fi
    
    _brew_info "使用 'brew-install-module $module' 安装此模块"
}

# ==============================================================================
# 便捷别名
# ==============================================================================

# 模块管理
alias blm='brew-list-modules'
alias bim='brew-install-module'
alias bcm='brew-check-module'
alias bims='brew-install-modules'
alias bpm='brew-preview-module'

# 一键安装
alias bas='brew-auto-setup'
alias bmin='brew-install-minimal'
alias bdev='brew-install-developer'
alias bsrv='brew-install-server'
alias bfull='brew-install-full'

# 维护工具
alias bsy='brew-sync'
alias bhc='brew-health-check'
alias bwm='brew-weekly-maintenance'

# 搜索工具
alias bse='brew-search-enhanced'
alias bie='brew-info-enhanced'

# ==============================================================================
# 初始化和环境检查
# ==============================================================================

# 静默环境检查（仅返回状态，不输出）
_brew_env_check() {
    # 检查 Homebrew 是否安装
    if ! command -v brew &> /dev/null; then
        return 1
    fi
    
    # 检查模块目录
    if ! _validate_homebrew_dir >/dev/null 2>&1; then
        return 2
    fi
    
    return 0
}

# 显式初始化函数（用户手动调用）
brew-init() {
    _brew_header "Homebrew 环境检查"
    
    # 检查 Homebrew 是否安装
    if ! command -v brew &> /dev/null; then
        _brew_warning "Homebrew 未安装"
        _brew_info "安装命令: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
    
    # 检查模块目录
    local homebrew_dir="$(_get_homebrew_dir)"
    if [[ ! -d "$homebrew_dir" ]]; then
        _brew_warning "Homebrew 模块目录不存在: $homebrew_dir"
        _brew_info "请设置 HOMEBREW_MODULE_DIR 环境变量或确保目录存在"
        return 1
    fi
    
    # 统计可用模块
    local module_count=$(find "$homebrew_dir" -name "Brewfile.*" 2>/dev/null | wc -l | tr -d ' ')
    local brew_version=$(brew --version 2>/dev/null | head -1 | sed 's/Homebrew //')
    
    _brew_success "Homebrew 环境正常"
    _brew_info "版本: $brew_version"
    _brew_info "模块目录: $homebrew_dir"
    _brew_info "可用模块: $module_count 个"
    
    return 0
}

# 首次使用时自动检查（仅在出错时提示）
_brew_ensure_env() {
    # 只在第一次调用时检查，使用全局变量缓存结果
    if [[ -z "$_BREW_ENV_CHECKED" ]]; then
        export _BREW_ENV_CHECKED=1
        
        if ! _brew_env_check; then
            local exit_code=$?
            case $exit_code in
                1)
                    _brew_warning "Homebrew 未安装，某些功能不可用"
                    _brew_info "运行 'brew-init' 查看详细信息"
                    ;;
                2)
                    _brew_warning "Homebrew 模块目录配置异常"
                    _brew_info "运行 'brew-init' 检查环境"
                    ;;
            esac
            return $exit_code
        fi
    fi
    
    return 0
}

# 在需要 Homebrew 的函数中添加自动检查
_brew_require_env() {
    if ! _brew_env_check; then
        _brew_error "环境检查失败，请运行 'brew-init' 查看详情"
        return 1
    fi
    return 0
}

# ==============================================================================
# 自动加载提示（静默）
# ==============================================================================

# 静默加载 - 只在有严重问题时警告
if ! command -v brew &> /dev/null; then
    # Homebrew 未安装，但不打扰用户
    :
elif [[ ! -d "$(_get_homebrew_dir)" ]]; then
    # 目录不存在，但不立即输出警告
    :
else
    # 环境正常，静默加载成功
    :
fi

# 添加便捷的初始化别名
alias brewi='brew-init'