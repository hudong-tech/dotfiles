#!/usr/bin/env zsh
# ==============================================================================
# PATH 路径配置
# 优先级：本地 bin > Homebrew > 系统默认
# ==============================================================================

# 移除路径中的重复项
typeset -U path

# 本地 bin 目录（最高优先级）
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    $path
)

# Homebrew 路径
if [[ -d "/opt/homebrew/bin" ]]; then
    # Apple Silicon Mac
    path=("/opt/homebrew/bin" "/opt/homebrew/sbin" $path)
    export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -d "/usr/local/bin" ]]; then
    # Intel Mac
    path=("/usr/local/bin" "/usr/local/sbin" $path)
    export HOMEBREW_PREFIX="/usr/local"
fi

# 开发工具路径
if [[ -d "/usr/local/go/bin" ]]; then
    path=("/usr/local/go/bin" $path)
fi

# Go workspace
if [[ -n "$GOPATH" ]]; then
    path=("$GOPATH/bin" $path)
fi

# Python 用户安装路径
if [[ -d "$HOME/Library/Python/3.9/bin" ]]; then
    path=("$HOME/Library/Python/3.9/bin" $path)
fi

# Rust/Cargo
if [[ -d "$HOME/.cargo/bin" ]]; then
    path=("$HOME/.cargo/bin" $path)
fi

# 导出最终路径
export PATH
