#!/bin/bash
# ==============================================================================
# Homebrew 环境一键设置脚本 - 改进版
# 用途：新环境快速搭建，支持多种安装模式和交互式向导
# 版本：2.0
# 作者：dotfiles 项目
# ==============================================================================

set -e  # 遇到错误立即退出

# ==============================================================================
# 全局变量和配置
# ==============================================================================

# 动态路径检测
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="${DOTFILES_HOME:-$(dirname "$SCRIPT_DIR")}"
readonly HOMEBREW_DIR="${HOMEBREW_MODULE_DIR:-$SCRIPT_DIR}"

# 版本信息
readonly SCRIPT_VERSION="2.0"
readonly MIN_MACOS_VERSION="10.15"

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# 输出函数
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
header() { echo -e "${PURPLE}🍺 $1${NC}"; }

# 使用普通变量和函数替代关联数组
MODULE_INSTALL_DETAILS=""
MODULE_FAILED_PACKAGES=""  
MODULE_SUCCESS_PACKAGES=""
MODULE_SKIPPED_PACKAGES=""
MODULE_SKIPPED_REASONS=""

# 辅助函数：设置模块详情
set_module_detail() {
    local module="$1"
    local detail="$2"
    MODULE_INSTALL_DETAILS=$(echo "$MODULE_INSTALL_DETAILS" | sed "s/${module}:[^|]*|//g")
    MODULE_INSTALL_DETAILS="${MODULE_INSTALL_DETAILS}${module}:${detail}|"
}

# 辅助函数：获取模块详情
get_module_detail() {
    local module="$1"
    echo "$MODULE_INSTALL_DETAILS" | grep -o "${module}:[^|]*" | cut -d: -f2-
}

# 辅助函数：添加失败包
add_failed_package() {
    local module="$1"
    local packages="$2"
    if [[ -n "$packages" ]]; then
        MODULE_FAILED_PACKAGES=$(echo "$MODULE_FAILED_PACKAGES" | sed "s/${module}:[^|]*|//g")
        MODULE_FAILED_PACKAGES="${MODULE_FAILED_PACKAGES}${module}:${packages}|"
    fi
}

# 辅助函数：获取失败包列表
get_failed_packages() {
    local module="$1"
    echo "$MODULE_FAILED_PACKAGES" | grep -o "${module}:[^|]*" | cut -d: -f2- | tr ',' ' '
}

# 辅助函数：添加成功包
add_success_package() {
    local module="$1"
    local packages="$2"
    if [[ -n "$packages" ]]; then
        MODULE_SUCCESS_PACKAGES=$(echo "$MODULE_SUCCESS_PACKAGES" | sed "s/${module}:[^|]*|//g")
        MODULE_SUCCESS_PACKAGES="${MODULE_SUCCESS_PACKAGES}${module}:${packages}|"
    fi
}

# 辅助函数：获取成功包列表
get_success_packages() {
    local module="$1"
    echo "$MODULE_SUCCESS_PACKAGES" | grep -o "${module}:[^|]*" | cut -d: -f2- | tr ',' ' '
}

# 辅助函数：获取成功包数量
get_success_count() {
    local module="$1"
    local packages=$(get_success_packages "$module")
    if [[ -n "$packages" ]]; then
        echo "$packages" | wc -w | tr -d ' '
    else
        echo "0"
    fi
}

# 辅助函数：获取失败包数量
get_failed_count() {
    local module="$1"
    local packages=$(get_failed_packages "$module")
    if [[ -n "$packages" ]]; then
        echo "$packages" | wc -w | tr -d ' '
    else
        echo "0"
    fi
}

# 辅助函数：添加跳过包
add_skipped_package() {
    local module="$1"
    local packages="$2"
    if [[ -n "$packages" ]]; then
        MODULE_SKIPPED_PACKAGES=$(echo "$MODULE_SKIPPED_PACKAGES" | sed "s/${module}:[^|]*|//g")
        MODULE_SKIPPED_PACKAGES="${MODULE_SKIPPED_PACKAGES}${module}:${packages}|"
    fi
}

# 辅助函数：添加跳过原因
add_skipped_reasons() {
    local module="$1"
    local reasons="$2"
    if [[ -n "$reasons" ]]; then
        MODULE_SKIPPED_REASONS=$(echo "$MODULE_SKIPPED_REASONS" | sed "s/${module}:[^|]*|//g")
        MODULE_SKIPPED_REASONS="${MODULE_SKIPPED_REASONS}${module}:${reasons}|"
    fi
}

# 辅助函数：获取跳过包列表
get_skipped_packages() {
    local module="$1"
    echo "$MODULE_SKIPPED_PACKAGES" | grep -o "${module}:[^|]*" | cut -d: -f2- | tr ',' ' '
}

# 辅助函数：获取跳过原因
get_skipped_reasons() {
    local module="$1"
    echo "$MODULE_SKIPPED_REASONS" | grep -o "${module}:[^|]*" | cut -d: -f2- | tr ',' ' '
}

# ==============================================================================
# 改进的工具函数
# ==============================================================================

# 检查模块是否为空
is_module_empty() {
    local brewfile="$1"
    
    if [[ ! -f "$brewfile" ]]; then
        return 0  # 文件不存在视为空
    fi
    
    # 计算实际安装条目（排除注释和空行）
    local package_count=$(grep -E "^(brew|cask|tap|file)" "$brewfile" | grep -v "^#" | wc -l | tr -d ' ')
    
    [[ $package_count -eq 0 ]]
}

