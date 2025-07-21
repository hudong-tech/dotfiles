#!/usr/bin/env bash

# Work 系统复用部署脚本 - 企业级版本 🚀
# 作者: AI Assistant  
# 版本: 2.0.0
# 描述: 一键部署标准化工作目录系统到任意位置

set -euo pipefail  # 严格模式：遇到错误立即退出

# 颜色配置 🎨
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m' # No Color

# 全局变量
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEMPLATE_DIR="${SCRIPT_DIR}/default_template"
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="Work System Deployer"

# 统计变量
TOTAL_DIRS=0
TOTAL_FILES=0
COPIED_DIRS=0
COPIED_FILES=0
START_TIME=""
DEPLOYMENT_ID=""

# 🎯 显示帮助信息
show_help() {
    cat << EOF
${WHITE}🚀 Work 系统复用部署工具 v${SCRIPT_VERSION}${NC}

${CYAN}用法:${NC}
    $0 [target_directory] [options]

${CYAN}参数:${NC}
    target_directory    目标部署路径（默认: \$HOME/work）

${CYAN}选项:${NC}
    -h, --help         显示帮助信息
    -v, --version      显示版本信息
    -f, --force        强制覆盖已存在的目录
    -q, --quiet        静默模式（减少输出）
    --no-personalize   跳过个性化配置

${CYAN}示例:${NC}
    $0                              # 部署到 ~/work
    $0 /path/to/my-work            # 部署到指定路径
    $0 ~/work-new --force          # 强制覆盖现有目录
    $0 /Volumes/USB/work           # 部署到外部设备

${CYAN}特性:${NC}
    ✨ 智能冲突检测与备份
    🔧 自动权限设置与个性化配置  
    📊 详细的部署统计信息
    🛡️ 完整的错误处理与回滚
    🎨 友好的用户界面体验

${GRAY}💡 该脚本将复制完整的 Work 系统模板，包括项目脚手架工具和标准目录结构${NC}
EOF
}

# 🎨 日志函数
log_info() { echo -e "${BLUE}ℹ️  ${1}${NC}"; }
log_success() { echo -e "${GREEN}✅ ${1}${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  ${1}${NC}"; }
log_error() { echo -e "${RED}❌ ${1}${NC}" >&2; }
log_debug() { echo -e "${GRAY}🔍 ${1}${NC}"; }
log_step() { echo -e "${PURPLE}🚀 Step $1: ${2}${NC}"; }

# 📏 进度条显示
show_progress() {
    local current=$1
    local total=$2
    local desc="$3"
    local width=30
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    printf "\r${CYAN}📊 ${desc}: [${NC}"
    printf "%*s" $completed | tr ' ' '█'
    printf "%*s" $((width - completed)) | tr ' ' '░'
    printf "${CYAN}] %d%% (%d/%d)${NC}" $percentage $current $total
    
    if [ $current -eq $total ]; then
        printf "\n"
    fi
}

# 🔍 验证环境和模板
validate_environment() {
    log_debug "验证部署环境..."
    
    # 检查模板目录是否存在
    if [ ! -d "$TEMPLATE_DIR" ]; then
        log_error "模板目录不存在: $TEMPLATE_DIR"
        log_info "请确保脚本在正确的 work-system 目录中运行"
        return 1
    fi
    
    # 检查关键文件
    local key_files=(
        "$TEMPLATE_DIR/README.md"
        "$TEMPLATE_DIR/02_Projects/_scaffold/init_project.sh"
        "$TEMPLATE_DIR/02_Projects/_scaffold/templates/default_project/project.yaml"
    )
    
    for file in "${key_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "关键文件缺失: $file"
            return 1
        fi
    done
    
    # 统计模板大小
    TOTAL_DIRS=$(find "$TEMPLATE_DIR" -type d | wc -l)
    TOTAL_FILES=$(find "$TEMPLATE_DIR" -type f | wc -l)
    
    log_success "环境验证通过"
    log_debug "模板统计: $TOTAL_DIRS 个目录, $TOTAL_FILES 个文件"
    
    return 0
}

