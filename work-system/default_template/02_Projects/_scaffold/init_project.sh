#!/usr/bin/env bash

# 项目初始化脚本 - 世界级程序员版本 🚀
# 作者: AI Assistant
# 版本: 1.0.0
# 描述: 基于模板快速创建标准化项目结构

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
readonly TEMPLATE_DIR="${SCRIPT_DIR}/templates/default_project"
readonly TARGET_BASE_DIR="${SCRIPT_DIR}/../01_Active"  # 默认创建在 Active 目录

# 统计变量
CREATED_DIRS=0
CREATED_FILES=0
PROCESSED_TEMPLATES=0
START_TIME=""

# 🎯 显示帮助信息
show_help() {
    cat << EOF
${WHITE}🚀 项目初始化脚本${NC}

${CYAN}用法:${NC}
    $0 <project-name> [description] [owner]

${CYAN}参数:${NC}
    project-name    项目名称（必须符合 proj-xxx-xxx 格式）
    description     项目描述（可选，默认为项目名称）
    owner          项目负责人（可选，默认为 @yourname）

${CYAN}示例:${NC}
    $0 proj-ai-beacon "AI媒体追踪平台"
    $0 proj-crm-lite "轻量级CRM系统" "@alice"

${CYAN}命名规范:${NC}
    ✅ proj-ai-beacon
    ✅ proj-growth-hacking  
    ✅ proj-data-pipeline
    ❌ ai-beacon (缺少 proj- 前缀)
    ❌ proj_ai_beacon (不能使用下划线)
    ❌ Proj-AI-Beacon (不能使用大写)

${GRAY}💡 脚本支持重复执行，已存在的项目将被跳过${NC}
EOF
}

# 🎨 日志函数
log_info() { echo -e "${BLUE}ℹ️  ${1}${NC}"; }
log_success() { echo -e "${GREEN}✅ ${1}${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  ${1}${NC}"; }
log_error() { echo -e "${RED}❌ ${1}${NC}" >&2; }
log_debug() { echo -e "${GRAY}🔍 ${1}${NC}"; }

# 📏 进度条显示
show_progress() {
    local current=$1
    local total=$2
    local width=30
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    printf "\r${CYAN}📊 进度: [${NC}"
    printf "%*s" $completed | tr ' ' '█'
    printf "%*s" $((width - completed)) | tr ' ' '░'
    printf "${CYAN}] %d%% (%d/%d)${NC}" $percentage $current $total
    
    if [ $current -eq $total ]; then
        printf "\n"
    fi
}