# 获取模块统计信息（修复数组索引）
get_module_stats() {
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

# 安全执行命令（带超时和重试）
safe_command() {
    local timeout_duration="${1:-1800}"  # 默认30分钟
    local max_retries="${2:-1}"
    shift 2
    local command=("$@")
    
    local attempt=1
    while [[ $attempt -le $max_retries ]]; do
        info "执行命令 (尝试 $attempt/$max_retries): ${command[*]}"
        
        local exit_code=0
        if command -v timeout >/dev/null 2>&1; then
            timeout "$timeout_duration" "${command[@]}"
            exit_code=$?
        else
            # macOS 没有 timeout，直接执行
            "${command[@]}"
            exit_code=$?
        fi
        
        if [[ $exit_code -eq 0 ]]; then
            return 0
        fi
        
        warning "命令执行失败 (退出码: $exit_code)"
        
        if [[ $attempt -lt $max_retries ]]; then
            warning "等待 10 秒后重试..."
            sleep 10
        fi
        
        attempt=$((attempt + 1))
    done
    
    error "命令执行失败，已重试 $max_retries 次"
    return $exit_code  # 返回真实的退出码，而不是固定的 1
}

# 获取可用模块（过滤空模块）
get_available_modules() {
    local all_modules=($(find "$HOMEBREW_DIR" -name "Brewfile.*" -exec basename {} \; | sed 's/Brewfile\.//' | sort))
    local valid_modules=()
    
    for module in "${all_modules[@]}"; do
        local brewfile="$HOMEBREW_DIR/Brewfile.$module"
        if ! is_module_empty "$brewfile"; then
            valid_modules+=("$module")
        fi
    done
    
    echo "${valid_modules[@]}"
}

# 获取所有模块（包括空模块）
get_all_modules() {
    find "$HOMEBREW_DIR" -name "Brewfile.*" -exec basename {} \; | sed 's/Brewfile\.//' | sort
}

# 验证模块有效性（修复数组索引）
validate_modules() {
    local modules=("$@")
    local invalid_modules=()
    local empty_modules=()
    local valid_modules=()
    local allow_empty_modules=false
    
    # 如果是完整安装模式，允许空模块
    if [[ "${modules[*]}" == *"fonts"* && "${modules[*]}" == *"essential"* && "${modules[*]}" == *"development"* && "${modules[*]}" == *"optional"* ]]; then
        allow_empty_modules=true
    fi
    
    for module in "${modules[@]}"; do
        local brewfile="$HOMEBREW_DIR/Brewfile.$module"
        
        if [[ ! -f "$brewfile" ]]; then
            invalid_modules+=("$module")
        elif is_module_empty "$brewfile"; then
            if [[ "$allow_empty_modules" == true ]]; then
                # 完整安装模式下，空模块也加入有效列表
                valid_modules+=("$module")
                empty_modules+=("$module")
            else
                empty_modules+=("$module")
            fi
        else
            valid_modules+=("$module")
        fi
    done
    
    if [[ ${#invalid_modules[@]} -gt 0 ]]; then
        error "以下模块不存在: ${invalid_modules[*]}"
        info "可用模块: $(get_all_modules | tr '\n' ' ')"
        return 1
    fi
    
    if [[ ${#empty_modules[@]} -gt 0 ]]; then
        if [[ "$allow_empty_modules" == true ]]; then
            info "以下模块为空但仍会处理: ${empty_modules[*]}"
        else
            warning "以下模块为空，将跳过: ${empty_modules[*]}"
            SKIPPED_MODULES+=("${empty_modules[@]}")
        fi
    fi
    
    if [[ ${#valid_modules[@]} -eq 0 ]]; then
        warning "没有有效的模块需要安装"
        return 1
    fi
    
    # 更新模块列表（包含有效模块）
    modules=("${valid_modules[@]}")
    return 0
}

# 显示模块信息（修复数组索引 - bash 从0开始）
show_module_info() {
    local module="$1"
    local brewfile="$HOMEBREW_DIR/Brewfile.$module"
    
    if is_module_empty "$brewfile"; then
        echo "  📭 空模块"
        return
    fi
    
    local stats=($(get_module_stats "$brewfile"))
    local brew_count=${stats[0]}  # bash 数组从0开始
    local cask_count=${stats[1]}
    local tap_count=${stats[2]}
    local file_count=${stats[3]}
    local file_size=$(du -h "$brewfile" 2>/dev/null | cut -f1)
    
    echo "  📦 $brew_count CLI工具, 🖥️ $cask_count GUI应用, 📁 $tap_count 仓库, 📄 $file_count 子模块, 💾 $file_size"
    
    # 显示安装时间估算
    local total_packages=$((brew_count + cask_count))
    if [[ $total_packages -gt 0 ]]; then
        local estimated_minutes=$((total_packages * 2))
        echo "  ⏱️ 预计安装时间: $estimated_minutes 分钟"
    fi
}

# 显示模块详细预览
show_module_preview() {
    local module="$1"
    local brewfile="$HOMEBREW_DIR/Brewfile.$module"
    
    echo -e "${CYAN}$module${NC}"
    show_module_info "$module"
    
    if ! is_module_empty "$brewfile"; then
        echo "    内容预览:"
        
        # 显示前3个 brew 包
        local brew_packages=($(grep "^brew " "$brewfile" | sed 's/^brew "//' | sed 's/".*//' | head -3))
        if [[ ${#brew_packages[@]} -gt 0 ]]; then
            printf '      CLI: %s\n' "${brew_packages[@]}"
        fi
        
        # 显示前3个 cask 包
        local cask_packages=($(grep "^cask " "$brewfile" | sed 's/^cask "//' | sed 's/".*//' | head -3))
        if [[ ${#cask_packages[@]} -gt 0 ]]; then
            printf '      GUI: %s\n' "${cask_packages[@]}"
        fi
        
        local total_packages=$(grep -c -E "^(brew|cask)" "$brewfile")
        if [[ $total_packages -gt 6 ]]; then
            echo "      ... 还有 $((total_packages - 6)) 个软件包"
        fi
    fi
    echo
}

# 安装单个模块（带完整错误处理）
install_module() {
    local module="$1"
    local brewfile="$HOMEBREW_DIR/Brewfile.$module"
    
    header "安装模块: $module"
    show_module_info "$module"
    
    if is_module_empty "$brewfile"; then
        warning "模块 $module 为空，跳过安装"
        SKIPPED_MODULES+=("$module")
        set_module_detail "$module" "target:0,new:0,using:0,failed:0,skipped:0,duration:0,reason:empty"
        return 0
    fi
    
    # 计算目标安装总数
    local total_packages=($(grep -E "^(brew|cask) " "$brewfile" | sed 's/^[^ ]* "//' | sed 's/".*//' | sort))
    local target_count=${#total_packages[@]}
    
    info "模块包含 $target_count 个软件包，开始安装..."
    
    # 检查磁盘空间
    local available_gb=$(df -g / | tail -1 | awk '{print $4}')
    local required_gb=$((target_count / 20 + 1))
    
    if [[ $available_gb -lt $required_gb ]]; then
        warning "磁盘空间可能不足以安装模块 $module"
        info "可用: ${available_gb}GB, 预计需要: ${required_gb}GB"
        
        read -p "是否继续安装此模块? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            SKIPPED_MODULES+=("$module")
            set_module_detail "$module" "target:$target_count,failed:$install_result,duration:$duration"
            return 0
        fi
    fi
    
    # 执行安装
    local start_time=$(date +%s)
    local install_log="/tmp/brew_install_${module}_$$.log"
    
    # 获取安装前的包列表
    local before_brews=($(brew list --formula 2>/dev/null | sort))
    local before_casks=($(brew list --cask 2>/dev/null | sort))
    
    info "开始安装模块: $module"
    
    # 执行安装并正确处理返回值
    set +e  # 临时关闭 errexit，手动处理错误
    safe_command 1800 1 brew bundle install --file="$brewfile" 2>&1 | tee "$install_log"
    local install_result=${PIPESTATUS[0]}  # 获取 safe_command 的真实退出码
    set -e  # 重新启用 errexit
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 解析安装日志，分析各种状态
    local newly_installed=()
    local already_using=()
    local failed_packages=()
    local skipped_packages=()
    local skipped_reasons=()
    
    while IFS= read -r line; do
        # 新安装的包
        if [[ "$line" =~ ^Installing[[:space:]]+([^[:space:]]+) ]]; then
            local pkg_name=$(echo "$line" | sed -n 's/Installing \([^[:space:]]*\).*/\1/p')
            if [[ -n "$pkg_name" ]]; then
                newly_installed+=("$pkg_name")
            fi
        # 已存在的包
        elif [[ "$line" == Using[[:space:]]* ]]; then
            local pkg_name=$(echo "$line" | awk '{print $2}')
            if [[ -n "$pkg_name" ]]; then
                already_using+=("$pkg_name")
            fi
        # 跳过的包及原因（简化版本）
        elif [[ "$line" == Skipping[[:space:]]* ]]; then
            local pkg_name=$(echo "$line" | awk '{print $2}')
            if [[ -n "$pkg_name" ]]; then
                skipped_packages+=("$pkg_name")
                
                # 提取跳过原因（如果有括号）
                if [[ "$line" == *"("* && "$line" == *")"* ]]; then
                    local reason=$(echo "$line" | sed -n 's/.*(\([^)]*\)).*/\1/p')
                    skipped_reasons+=("$pkg_name:$reason")
                else
                    skipped_reasons+=("$pkg_name:未知原因")
                fi
            fi
        # 安装失败的包
        elif [[ "$line" == *"Installing"*"has failed"* ]]; then
            local pkg_name=$(echo "$line" | sed -n 's/Installing \([^[:space:]]*\) has failed.*/\1/p')
            if [[ -n "$pkg_name" ]]; then
                failed_packages+=("$pkg_name")
            fi
        elif [[ "$line" == *"No available formula with the name"* ]]; then
            local pkg_name=$(echo "$line" | sed -n 's/.*with the name "\([^"]*\)".*/\1/p')
            if [[ -n "$pkg_name" ]]; then
                failed_packages+=("$pkg_name")
            fi
        fi
    done < "$install_log"
    
    # 去重数组
    if [[ ${#newly_installed[@]} -gt 0 ]]; then
        newly_installed=($(printf '%s\n' "${newly_installed[@]}" | sort -u))
    fi
    if [[ ${#already_using[@]} -gt 0 ]]; then
        already_using=($(printf '%s\n' "${already_using[@]}" | sort -u))
    fi
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        failed_packages=($(printf '%s\n' "${failed_packages[@]}" | sort -u))
    fi
    if [[ ${#skipped_packages[@]} -gt 0 ]]; then
        skipped_packages=($(printf '%s\n' "${skipped_packages[@]}" | sort -u))
    fi
    
    local new_count=${#newly_installed[@]}
    local using_count=${#already_using[@]}
    local failed_count=${#failed_packages[@]}
    local skip_count=${#skipped_packages[@]}
    
    # 记录详细统计信息
    if [[ ${#newly_installed[@]} -gt 0 ]]; then
        add_success_package "$module" "${newly_installed[*]}"
    fi
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        add_failed_package "$module" "${failed_packages[*]}"
    fi
    if [[ ${#skipped_packages[@]} -gt 0 ]]; then
        add_skipped_package "$module" "${skipped_packages[*]}"
        add_skipped_reasons "$module" "${skipped_reasons[*]}"
    fi
    
    # 设置模块详细信息（扩展格式）
    set_module_detail "$module" "target:$target_count,new:$new_count,using:$using_count,failed:$failed_count,skipped:$skip_count,duration:$duration"
    
    # 判断安装结果并显示详细信息
    if [[ $install_result -eq 0 ]]; then
        local status_msg="$new_count 个新安装, $using_count 个已安装"
        if [[ $skip_count -gt 0 ]]; then
            status_msg="$status_msg, $skip_count 个跳过"
        fi
        if [[ $failed_count -gt 0 ]]; then
            status_msg="$status_msg, $failed_count 个失败"
        fi
        
        if [[ $failed_count -eq 0 ]]; then
            success "模块 $module 安装完成 ($status_msg, 共 $target_count 个, 用时: $((duration / 60))分钟)"
            INSTALLED_MODULES+=("$module")
        else
            warning "模块 $module 部分安装完成 ($status_msg, 共 $target_count 个, 用时: $((duration / 60))分钟)"
            if [[ ${#failed_packages[@]} -gt 0 ]]; then
                info "失败的包: ${failed_packages[*]}"
            fi
            INSTALLED_MODULES+=("$module")  # 部分成功也算安装了
        fi
        
        # 显示详细列表
        if [[ $new_count -gt 0 && $new_count -le 10 ]]; then
            info "新安装: ${newly_installed[*]}"
        elif [[ $new_count -gt 10 ]]; then
            info "新安装: ${newly_installed[@]:0:5} ... (还有 $((new_count - 5)) 个)"
        fi
        
        # 显示跳过的包及原因
        if [[ $skip_count -gt 0 ]]; then
            info "跳过的包:"
            for reason_pair in "${skipped_reasons[@]}"; do
                local pkg="${reason_pair%:*}"
                local reason="${reason_pair#*:}"
                echo "  • $pkg - $reason"
            done
        fi
        
        # 清理日志文件（如果完全成功）
        if [[ $failed_count -eq 0 ]]; then
            rm -f "$install_log"
        fi
        return 0
    else
        error "模块 $module 安装失败 (退出码: $install_result, 用时: $((duration / 60))分钟)"
        FAILED_MODULES+=("$module")
        set_module_detail "$module" "target:$target_count,failed:$install_result,duration:$duration"
        
        # 显示故障排除信息
        echo
        error "安装失败详情 (查看日志: $install_log):"
        tail -10 "$install_log" 2>/dev/null || echo "无法读取日志文件"
        
        return 1
    fi
}

# 模块安装优先级排序（使用 case 语句替代关联数组）
get_module_priority() {
    local module="$1"
    case "$module" in
        "fonts") echo "1" ;;
        "essential") echo "2" ;;
        "development") echo "3" ;;
        "optional") echo "4" ;;
        *) echo "99" ;;
    esac
}

# 模块安装优先级排序
sort_modules_by_priority() {
    local input_modules=("$@")
    local sorted_modules=()
    
    # 创建带优先级的临时数组
    local modules_with_priority=()
    for module in "${input_modules[@]}"; do
        local priority=$(get_module_priority "$module")
        modules_with_priority+=("$priority:$module")
    done
    
    # 排序并提取模块名
    IFS=$'\n' sorted_with_priority=($(printf '%s\n' "${modules_with_priority[@]}" | sort -n))
    unset IFS
    
    for item in "${sorted_with_priority[@]}"; do
        sorted_modules+=("${item#*:}")  # 提取冒号后的模块名
    done
    
    echo "${sorted_modules[@]}"
}

# 修改获取预定义方案的模块函数
get_profile_modules() {
    local profile="$1"
    local modules=()
    
    case "$profile" in
        "minimal")
            modules=("essential")
            ;;
        "developer")
            modules=("essential" "development")
            # 只有当 fonts 模块非空时才添加
            if ! is_module_empty "$HOMEBREW_DIR/Brewfile.fonts"; then
                modules=("fonts" "${modules[@]}")  # fonts 放在前面
            fi
            ;;
        "server")
            modules=("essential" "development")
            ;;
        "full")
            # 🔧 关键修改：获取所有模块并按优先级排序，包括空模块
            local all_modules=($(get_all_modules))
            modules=($(sort_modules_by_priority "${all_modules[@]}"))
            ;;
        *)
            error "未知方案: $profile"
            return 1
            ;;
    esac
    
    echo "${modules[@]}"
}

# 修改批量安装模块函数，确保按优先级顺序安装
install_modules() {
    local requested_modules=("$@")
    
    # 验证模块
    local valid_modules=()
    for module in "${requested_modules[@]}"; do
        local brewfile="$HOMEBREW_DIR/Brewfile.$module"
        if [[ ! -f "$brewfile" ]]; then
            error "模块文件不存在: Brewfile.$module"
            return 1
        elif ! is_module_empty "$brewfile"; then
            valid_modules+=("$module")
        else
            SKIPPED_MODULES+=("$module")
        fi
    done
    
    if [[ ${#valid_modules[@]} -eq 0 ]]; then
        warning "没有有效的模块需要安装"
        return 0
    fi
    
    # 按优先级排序模块
    local sorted_modules=($(sort_modules_by_priority "${valid_modules[@]}"))
    
    # 显示安装计划
    header "安装计划"
    info "将按以下顺序安装模块:"
    
    local total_packages=0
    
    for i in "${!sorted_modules[@]}"; do
        local module="${sorted_modules[$i]}"
        local brewfile="$HOMEBREW_DIR/Brewfile.$module"
        local stats=($(get_module_stats "$brewfile"))
        local count=$((${stats[0]} + ${stats[1]}))
        total_packages=$((total_packages + count))
        
        echo -e "  $((i+1)). ${CYAN}$module${NC}"
        show_module_info "$module"
    done
    
    if [[ ${#SKIPPED_MODULES[@]} -gt 0 ]]; then
        warning "跳过的空模块: ${SKIPPED_MODULES[*]}"
    fi
    
    echo
    info "总计: ${#sorted_modules[@]} 个模块，约 $total_packages 个软件包"
    info "安装顺序: fonts → essential → development → optional"
    
    # 最终确认
    echo
    read -p "是否继续安装? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        info "安装已取消"
        return 0
    fi
    
    # 执行安装（使用排序后的模块列表）
    local start_time=$(date +%s)
    
    for i in "${!sorted_modules[@]}"; do
        local module="${sorted_modules[$i]}"
        local progress="$((i+1))/${#sorted_modules[@]}"
        
        info "安装进度: $progress - $module"
        
        if ! install_module "$module"; then
            # 询问是否继续
            if [[ $((${#sorted_modules[@]} - i - 1)) -gt 0 ]]; then
                echo
                warning "模块 $module 安装失败"
                read -p "是否继续安装其余 $((${#sorted_modules[@]} - i - 1)) 个模块? (Y/n): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Nn]$ ]]; then
                    warning "用户选择中止安装"
                    break
                fi
            fi
        fi
    done
    
    local end_time=$(date +%s)
    local total_duration=$((end_time - start_time))
    
    # 显示详细的安装结果统计
    show_detailed_install_summary "$total_duration"
    
    if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
        return 1
    fi
    
    return 0
}

# ==============================================================================
# 改进的交互式向导（避免递归）
# ==============================================================================

# 显示所有模块详情
show_all_modules() {
    header "可用模块详情"
    echo
    
    local available_modules=($(get_available_modules))
    
    if [[ ${#available_modules[@]} -eq 0 ]]; then
        warning "没有找到可用的模块"
        return 1
    fi
    
    for module in "${available_modules[@]}"; do
        show_module_preview "$module"
    done
    
    info "总计: ${#available_modules[@]} 个可用模块"
}

# 交互式模块选择
interactive_module_selection() {
    local available_modules=($(get_available_modules))
    
    if [[ ${#available_modules[@]} -eq 0 ]]; then
        error "没有可用的模块"
        return 1
    fi
    
    echo "可用模块:"
    for i in "${!available_modules[@]}"; do
        local module="${available_modules[$i]}"
        echo -e "  $((i+1))) ${CYAN}$module${NC}"
        show_module_info "$module"
    done
    
    echo
    info "请输入要安装的模块编号 (空格分隔，如: 1 2 3):"
    read -p "选择: " -a selected_indices
    
    local selected_modules=()
    for index in "${selected_indices[@]}"; do
        # 验证输入是否为数字
        if [[ "$index" =~ ^[0-9]+$ ]] && [[ $index -ge 1 ]] && [[ $index -le ${#available_modules[@]} ]]; then
            selected_modules+=("${available_modules[$((index-1))]}")
        else
            warning "无效选择: $index (忽略)"
        fi
    done
    
    if [[ ${#selected_modules[@]} -eq 0 ]]; then
        warning "未选择有效模块"
        return 1
    fi
    
    info "已选择模块: ${selected_modules[*]}"
    install_modules "${selected_modules[@]}"
}

# 改进的交互式安装向导（无递归）
interactive_setup() {
    header "Homebrew 安装向导"
    echo
    
    # 环境检测
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        info "🖥️  检测到远程连接（服务器环境）"
        echo
        echo "服务器环境推荐方案:"
        echo "  server - essential + development"
        echo
        read -p "是否使用服务器推荐配置? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            local modules=($(get_profile_modules "server"))
            install_modules "${modules[@]}"
            return
        fi
    else
        info "💻 检测到本地环境"
    fi
    
    # 主菜单循环（避免递归）
    while true; do
        echo
        echo "请选择安装方案:"
        echo "  1) minimal   - 基础工具包"
        echo "  2) developer - 开发环境"
        echo "  3) server    - 服务器环境"
        echo "  4) full      - 完整环境"
        echo "  5) custom    - 自定义选择模块"
        echo "  6) preview   - 查看详细模块信息"
        echo "  7) quit      - 退出向导"
        echo
        
        read -p "请选择 (1-7): " -n 1 -r choice
        echo
        
        case $choice in
            1)
                local modules=($(get_profile_modules "minimal"))
                install_modules "${modules[@]}"
                break
                ;;
            2)
                local modules=($(get_profile_modules "developer"))
                install_modules "${modules[@]}"
                break
                ;;
            3)
                local modules=($(get_profile_modules "server"))
                install_modules "${modules[@]}"
                break
                ;;
            4)
                local modules=($(get_profile_modules "full"))
                install_modules "${modules[@]}"
                break
                ;;
            5)
                interactive_module_selection
                break
                ;;
            6)
                show_all_modules
                # 继续循环，不退出
                ;;
            7)
                info "退出安装向导"
                return 0
                ;;
            *)
                warning "无效选择 '$choice'，请重新选择"
                # 继续循环
                ;;
        esac
    done
}

# ==============================================================================
# 清理和后处理
# ==============================================================================

# 清理安装环境
cleanup_environment() {
    info "清理安装缓存和临时文件..."
    
    # 清理 Homebrew 缓存
    local cache_before=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "未知")
    
    if brew cleanup 2>/dev/null; then
        local cache_after=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "未知")
        success "Homebrew 缓存清理完成 ($cache_before → $cache_after)"
    else
        warning "缓存清理过程中出现警告，但不影响使用"
    fi
    
    # 清理临时文件
    local temp_files=($(find /tmp -name "brew_install_*_$.log" 2>/dev/null))
    if [[ ${#temp_files[@]} -gt 0 ]]; then
        rm -f "${temp_files[@]}"
        info "清理了 ${#temp_files[@]} 个临时日志文件"
    fi
    
    # 清理状态文件
    local status_files=($(find /tmp -name "homebrew_install_$.status" 2>/dev/null))
    if [[ ${#status_files[@]} -gt 0 ]]; then
        rm -f "${status_files[@]}"
        info "清理了 ${#status_files[@]} 个状态文件"
    fi
}

# 显示完成信息（改进版）
show_completion_info() {
    header "🎉 Homebrew 环境设置完成！"
    echo
    
    # 安装统计
    local cli_count=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    local gui_count=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
    local cache_size=$(du -sh "$(brew --cache)" 2>/dev/null | cut -f1 || echo "未知")
    
    info "安装统计:"
    echo "  CLI 工具: $cli_count 个"
    echo "  GUI 应用: $gui_count 个"
    echo "  缓存大小: $cache_size"
    
    if [[ ${#INSTALLED_MODULES[@]} -gt 0 ]]; then
        echo "  安装的模块: ${INSTALLED_MODULES[*]}"
    fi
    
    echo
    info "环境配置:"
    echo "  Homebrew 路径: $(brew --prefix)"
    echo "  配置文件: ~/.zshrc 或 ~/.bash_profile"
    
    echo
    info "后续步骤:"
    echo "  1. 重启终端或运行: source ~/.zshrc"
    echo "  2. 验证安装: brew doctor"
    echo "  3. 查看已安装软件: brew list"
    
    # 更新管理函数相关说明
    if [[ -f "$HOMEBREW_DIR/brew-functions.zsh" ]]; then
        echo "  4. 加载管理函数: source $HOMEBREW_DIR/brew-functions.zsh"
        echo "  5. 检查环境状态: brew-init (或 brewi)"
        echo "  6. 查看可用模块: brew-list-modules"
        echo "  7. 定期维护: brew-weekly-maintenance"
    else
        echo "  4. 定期维护: brew update && brew upgrade && brew cleanup"
    fi
    
    echo
    info "管理函数快速指南:"
    if [[ -f "$HOMEBREW_DIR/brew-functions.zsh" ]]; then
        echo "  brew-init               # 检查 Homebrew 环境状态"
        echo "  brew-list-modules       # 查看所有可用模块"
        echo "  brew-install-module     # 安装特定模块"
        echo "  brew-sync              # 同步检查未记录软件"
        echo "  brew-health-check      # 健康检查"
        echo "  brew-weekly-maintenance # 每周维护"
    else
        echo "  brew search <软件名>     # 搜索软件"
        echo "  brew info <软件名>       # 查看软件信息"
        echo "  brew install <软件名>    # 安装软件"
        echo "  brew uninstall <软件名>  # 卸载软件"
    fi
    
    echo
    info "常用 Homebrew 命令:"
    echo "  brew search <软件名>     # 搜索软件"
    echo "  brew info <软件名>       # 查看软件信息"
    echo "  brew install <软件名>    # 安装软件"
    echo "  brew uninstall <软件名>  # 卸载软件"
    echo "  brew list               # 列出已安装软件"
    echo "  brew outdated           # 查看可更新软件"
    echo "  brew upgrade            # 更新所有软件"
    
    # 显示可能的问题和解决方案
    echo
    info "如果遇到问题:"
    echo "  1. 环境检查: brew-init (如果已加载管理函数)"
    echo "  2. Homebrew 诊断: brew doctor"
    echo "  3. 权限问题: sudo chown -R \$(whoami) \$(brew --prefix)"
    echo "  4. 路径问题: echo 'export PATH=\"\$(brew --prefix)/bin:\$PATH\"' >> ~/.zshrc"
    echo "  5. 网络问题: 检查防火墙和代理设置"
    
    echo
    info "文档和帮助:"
    echo "  Homebrew 官方文档: https://docs.brew.sh/"
    echo "  脚本帮助: $0 --help"
    if [[ -f "$HOMEBREW_DIR/README.md" ]]; then
        echo "  项目文档: $HOMEBREW_DIR/README.md"
    fi
}

# ==============================================================================
# 帮助和使用说明
# ==============================================================================

show_help() {
    cat << EOF
🍺 Homebrew 环境设置脚本 v${SCRIPT_VERSION}

用法:
  $0 [选项] [模块...]

选项:
  -h, --help              显示此帮助信息
  -i, --interactive       启动交互式安装向导 (推荐)
  -p, --profile <名称>    使用预定义安装方案
  -l, --list              列出可用模块和方案
  -u, --update-only       仅更新 Homebrew，不安装软件
  -y, --yes               对所有询问自动回答 yes
  --no-cleanup            跳过安装后清理步骤
  --dry-run               显示将要执行的操作，但不实际安装
  --version               显示脚本版本

模块:
  essential               基础必备工具
  development             开发环境工具
  fonts                   编程字体
  optional                可选工具 (如果非空)

预定义方案:
  minimal                 仅基础工具 (essential)
  developer               开发环境 (essential + development + fonts*)
  server                  服务器环境 (essential + development)
  full                    完整环境 (所有非空模块)

示例:
  $0 --interactive                    # 交互式安装 (推荐新用户)
  $0 --profile developer              # 使用开发者方案
  $0 essential development fonts      # 安装指定模块
  $0 --list                          # 查看所有选项
  $0 --update-only                   # 仅更新 Homebrew
  $0 --dry-run --profile full        # 预览完整安装

安装后使用:
  source /path/to/brew-functions.zsh  # 加载管理函数
  brew-init                          # 检查环境状态
  brew-list-modules                  # 查看可用模块

环境变量:
  HOMEBREW_MODULE_DIR                 # 自定义模块目录
  DOTFILES_HOME                      # 自定义 dotfiles 目录

注意:
  * fonts 模块只有在非空时才会被包含在 developer 方案中
  
更多信息:
  项目主页: https://github.com/your-username/dotfiles
  Homebrew 文档: https://docs.brew.sh/

EOF
}

# 显示版本信息
show_version() {
    echo "Homebrew 环境设置脚本 v${SCRIPT_VERSION}"
    echo "支持的 macOS 版本: $MIN_MACOS_VERSION+"
    echo "作者: dotfiles 项目"
}

# 列出可用选项
show_list() {
    header "可用模块"
    echo
    
    local available_modules=($(get_available_modules))
    if [[ ${#available_modules[@]} -eq 0 ]]; then
        warning "没有找到可用的模块"
        return 1
    fi
    
    for module in "${available_modules[@]}"; do
        show_module_preview "$module"
    done
    
    echo
    header "预定义方案"
    echo
    
    local profiles=("minimal" "developer" "server" "full")
    for profile in "${profiles[@]}"; do
        echo -e "${CYAN}$profile${NC}:"
        local modules=($(get_profile_modules "$profile"))
        echo "  模块: ${modules[*]}"
        
        local total_packages=0
        for module in "${modules[@]}"; do
            local brewfile="$HOMEBREW_DIR/Brewfile.$module"
            if [[ -f "$brewfile" ]] && ! is_module_empty "$brewfile"; then
                local stats=($(get_module_stats "$brewfile"))
                total_packages=$((total_packages + ${stats[0]} + ${stats[1]}))
            fi
        done
        echo "  预计软件包数: $total_packages"
        echo
    done
}

# ==============================================================================
# 系统检查函数
# ==============================================================================

# 版本比较函数
version_compare() {
    local version1="$1"
    local version2="$2"
    
    # 将版本号转换为数字进行比较
    local v1_major=$(echo "$version1" | cut -d. -f1)
    local v1_minor=$(echo "$version1" | cut -d. -f2)
    local v2_major=$(echo "$version2" | cut -d. -f1)
    local v2_minor=$(echo "$version2" | cut -d. -f2)
    
    if [[ $v1_major -lt $v2_major ]]; then
        return 1
    elif [[ $v1_major -eq $v2_major ]] && [[ $v1_minor -lt $v2_minor ]]; then
        return 1
    else
        return 0
    fi
}

# 检查操作系统
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        error "此脚本仅支持 macOS 系统"
        exit 1
    fi
    
    local macos_version=$(sw_vers -productVersion)
    local macos_name=$(sw_vers -productName)
    info "$macos_name $macos_version"
    
    # 检查最低版本要求
    if ! version_compare "$macos_version" "$MIN_MACOS_VERSION"; then
        warning "macOS 版本过低，建议升级到 $MIN_MACOS_VERSION 或更高版本"
        read -p "是否继续安装? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    # 检查芯片架构
    local arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
        info "检测到 Apple Silicon (M系列芯片)"
        export HOMEBREW_PREFIX="/opt/homebrew"
    else
        info "检测到 Intel x86_64 芯片"
        export HOMEBREW_PREFIX="/usr/local"
    fi
    
    # 检查是否为虚拟机
    if system_profiler SPHardwareDataType | grep -q "VirtualBox\|VMware\|Parallels"; then
        warning "检测到虚拟机环境，安装可能较慢"
    fi
}

# 检查依赖工具
check_dependencies() {
    info "检查系统依赖..."
    
    local missing_deps=()
    
    # 检查必需的命令行工具
    local required_tools=("curl" "git" "xcode-select")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_deps+=("$tool")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "缺少必需的工具: ${missing_deps[*]}"
        info "请先安装这些工具后再运行此脚本"
        exit 1
    fi
    
    # 检查 Xcode Command Line Tools
    if ! xcode-select -p >/dev/null 2>&1; then
        warning "Xcode Command Line Tools 未安装"
        info "正在安装 Xcode Command Line Tools..."
        xcode-select --install
        info "请等待安装完成后重新运行此脚本"
        exit 1
    fi
    
    success "依赖检查通过"
}

# 检查网络连接
check_network() {
    info "检查网络连接..."
    
    local test_hosts=("github.com" "formulae.brew.sh" "api.github.com")
    local successful_tests=0
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 5000 "$host" >/dev/null 2>&1; then
            successful_tests=$((successful_tests + 1))
        fi
    done
    
    if [[ $successful_tests -eq 0 ]]; then
        error "无法连接到任何测试主机，请检查网络连接"
        echo "测试的主机: ${test_hosts[*]}"
        exit 1
    elif [[ $successful_tests -lt ${#test_hosts[@]} ]]; then
        warning "部分网络连接不稳定，可能影响安装速度"
        info "成功连接: $successful_tests/${#test_hosts[@]} 个主机"
        
        read -p "是否继续安装? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            exit 0
        fi
    else
        success "网络连接正常"
    fi
}

# 检查磁盘空间
check_disk_space() {
    local available_gb=$(df -g / | tail -1 | awk '{print $4}')
    local recommended_gb=10
    local minimum_gb=5
    
    info "可用磁盘空间: ${available_gb}GB"
    
    if [[ $available_gb -lt $minimum_gb ]]; then
        error "可用磁盘空间不足 ${minimum_gb}GB"
        echo "Homebrew 和软件包至少需要 ${minimum_gb}GB 空间"
        exit 1
    elif [[ $available_gb -lt $recommended_gb ]]; then
        warning "可用磁盘空间不足 ${recommended_gb}GB (推荐值)"
        echo "当前可用: ${available_gb}GB，可能影响大型软件的安装"
        
        read -p "是否继续安装? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        success "磁盘空间充足"
    fi
}

# 检查目录结构
check_directories() {
    info "检查目录结构..."
    
    if [[ ! -d "$HOMEBREW_DIR" ]]; then
        error "Homebrew 模块目录不存在: $HOMEBREW_DIR"
        info "请确保在正确的目录中运行此脚本"
        exit 1
    fi
    
    if [[ ! -f "$HOMEBREW_DIR/Brewfile.essential" ]]; then
        error "未找到必需的 Brewfile.essential"
        info "请确保所有模块文件都存在"
        exit 1
    fi
    
    success "目录检查通过"
    info "  dotfiles: $DOTFILES_DIR"
    info "  homebrew: $HOMEBREW_DIR"
}

# ==============================================================================
# Homebrew 管理函数
# ==============================================================================

# 安装 Homebrew
install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        success "Homebrew 已安装"
        local version=$(brew --version | head -1 | sed 's/Homebrew //')
        info "版本: $version"
        return 0
    fi
    
    header "安装 Homebrew"
    info "正在下载并安装 Homebrew..."
    
    # 设置非交互模式
    export NONINTERACTIVE=1
    
    # 执行安装（带重试）
    if safe_command 1800 2 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        success "Homebrew 安装成功"
    else
        error "Homebrew 安装失败"
        info "请检查网络连接或手动安装 Homebrew"
        exit 1
    fi
    
    # 配置环境变量
    local brew_paths=("/opt/homebrew/bin/brew" "/usr/local/bin/brew")
    local brew_found=false
    
    for brew_path in "${brew_paths[@]}"; do
        if [[ -x "$brew_path" ]]; then
            eval "$("$brew_path" shellenv)"
            brew_found=true
            break
        fi
    done
    
    if [[ "$brew_found" == false ]]; then
        error "Homebrew 安装后无法找到 brew 命令"
        info "请手动配置环境变量或重新启动终端"
        exit 1
    fi
    
    # 验证安装
    if ! command -v brew >/dev/null 2>&1; then
        error "Homebrew 安装验证失败"
        exit 1
    fi
    
    success "Homebrew 安装并配置完成"
}

# 更新 Homebrew
update_homebrew() {
    info "更新 Homebrew 数据库..."
    
    local update_start=$(date +%s)
    
    if safe_command 600 2 brew update; then
        local update_end=$(date +%s)
        local update_duration=$((update_end - update_start))
        success "Homebrew 更新完成 (用时: ${update_duration}秒)"
        
        # 显示更新统计
        local outdated_count=$(brew outdated | wc -l | tr -d ' ')
        if [[ $outdated_count -gt 0 ]]; then
            info "发现 $outdated_count 个可升级的软件包"
        fi
    else
        warning "Homebrew 更新失败，但继续安装"
        info "可以稍后手动运行 'brew update'"
    fi
}

# 添加详细的安装结果统计函数
show_detailed_install_summary() {
    local total_duration="$1"
    
    header "详细安装结果统计"
    
    local total_new_packages=0
    local total_existing_packages=0
    local total_failed_packages=0
    local total_skipped_packages=0
    local total_target_packages=0
    local total_modules_attempted=$((${#INSTALLED_MODULES[@]} + ${#FAILED_MODULES[@]}))
    
    # 成功安装的模块
    if [[ ${#INSTALLED_MODULES[@]} -gt 0 ]]; then
        echo
        success "成功安装 ${#INSTALLED_MODULES[@]} 个模块:"
        
        for module in "${INSTALLED_MODULES[@]}"; do
            local details=$(get_module_detail "$module")
            
            # 解析详细信息
            local target_count=$(echo "$details" | sed -n 's/.*target:\([0-9]*\).*/\1/p')
            local new_count=$(echo "$details" | sed -n 's/.*new:\([0-9]*\).*/\1/p')
            local using_count=$(echo "$details" | sed -n 's/.*using:\([0-9]*\).*/\1/p')
            local failed_count=$(echo "$details" | sed -n 's/.*failed:\([0-9]*\).*/\1/p')
            local skipped_count=$(echo "$details" | sed -n 's/.*skipped:\([0-9]*\).*/\1/p')
            local duration=$(echo "$details" | sed -n 's/.*duration:\([0-9]*\).*/\1/p')
            
            # 默认值处理
            target_count=${target_count:-0}
            new_count=${new_count:-0}
            using_count=${using_count:-0}
            failed_count=${failed_count:-0}
            skipped_count=${skipped_count:-0}
            duration=${duration:-0}
            
            # 累计统计
            total_target_packages=$((total_target_packages + target_count))
            total_new_packages=$((total_new_packages + new_count))
            total_existing_packages=$((total_existing_packages + using_count))
            total_failed_packages=$((total_failed_packages + failed_count))
            total_skipped_packages=$((total_skipped_packages + skipped_count))
            
            # 📍 关键修改：目标数量放在模块名后面，"已存在"改为"已安装"
            echo -e "  ✅ ${CYAN}$module${NC} ${PURPLE}(目标: $target_count 个)${NC}"
            echo "     新安装: $new_count 个, 已安装: $using_count 个, 跳过: $skipped_count 个, 失败: $failed_count 个, 用时: $((duration / 60))分钟"
            
            # 显示详细的软件包信息
            if [[ $new_count -gt 0 ]]; then
                local success_packages=$(get_success_packages "$module")
                if [[ -n "$success_packages" ]]; then
                    echo -e "     ${GREEN}新安装: $success_packages${NC}"
                fi
            fi
            
            # 🔧 新增：显示跳过的包
            if [[ $skipped_count -gt 0 ]]; then
                local skipped_packages=$(get_skipped_packages "$module")
                local skipped_reasons=$(get_skipped_reasons "$module")
                if [[ -n "$skipped_packages" ]]; then
                    echo -e "     ${YELLOW}跳过: $skipped_packages${NC}"
                    if [[ -n "$skipped_reasons" ]]; then
                        echo -e "     ${YELLOW}原因: $skipped_reasons${NC}"
                    fi
                fi
            fi
            
            if [[ $failed_count -gt 0 ]]; then
                local failed_packages=$(get_failed_packages "$module")
                if [[ -n "$failed_packages" ]]; then
                    echo -e "     ${RED}失败: $failed_packages${NC}"
                fi
            fi
        done
    fi
    
    # 完全失败的模块
    if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
        echo
        error "安装失败 ${#FAILED_MODULES[@]} 个模块:"
        
        for module in "${FAILED_MODULES[@]}"; do
            local details=$(get_module_detail "$module")
            local target_count=$(echo "$details" | sed -n 's/.*target:\([0-9]*\).*/\1/p')
            local exit_code=$(echo "$details" | sed -n 's/.*failed:\([0-9]*\).*/\1/p')
            local duration=$(echo "$details" | sed -n 's/.*duration:\([0-9]*\).*/\1/p')
            
            target_count=${target_count:-0}
            total_target_packages=$((total_target_packages + target_count))
            
            echo -e "  ❌ ${RED}$module${NC} ${PURPLE}(目标: $target_count 个)${NC}"
            echo "     错误码: $exit_code, 用时: $((duration / 60))分钟"
            echo "     日志: /tmp/brew_install_${module}_$$.log"
        done
    fi
    
    # 跳过的模块
    if [[ ${#SKIPPED_MODULES[@]} -gt 0 ]]; then
        echo
        warning "跳过 ${#SKIPPED_MODULES[@]} 个模块:"
        
        for module in "${SKIPPED_MODULES[@]}"; do
            local details=$(get_module_detail "$module")
            local target_count=$(echo "$details" | sed -n 's/.*target:\([0-9]*\).*/\1/p')
            local reason="${details#*:}"
            reason="${reason%%,*}"  # 取第一个字段作为原因
            
            target_count=${target_count:-0}
            total_target_packages=$((total_target_packages + target_count))
            
            case "$reason" in
                "empty")
                    echo -e "  ⏭️  ${YELLOW}$module${NC} ${PURPLE}(目标: $target_count 个)${NC} - 模块为空"
                    ;;
                "disk_space")
                    echo -e "  ⏭️  ${YELLOW}$module${NC} ${PURPLE}(目标: $target_count 个)${NC} - 磁盘空间不足"
                    ;;
                *)
                    echo -e "  ⏭️  ${YELLOW}$module${NC} ${PURPLE}(目标: $target_count 个)${NC} - $reason"
                    ;;
            esac
        done
    fi
    
    # 总体统计
    echo
    header "总体统计"
    echo "  模块统计: $total_modules_attempted 个尝试, ${#INSTALLED_MODULES[@]} 个成功, ${#FAILED_MODULES[@]} 个失败, ${#SKIPPED_MODULES[@]} 个跳过"
    echo "  软件包统计: 目标 $total_target_packages 个, 新安装 $total_new_packages 个, 已安装 $total_existing_packages 个, 失败 $total_failed_packages 个"
    echo "  总用时: $((total_duration / 60))分钟 $((total_duration % 60))秒"
    
    # 安装效率分析
    if [[ $total_modules_attempted -gt 0 ]]; then
        local success_rate=$(( (${#INSTALLED_MODULES[@]} * 100) / total_modules_attempted ))
        echo "  模块成功率: $success_rate%"
    fi
    
    if [[ $total_target_packages -gt 0 ]]; then
        local package_success_rate=$(( ((total_new_packages + total_existing_packages) * 100) / total_target_packages ))
        echo "  软件包完成率: $package_success_rate%"
    fi
}

# ==============================================================================
# 主程序逻辑
# ==============================================================================

main() {
    # 解析命令行参数
    local interactive=false
    local profile=""
    local modules=()
    local update_only=false
    local auto_yes=false
    local no_cleanup=false
    local dry_run=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            -i|--interactive)
                interactive=true
                shift
                ;;
            -p|--profile)
                if [[ -z "$2" ]]; then
                    error "选项 --profile 需要参数"
                    exit 1
                fi
                profile="$2"
                shift 2
                ;;
            -l|--list)
                show_list
                exit 0
                ;;
            -u|--update-only)
                update_only=true
                shift
                ;;
            -y|--yes)
                auto_yes=true
                export NONINTERACTIVE=1
                shift
                ;;
            --no-cleanup)
                no_cleanup=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -*)
                error "未知选项: $1"
                echo "使用 --help 查看帮助信息"
                exit 1
                ;;
            *)
                modules+=("$1")
                shift
                ;;
        esac
    done
    
    # 显示欢迎信息
    header "Homebrew 环境设置脚本 v${SCRIPT_VERSION}"
    info "初始化设置..."
    echo
    
    # 系统检查
    check_macos
    check_dependencies
    check_directories
    check_network
    check_disk_space
    echo
    
    # 安装和更新 Homebrew
    install_homebrew
    update_homebrew
    echo
    
    # 如果只是更新模式
    if [[ "$update_only" == true ]]; then
        success "Homebrew 更新完成"
        exit 0
    fi
    
    # Dry run 模式提示
    if [[ "$dry_run" == true ]]; then
        warning "Dry run 模式：仅显示操作，不实际安装"
        export DRY_RUN=true
    fi
    
    # 根据参数选择安装方式
    if [[ "$interactive" == true ]]; then
        interactive_setup
    elif [[ -n "$profile" ]]; then
        local profile_modules=($(get_profile_modules "$profile"))
        if [[ $? -eq 0 ]] && [[ ${#profile_modules[@]} -gt 0 ]]; then
            info "使用预定义方案: $profile"
            info "包含模块: ${profile_modules[*]}"
            
            if [[ "$dry_run" == true ]]; then
                info "Dry run: 将要安装的模块"
                for module in "${profile_modules[@]}"; do
                    show_module_preview "$module"
                done
            else
                install_modules "${profile_modules[@]}"
            fi
        else
            error "方案 '$profile' 无效或为空"
            info "可用方案: minimal, developer, server, full"
            exit 1
        fi
    elif [[ ${#modules[@]} -gt 0 ]]; then
        if [[ "$dry_run" == true ]]; then
            info "Dry run: 将要安装的模块"
            for module in "${modules[@]}"; do
                local brewfile="$HOMEBREW_DIR/Brewfile.$module"
                if [[ -f "$brewfile" ]]; then
                    show_module_preview "$module"
                else
                    error "模块不存在: $module"
                fi
            done
        else
            install_modules "${modules[@]}"
        fi
    else
        # 没有指定参数，根据是否自动模式决定
        if [[ "$auto_yes" == true ]]; then
            info "自动模式：启动交互式向导"
            interactive_setup
        else
            warning "未指定安装内容"
            echo
            echo "可用选项:"
            echo "  --interactive          启动交互式向导"
            echo "  --profile <方案名>     使用预定义方案"
            echo "  --list                 查看所有选项"
            echo "  --help                 显示帮助信息"
            echo
            read -p "是否启动交互式向导? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                interactive_setup
            else
                info "使用 --help 查看完整使用说明"
                exit 0
            fi
        fi
    fi
    
    # 后处理
    if [[ "$dry_run" != true ]]; then
        echo
        
        # 清理环境
        if [[ "$no_cleanup" != true ]]; then
            cleanup_environment
            echo
        fi
        
        # 显示完成信息
        show_completion_info
        
        # 最终健康检查
        echo
        info "执行最终检查..."
        if command -v brew >/dev/null 2>&1 && brew doctor >/dev/null 2>&1; then
            success "Homebrew 环境健康检查通过"
        else
            warning "Homebrew 环境检查发现问题，但基本功能正常"
            info "运行 'brew doctor' 查看详细信息"
        fi
        
        # 成功退出
        echo
        success "🎉 安装过程完成！感谢使用 Homebrew 环境设置脚本"
        
        # 友好的下一步提示
        echo
        info "💡 小贴士："
        if [[ -f "$HOMEBREW_DIR/brew-functions.zsh" ]]; then
            echo "  在新终端中运行以下命令开始使用管理功能："
            echo "  source $HOMEBREW_DIR/brew-functions.zsh"
            echo "  brew-init  # 检查环境状态"
        else
            echo "  运行 'brew doctor' 确保环境正常"
            echo "  运行 'brew list' 查看已安装的软件"
        fi
        
        if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
            warning "注意：有 ${#FAILED_MODULES[@]} 个模块安装失败，请检查日志"
            exit 1
        fi
    else
        echo
        info "Dry run 完成，使用 --help 查看实际安装选项"
    fi
}

# ==============================================================================
# 错误处理和信号捕获
# ==============================================================================

# 清理函数
cleanup_on_exit() {
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo
        error "脚本执行被中断或出现错误 (退出码: $exit_code)"
        
        # 显示已完成的操作
        if [[ ${#INSTALLED_MODULES[@]} -gt 0 ]]; then
            info "已成功安装的模块: ${INSTALLED_MODULES[*]}"
        fi
        
        if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
            warning "安装失败的模块: ${FAILED_MODULES[*]}"
        fi
        
        # 清理临时文件
        local temp_files=($(find /tmp -name "*brew*$*" 2>/dev/null))
        if [[ ${#temp_files[@]} -gt 0 ]]; then
            info "清理临时文件..."
            rm -f "${temp_files[@]}"
        fi
        
        echo
        info "故障排除建议:"
        echo "  1. 检查网络连接"
        echo "  2. 确保有足够的磁盘空间"
        echo "  3. 运行 'brew doctor' 检查 Homebrew 状态"
        echo "  4. 查看完整日志文件"
        echo "  5. 重新运行脚本"
        
        echo
        info "如需帮助，请查看:"
        echo "  脚本帮助: $0 --help"
        echo "  Homebrew 文档: https://docs.brew.sh/"
    fi
    
    exit $exit_code
}

# 中断处理
handle_interrupt() {
    echo
    warning "安装被用户中断"
    
    # 给用户选择是否清理
    read -p "是否清理临时文件? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        cleanup_environment
    fi
    
    exit 130
}

# 设置信号处理
trap cleanup_on_exit EXIT
trap handle_interrupt INT TERM

# ==============================================================================
# 脚本入口点
# ==============================================================================

# 检查是否以 root 权限运行
if [[ $EUID -eq 0 ]]; then
    error "请勿以 root 权限运行此脚本"
    info "Homebrew 需要在用户权限下安装"
    exit 1
fi

# 检查 macOS 版本（基础检查）
if [[ "$(uname)" != "Darwin" ]]; then
    error "此脚本仅支持 macOS 系统"
    exit 1
fi

# 运行主程序
main "$@"