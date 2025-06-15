#!/usr/bin/env bash

# =========================================================================
# build_dir_tree.sh - dirtree 交互式目录构建系统
# =========================================================================
#
# 🌳 目录结构创建工具的交互式界面
# 📁 与 dotfiles 项目集成使用
#
# 版本：v1.0
# 创建时间：2025-06-15
#
# =========================================================================

# 🎨 颜色定义 - 只保留基本颜色用于图标
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 📂 脚本路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FUNCTIONS_FILE="${SCRIPT_DIR}/functions.zsh"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

# 🔧 加载功能函数
if [[ -f "$FUNCTIONS_FILE" ]]; then
    source "$FUNCTIONS_FILE"
    # 确保 functions.zsh 中的模板目录路径与当前脚本一致
    DIRTREE_TEMPLATES_DIR="$TEMPLATES_DIR"
else
    echo "❌ 错误: 找不到 functions.zsh 文件"
    echo "请确保 functions.zsh 在同一目录下"
    exit 1
fi

# 📝 全局变量
SELECTED_TEMPLATE=""
TARGET_DIRECTORY=""
TEMPLATE_LIST=()

# =========================================================================
# 🖥️ 界面显示函数
# =========================================================================

# 清屏函数
clear_screen() {
    clear
}

# 显示主菜单
show_main_menu() {
    clear_screen
    echo "🌳 ========================================================"
    echo "🌳              DIRTREE 目录结构构建工具"
    echo "🌳 ========================================================"
    echo ""
    echo "🎯 主菜单 - 请选择操作:"
    echo ""
    echo "   1️⃣  快速开始          🚀 创建目录结构"
    echo "   2️⃣  模板管理          📋 管理和预览模板文件"
    echo "   q   退出程序          👋 安全退出"
    echo ""
    echo "========================================================"
}

