#!/bin/bash

# ===================================================================
# VSCode 插件批量安装脚本
# ===================================================================
# 
# 功能：
#   - 批量安装 extensions.list 中列出的 VSCode 插件
#   - 智能检测已安装插件，避免重复安装
#   - 自动去除插件列表中的注释
#   - 提供详细的安装进度和统计信息
#   - 记录安装失败的插件并给出解决建议
#
# 使用方法：
#   ./install-extensions.sh
#
# ===================================================================

set -e

# 设置颜色常量
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# 获取脚本目录
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly EXTENSIONS_FILE="$SCRIPT_DIR/extensions.list"

# 统计变量
total_target_packages=0
total_new_packages=0
total_existing_packages=0
total_failed_packages=0
failed_extensions=()

# 开始时间
start_time=$(date +%s)

# ===================================================================
# 工具函数
# ===================================================================

print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    ${CYAN}VSCode 插件批量安装器${BLUE}                    ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_separator() {
    echo -e "${BLUE}──────────────────────────────────────────────────────────────${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_progress() {
    local current=$1
    local total=$2
    local extension=$3
    local percentage=$((current * 100 / total))
    
    printf "${PURPLE}📦 [%3d/%3d] (%3d%%) ${NC}正在处理: ${CYAN}%s${NC}\n" "$current" "$total" "$percentage" "$extension"
}

# ===================================================================
# 环境检查函数
# ===================================================================

check_prerequisites() {
    print_info "🔍 正在检查运行环境..."
    
    # 🔧 检查 code 命令
    if ! command -v code >/dev/null 2>&1; then
        print_error "🚫 未找到 code 命令"
        echo ""
        echo -e "${YELLOW}💡 解决方案：${NC}"
        echo "  📝 1. 在 VSCode 中按 Cmd+Shift+P（Mac）或 Ctrl+Shift+P（Windows/Linux）"
        echo "  🔧 2. 输入 Shell Command: Install code command in PATH"
        echo "  ✨ 3. 选择并执行该命令"
        echo ""
        echo "  🍺 或者通过 Homebrew 安装："
        echo "     brew install --cask visual-studio-code"
        echo ""
        exit 1
    fi
    
    # 📄 检查插件列表文件
    if [ ! -f "$EXTENSIONS_FILE" ]; then
        print_error "📂 插件列表文件不存在: $EXTENSIONS_FILE"
        echo ""
        echo -e "${YELLOW}💡 解决方案：${NC}"
        echo "  📝 请先创建 extensions.list 文件，或运行以下命令生成："
        echo "     code --list-extensions > extensions.list"
        echo ""
        exit 1
    fi
    
    # 📋 检查文件是否为空
    if [ ! -s "$EXTENSIONS_FILE" ]; then
        print_warning "📭 插件列表文件为空，没有需要安装的插件"
        exit 0
    fi
    
    print_success "🎯 环境检查通过"
}

# ===================================================================
# 插件处理函数
# ===================================================================

get_installed_extensions() {
    # 🔍 获取已安装插件列表，添加错误处理
    local installed
    if installed=$(code --list-extensions 2>/dev/null); then
        echo "$installed"
    else
        # 如果命令失败，返回空字符串
        echo ""
    fi
}

is_extension_installed() {
    local extension=$1
    local installed_extensions=$2
    
    # 🔍 如果已安装列表为空，返回未安装
    if [ -z "$installed_extensions" ]; then
        return 1
    fi
    
    # 🔍 检查插件是否在已安装列表中
    echo "$installed_extensions" | grep -q "^${extension}$"
}

install_single_extension() {
    local extension=$1
    
    # 使用临时文件捕获输出
    local temp_output=$(mktemp)
    
    if code --install-extension "$extension" --force >/dev/null 2>"$temp_output"; then
        rm -f "$temp_output"
        return 0
    else
        # 保存错误信息
        local error_msg=$(cat "$temp_output" 2>/dev/null || echo "未知错误")
        rm -f "$temp_output"
        echo "$error_msg"
        return 1
    fi
}

# ===================================================================
# 主要安装逻辑
# ===================================================================