# 🔍 验证项目名称格式
validate_project_name() {
    local project_name="$1"
    
    log_debug "验证项目名称: $project_name"
    
    # 检查是否以 proj- 开头
    if [[ ! "$project_name" =~ ^proj- ]]; then
        log_error "项目名称必须以 'proj-' 开头"
        return 1
    fi
    
    # 检查格式：只能包含小写字母、数字和连字符
    if [[ ! "$project_name" =~ ^proj-[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
        log_error "项目名称格式不正确，只能包含小写字母、数字和连字符"
        log_info "正确格式示例: proj-ai-beacon, proj-data-pipeline"
        return 1
    fi
    
    # 检查长度（建议不超过 30 字符）
    if [ ${#project_name} -gt 30 ]; then
        log_warning "项目名称较长 (${#project_name} 字符)，建议保持在 30 字符以内"
    fi
    
    log_success "项目名称验证通过"
    return 0
}

# 🏗️ 创建目录结构
create_directory_structure() {
    local project_name="$1"
    local target_dir="$TARGET_BASE_DIR/$project_name"
    
    log_info "创建项目目录: $target_dir"
    
    # 检查项目是否已存在
    if [ -d "$target_dir" ]; then
        log_warning "项目目录已存在，跳过创建: $target_dir"
        return 2  # 返回特殊状态码表示跳过
    fi
    
    # 检查模板目录是否存在
    if [ ! -d "$TEMPLATE_DIR" ]; then
        log_error "模板目录不存在: $TEMPLATE_DIR"
        return 1
    fi
    
    # 复制模板目录
    cp -r "$TEMPLATE_DIR" "$target_dir" 2>/dev/null || {
        log_error "复制模板失败"
        return 1
    }
    
    # 统计创建的目录和文件
    CREATED_DIRS=$(find "$target_dir" -type d | wc -l)
    CREATED_FILES=$(find "$target_dir" -type f | wc -l)
    
    log_success "目录结构创建完成"
    return 0
}

# 🔄 处理模板文件中的占位符
process_templates() {
    local project_name="$1"
    local description="$2"
    local owner="$3"
    local target_dir="$TARGET_BASE_DIR/$project_name"
    
    local start_date=$(date +%Y-%m-%d)
    local due_date=$(date -d "+30 days" +%Y-%m-%d 2>/dev/null || date -v+30d +%Y-%m-%d)
    
    log_info "处理模板文件中的占位符..."
    
    local template_files=("README.md" "project.yaml" "CHANGELOG.md")
    local total_templates=${#template_files[@]}
    local processed=0
    
    for template_file in "${template_files[@]}"; do
        local file_path="$target_dir/$template_file"
        
        if [ -f "$file_path" ]; then
            log_debug "处理模板文件: $template_file"
            
            # 创建临时文件进行替换
            local temp_file=$(mktemp)
            
            # 执行占位符替换
            sed -e "s/PROJECT_NAME/$project_name/g" \
                -e "s/PROJECT_DESC/$description/g" \
                -e "s/__START_DATE__/$start_date/g" \
                -e "s/__DUE_DATE__/$due_date/g" \
                -e "s/@yourname/$owner/g" \
                -e "s/\$(date +%F)/$start_date/g" \
                "$file_path" > "$temp_file"
            
            # 替换原文件
            mv "$temp_file" "$file_path" || {
                log_error "处理模板文件失败: $template_file"
                rm -f "$temp_file"
                return 1
            }
            
            ((processed++))
            show_progress $processed $total_templates
            
        else
            log_warning "模板文件不存在: $template_file"
        fi
    done
    
    PROCESSED_TEMPLATES=$processed
    log_success "模板处理完成"
    return 0
}

# 📊 显示创建统计
show_statistics() {
    local project_name="$1"
    local target_dir="$TARGET_BASE_DIR/$project_name"
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    echo
    echo -e "${WHITE}📈 项目创建统计${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📁 项目名称:${NC} $project_name"
    echo -e "${CYAN}📂 项目路径:${NC} $target_dir"
    echo -e "${CYAN}🗂️  创建目录:${NC} $CREATED_DIRS 个"
    echo -e "${CYAN}📄 创建文件:${NC} $CREATED_FILES 个"
    echo -e "${CYAN}🔧 处理模板:${NC} $PROCESSED_TEMPLATES 个"
    echo -e "${CYAN}⏱️  执行时间:${NC} ${duration}s"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

# 🎉 显示成功信息
show_success_message() {
    local project_name="$1"
    local target_dir="$TARGET_BASE_DIR/$project_name"
    
    echo -e "${GREEN}🎉 项目创建成功！${NC}"
    echo
    echo -e "${WHITE}🚀 下一步操作:${NC}"
    echo -e "   1. ${CYAN}cd ${target_dir}${NC}"
    echo -e "   2. ${CYAN}编辑 project.yaml 完善项目信息${NC}"
    echo -e "   3. ${CYAN}编辑 README.md 填写项目详情${NC}"
    echo -e "   4. ${CYAN}开始你的项目开发之旅！${NC}"
    echo
    echo -e "${GRAY}💡 提示: 记得定期更新 CHANGELOG.md 记录项目变更${NC}"
}

# 🧹 清理函数
cleanup() {
    # 清理可能的临时文件
    find /tmp -name "tmp.*" -user "$(whoami)" -mtime +1 -delete 2>/dev/null || true
}

# 🚪 退出处理
trap cleanup EXIT

# 🎯 主函数
main() {
    START_TIME=$(date +%s)
    
    # 显示欢迎信息
    echo -e "${PURPLE}"
    cat << 'EOF'
╭─────────────────────────────────────────╮
│          🚀 项目初始化脚本 v1.0          │
│                                         │
│     让项目创建变得简单而标准化 ✨         │
╰─────────────────────────────────────────╯
EOF
    echo -e "${NC}"
    
    # 参数检查
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    if [ $# -lt 1 ]; then
        log_error "缺少必需的参数"
        show_help
        exit 1
    fi
    
    # 获取参数
    local project_name="$1"
    local description="${2:-$project_name}"
    local owner="${3:-@yourname}"
    
    log_info "开始初始化项目: $project_name"
    log_debug "项目描述: $description"
    log_debug "项目负责人: $owner"
    
    # Step 1: 验证项目名称
    echo -e "\n${WHITE}Step 1/3: 验证项目名称${NC}"
    if ! validate_project_name "$project_name"; then
        exit 1
    fi
    
    # Step 2: 创建目录结构
    echo -e "\n${WHITE}Step 2/3: 创建目录结构${NC}"
    local create_result
    create_directory_structure "$project_name"
    create_result=$?
    
    if [ $create_result -eq 2 ]; then
        # 项目已存在，跳过
        log_info "项目已存在，脚本执行完成"
        exit 0
    elif [ $create_result -ne 0 ]; then
        # 创建失败
        exit 1
    fi
    
    # Step 3: 处理模板
    echo -e "\n${WHITE}Step 3/3: 处理模板文件${NC}"
    if ! process_templates "$project_name" "$description" "$owner"; then
        # 清理已创建的目录
        rm -rf "$TARGET_BASE_DIR/$project_name"
        log_error "模板处理失败，已清理创建的文件"
        exit 1
    fi
    
    # 显示统计信息和成功消息
    show_statistics "$project_name"
    show_success_message "$project_name"
    
    log_success "项目 '$project_name' 初始化完成！🎊"
    exit 0
}

# 🎬 脚本入口
main "$@"