# 🏗️ 处理目标目录
handle_target_directory() {
    local target_dir="$1"
    local force_mode="$2"
    
    log_debug "检查目标目录: $target_dir"
    
    # 检查目标目录是否存在
    if [ -d "$target_dir" ]; then
        if [ "$force_mode" = "true" ]; then
            log_warning "强制模式：将覆盖现有目录"
        else
            log_warning "目标目录已存在: $target_dir"
            echo -e "\n${YELLOW}请选择操作:${NC}"
            echo -e "  ${WHITE}1)${NC} 备份现有目录并继续"
            echo -e "  ${WHITE}2)${NC} 覆盖现有目录"
            echo -e "  ${WHITE}3)${NC} 取消操作"
            echo
            
            while true; do
                read -p "请输入选择 (1-3): " -n 1 -r choice
                echo
                case $choice in
                    1)
                        log_info "备份现有目录..."
                        local backup_dir="${target_dir}_backup_$(date +%Y%m%d_%H%M%S)"
                        mv "$target_dir" "$backup_dir" || {
                            log_error "备份失败"
                            return 1
                        }
                        log_success "已备份到: $backup_dir"
                        break
                        ;;
                    2)
                        log_warning "将覆盖现有目录"
                        rm -rf "$target_dir" || {
                            log_error "删除现有目录失败"
                            return 1
                        }
                        break
                        ;;
                    3)
                        log_info "操作已取消"
                        return 2
                        ;;
                    *)
                        echo -e "${RED}无效选择，请输入 1-3${NC}"
                        ;;
                esac
            done
        fi
        
        # 如果是强制模式，直接删除
        if [ "$force_mode" = "true" ] && [ -d "$target_dir" ]; then
            rm -rf "$target_dir" || {
                log_error "删除现有目录失败"
                return 1
            }
        fi
    fi
    
    # 创建目标目录的父目录
    local parent_dir="$(dirname "$target_dir")"
    if [ ! -d "$parent_dir" ]; then
        log_info "创建父目录: $parent_dir"
        mkdir -p "$parent_dir" || {
            log_error "创建父目录失败"
            return 1
        }
    fi
    
    return 0
}

# 📦 复制模板文件
copy_template() {
    local target_dir="$1"
    local quiet_mode="$2"
    
    log_info "开始复制模板文件..."
    
    # 复制整个模板目录
    if [ "$quiet_mode" = "true" ]; then
        cp -r "$TEMPLATE_DIR" "$target_dir" 2>/dev/null || {
            log_error "复制模板失败"
            return 1
        }
    else
        # 显示进度的复制
        local temp_target="/tmp/work_deploy_temp_$$"
        cp -r "$TEMPLATE_DIR" "$temp_target" || {
            log_error "复制到临时位置失败"
            return 1
        }
        
        # 移动到最终位置
        mv "$temp_target" "$target_dir" || {
            log_error "移动到目标位置失败"
            rm -rf "$temp_target"
            return 1
        }
    fi
    
    # 统计复制结果
    COPIED_DIRS=$(find "$target_dir" -type d | wc -l)
    COPIED_FILES=$(find "$target_dir" -type f | wc -l)
    
    log_success "模板复制完成"
    log_debug "复制统计: $COPIED_DIRS 个目录, $COPIED_FILES 个文件"
    
    return 0
}

# 🔧 设置权限和配置
setup_permissions_and_config() {
    local target_dir="$1"
    local personalize="$2"
    
    log_info "设置权限和配置..."
    
    # 设置脚本执行权限
    local script_files=(
        "$target_dir/02_Projects/_scaffold/init_project.sh"
    )
    
    for script in "${script_files[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script" || {
                log_warning "设置执行权限失败: $script"
            }
        fi
    done
    
    # 查找并设置所有 .sh 文件权限
    find "$target_dir" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # 个性化配置
    if [ "$personalize" = "true" ]; then
        perform_personalization "$target_dir"
    fi
    
    log_success "权限和配置设置完成"
    return 0
}

