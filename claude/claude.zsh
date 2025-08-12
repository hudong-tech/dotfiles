#!/usr/bin/env zsh
# ==============================================================================
# Claude API 配置管理函数
# ==============================================================================

# Claude配置切换函数
claude-use() {
    local profiles_dir="$DOTFILES/claude/profiles"
    
    case $1 in
        "official")
            if [[ -f "$profiles_dir/official.env" ]]; then
                source "$profiles_dir/official.env"
                echo "✅ 已切换到官方API"
            else
                echo "❌ 配置文件不存在: $profiles_dir/official.env"
                echo "💡 请先创建配置文件: cp $profiles_dir/official.env.template $profiles_dir/official.env"
            fi
            ;;
        "proxy")
            if [[ -f "$profiles_dir/proxy.env" ]]; then
                source "$profiles_dir/proxy.env"
                echo "✅ 已切换到代理API"
            else
                echo "❌ 配置文件不存在: $profiles_dir/proxy.env"
                echo "💡 请先创建配置文件: cp $profiles_dir/proxy.env.template $profiles_dir/proxy.env"
            fi
            ;;
        "status")
            claude-status
            ;;
        *)
            echo "用法: claude-use [official|proxy|status]"
            echo "  official - 切换到官方API"
            echo "  proxy    - 切换到代理API"
            echo "  status   - 查看当前配置"
            ;;
    esac
}

# 显示当前配置状态
claude-status() {
    echo "🔍 当前Claude配置："
    if [[ -n "$ANTHROPIC_BASE_URL" ]]; then
        echo "  API地址: $ANTHROPIC_BASE_URL"
        echo "  配置类型: 代理API"
    else
        echo "  API地址: https://api.anthropic.com (默认)"
        echo "  配置类型: 官方API"
    fi
    echo "  API密钥: ${ANTHROPIC_API_KEY:0:20}..."
}

# 带配置信息的claude别名
claude-with-status() {
    claude-status
    echo ""
    claude "$@"
}

# 设置GUI环境变量函数
claude-set-gui-env() {
    launchctl setenv ANTHROPIC_BASE_URL "$ANTHROPIC_BASE_URL"
    launchctl setenv ANTHROPIC_API_KEY "$ANTHROPIC_API_KEY"
    echo "✅ GUI 环境变量已设置完成"
    echo "💡 请重启 Cursor 应用程序以使环境变量生效"
}

# 删除Claude API配置函数
claude-remove() {
    # 清除当前会话的Claude环境变量
    unset ANTHROPIC_BASE_URL ANTHROPIC_API_KEY ANTHROPIC_MODEL ANTHROPIC_MAX_TOKENS
    
    # 清除GUI应用程序的Claude环境变量
    launchctl unsetenv ANTHROPIC_BASE_URL 2>/dev/null
    launchctl unsetenv ANTHROPIC_API_KEY 2>/dev/null
    launchctl unsetenv ANTHROPIC_MODEL 2>/dev/null
    launchctl unsetenv ANTHROPIC_MAX_TOKENS 2>/dev/null
    
    echo "🗑️  Claude API 配置已彻底删除"
    echo "   ✅ 终端环境变量已清除"
    echo "   ✅ GUI应用程序环境变量已清除"
    echo ""
    echo "💡 提示："
    echo "   - 请重启GUI应用程序以确保设置完全清除"
    echo "   - 如需重新配置，请使用 'claude-use official' 或 'claude-use proxy'"
    echo "   - 配置文件仍保留在 ~/dotfiles/claude/profiles/ 目录中"
}

# Claude配置初始化函数
claude-init() {
    local profiles_dir="$DOTFILES/claude/profiles"
    
    echo "🚀 Claude配置初始化"
    echo "📁 配置目录: $profiles_dir"
    echo ""
    
    # 检查并创建官方API配置
    if [[ ! -f "$profiles_dir/official.env" ]]; then
        if [[ -f "$profiles_dir/official.env.template" ]]; then
            cp "$profiles_dir/official.env.template" "$profiles_dir/official.env"
            echo "✅ 已创建官方API配置文件: official.env"
            echo "📝 请编辑文件填入你的API密钥: vim $profiles_dir/official.env"
        else
            echo "❌ 模板文件不存在: official.env.template"
        fi
    else
        echo "ℹ️  官方API配置文件已存在: official.env"
    fi
    
    # 检查并创建代理API配置
    if [[ ! -f "$profiles_dir/proxy.env" ]]; then
        if [[ -f "$profiles_dir/proxy.env.template" ]]; then
            cp "$profiles_dir/proxy.env.template" "$profiles_dir/proxy.env"
            echo "✅ 已创建代理API配置文件: proxy.env"
            echo "📝 请编辑文件填入你的API配置: vim $profiles_dir/proxy.env"
        else
            echo "❌ 模板文件不存在: proxy.env.template"
        fi
    else
        echo "ℹ️  代理API配置文件已存在: proxy.env"
    fi
    
    echo ""
    echo "🎯 下一步："
    echo "  1. 编辑配置文件填入实际的API密钥"
    echo "  2. 使用 'claude-use official' 或 'claude-use proxy' 切换配置"
    echo "  3. 使用 'claude-use status' 查看当前状态"
}
