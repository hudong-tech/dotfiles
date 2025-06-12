#!/usr/bin/env zsh
# ==============================================================================
# Conda 配置和初始化检查
# ==============================================================================

# 检查 conda 可用性
if ! command -v conda >/dev/null 2>&1; then
    [[ -n "$DOTFILES_DEBUG" ]] && echo "⚠️  Conda 未安装或未在 PATH 中"
    return 0
fi

# 设置 conda 相关环境变量（如果需要）
# export CONDA_AUTO_ACTIVATE_BASE=false

# 调试信息
if [[ -n "$DOTFILES_DEBUG" ]]; then
    echo "✅ Conda 可用"
    echo "   - 版本: $(conda --version 2>/dev/null)"
    echo "   - 当前环境: ${CONDA_DEFAULT_ENV:-base}"
fi

# 标记 conda 模块已初始化
export CONDA_MODULE_LOADED=1