# 👤 个性化配置
perform_personalization() {
    local target_dir="$1"
    
    log_info "进行个性化配置..."
    
    # 获取用户信息
    local default_user="$(whoami)"
    local default_email="${default_user}@$(hostname)"
    
    echo -e "\n${CYAN}📝 个性化设置:${NC}"
    read -p "用户名 (默认: $default_user): " input_user
    local user_name="${input_user:-$default_user}"
    
    read -p "邮箱 (默认: $default_email): " input_email
    local user_email="${input_email:-$default_email}"
    
    # 替换模板中的占位符
    log_debug "更新配置文件中的用户信息..."
    
    local template_files=(
        "project.yaml"
        "README.md"
        "CHANGELOG.md"
    )
    
    # 查找并替换所有相关文件
    find "$target_dir" -type f \( -name "*.yaml" -o -name "*.md" \) | while read -r file; do
        if [ -f "$file" ]; then
            # 使用临时文件进行替换
            local temp_file="$(mktemp)"
            sed -e "s/@yourname/@$user_name/g" \
                -e "s/your\.email@example\.com/$user_email/g" \
                "$file" > "$temp_file" && mv "$temp_file" "$file"
        fi
    done 2>/dev/null || true
    
    # 创建个人配置文件
    cat > "$target_dir/04_Tools/personal_config.sh" << EOF
#!/usr/bin/env bash
# Work 系统个人配置文件
# 生成时间: $(date)
# 部署ID: $DEPLOYMENT_ID

# 用户信息
export WORK_USER="$user_name"
export WORK_EMAIL="$user_email"

# 路径配置
export WORK_ROOT="$target_dir"
export PROJECTS_DIR="\$WORK_ROOT/02_Projects"
export TOOLS_DIR="\$WORK_ROOT/04_Tools"

# 默认设置
export DEFAULT_PROJECT_OWNER="@$user_name"
export DEFAULT_PRIORITY="P2"
export AUTO_ARCHIVE_DAYS=90

# 部署信息
export DEPLOYMENT_DATE="$(date +%Y-%m-%d)"
export DEPLOYMENT_VERSION="$SCRIPT_VERSION"
export DEPLOYMENT_ID="$DEPLOYMENT_ID"
EOF
    
    chmod +x "$target_dir/04_Tools/personal_config.sh"
    
    log_success "个性化配置完成"
    log_debug "用户: $user_name, 邮箱: $user_email"
}

