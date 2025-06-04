#!/usr/bin/env zsh
# ==============================================================================
# 环境变量配置
# ==============================================================================

# 语言和编码
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# 默认编辑器
export EDITOR="vim"
export VISUAL="code"  # GUI 编辑器

# 分页器
export PAGER="less"
export LESS="-R"

# 颜色支持
export TERM="xterm-256color"

# 开发环境
# --------------------------------------------------

# Node.js
export NVM_DIR="$HOME/.nvm"

# Java
if [[ -d "/Library/Java/JavaVirtualMachines" ]]; then
    # 自动找到最新版本的 Java
    JAVA_VERSION=$(ls /Library/Java/JavaVirtualMachines/ | grep -E "jdk|adoptopenjdk" | sort -V | tail -1)
    if [[ -n "$JAVA_VERSION" ]]; then
        export JAVA_HOME="/Library/Java/JavaVirtualMachines/$JAVA_VERSION/Contents/Home"
    fi
fi

# Go
export GOPATH="$HOME/go"
export GO111MODULE="on"

# Python
export PYTHONPATH="$HOME/.local/lib/python3.9/site-packages:$PYTHONPATH"

# Rust
export RUST_SRC_PATH="$HOME/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src"

# 工具配置
# --------------------------------------------------

# Homebrew
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# GPG
export GPG_TTY=$(tty)

# ──────────────────────────────────────────────────────────────────────────────
# Clash Verge mixed-port（HTTP + SOCKS5）代理设置：端口 7897
# ──────────────────────────────────────────────────────────────────────────────

# 1. HTTP/HTTPS 代理指向 127.0.0.1:7897
export HTTP_PROXY="http://127.0.0.1:7897"
export HTTPS_PROXY="http://127.0.0.1:7897"
export http_proxy="$HTTP_PROXY"
export https_proxy="$HTTPS_PROXY"

# 2. SOCKS5 全局代理也指向同一端口
export ALL_PROXY="socks5://127.0.0.1:7897"
export all_proxy="$ALL_PROXY"

# 3. 本地地址不走代理
export NO_PROXY="127.0.0.1,localhost,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12"
export no_proxy="$NO_PROXY"

# 4. 让 Git 也走同样的代理
git config --global http.proxy "$HTTP_PROXY"
git config --global https.proxy "$HTTPS_PROXY"

# 5. 代理管理函数（添加到 functions.zsh 中调用）
# 这些函数可以方便地开关代理
proxy_on() {
    export HTTP_PROXY="http://127.0.0.1:7897"
    export HTTPS_PROXY="http://127.0.0.1:7897"
    export http_proxy="$HTTP_PROXY"
    export https_proxy="$HTTPS_PROXY"
    export ALL_PROXY="socks5://127.0.0.1:7897"
    export all_proxy="$ALL_PROXY"
    export NO_PROXY="127.0.0.1,localhost,::1,192.168.0.0/16,10.0.0.0/12,172.16.0.0/12"
    export no_proxy="$NO_PROXY"
    
    git config --global http.proxy "$HTTP_PROXY"
    git config --global https.proxy "$HTTPS_PROXY"
    
    echo "✅ 代理已开启 (HTTP: $HTTP_PROXY, SOCKS5: $ALL_PROXY)"
}

proxy_off() {
    unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy NO_PROXY no_proxy
    
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    
    echo "✅ 代理已关闭"
}

proxy_status() {
    if [[ -n "$HTTP_PROXY" ]]; then
        echo "🟢 代理状态: 开启"
        echo "   HTTP/HTTPS: $HTTP_PROXY"
        echo "   SOCKS5: $ALL_PROXY"
        echo "   排除地址: $NO_PROXY"
    else
        echo "🔴 代理状态: 关闭"
    fi
}

# ──────────────────────────────────────────────────────────────────────────────

# macOS 特定
# --------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    # 禁用 macOS Catalina+ 的 zsh 警告
    export BASH_SILENCE_DEPRECATION_WARNING=1
    
    # LibreSSL/OpenSSL 路径
    if [[ -d "/opt/homebrew/opt/openssl" ]]; then
        export LDFLAGS="-L/opt/homebrew/opt/openssl/lib"
        export CPPFLAGS="-I/opt/homebrew/opt/openssl/include"
    fi
fi

# 个性化设置
# --------------------------------------------------

# 历史记录时间格式
export HIST_STAMPS="yyyy-mm-dd"

# 禁用 .DS_Store 文件
export COPYFILE_DISABLE=1

# 让 man 页面支持颜色
export MANPAGER="less -R --use-color -Dd+r -Du+b"
