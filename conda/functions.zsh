#!/usr/bin/env zsh
# ==============================================================================
# Conda 函数集 - 增强原生 conda 功能
# 遵循 Python 命名约定，使用 snake_case 格式
# ==============================================================================

# ------------------------------------------------------------------------------
# 环境管理函数
# ------------------------------------------------------------------------------

# 快速创建 Python 环境
# 参数：
#   $1: 环境名称（默认：pyenv）
#   $2: Python版本（默认：3.10）
# 使用示例：
#   conda_create_python_env myproject 3.11
#   conda_create_python_env webdev  # 使用默认Python版本
conda_create_python_env() {
    local env_name="${1:-pyenv}"
    local python_version="${2:-3.10}"
    
    echo "🐍 创建 Python $python_version 环境: $env_name"
    echo "📦 自动安装 pip"
    
    if conda create -n "$env_name" python="$python_version" pip -y; then
        echo "✅ 环境创建成功！"
        echo "💡 激活环境: conda activate $env_name"
    else
        echo "❌ 环境创建失败"
        return 1
    fi
}

# 从模板文件创建环境
# 参数：
#   $1: 模板名称（必需）
#   $2: 新环境名称（可选，默认使用模板中的名称）
# 使用示例：
#   conda_create_from_template datascience
#   conda_create_from_template machinelearning my-ml-env
conda_create_from_template() {
    local template_name="$1"
    local custom_env_name="$2"
    
    if [[ -z "$template_name" ]]; then
        echo "📋 可用模板:"
        find "$DOTFILES/conda/environments" -name "*.yml" 2>/dev/null | \
            xargs -n1 basename | sed 's/.yml$//' | sort | \
            sed 's/^/  - /'
        echo ""
        echo "💡 使用方法: conda_create_from_template <模板名> [环境名]"
        return 1
    fi
    
    local template_file="$DOTFILES/conda/environments/${template_name}.yml"
    if [[ ! -f "$template_file" ]]; then
        echo "❌ 模板不存在: $template_name"
        echo "📁 检查路径: $template_file"
        return 1
    fi
    
    if [[ -n "$custom_env_name" ]]; then
        echo "📄 从模板 '$template_name' 创建环境 '$custom_env_name'"
        # 创建临时文件，修改环境名
        local temp_file=$(mktemp)
        sed "s/^name: .*/name: $custom_env_name/" "$template_file" > "$temp_file"
        
        if conda env create -f "$temp_file"; then
            echo "✅ 环境 '$custom_env_name' 创建成功"
            echo "💡 激活环境: conda activate $custom_env_name"
        else
            echo "❌ 环境创建失败"
            rm "$temp_file"
            return 1
        fi
        rm "$temp_file"
    else
        echo "📄 从模板 '$template_name' 创建环境"
        local env_name=$(grep "^name:" "$template_file" | cut -d' ' -f2)
        
        if conda env create -f "$template_file"; then
            echo "✅ 环境 '$env_name' 创建成功"
            echo "💡 激活环境: conda activate $env_name"
        else
            echo "❌ 环境创建失败"
            return 1
        fi
    fi
}

