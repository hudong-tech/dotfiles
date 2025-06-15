#!/usr/bin/env bash

# =========================================================================
# dirtree 模块 - Shell 集成函数
# =========================================================================
#
# 🌳 目录结构创建工具的便捷函数集合
# 📁 与 dotfiles 项目集成使用
#
# 版本：v1.0
# 创建时间：2025-06-14
#
# =========================================================================

# 🎨 颜色定义（检查是否已定义）
[[ -z "${RED:-}" ]] && RED='\033[0;31m'
[[ -z "${GREEN:-}" ]] && GREEN='\033[0;32m'
[[ -z "${YELLOW:-}" ]] && YELLOW='\033[1;33m'
[[ -z "${BLUE:-}" ]] && BLUE='\033[0;34m'
[[ -z "${PURPLE:-}" ]] && PURPLE='\033[0;35m'
[[ -z "${CYAN:-}" ]] && CYAN='\033[0;36m'
[[ -z "${NC:-}" ]] && NC='\033[0m'

# 📝 日志函数
_dirtree_log_info() { echo -e "${BLUE}ℹ️  [INFO]${NC} $1"; }
_dirtree_log_success() { echo -e "${GREEN}✅ [SUCCESS]${NC} $1"; }
_dirtree_log_warning() { echo -e "${YELLOW}⚠️  [WARNING]${NC} $1"; }
_dirtree_log_error() { echo -e "${RED}❌ [ERROR]${NC} $1"; }
_dirtree_log_header() { echo -e "${PURPLE}🌳 [DIRTREE]${NC} $1"; }

# 📂 模块路径
DIRTREE_DIR="${HOME}/dotfiles/dirtree"
DIRTREE_TEMPLATES_DIR="${DIRTREE_DIR}/templates"

# =========================================================================
# 🚀 核心创建功能
# =========================================================================