process_extensions() {
    print_info "📋 正在分析插件列表..."
    
    # 📦 读取要安装的插件列表（过滤空行和注释）
    local extensions_to_install=()
    while IFS= read -r line; do
        # 🧹 去除首尾空格
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # ⏭️  跳过空行和注释行
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            # 🔪 提取插件 ID（去掉 # 后面的注释部分）
            local extension_id=$(echo "$line" | sed 's/[[:space:]]*#.*$//')
            # 🧹 再次去除可能的尾部空格
            extension_id=$(echo "$extension_id" | sed 's/[[:space:]]*$//')
            
            if [[ -n "$extension_id" ]]; then
                extensions_to_install+=("$extension_id")
            fi
        fi
    done < "$EXTENSIONS_FILE"
    
    total_target_packages=${#extensions_to_install[@]}
    
    if [ $total_target_packages -eq 0 ]; then
        print_warning "🔍 没有找到有效的插件配置"
        exit 0
    fi
    
    print_info "🎯 发现 $total_target_packages 个插件需要处理"
    
    # 🔍 获取已安装插件列表
    print_info "🔍 正在检查已安装插件..."
    local installed_extensions
    installed_extensions=$(get_installed_extensions)
    
    if [ -z "$installed_extensions" ]; then
        print_warning "⚠️  无法获取已安装插件列表，将尝试安装所有插件"
    else
        local installed_count=$(echo "$installed_extensions" | wc -l)
        print_info "📊 当前已安装 $installed_count 个插件"
    fi
    
    print_separator
    echo -e "${BLUE}🚀 开始安装插件...${NC}"
    echo ""
    
    # 🔄 处理每个插件
    local current=0
    for extension in "${extensions_to_install[@]}"; do
        ((current++))
        print_progress "$current" "$total_target_packages" "$extension"
        
        if [ -n "$installed_extensions" ] && is_extension_installed "$extension" "$installed_extensions"; then
            print_warning "⏭️  已安装，跳过: $extension"
            ((total_existing_packages++))
        else
            print_info "🔽 开始安装: $extension"
            
            local install_result
            if install_result=$(install_single_extension "$extension"); then
                print_success "🎉 安装成功: $extension"
                ((total_new_packages++))
                # 🔄 更新已安装列表
                installed_extensions="$installed_extensions"$'\n'"$extension"
            else
                print_error "💥 安装失败: $extension"
                failed_extensions+=("$extension|$install_result")
                ((total_failed_packages++))
            fi
        fi
        
        echo ""
    done
}

# ===================================================================
# 统计报告函数
# ===================================================================

print_statistics() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - start_time))
    local package_success_rate
    
    if [ $total_target_packages -eq 0 ]; then
        package_success_rate=0
    else
        package_success_rate=$(( (total_new_packages + total_existing_packages) * 100 / total_target_packages ))
    fi
    
    print_separator
    echo -e "${BLUE}🎉 安装完成！${NC}"
    echo ""
    
    # 📊 包统计
    echo -e "${CYAN}📊 安装统计:${NC}"
    echo -e "  📦 软件包统计: 目标 ${BLUE}$total_target_packages${NC} 个, 新安装 ${GREEN}$total_new_packages${NC} 个, 已安装（跳过） ${YELLOW}$total_existing_packages${NC} 个, 失败 ${RED}$total_failed_packages${NC} 个"
    echo -e "  ⏱️  总用时: ${PURPLE}$((total_duration / 60))${NC}分钟 ${PURPLE}$((total_duration % 60))${NC}秒"
    echo -e "  🎯 软件包完成率: ${GREEN}$package_success_rate%${NC}"
    
    # 🔥 失败详情
    if [ $total_failed_packages -gt 0 ]; then
        echo ""
        echo -e "${RED}💥 安装失败的插件详情:${NC}"
        for failed_info in "${failed_extensions[@]}"; do
            local extension=$(echo "$failed_info" | cut -d'|' -f1)
            local error_msg=$(echo "$failed_info" | cut -d'|' -f2-)
            echo -e "  🚫 ${RED}$extension${NC}"
            if [ -n "$error_msg" ] && [ "$error_msg" != " " ]; then
                echo -e "     💬 错误原因: ${YELLOW}$error_msg${NC}"
            fi
        done
        
        echo ""
        echo -e "${YELLOW}💡 解决建议:${NC}"
        echo "  🌐 1. 检查网络连接是否正常"
        echo "  🔍 2. 确认插件 ID 是否正确"
        echo "  🆙 3. 检查 VSCode 是否为最新版本"
        echo "  🔧 4. 尝试手动安装失败的插件"
        echo "  🔄 5. 如果是网络问题，可以稍后重新运行此脚本"
        
        echo ""
        echo -e "${RED}📋 失败的软件包名称:${NC}"
        for failed_info in "${failed_extensions[@]}"; do
            local extension=$(echo "$failed_info" | cut -d'|' -f1)
            local error_msg=$(echo "$failed_info" | cut -d'|' -f2-)
            if [ -n "$error_msg" ] && [ "$error_msg" != " " ]; then
                echo -e "  • ${RED}$extension${NC} (${YELLOW}$error_msg${NC})"
            else
                echo -e "  • ${RED}$extension${NC}"
            fi
        done
    fi
    
    echo ""
    if [ $total_failed_packages -eq 0 ]; then
        print_success "🌟 所有插件安装成功！🎊"
    else
        print_warning "⚠️  部分插件安装失败，请查看上方详情"
    fi
}

# ===================================================================
# 主函数
# ===================================================================

main() {
    print_header
    
    print_info "🚀 开始 VSCode 插件批量安装流程"
    print_info "📂 插件列表文件: $EXTENSIONS_FILE"
    echo ""
    
    check_prerequisites
    echo ""
    
    process_extensions
    
    print_statistics
    
    echo ""
    print_info "🔄 插件安装流程完成，请重启 VSCode 以确保所有插件正常加载"
}

# 执行主函数
main "$@"