# 将当前环境保存为模板
# 参数：
#   $1: 模板名称（可选，默认使用当前目录名）
# 使用示例：
#   conda_save_as_template my-template
#   conda_save_as_template  # 使用当前目录名
conda_save_as_template() {
    local template_name="${1:-$(basename $PWD)}"
    local current_env="${CONDA_DEFAULT_ENV:-base}"
    local output_file="$DOTFILES/conda/environments/${template_name}.yml"
    
    echo "💾 将环境 '$current_env' 导出为模板 '$template_name'"
    echo "📁 保存位置: $output_file"
    
    # 确保目录存在
    mkdir -p "$(dirname "$output_file")"
    
    if conda env export > "$output_file"; then
        # 修改模板中的环境名为模板名
        if [[ "$template_name" != "$current_env" ]]; then
            sed -i.bak "s/^name: .*/name: $template_name/" "$output_file"
            rm "${output_file}.bak" 2>/dev/null
        fi
        echo "✅ 模板保存成功: $template_name"
        echo "💡 使用模板: conda_create_from_template $template_name"
    else
        echo "❌ 模板保存失败"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# 状态和信息函数
# ------------------------------------------------------------------------------

# 显示 conda 环境状态总览
# 无参数
# 使用示例：
#   conda_status
conda_status() {
    echo "📊 Conda 环境状态总览"
    echo "==============================="
    
    # 基本信息
    echo "🐍 Conda 版本: $(conda --version 2>/dev/null || echo '未知')"
    echo "🏠 当前环境: ${CONDA_DEFAULT_ENV:-base}"
    echo "📍 Conda 根目录: ${CONDA_PREFIX:-未知}"
    echo ""
    
    # 环境统计
    local env_count=$(conda env list 2>/dev/null | grep -c '/' || echo 0)
    echo "📋 环境总数: $env_count"
    echo ""
    
    # 环境列表
    echo "📂 所有环境:"
    conda env list 2>/dev/null || echo "无法获取环境列表"
    echo ""
    
    # 缓存信息
    if [[ -d ~/.conda ]]; then
        local cache_size=$(du -sh ~/.conda 2>/dev/null | cut -f1)
        echo "💾 缓存大小: ${cache_size:-未知}"
        
        # 缓存详情
        echo "📦 缓存详情:"
        if [[ -d ~/.conda/pkgs ]]; then
            local pkgs_size=$(du -sh ~/.conda/pkgs 2>/dev/null | cut -f1)
            local pkgs_count=$(find ~/.conda/pkgs -maxdepth 1 -type d 2>/dev/null | wc -l)
            echo "  - 包缓存: $pkgs_size ($((pkgs_count - 1)) 个包)"
        fi
        if [[ -d ~/.conda/envs ]]; then
            local envs_size=$(du -sh ~/.conda/envs 2>/dev/null | cut -f1)
            echo "  - 环境存储: $envs_size"
        fi
    else
        echo "💾 缓存目录: 未找到"
    fi
    
    # 配置信息
    echo ""
    echo "⚙️  配置信息:"
    echo "  - 配置文件: ${HOME}/.condarc $(test -f ~/.condarc && echo '✅' || echo '❌')"
    echo "  - 当前通道:"
    conda config --show channels 2>/dev/null | grep -v "^--" | sed 's/^/    /'
}

# 分析环境磁盘占用情况
# 参数：
#   $1: 环境名称（可选，默认当前环境）
# 使用示例：
#   conda_env_size
#   conda_env_size myenv
conda_env_size() {
    local env_name="${1:-$CONDA_DEFAULT_ENV}"
    
    if [[ -z "$env_name" || "$env_name" == "base" ]]; then
        env_name="base"
        echo "📊 分析 base 环境磁盘占用"
        local env_path="$CONDA_PREFIX"
    else
        echo "📊 分析环境 '$env_name' 磁盘占用"
        local env_path=$(conda info --envs 2>/dev/null | grep "^$env_name " | awk '{print $NF}')
    fi
    
    if [[ ! -d "$env_path" ]]; then
        echo "❌ 环境路径不存在: $env_path"
        return 1
    fi
    
    echo "==============================="
    echo "📁 环境路径: $env_path"
    
    # 总大小
    local total_size=$(du -sh "$env_path" 2>/dev/null | cut -f1)
    echo "💾 总大小: $total_size"
    echo ""
    
    # 目录分析
    echo "📂 主要目录占用:"
    du -sh "$env_path"/* 2>/dev/null | sort -hr | head -8 | \
        while read size path; do
            local dir_name=$(basename "$path")
            echo "  $size  $dir_name"
        done
    echo ""
    
    # 包统计
    echo "📦 包信息:"
    local package_count=$(conda list -n "$env_name" 2>/dev/null | tail -n +4 | wc -l)
    echo "  - 已安装包数量: $package_count"
    
    # pip 包统计
    local current_env="$CONDA_DEFAULT_ENV"
    if conda activate "$env_name" 2>/dev/null; then
        if command -v pip >/dev/null 2>&1; then
            local pip_count=$(pip list 2>/dev/null | tail -n +3 | wc -l)
            echo "  - pip 包数量: $pip_count"
        fi
        # 恢复原环境
        if [[ -n "$current_env" && "$current_env" != "$env_name" ]]; then
            conda activate "$current_env" 2>/dev/null
        fi
    fi
}

# ------------------------------------------------------------------------------
# 维护和清理函数
# ------------------------------------------------------------------------------

# 清理 conda 缓存和临时文件
# 无参数
# 使用示例：
#   conda_cleanup
conda_cleanup() {
    echo "🧹 Conda 缓存清理工具"
    echo "======================"
    
    # 显示清理前状态
    if [[ -d ~/.conda ]]; then
        local before_size=$(du -sh ~/.conda 2>/dev/null | cut -f1)
        echo "📊 清理前缓存大小: $before_size"
        
        # 缓存详情
        echo ""
        echo "📦 清理前缓存详情:"
        if [[ -d ~/.conda/pkgs ]]; then
            local pkgs_size=$(du -sh ~/.conda/pkgs 2>/dev/null | cut -f1)
            local pkgs_count=$(find ~/.conda/pkgs -maxdepth 1 -type d 2>/dev/null | wc -l)
            echo "  - 包缓存: $pkgs_size ($((pkgs_count - 1)) 个包)"
        fi
    else
        echo "📊 未找到 conda 缓存目录"
        return 0
    fi
    
    echo ""
    echo "🗑️  执行清理操作..."
    
    # 执行清理
    echo "  - 清理包缓存..."
    conda clean --packages -y
    
    echo "  - 清理压缩包缓存..."
    conda clean --tarballs -y
    
    echo "  - 清理索引缓存..."
    conda clean --index-cache -y
    
    echo "  - 清理源缓存..."
    conda clean --source-cache -y
    
    echo "  - 清理临时文件..."
    conda clean --tempfiles -y
    
    # 显示清理后状态
    echo ""
    if [[ -d ~/.conda ]]; then
        local after_size=$(du -sh ~/.conda 2>/dev/null | cut -f1)
        echo "📊 清理后缓存大小: $after_size"
        echo "✅ 清理完成！"
    else
        echo "✅ 清理完成！缓存目录已被完全清除"
    fi
    
    echo ""
    echo "💡 提示: 被清理的包在下次安装时会重新下载"
}

# 检查环境健康状态
# 参数：
#   $1: 环境名称（可选，默认当前环境）
# 使用示例：
#   conda_check_env
#   conda_check_env myenv
conda_check_env() {
    local env_name="${1:-$CONDA_DEFAULT_ENV}"
    local original_env="$CONDA_DEFAULT_ENV"
    
    echo "🔍 检查环境健康状态: ${env_name:-base}"
    echo "=================================="
    
    # 检查环境是否存在
    if [[ "$env_name" == "base" ]] || [[ -z "$env_name" ]]; then
        env_name="base"
        echo "📋 检查 base 环境"
    else
        if ! conda env list 2>/dev/null | grep -q "^$env_name "; then
            echo "❌ 环境不存在: $env_name"
            echo "📋 可用环境:"
            conda env list
            return 1
        fi
        echo "📋 检查环境: $env_name"
    fi
    
    # 检查环境路径
    local env_path
    if [[ "$env_name" == "base" ]]; then
        env_path="$CONDA_PREFIX"
    else
        env_path=$(conda info --envs 2>/dev/null | grep "^$env_name " | awk '{print $NF}')
    fi
    
    if [[ ! -d "$env_path" ]]; then
        echo "❌ 环境目录不存在: $env_path"
        return 1
    fi
    echo "✅ 环境目录存在: $env_path"
    
    # 检查包完整性
    echo ""
    echo "📦 检查包完整性..."
    if conda list -n "$env_name" >/dev/null 2>&1; then
        local package_count=$(conda list -n "$env_name" 2>/dev/null | tail -n +4 | wc -l)
        echo "✅ 包列表正常，共 $package_count 个包"
    else
        echo "❌ 包列表异常，环境可能损坏"
        return 1
    fi
    
    # 检查关键组件
    echo ""
    echo "🔧 检查关键组件..."
    
    # 临时切换到目标环境进行检查
    if conda activate "$env_name" 2>/dev/null; then
        # 检查 Python
        if command -v python >/dev/null 2>&1; then
            local python_version=$(python --version 2>&1)
            echo "✅ Python: $python_version"
        else
            echo "⚠️  Python 未安装"
        fi
        
        # 检查 pip
        if command -v pip >/dev/null 2>&1; then
            local pip_version=$(pip --version 2>&1 | cut -d' ' -f2)
            local pip_count=$(pip list 2>/dev/null | tail -n +3 | wc -l)
            echo "✅ pip: $pip_version ($pip_count 个包)"
        else
            echo "⚠️  pip 未安装"
        fi
        
        # 检查 conda
        if command -v conda >/dev/null 2>&1; then
            echo "✅ conda 命令可用"
        else
            echo "❌ conda 命令不可用"
        fi
        
        # 恢复原环境
        if [[ -n "$original_env" && "$original_env" != "$env_name" ]]; then
            conda activate "$original_env" 2>/dev/null
        elif [[ "$env_name" != "base" ]]; then
            conda deactivate 2>/dev/null
        fi
    else
        echo "❌ 无法激活环境，环境可能损坏"
        return 1
    fi
    
    echo ""
    echo "✅ 环境检查完成，状态正常"
}

# ------------------------------------------------------------------------------
# 源管理函数（中国用户网络优化）
# ------------------------------------------------------------------------------

# 切换 conda 源配置
# 参数：
#   $1: 源类型（从 sources.yml 读取）
# 使用示例：
#   conda_switch_source china     # 切换到中国镜像源
#   conda_switch_source official  # 切换到官方源
#   conda_switch_source tsinghua  # 切换到清华镜像
conda_switch_source() {
    local source_type="$1"
    local sources_file="$DOTFILES/conda/sources.yml"
    
    # 检查源配置文件是否存在
    if [[ ! -f "$sources_file" ]]; then
        echo "❌ 源配置文件不存在: $sources_file"
        return 1
    fi
    
    if [[ -z "$source_type" ]]; then
        echo "🌐 Conda 源管理工具"
        echo "=================="
        echo "💡 使用方法: conda_switch_source <源类型>"
        echo ""
        echo "📋 可用源类型:"
        
        # 从配置文件读取可用源
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
import yaml
import sys
try:
    with open('$sources_file', 'r', encoding='utf-8') as f:
        sources = yaml.safe_load(f)
    for key, value in sources.items():
        if isinstance(value, dict) and 'name' in value:
            print(f'  {key:<12} - {value[\"name\"]}')
            if 'description' in value:
                print(f'               {value[\"description\"]}')
except Exception as e:
    print('  无法解析配置文件，请检查 sources.yml 格式')
"
        else
            echo "  官方源、中国镜像源等（需要 Python3 解析详细列表）"
        fi
        
        echo ""
        echo "🔍 当前源配置:"
        conda config --show channels
        return 1
    fi
    
    # 特殊处理：直接编辑配置文件
    if [[ "$source_type" == "custom" ]]; then
        echo "⚙️  自定义源配置"
        echo "📁 源配置文件: $sources_file"
        echo "📁 conda 配置文件: ~/.condarc"
        
        if command -v code >/dev/null 2>&1; then
            echo "💡 编辑源配置: code $sources_file"
            echo "💡 编辑 conda 配置: code ~/.condarc"
        elif command -v vim >/dev/null 2>&1; then
            echo "💡 编辑源配置: vim $sources_file"
            echo "💡 编辑 conda 配置: vim ~/.condarc"
        fi
        return 0
    fi
    
    # 使用 Python 解析 YAML 配置
    if ! command -v python3 >/dev/null 2>&1; then
        echo "❌ 需要 Python3 来解析配置文件"
        echo "💡 请安装 Python3 或手动配置 ~/.condarc"
        return 1
    fi
    
    # 读取并应用源配置
    local config_result=$(python3 -c "
import yaml
import sys
import json

try:
    with open('$sources_file', 'r', encoding='utf-8') as f:
        sources = yaml.safe_load(f)
    
    if '$source_type' not in sources:
        print('ERROR: 源类型不存在: $source_type')
        sys.exit(1)
    
    source_config = sources['$source_type']
    
    # 输出配置信息
    result = {
        'name': source_config.get('name', '$source_type'),
        'description': source_config.get('description', ''),
        'channels': source_config.get('channels', []),
        'config': source_config.get('config', {})
    }
    
    print(json.dumps(result, ensure_ascii=False))
    
except Exception as e:
    print(f'ERROR: 解析配置失败: {e}')
    sys.exit(1)
")
    
    if [[ "$config_result" == ERROR:* ]]; then
        echo "❌ ${config_result#ERROR: }"
        return 1
    fi
    
    # 解析配置结果
    local source_name=$(echo "$config_result" | python3 -c "import json,sys; data=json.load(sys.stdin); print(data['name'])")
    local source_desc=$(echo "$config_result" | python3 -c "import json,sys; data=json.load(sys.stdin); print(data['description'])")
    
    echo "🌐 切换到: $source_name"
    if [[ -n "$source_desc" ]]; then
        echo "📖 描述: $source_desc"
    fi
    
    # 清除现有 channels 配置
    conda config --remove-key channels 2>/dev/null || true
    
    # 添加新的 channels（逆序添加，因为 conda config --add 是插入到前面）
    echo "$config_result" | python3 -c "
import json
import sys
import subprocess

data = json.load(sys.stdin)
channels = data['channels']

# 逆序添加 channels
for channel in reversed(channels):
    subprocess.run(['conda', 'config', '--add', 'channels', channel], check=True)

# 应用其他配置
config_settings = data['config']
for key, value in config_settings.items():
    if isinstance(value, bool):
        value_str = 'yes' if value else 'no'
    else:
        value_str = str(value)
    subprocess.run(['conda', 'config', '--set', key, value_str], check=True)
"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ 源切换成功"
    else
        echo "❌ 源切换失败"
        return 1
    fi
    
    echo ""
    echo "🔍 当前源配置:"
    conda config --show channels
}

# 测试 conda 源连接状态
# 无参数
# 使用示例：
#   conda_test_connection
conda_test_connection() {
    echo "🌐 测试 Conda 源连接状态"
    echo "========================"
    
    # 获取当前配置的源
    local channels=($(conda config --show channels 2>/dev/null | grep -v "^--" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | grep -v "^$"))
    
    if [[ ${#channels[@]} -eq 0 ]]; then
        echo "⚠️  未找到配置的源"
        return 1
    fi
    
    echo "📋 当前配置的源:"
    printf '%s\n' "${channels[@]}" | sed 's/^/  - /'
    echo ""
    
    echo "🔍 测试连接..."
    local success_count=0
    local total_count=${#channels[@]}
    
    for channel in "${channels[@]}"; do
        if [[ "$channel" =~ ^https?:// ]]; then
            echo -n "  测试 $channel ... "
            
            # 使用 curl 测试连接
            if command -v curl >/dev/null 2>&1; then
                if curl -s --connect-timeout 10 --max-time 15 "$channel" >/dev/null 2>&1; then
                    echo "✅ 正常"
                    ((success_count++))
                else
                    echo "❌ 失败"
                fi
            # 使用 wget 作为备选
            elif command -v wget >/dev/null 2>&1; then
                if wget -q --timeout=10 --tries=1 --spider "$channel" 2>/dev/null; then
                    echo "✅ 正常"
                    ((success_count++))
                else
                    echo "❌ 失败"
                fi
            else
                echo "⚠️  无法测试（缺少 curl 或 wget）"
            fi
        else
            echo "  跳过 $channel (本地或特殊源)"
        fi
    done
    
    echo ""
    echo "📊 连接测试结果: $success_count/$total_count 个源可用"
    
    if [[ $success_count -eq 0 ]]; then
        echo "❌ 所有源均无法连接"
        echo "💡 建议:"
        echo "  1. 检查网络连接"
        echo "  2. 尝试切换源: conda_switch_source china"
        echo "  3. 检查防火墙设置"
        return 1
    elif [[ $success_count -lt $total_count ]]; then
        echo "⚠️  部分源无法连接"
        echo "💡 建议清理无效源或切换到可用源"
    else
        echo "✅ 所有源连接正常"
    fi
    
    # 测试实际包搜索功能
    echo ""
    echo "🔍 测试包搜索功能..."
    if conda search python -c defaults --info >/dev/null 2>&1; then
        echo "✅ 包搜索功能正常"
    else
        echo "❌ 包搜索功能异常"
        echo "💡 可能需要更新索引: conda update conda"
    fi
}

# ------------------------------------------------------------------------------
# 自动补全设置
# ------------------------------------------------------------------------------
if [[ -n "$ZSH_VERSION" ]]; then
    # 环境名补全
    _conda_envs() {
        local envs=($(conda env list 2>/dev/null | awk 'NR>2 && !/^#/ {print $1}'))
        compadd -a envs
    }
    
    # 模板名补全
    _conda_templates() {
        local templates=()
        if [[ -d "$DOTFILES/conda/environments" ]]; then
            templates=($(find "$DOTFILES/conda/environments" -name "*.yml" 2>/dev/null | \
                xargs -n1 basename | sed 's/.yml$//' | sort))
        fi
        compadd -a templates
    }
    
    # 源类型补全
    _conda_sources() {
        local sources=("official" "china" "custom")
        compadd -a sources
    }
    
    # 设置自动补全
    compdef _conda_envs conda_env_size conda_check_env
    compdef _conda_templates conda_create_from_template
    compdef _conda_sources conda_switch_source
fi

# ------------------------------------------------------------------------------
# 模块加载信息
# ------------------------------------------------------------------------------
if [[ -n "$DOTFILES_DEBUG" ]]; then
    echo "✅ Conda 函数模块已加载"
    echo "   📂 环境管理: conda_create_python_env, conda_create_from_template, conda_save_as_template"
    echo "   📊 状态信息: conda_status, conda_env_size"  
    echo "   🛠️  维护工具: conda_cleanup, conda_check_env"
    echo "   🌐 源管理: conda_switch_source, conda_test_connection"
fi