# 显示模板选择界面
show_template_selection() {
    clear_screen
    echo "🚀 ========================================================"
    echo "🚀                  选择模板"
    echo "🚀 ========================================================"
    echo ""
    echo "📋 请使用方向键选择模板，回车确认:"
    echo ""
    
    # 加载模板列表
    load_template_list
    
    if [[ ${#TEMPLATE_LIST[@]} -eq 0 ]]; then
        echo "   ❌ 未找到任何模板文件"
        echo ""
        echo "════════════════════════════════════════════════════════════"
        echo "💡 按任意键返回主菜单"
        read -n1
        return 1
    fi
}

# 显示模板菜单
display_template_menu() {
    local current_index="$1"
    
    # 移动光标到模板列表开始位置
    echo -e "\033[8;1H"  # 移动到第8行第1列
    echo -e "\033[J"     # 清除从当前位置到屏幕末尾的内容
    
    echo "   ┌─────────────────────────────────────────────────────┐"
    
    for ((i=0; i<${#TEMPLATE_LIST[@]}; i++)); do
        if [[ $i -eq $current_index ]]; then
            echo " ► │  ${TEMPLATE_LIST[$i]}$(printf "%*s" $((47 - ${#TEMPLATE_LIST[$i]})) "")│"
        else
            echo "   │  ${TEMPLATE_LIST[$i]}$(printf "%*s" $((47 - ${#TEMPLATE_LIST[$i]})) "")│"
        fi
    done
    
    echo "   └─────────────────────────────────────────────────────┘"
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "💡 操作提示:"
    echo "   ↑↓  选择模板    | Enter  确认选择  | 0  返回主菜单"
    echo "════════════════════════════════════════════════════════════"
}

# 显示目标目录输入界面
show_directory_input() {
    clear_screen
    echo "🚀 ========================================================"
    echo "🚀                设置目标目录"
    echo "🚀 ========================================================"
    echo ""
    echo "✅ 已选择模板: $SELECTED_TEMPLATE"
    echo ""
    echo "⚠️  重要提醒:"
    echo "   • 必须输入完整的绝对路径"
    echo "   • 目标目录必须为空或不存在"
    echo "   • 将会在此目录下创建模板结构"
    echo ""
    echo "💡 示例路径:"
    echo "   /Users/phil/Documents/MyProject"
    echo "   /home/user/workspace/docs"
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "输入完成后按 Enter 继续，输入 0 返回主菜单"
    echo ""
}

# 显示创建确认界面
show_creation_confirmation() {
    clear_screen
    echo "🚀 ========================================================"
    echo "🚀                创建确认"
    echo "🚀 ========================================================"
    echo ""
    echo "🎯 创建配置信息:"
    echo ""
    echo "   📋 选择模板: $SELECTED_TEMPLATE"
    echo "   📁 目标目录: $TARGET_DIRECTORY"
    
    # 获取预计创建的目录数量
    local template_file="${TEMPLATES_DIR}/${SELECTED_TEMPLATE}.dirs"
    local dir_count=0
    if [[ -f "$template_file" ]]; then
        dir_count=$(grep -v -E '^[[:space:]]*$|^[[:space:]]*#' "$template_file" | wc -l | tr -d ' ')
    fi
    echo "   📊 预计创建: $dir_count 个目录"
    echo ""
    echo "🔧 可修改选项:"
    echo ""
    echo "   1️⃣  重新选择模板      📋 返回模板选择界面"
    echo "   2️⃣  修改目标目录      📁 重新输入目录路径"
    echo "   3️⃣  预览目录结构      👁️  查看将要创建的目录"
    echo ""
    echo "🎯 执行选项:"
    echo ""
    echo "   Enter 确认创建        ✅ 开始执行创建操作"
    echo "   0️⃣  返回主菜单        ↩️  取消并回到主界面"
    echo ""
    echo "========================================================"
}

# 显示模板管理菜单
show_template_management() {
    clear_screen
    echo "📋 ========================================================"
    echo "📋                    模板管理"
    echo "📋 ========================================================"
    echo ""
    echo "🛠️ 模板操作:"
    echo ""
    echo "   1️⃣  列出所有模板      📝 显示所有可用模板"
    echo "   2️⃣  预览模板结构      👁️  查看模板目录树"
    echo "   3️⃣  验证模板格式      ✅ 检查模板文件合法性"
    echo ""
    echo "   0️⃣  返回主菜单        ↩️  回到主界面"
    echo ""
    echo "========================================================"
}

# =========================================================================
# 🔧 核心功能函数
# =========================================================================

# 加载模板列表
load_template_list() {
    TEMPLATE_LIST=()
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        return 1
    fi
    
    for template in "$TEMPLATES_DIR"/*.dirs; do
        if [[ -f "$template" ]]; then
            local name=$(basename "$template" .dirs)
            TEMPLATE_LIST+=("$name")
        fi
    done
}

# 验证目标目录
validate_target_directory() {
    local dir="$1"
    
    # 检查是否为绝对路径
    if [[ ! "$dir" =~ ^/ ]]; then
        echo "❌ 错误: 必须输入绝对路径"
        return 1
    fi
    
    # 检查路径长度
    if [[ ${#dir} -gt 200 ]]; then
        echo "❌ 错误: 路径过长"
        return 1
    fi
    
    # 检查父目录是否存在
    local parent_dir=$(dirname "$dir")
    if [[ ! -d "$parent_dir" ]]; then
        echo "❌ 错误: 父目录不存在: $parent_dir"
        return 1
    fi
    
    # 检查目标目录是否为空（智能检查，忽略系统文件）
    if [[ -d "$dir" ]]; then
        # 获取目录中的文件，排除系统文件
        local files=$(ls -A "$dir" 2>/dev/null | grep -v -E '^\.DS_Store$|^\.localized$|^Thumbs\.db$|^desktop\.ini$' | head -1)
        if [[ -n "$files" ]]; then
            echo "❌ 错误: 目标目录不为空: $dir"
            echo "💡 提示: 目录中包含有效文件，请选择空目录或不存在的目录"
            return 1
        fi
    fi
    
    return 0
}

# 执行目录创建
execute_creation() {
    clear_screen
    echo "🚀 ========================================================"
    echo "🚀                执行目录创建"
    echo "🚀 ========================================================"
    echo ""
    echo "🎯 开始创建目录结构..."
    echo "   📋 模板: $SELECTED_TEMPLATE"
    echo "   📁 目标: $TARGET_DIRECTORY"
    echo ""
    
    # 创建目标目录（如果不存在）
    if [[ ! -d "$TARGET_DIRECTORY" ]]; then
        if ! mkdir -p "$TARGET_DIRECTORY" 2>/dev/null; then
            echo "❌ 创建目录失败: $TARGET_DIRECTORY"
            echo ""
            echo "════════════════════════════════════════════════════════════"
            echo "按任意键返回主菜单..."
            read -n1
            return 1
        fi
    fi
    
    # 调用 functions.zsh 中的创建函数
    echo "🔄 正在创建目录结构..."
    echo ""
    
    # 重定向输出，避免与界面冲突
    local temp_log="/tmp/dirtree_creation.log"
    if dirtree_create "$TARGET_DIRECTORY" "$SELECTED_TEMPLATE" > "$temp_log" 2>&1; then
        # 提取统计信息 - 更新正则表达式
        local created_count=$(grep -o "新建目录: [0-9]\+" "$temp_log" | grep -o "[0-9]\+" | tail -1 || echo "0")
        local skipped_count=$(grep -o "已存在: [0-9]\+" "$temp_log" | grep -o "[0-9]\+" | tail -1 || echo "0") 
        local total_count=$(grep -o "总目录数: [0-9]\+" "$temp_log" | grep -o "[0-9]\+" | tail -1)
        
        # 如果没有从日志中获取到数据，直接计算模板文件中的目录数
        if [[ -z "$total_count" || "$total_count" == "0" ]]; then
            local template_file="${TEMPLATES_DIR}/${SELECTED_TEMPLATE}.dirs"
            if [[ -f "$template_file" ]]; then
                total_count=$(grep -v -E '^[[:space:]]*$|^[[:space:]]*#' "$template_file" | wc -l | tr -d ' ')
            else
                total_count="0"
            fi
        fi
        
        # 如果还是没有创建数据，尝试不同的提取方式
        if [[ -z "$created_count" || "$created_count" == "0" ]]; then
            created_count=$(grep -c "mkdir.*成功\|创建.*成功\|SUCCESS" "$temp_log" 2>/dev/null || echo "0")
        fi
        
        local failed_count=$((total_count - created_count - skipped_count))
        [[ $failed_count -lt 0 ]] && failed_count=0
        
        echo "✅ 创建完成!"
        echo ""
        echo "📊 创建统计:"
        echo "   ✅ 创建成功: $created_count 个目录"
        echo "   ❌ 创建失败: $failed_count 个目录"  
        echo "   📁 总计处理: $total_count 个目录"
        echo ""
        echo "💡 下一步操作:"
        echo "   📊 查看结构: dirtree_status \"$TARGET_DIRECTORY\""
        echo "   🧹 清理工具: dirtree_cleanup \"$TARGET_DIRECTORY\""
    else
        echo "❌ 创建过程中出现错误"
        echo ""
        echo "错误详情:"
        cat "$temp_log"
    fi
    
    # 清理临时文件
    [[ -f "$temp_log" ]] && rm -f "$temp_log"
    
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "按任意键返回主菜单..."
    read -n1
}

# =========================================================================
# 📋 模板管理功能
# =========================================================================

# 列出所有模板
list_all_templates() {
    clear_screen
    echo "📋 ========================================================"
    echo "📋                 所有可用模板"
    echo "📋 ========================================================"
    echo ""
    echo "📚 模板清单:"
    echo ""
    
    load_template_list
    
    if [[ ${#TEMPLATE_LIST[@]} -eq 0 ]]; then
        echo "   ❌ 未找到任何模板文件"
    else
        for ((i=0; i<${#TEMPLATE_LIST[@]}; i++)); do
            echo "   $((i+1)). ${TEMPLATE_LIST[$i]}"
        done
        echo ""
        echo "✅ 共找到 ${#TEMPLATE_LIST[@]} 个可用模板"
    fi
    
    echo ""
    echo "💡 操作说明:"
    echo "   输入模板名查看预览或验证"
    echo "   或选择其他操作"
    echo ""
    echo "   0️⃣  返回上级菜单      ↩️  回到模板管理"
    echo ""
    echo "========================================================"
}

# 预览模板结构
preview_template() {
    local template_name="$1"
    
    if [[ -z "$template_name" ]]; then
        # 如果没有传入模板名，显示模板选择界面
        load_template_list
        if [[ ${#TEMPLATE_LIST[@]} -eq 0 ]]; then
            echo "❌ 未找到任何模板文件"
            echo "按任意键返回模板管理..."
            read -n1
            return 1
        fi
        
        local selected_index=0
        while true; do
            clear_screen
            echo "📋 ========================================================"
            echo "📋                选择要预览的模板"
            echo "📋 ========================================================"
            echo ""
            echo "📋 请使用方向键选择模板，回车确认:"
            echo ""
            echo "   ┌─────────────────────────────────────────────────────┐"
            
            for ((i=0; i<${#TEMPLATE_LIST[@]}; i++)); do
                if [[ $i -eq $selected_index ]]; then
                    echo " ► │  ${TEMPLATE_LIST[$i]}$(printf "%*s" $((47 - ${#TEMPLATE_LIST[$i]})) "")│"
                else
                    echo "   │  ${TEMPLATE_LIST[$i]}$(printf "%*s" $((47 - ${#TEMPLATE_LIST[$i]})) "")│"
                fi
            done
            
            echo "   └─────────────────────────────────────────────────────┘"
            echo ""
            echo "════════════════════════════════════════════════════════════"
            echo "💡 操作提示:"
            echo "   ↑↓  选择模板    | Enter  确认选择  | 0  返回模板管理"
            echo "════════════════════════════════════════════════════════════"
            
            read -rsn1 key
            case "$key" in
                $'\e')  # ESC 序列开始
                    read -rsn2 key
                    case "$key" in
                        '[A')  # 上箭头
                            ((selected_index > 0)) && ((selected_index--))
                            ;;
                        '[B')  # 下箭头
                            ((selected_index < ${#TEMPLATE_LIST[@]} - 1)) && ((selected_index++))
                            ;;
                    esac
                    ;;
                '')  # Enter
                    template_name="${TEMPLATE_LIST[$selected_index]}"
                    break
                    ;;
                '0')  # 返回模板管理
                    return 1
                    ;;
            esac
        done
    fi
    
    [[ -z "$template_name" ]] && return 1
    
    clear_screen
    echo "📋 ========================================================"
    echo "📋              模板预览: $template_name"
    echo "📋 ========================================================"
    echo ""
    
    # 检查模板是否存在
    local template_file="${TEMPLATES_DIR}/${template_name}.dirs"
    if [[ ! -f "$template_file" ]]; then
        echo "❌ 模板不存在: $template_name"
        echo "💡 使用模板管理菜单的选项1查看可用模板"
    else
        # 直接读取模板文件并生成简洁的目录树
        echo "🗂️  将要创建的目录结构:"
        echo ""
        
        local count=0
        local current_section=""
        local indent=""
        
        while IFS= read -r line; do
            # 跳过空行
            [[ -z "$line" ]] && continue
            
            # 检测分区标题
            if [[ "$line" =~ ^#[[:space:]]*===[[:space:]]*(.+)[[:space:]]*===[[:space:]]*$ ]]; then
                local section="${BASH_REMATCH[1]}"
                if [[ "$section" != "$current_section" ]]; then
                    echo ""
                    echo "📂 $section"
                    current_section="$section"
                fi
                continue
            fi
            
            # 跳过其他注释
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            
            # 清理路径
            local dir_path="${line#"${line%%[![:space:]]*}"}"
            dir_path="${dir_path%"${dir_path##*[![:space:]]}"}"
            
            [[ -z "$dir_path" ]] && continue
            
            # 计算缩进级别
            local depth=$(echo "$dir_path" | tr -cd '/' | wc -c)
            indent=""
            for ((i=1; i<depth; i++)); do
                indent="   $indent"
            done
            
            local dir_name=$(basename "$dir_path")
            echo "   $indent├── 📁 $dir_name"
            ((count++))
        done < "$template_file"
        
        echo ""
        echo "📊 统计: 共 $count 个目录"
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "按任意键返回模板管理..."
    read -n1
}

# 验证模板格式
validate_template() {
    local template_name="$1"
    
    if [[ -z "$template_name" ]]; then
        echo -n "📝 请输入要验证的模板名: "
        read -r template_name
    fi
    
    [[ -z "$template_name" ]] && return 1
    
    clear_screen
    echo "📋 ========================================================"
    echo "📋              模板验证: $template_name"
    echo "📋 ========================================================"
    echo ""
    
    # 检查模板是否存在
    local template_file="${TEMPLATES_DIR}/${template_name}.dirs"
    if [[ ! -f "$template_file" ]]; then
        echo "❌ 模板不存在: $template_name"
        echo "💡 使用模板管理菜单的选项1查看可用模板"
    else
        # 调用 functions.zsh 中的验证函数，重定向输出
        local temp_log="/tmp/dirtree_validate.log"
        if dirtree_validate "$template_name" > "$temp_log" 2>&1; then
            # 只显示验证结果，过滤掉详细的日志信息
            grep -E "验证结果|统计信息|有效目录|警告|错误|模板格式" "$temp_log" || cat "$temp_log"
        else
            echo "❌ 验证过程中出现错误"
            cat "$temp_log"
        fi
        
        # 清理临时文件
        [[ -f "$temp_log" ]] && rm -f "$temp_log"
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "按任意键返回模板管理..."
    read -n1
}

# =========================================================================
# 🎮 交互控制函数
# =========================================================================

# 模板选择交互
template_selection_interactive() {
    load_template_list
    
    if [[ ${#TEMPLATE_LIST[@]} -eq 0 ]]; then
        echo "❌ 未找到任何模板文件"
        echo "按任意键返回主菜单"
        read -n1
        return 1
    fi
    
    local selected_index=0
    show_template_selection
    display_template_menu "$selected_index"
    
    while true; do
        read -rsn1 key
        
        case "$key" in
            $'\e')  # ESC 序列开始
                read -rsn2 key
                case "$key" in
                    '[A')  # 上箭头
                        ((selected_index > 0)) && ((selected_index--))
                        display_template_menu "$selected_index"
                        ;;
                    '[B')  # 下箭头
                        ((selected_index < ${#TEMPLATE_LIST[@]} - 1)) && ((selected_index++))
                        display_template_menu "$selected_index"
                        ;;
                esac
                ;;
            '')  # Enter
                SELECTED_TEMPLATE="${TEMPLATE_LIST[$selected_index]}"
                return 0
                ;;
            '0')  # 返回主菜单
                return 1
                ;;
        esac
    done
}

# 目标目录输入交互
directory_input_interactive() {
    show_directory_input
    
    while true; do
        echo -n "📁 请输入目标目录的完整路径: "
        read -r input_dir
        
        if [[ "$input_dir" == "0" ]]; then
            return 1
        fi
        
        if [[ -z "$input_dir" ]]; then
            echo "⚠️  请输入目录路径"
            continue
        fi
        
        if validate_target_directory "$input_dir"; then
            TARGET_DIRECTORY="$input_dir"
            return 0
        fi
        
        echo "按任意键继续..."
        read -n1
        show_directory_input
    done
}

# 创建确认交互
confirmation_interactive() {
    while true; do
        show_creation_confirmation
        echo -n "请输入选项 [1-3/Enter/0]: "
        read -r choice
        
        case "$choice" in
            1)  # 重新选择模板
                if template_selection_interactive; then
                    continue
                else
                    return 1
                fi
                ;;
            2)  # 修改目标目录
                if directory_input_interactive; then
                    continue
                else
                    return 1
                fi
                ;;
            3)  # 预览目录结构
                preview_template "$SELECTED_TEMPLATE"
                ;;
            ""|" ")  # Enter 或空格 - 确认创建
                return 0
                ;;
            0)  # 返回主菜单
                return 1
                ;;
            *)
                echo "❌ 无效选项，请重新选择"
                sleep 1
                ;;
        esac
    done
}

# =========================================================================
# 🚀 主程序流程
# =========================================================================

# 快速开始流程
quick_start() {
    # 步骤1: 选择模板
    if ! template_selection_interactive; then
        return 1
    fi
    
    # 步骤2: 输入目标目录
    if ! directory_input_interactive; then
        return 1
    fi
    
    # 步骤3: 确认创建
    if ! confirmation_interactive; then
        return 1
    fi
    
    # 步骤4: 执行创建
    execute_creation
}

# 模板管理流程
template_management() {
    while true; do
        show_template_management
        echo -n "请输入选项 [0-3]: "
        read -r choice
        
        case "$choice" in
            1)  # 列出所有模板
                list_all_templates
                echo -n "请输入模板名或选项 [0]: "
                read -r template_choice
                if [[ "$template_choice" != "0" && -n "$template_choice" ]]; then
                    preview_template "$template_choice"
                fi
                ;;
            2)  # 预览模板结构
                preview_template
                ;;
            3)  # 验证模板格式
                validate_template
                ;;
            0)  # 返回主菜单
                return 0
                ;;
            *)
                echo "❌ 无效选项，请重新选择"
                sleep 1
                ;;
        esac
    done
}

# 主程序入口
main() {
    # 检查模板目录
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        echo "❌ 错误: 模板目录不存在: $TEMPLATES_DIR"
        exit 1
    fi
    
    while true; do
        show_main_menu
        echo -n "请输入选项 [1-2/q]: "
        read -r choice
        
        case "$choice" in
            1)  # 快速开始
                quick_start
                ;;
            2)  # 模板管理
                template_management
                ;;
            q|Q|quit|exit)  # 退出程序 - 支持多种退出方式
                clear_screen
                echo "👋 感谢使用 DIRTREE 工具！"
                echo "🌳 愿你的目录结构井然有序！"
                exit 0
                ;;
            *)
                echo "❌ 无效选项，请重新选择"
                sleep 1
                ;;
        esac
    done
}

# 运行主程序
main