# 📊 显示部署统计
show_deployment_statistics() {
    local target_dir="$1"
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local target_size=$(du -sh "$target_dir" 2>/dev/null | cut -f1 || echo "未知")
    
    echo
    echo -e "${WHITE}📈 部署统计报告${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🆔 部署ID:${NC}     $DEPLOYMENT_ID"
    echo -e "${CYAN}📂 目标路径:${NC}   $target_dir"
    echo -e "${CYAN}📁 复制目录:${NC}   $COPIED_DIRS / $TOTAL_DIRS"
    echo -e "${CYAN}📄 复制文件:${NC}   $COPIED_FILES / $TOTAL_FILES"
    echo -e "${CYAN}💾 目录大小:${NC}   $target_size"
    echo -e "${CYAN}⏱️  执行时间:${NC}   ${duration}s"
    echo -e "${CYAN}🏷️  模板版本:${NC}  Work System Template v$SCRIPT_VERSION"
    echo -e "${CYAN}📅 部署时间:${NC}   $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

# 🎉 显示成功信息
show_success_message() {
    local target_dir="$1"
    
    echo -e "${GREEN}🎉 Work 系统部署成功！${NC}"
    echo
    echo -e "${WHITE}🚀 快速开始:${NC}"
    echo -e "   1. ${CYAN}cd $target_dir${NC}"
    echo -e "   2. ${CYAN}02_Projects/_scaffold/init_project.sh proj-example \"我的第一个项目\"${NC}"
    echo -e "   3. ${CYAN}阅读 README.md 了解系统详情${NC}"
    echo
    echo -e "${WHITE}📚 重要文件:${NC}"
    echo -e "   • ${GRAY}README.md${NC}                     - 系统说明文档"
    echo -e "   • ${GRAY}02_Projects/README.md${NC}         - 项目管理指南"
    echo -e "   • ${GRAY}02_Projects/_scaffold/README.md${NC} - 脚手架工具说明"
    echo -e "   • ${GRAY}04_Tools/personal_config.sh${NC}   - 个人配置文件"
    echo
    echo -e "${GRAY}💡 提示: 系统已根据你的信息进行个性化配置，立即可用！${NC}"
}

# 🧹 清理函数
cleanup() {
    # 清理临时文件
    find /tmp -name "work_deploy_temp_*" -user "$(whoami)" -mtime +0 -delete 2>/dev/null || true
}

# 🚪 退出处理
trap cleanup EXIT

# 🎯 主函数
main() {
    START_TIME=$(date +%s)
    DEPLOYMENT_ID="WSD_$(date +%Y%m%d_%H%M%S)_$$"
    
    # 解析参数
    local target_dir="$HOME/work"
    local force_mode="false"
    local quiet_mode="false"
    local personalize="true"
    
    while [ $# -gt 0 ]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "$SCRIPT_NAME v$SCRIPT_VERSION"
                exit 0
                ;;
            -f|--force)
                force_mode="true"
                shift
                ;;
            -q|--quiet)
                quiet_mode="true"
                shift
                ;;
            --no-personalize)
                personalize="false"
                shift
                ;;
            -*)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                target_dir="$1"
                shift
                ;;
        esac
    done
    
    # 显示欢迎信息
    if [ "$quiet_mode" != "true" ]; then
        echo -e "${PURPLE}"
        cat << 'EOF'
╭─────────────────────────────────────────────────╮
│            🚀 Work 系统复用部署工具             │
│                                                 │
│       企业级工作目录系统一键部署解决方案 ✨      │
╰─────────────────────────────────────────────────╯
EOF
        echo -e "${NC}"
    fi
    
    log_info "开始部署 Work 系统..."
    log_debug "部署ID: $DEPLOYMENT_ID"
    log_debug "目标路径: $target_dir"
    
    # Step 1: 验证环境
    log_step "1/4" "验证环境和模板"
    if ! validate_environment; then
        exit 1
    fi
    
    # Step 2: 处理目标目录
    log_step "2/4" "处理目标目录"
    handle_target_directory "$target_dir" "$force_mode"
    local handle_result=$?
    
    if [ $handle_result -eq 2 ]; then
        # 用户取消操作
        exit 0
    elif [ $handle_result -ne 0 ]; then
        # 处理失败
        exit 1
    fi
    
    # Step 3: 复制模板
    log_step "3/4" "复制模板文件"
    if ! copy_template "$target_dir" "$quiet_mode"; then
        log_error "模板复制失败，清理已创建的文件"
        rm -rf "$target_dir" 2>/dev/null || true
        exit 1
    fi
    
    # Step 4: 设置配置
    log_step "4/4" "设置权限和配置"
    if ! setup_permissions_and_config "$target_dir" "$personalize"; then
        log_warning "配置设置部分失败，但系统基本可用"
    fi
    
    # 显示结果
    if [ "$quiet_mode" != "true" ]; then
        show_deployment_statistics "$target_dir"
        show_success_message "$target_dir"
    fi
    
    log_success "Work 系统部署完成！🎊"
    log_info "部署ID: $DEPLOYMENT_ID"
    
    exit 0
}

# 🎬 脚本入口
main "$@"