# 创建目录结构
dirtree_create() {
    local target_dir="$1"
    local template_file="$2"
    
    if [[ -z "$target_dir" || -z "$template_file" ]]; then
        _dirtree_log_error "参数不完整！请提供目标目录和模板文件"
        echo ""
        echo "📖 用法示例:"
        echo "   ${CYAN}dirtree_create ~/Documents documents${NC}"
        echo "   ${CYAN}dirtree_create ~/MyProject /path/to/custom.dirs${NC}"
        echo ""
        echo "💡 提示: 使用 ${CYAN}dirtree_list${NC} 查看可用模板"
        return 1
    fi
    
    # 🔍 如果模板文件不包含路径，从模板目录查找
    if [[ ! -f "$template_file" && ! "$template_file" =~ / ]]; then
        template_file="${DIRTREE_TEMPLATES_DIR}/${template_file}.dirs"
    fi
    
    # ✅ 检查模板文件是否存在
    if [[ ! -f "$template_file" ]]; then
        _dirtree_log_error "模板文件不存在: $template_file"
        echo "💡 使用 ${CYAN}dirtree_list${NC} 查看可用模板"
        return 1
    fi
    
    # 🎯 显示即将执行的操作
    _dirtree_log_header "准备创建目录结构"
    echo "📁 目标目录: ${CYAN}$target_dir${NC}"
    echo "📋 使用模板: ${CYAN}$(basename "$template_file")${NC}"
    echo ""
    
    # 🚀 直接在函数内创建目录结构，替换外部脚本调用
    local created_count=0
    local failed_count=0
    local skipped_count=0
    
    _dirtree_log_info "开始创建目录结构..."
    echo ""
    
    # 读取模板文件并创建目录
    while IFS= read -r line; do
        # 跳过空行和注释
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # 清理路径
        local dir_path="${line#"${line%%[![:space:]]*}"}"
        dir_path="${dir_path%"${dir_path##*[![:space:]]}"}"
        
        [[ -z "$dir_path" ]] && continue
        
        # 构建完整路径
        local full_path="${target_dir}/${dir_path}"
        
        # 创建目录
        if [[ -d "$full_path" ]]; then
            echo "   ⏭️  已存在: ${CYAN}$dir_path${NC}"
            ((skipped_count++))
        elif mkdir -p "$full_path" 2>/dev/null; then
            echo "   ✅ 已创建: ${CYAN}$dir_path${NC}"
            ((created_count++))
        else
            echo "   ❌ 创建失败: ${CYAN}$dir_path${NC}"
            ((failed_count++))
        fi
    done < "$template_file"
    
    echo ""
    
    # 显示创建结果
    if [[ $failed_count -eq 0 ]]; then
        _dirtree_log_success "目录结构创建完成！"
        echo "📊 创建统计:"
        echo "   ✅ 新建目录: ${GREEN}$created_count${NC} 个"
        echo "   ⏭️  已存在: ${YELLOW}$skipped_count${NC} 个"
        echo "   📁 总目录数: ${CYAN}$((created_count + skipped_count))${NC} 个"
        echo ""
        echo "💡 你可以使用以下命令继续操作:"
        echo "   📊 查看统计: ${CYAN}dirtree_status \"$target_dir\"${NC}"
        echo "   📝 生成文档: ${CYAN}dirtree_generate_docs \"$(basename "$template_file" .dirs)\"${NC}"
        echo "   🧹 清理空目录: ${CYAN}dirtree_cleanup \"$target_dir\"${NC}"
        return 0
    else
        _dirtree_log_error "目录结构创建过程中出现问题！"
        echo "📊 创建统计:"
        echo "   ✅ 成功创建: ${GREEN}$created_count${NC} 个"
        echo "   ⏭️  已存在: ${YELLOW}$skipped_count${NC} 个"
        echo "   ❌ 创建失败: ${RED}$failed_count${NC} 个"
        return 1
    fi
}

# 快捷创建文档结构
dirtree_create_docs() {
    local target_dir="${1:-$HOME/Documents}"
    
    _dirtree_log_header "快捷创建文档管理结构"
    echo "📁 目标目录: ${CYAN}$target_dir${NC}"
    echo "📋 使用模板: ${CYAN}documents${NC}"
    echo ""
    
    dirtree_create "$target_dir" "documents"
}

# =========================================================================
# 📋 模板管理功能
# =========================================================================

# 列出可用模板
dirtree_list() {
    _dirtree_log_header "可用模板列表"
    echo ""
    
    if [[ ! -d "$DIRTREE_TEMPLATES_DIR" ]]; then
        _dirtree_log_warning "模板目录不存在: $DIRTREE_TEMPLATES_DIR"
        echo "💡 请确保 dirtree 模块正确安装"
        return 1
    fi
    
    local count=0
    echo "📚 模板清单:"
    echo "┌──────────────────┬────────────────────────────────────────────────────┐"
    printf "│ %-16s │ %-50s │\n" "模板名称" "描述"
    echo "├──────────────────┼────────────────────────────────────────────────────┤"
    
    for template in "$DIRTREE_TEMPLATES_DIR"/*.dirs; do
        if [[ -f "$template" ]]; then
            local name=$(basename "$template" .dirs)
            local description=$(grep "^# 模板描述：" "$template" | sed 's/^# 模板描述：//' | head -1)
            [[ -z "$description" ]] && description="无描述信息"
            
            # 限制描述长度（考虑中文字符）
            if [[ ${#description} -gt 50 ]]; then
                description="${description:0:47}..."
            fi
            
            printf "│ ${CYAN}%-16s${NC} │ %-50s │\n" "$name" "$description"
            ((count++))
        fi
    done
    
    echo "└──────────────────┴────────────────────────────────────────────────────┘"
    echo ""
    
    if [[ $count -eq 0 ]]; then
        _dirtree_log_warning "未找到任何模板文件"
        echo "💡 请检查模板目录: $DIRTREE_TEMPLATES_DIR"
    else
        _dirtree_log_success "共找到 $count 个可用模板"
        echo ""
        echo "💡 使用方法:"
        echo "   📖 查看详情: ${CYAN}dirtree_info <模板名>${NC}"
        echo "   👀 预览结构: ${CYAN}dirtree_preview <模板名>${NC}"
        echo "   🚀 创建结构: ${CYAN}dirtree_create <目标目录> <模板名>${NC}"
    fi
}

# 显示模板详细信息
dirtree_info() {
    local template_name="$1"
    
    if [[ -z "$template_name" ]]; then
        _dirtree_log_error "请指定模板名称！"
        echo "📖 用法: ${CYAN}dirtree_info <模板名称>${NC}"
        echo "💡 使用 ${CYAN}dirtree_list${NC} 查看可用模板"
        return 1
    fi
    
    local template_file="${DIRTREE_TEMPLATES_DIR}/${template_name}.dirs"
    
    if [[ ! -f "$template_file" ]]; then
        _dirtree_log_error "模板不存在: $template_name"
        echo "💡 使用 ${CYAN}dirtree_list${NC} 查看可用模板"
        return 1
    fi
    
    _dirtree_log_header "模板详细信息"
    echo ""
    echo "📋 模板名称: ${CYAN}$template_name${NC}"
    echo "📁 文件路径: ${CYAN}$template_file${NC}"
    echo ""
    
    # 📊 提取模板头部信息
    echo "📖 模板信息:"
    echo "┌─────────────────────────────────────────────────────────────────┐"
    
    local info_found=false
    while IFS= read -r line; do
        if [[ "$line" =~ ^#[[:space:]]*(模板名称|模板描述|适用场景|创建时间|版本)：(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            printf "│ %-15s: %-47s │\n" "$key" "$value"
            info_found=true
        fi
    done < "$template_file"
    
    if [[ "$info_found" == false ]]; then
        printf "│ %-63s │\n" "暂无详细信息"
    fi
    
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # 📈 统计信息
    local total_lines=$(wc -l < "$template_file")
    local dir_count=$(grep -v -E '^[[:space:]]*$|^[[:space:]]*#' "$template_file" | wc -l)
    local comment_lines=$(grep -E '^[[:space:]]*#' "$template_file" | wc -l)
    
    echo "📊 统计信息:"
    echo "   📄 总行数: $total_lines"
    echo "   📁 目录数: $dir_count"
    echo "   💬 注释行: $comment_lines"
    echo ""
    
    echo "💡 下一步操作:"
    echo "   👀 预览结构: ${CYAN}dirtree_preview $template_name${NC}"
    echo "   ✅验证格式: ${CYAN}dirtree_validate $template_name${NC}"
    echo "   🚀 创建结构: ${CYAN}dirtree_create <目标目录> $template_name${NC}"
}

# 预览模板将创建的目录结构
dirtree_preview() {
    local template_name="$1"
    
    if [[ -z "$template_name" ]]; then
        _dirtree_log_error "请指定模板名称！"
        echo "📖 用法: ${CYAN}dirtree_preview <模板名称>${NC}"
        return 1
    fi
    
    local template_file="${DIRTREE_TEMPLATES_DIR}/${template_name}.dirs"
    
    if [[ ! -f "$template_file" ]]; then
        _dirtree_log_error "模板不存在: $template_name"
        echo "💡 使用 ${CYAN}dirtree_list${NC} 查看可用模板"
        return 1
    fi
    
    _dirtree_log_header "模板预览: $template_name"
    echo ""
    
    local count=0
    local current_section=""
    
    echo "🗂️  将要创建的目录结构:"
    echo ""
    
    while IFS= read -r line; do
        # 检测分区标题
        if [[ "$line" =~ ^#[[:space:]]*===[[:space:]]*(.+)[[:space:]]*===[[:space:]]*$ ]]; then
            local section="${BASH_REMATCH[1]}"
            if [[ "$section" != "$current_section" ]]; then
                echo "📂 ${YELLOW}$section${NC}"
                current_section="$section"
            fi
            continue
        fi
        
        # 跳过其他注释和空行
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # 清理路径
        local dir_path="${line#"${line%%[![:space:]]*}"}"
        dir_path="${dir_path%"${dir_path##*[![:space:]]}"}"
        
        [[ -z "$dir_path" ]] && continue
        
        # 计算缩进级别用于显示
        local depth=$(echo "$dir_path" | tr -cd '/' | wc -c)
        local indent=""
        for ((i=0; i<depth; i++)); do
            indent="  $indent"
        done
        
        local dir_name=$(basename "$dir_path")
        echo "   $indent├── 📁 ${CYAN}$dir_name${NC}"
        ((count++))
    done < "$template_file"
    
    echo ""
    _dirtree_log_success "预览完成，将创建 ${count} 个目录"
    echo ""
    echo "💡 下一步操作:"
    echo "   🚀 立即创建: ${CYAN}dirtree_create <目标目录> $template_name${NC}"
    echo "   ✅ 验证模板: ${CYAN}dirtree_validate $template_name${NC}"
}

# 验证模板文件格式
dirtree_validate() {
    local template_file="$1"
    
    if [[ -z "$template_file" ]]; then
        _dirtree_log_error "请指定模板文件！"
        echo "📖 用法: ${CYAN}dirtree_validate <模板文件>${NC}"
        return 1
    fi
    
    # 🔍 如果是模板名称，转换为完整路径
    if [[ ! -f "$template_file" && ! "$template_file" =~ / ]]; then
        template_file="${DIRTREE_TEMPLATES_DIR}/${template_file}.dirs"
    fi
    
    if [[ ! -f "$template_file" ]]; then
        _dirtree_log_error "模板文件不存在: $template_file"
        return 1
    fi
    
    _dirtree_log_header "验证模板格式"
    echo "📁 文件: ${CYAN}$(basename "$template_file")${NC}"
    echo ""
    
    local line_count=0
    local valid_dirs=0
    local errors=0
    local warnings=0
    
    echo "🔍 正在检查模板格式..."
    echo ""
    
    while IFS= read -r line; do
        ((line_count++))
        
        # 跳过空行和注释
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # 清理路径
        local dir_path="${line#"${line%%[![:space:]]*}"}"
        dir_path="${dir_path%"${dir_path##*[![:space:]]}"}"
        
        [[ -z "$dir_path" ]] && continue
        
        # ✅ 验证路径格式
        if [[ "$dir_path" =~ ^/ ]]; then
            _dirtree_log_error "第 $line_count 行: 不允许绝对路径 '$dir_path'"
            ((errors++))
        elif [[ "$dir_path" =~ \.\. ]]; then
            _dirtree_log_error "第 $line_count 行: 不允许包含 .. 的路径 '$dir_path'"
            ((errors++))
        elif [[ "$dir_path" =~ [[:space:]] ]]; then
            _dirtree_log_warning "第 $line_count 行: 路径包含空格，可能导致兼容性问题 '$dir_path'"
            ((warnings++))
        elif [[ ${#dir_path} -gt 200 ]]; then
            _dirtree_log_warning "第 $line_count 行: 路径过长（${#dir_path} 字符）'$dir_path'"
            ((warnings++))
        else
            ((valid_dirs++))
        fi
    done < "$template_file"
    
    echo ""
    echo "📊 验证结果:"
    echo "   📄 总行数: $line_count"
    echo "   ✅ 有效目录: $valid_dirs"
    echo "   ⚠️  警告: $warnings"
    echo "   ❌ 错误: $errors"
    echo ""
    
    if [[ $errors -eq 0 ]]; then
        if [[ $warnings -eq 0 ]]; then
            _dirtree_log_success "模板格式完美！ 🎉"
        else
            _dirtree_log_success "模板格式有效，但有 $warnings 个警告"
        fi
        echo "💡 你可以安全地使用此模板: ${CYAN}dirtree_create <目标目录> $(basename "$template_file" .dirs)${NC}"
        return 0
    else
        _dirtree_log_error "发现 $errors 个错误，请修复后再使用"
        return 1
    fi
}

# =========================================================================
# 📊 目录结构分析功能
# =========================================================================

# 显示目录结构统计
dirtree_status() {
    local target_dir="${1:-$PWD}"
    
    if [[ ! -d "$target_dir" ]]; then
        _dirtree_log_error "目录不存在: $target_dir"
        return 1
    fi
    
    _dirtree_log_header "目录结构分析"
    echo "📁 分析目录: ${CYAN}$target_dir${NC}"
    echo ""
    
    # 📊 基础统计
    echo "📈 基础统计:"
    local total_dirs=$(find "$target_dir" -type d 2>/dev/null | wc -l)
    local total_files=$(find "$target_dir" -type f 2>/dev/null | wc -l)
    local total_size=$(du -sh "$target_dir" 2>/dev/null | cut -f1 || echo "未知")
    
    echo "   📁 目录数量: ${CYAN}$total_dirs${NC}"
    echo "   📄 文件数量: ${CYAN}$total_files${NC}"
    echo "   💾 总大小: ${CYAN}$total_size${NC}"
    echo ""
    
    # 📏 深度统计
    echo "📏 结构深度:"
    local base_depth=$(echo "$target_dir" | tr "/" "\n" | wc -l)
    local max_depth_raw=$(find "$target_dir" -type d -exec bash -c 'echo $(echo "{}" | tr "/" "\n" | wc -l)' \; 2>/dev/null | sort -n | tail -1)
    local max_depth=$((max_depth_raw - base_depth + 1))
    echo "   📐 最大深度: ${CYAN}$max_depth${NC} 层"
    
    # 🗂️ 顶级目录分析
    echo ""
    echo "🗂️  顶级目录分析:"
    local top_dirs=0
    for dir in "$target_dir"/*/; do
        if [[ -d "$dir" ]]; then
            local dir_name=$(basename "$dir")
            local sub_count=$(find "$dir" -mindepth 1 -type d 2>/dev/null | wc -l)
            local file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
            echo "   📂 ${CYAN}$dir_name${NC}: $sub_count 个子目录, $file_count 个文件"
            ((top_dirs++))
        fi
    done
    
    if [[ $top_dirs -eq 0 ]]; then
        echo "   🤷 无顶级子目录"
    fi
    
    # 📂 空目录统计
    echo ""
    local empty_dirs=$(find "$target_dir" -type d -empty 2>/dev/null | wc -l)
    if [[ $empty_dirs -gt 0 ]]; then
        echo "🗑️  空目录检测:"
        echo "   📊 发现 ${YELLOW}$empty_dirs${NC} 个空目录"
        if [[ $empty_dirs -le 5 ]]; then
            find "$target_dir" -type d -empty 2>/dev/null | sed 's/^/   📂 /'
        else
            find "$target_dir" -type d -empty 2>/dev/null | head -3 | sed 's/^/   📂 /'
            echo "   ... 还有 $((empty_dirs - 3)) 个空目录"
        fi
        echo "   💡 使用 ${CYAN}dirtree_cleanup \"$target_dir\"${NC} 清理空目录"
    else
        echo "✨ 太棒了！没有发现空目录"
    fi
    
    # 📅 最近活动
    echo ""
    echo "📅 最近活动:"
    local newest_file=$(find "$target_dir" -type f -exec stat -f '%m %N' {} \; 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || \
                       find "$target_dir" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
    if [[ -n "$newest_file" ]]; then
        echo "   🆕 最新文件: ${CYAN}$(basename "$newest_file")${NC}"
        echo "   📍 位置: $(dirname "$newest_file")"
    else
        echo "   🤷 未找到文件"
    fi
    
    echo ""
    echo "💡 可用操作:"
    echo "   🧹 清理空目录: ${CYAN}dirtree_cleanup \"$target_dir\"${NC}"
    echo "   📝 生成文档: ${CYAN}dirtree_generate_docs \"$target_dir\"${NC}"
    echo "   💾 备份结构: ${CYAN}dirtree_backup \"$target_dir\"${NC}"
}

# 清理空目录
dirtree_cleanup() {
    local target_dir="${1:-$PWD}"
    
    if [[ ! -d "$target_dir" ]]; then
        _dirtree_log_error "目录不存在: $target_dir"
        return 1
    fi
    
    _dirtree_log_header "空目录清理工具"
    echo "📁 清理目录: ${CYAN}$target_dir${NC}"
    echo ""
    
    # 🔍 查找空目录
    local empty_dirs=()
    while IFS= read -r -d '' dir; do
        empty_dirs+=("$dir")
    done < <(find "$target_dir" -type d -empty -print0 2>/dev/null)
    
    if [[ ${#empty_dirs[@]} -eq 0 ]]; then
        _dirtree_log_success "恭喜！未发现空目录 🎉"
        return 0
    fi
    
    echo "🗑️  发现 ${#empty_dirs[@]} 个空目录:"
    for dir in "${empty_dirs[@]}"; do
        local relative_path="${dir#$target_dir/}"
        [[ "$relative_path" == "$target_dir" ]] && relative_path="."
        echo "   📂 $relative_path"
    done
    
    echo ""
    echo "⚠️  注意: 删除操作无法撤销！"
    read -r -p "🤔 是否删除这些空目录? [y/N]: " response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo "🧹 正在清理..."
        local cleaned=0
        local failed=0
        
        for dir in "${empty_dirs[@]}"; do
            local relative_path="${dir#$target_dir/}"
            [[ "$relative_path" == "$target_dir" ]] && relative_path="."
            
            if rmdir "$dir" 2>/dev/null; then
                echo "   ✅ 已删除: $relative_path"
                ((cleaned++))
            else
                echo "   ❌ 删除失败: $relative_path"
                ((failed++))
            fi
        done
        
        echo ""
        if [[ $failed -eq 0 ]]; then
            _dirtree_log_success "清理完成！成功删除 $cleaned 个空目录 🎉"
        else
            _dirtree_log_warning "清理完成，成功删除 $cleaned 个，失败 $failed 个"
        fi
    else
        _dirtree_log_info "已取消清理操作"
    fi
}

# =========================================================================
# 📝 文档生成功能
# =========================================================================

# 生成模板文件的目录树结构并追加到文件末尾
dirtree_generate_docs() {
    local template_name="$1"
    
    if [[ -z "$template_name" ]]; then
        _dirtree_log_error "请指定模板名称！"
        echo "📖 用法: ${CYAN}dirtree_generate_docs <模板名称>${NC}"
        echo "💡 示例: ${CYAN}dirtree_generate_docs documents${NC}"
        echo "💡 使用 ${CYAN}dirtree_list${NC} 查看可用模板"
        return 1
    fi
    
    local template_file="${DIRTREE_TEMPLATES_DIR}/${template_name}.dirs"
    
    if [[ ! -f "$template_file" ]]; then
        _dirtree_log_error "模板文件不存在: $template_name"
        echo "💡 使用 ${CYAN}dirtree_list${NC} 查看可用模板"
        return 1
    fi
    
    _dirtree_log_header "生成模板目录树文档"
    echo "📋 模板文件: ${CYAN}$template_name${NC}"
    echo "📁 文件路径: ${CYAN}$template_file${NC}"
    echo ""
    
    # 🔍 检查文件是否已包含目录树结构
    if grep -q "# 目录用途说明" "$template_file"; then
        echo "⚠️  检测到文件已包含目录树结构"
        read -r -p "🤔 是否覆盖现有内容? [y/N]: " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            _dirtree_log_info "操作已取消"
            return 0
        fi
        
        # 删除现有的目录树部分
        sed -i.bak '/# =========================================================================/,$d' "$template_file"
        _dirtree_log_info "已移除现有目录树结构"
    fi
    
    echo "📝 正在解析模板文件并生成目录树..."
    
    # 🌳 生成目录树结构并追加到文件
    _generate_tree_from_template "$template_file"
    
    _dirtree_log_success "目录树文档生成完成！"
    echo "📄 已追加到: ${CYAN}$template_file${NC}"
    echo ""
    echo "💡 你可以："
    echo "   👀 查看文件: ${CYAN}cat \"$template_file\"${NC}"
    echo "   📝 编辑文件: ${CYAN}\$EDITOR \"$template_file\"${NC}"
    echo "   🚀 创建结构: ${CYAN}dirtree_create <目标目录> $template_name${NC}"
}

# 从模板文件生成目录树结构
_generate_tree_from_template() {
    local template_file="$1"
    
    # 📊 收集所有目录路径
    local -a all_paths=()
    local dir_count=0
    
    while IFS= read -r line; do
        # 跳过空行和注释
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # 清理路径
        local dir_path="${line#"${line%%[![:space:]]*}"}"
        dir_path="${dir_path%"${dir_path##*[![:space:]]}"}"
        
        [[ -z "$dir_path" ]] && continue
        
        all_paths+=("$dir_path")
        ((dir_count++))
    done < "$template_file"
    
    if [[ $dir_count -eq 0 ]]; then
        _dirtree_log_warning "模板文件中未找到有效的目录路径"
        return 1
    fi
    
    # 📝 追加目录树结构到文件
    cat >> "$template_file" << 'EOF'

# =========================================================================
# 目录用途说明
# =========================================================================
#
EOF
    
    # 🌳 生成简化的树形结构
    _generate_simple_tree_structure "${all_paths[@]}" >> "$template_file"
    
    # 📊 添加统计信息
    local max_depth=0
    for path in "${all_paths[@]}"; do
        local depth=$(echo "$path" | tr -cd '/' | wc -c)
        ((depth > max_depth)) && max_depth=$depth
    done
    
    cat >> "$template_file" << EOF
#
# =========================================================================
# 维护建议
# =========================================================================
# 📅 定期维护计划：
# - 每日：新增文档归类存放
# - 每周：整理工作文档，更新项目状态
# - 每月：个人资料整理，过期内容移至归档
# - 每季：归档系统清理，删除无用文件
# - 每年：系统结构优化，备份重要数据
#
# 🏷️ 命名规范：
# - 目录：数字前缀_英文名称 (如：01_Projects)
# - 文件：日期前缀_描述性名称 (如：2025-06-14_meeting-notes.md)
# - 项目：项目名称_版本号 (如：ProjectA_v1.0)
#
# 📊 结构统计：
# - 总目录数：$dir_count 个
# - 最大深度：$((max_depth + 1)) 层
# - 生成时间：$(date '+%Y-%m-%d %H:%M:%S')
#
# 🔐 安全提醒：
# - 敏感信息加密存储
# - 定期备份到多个位置
# - 访问权限合理设置
# - 版本控制重要文档
#
# =========================================================================
EOF
    
    _dirtree_log_info "已添加 $dir_count 个目录，最大深度 $((max_depth + 1)) 层"
}

# 生成简化的目录树形结构
_generate_simple_tree_structure() {
    local -a paths=("$@")
    local current_root=""
    
    for path in "${paths[@]}"; do
        # 获取顶级目录
        local root_dir="${path%%/*}"
        
        # 如果是新的根目录，添加分组标题
        if [[ "$root_dir" != "$current_root" ]]; then
            [[ -n "$current_root" ]] && echo "#"
            
            # 只显示目录名，不添加特定的说明
            echo "# 📁 $root_dir"
            
            current_root="$root_dir"
        fi
        
        # 简单的缩进显示，不使用复杂的树形符号
        local depth=$(echo "$path" | tr -cd '/' | wc -c)
        local indent=""
        for ((i=0; i<=depth; i++)); do
            indent="  $indent"
        done
        
        local dir_name=$(basename "$path")
        echo "#$indent├── $dir_name"
    done
}

# 删除不再需要的复杂函数

# 手动生成目录树（保留作为备用功能）
_manual_tree_generation() {
    local dir="$1"
    find "$dir" -type d | sort | sed -e "s|^$dir||" -e '/^$/d' -e 's|^/||' | \
    awk '{
        depth = gsub(/\//, "/", $0)
        for(i=1; i<=depth; i++) printf "  "
        print "├── " $NF "/"
    }'
}

# =========================================================================
# 💾 备份功能
# =========================================================================

# 备份目录结构
dirtree_backup() {
    local source_dir="$1"
    
    if [[ -z "$source_dir" ]]; then
        _dirtree_log_error "请指定要备份的目录！"
        echo "📖 用法: ${CYAN}dirtree_backup <源目录>${NC}"
        echo "💡 示例: ${CYAN}dirtree_backup ~/Documents${NC}"
        return 1
    fi
    
    if [[ ! -d "$source_dir" ]]; then
        _dirtree_log_error "源目录不存在: $source_dir"
        return 1
    fi
    
    _dirtree_log_header "备份目录结构"
    echo "📁 源目录: ${CYAN}$source_dir${NC}"
    echo ""
    
    # 🏠 创建备份目录
    local backup_base_dir="$HOME/dirtree_backups"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local source_name=$(basename "$source_dir")
    local backup_dir="${backup_base_dir}/${source_name}_${timestamp}"
    
    if [[ ! -d "$backup_base_dir" ]]; then
        mkdir -p "$backup_base_dir"
        _dirtree_log_info "已创建备份根目录: $backup_base_dir"
    fi
    
    echo "📦 备份位置: ${CYAN}$backup_dir${NC}"
    echo ""
    
    # 🗃️ 创建备份文件
    local backup_file="${backup_dir}.tar.gz"
    
    _dirtree_log_info "正在创建目录结构备份..."
    
    # 只备份目录结构（不包含文件内容）
    if tar -czf "$backup_file" -C "$(dirname "$source_dir")" \
       --exclude='*' \
       --include='*/' \
       "$(basename "$source_dir")" 2>/dev/null; then
        
        echo ""
        _dirtree_log_success "备份创建完成！"
        echo ""
        echo "📊 备份信息:"
        echo "   📁 源目录: $source_dir"
        echo "   📦 备份文件: $backup_file"
        echo "   ⏱️  创建时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "   📏 文件大小: $(du -h "$backup_file" | cut -f1)"
        echo ""
        echo "💡 恢复命令:"
        echo "   ${CYAN}tar -xzf \"$backup_file\" -C /path/to/restore/${NC}"
        
    else
        _dirtree_log_error "备份创建失败！"
        return 1
    fi
}