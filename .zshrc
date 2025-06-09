# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#!/usr/bin/env zsh
# ==============================================================================
# ~/.zshrc - Zsh 启动配置 (模块化 + Oh My Zsh 混合方案)
# 注意：如果你把此文件放在 ~/dotfiles/.zshrc，请确保用 ln -sf 链接到 ~/.zshrc
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. 基础路径和错误处理
# ------------------------------------------------------------------------------
# 获取 dotfiles 目录路径
export DOTFILES="$HOME/dotfiles"
if [[ ! -d "$DOTFILES" ]]; then
    export DOTFILES="$(cd "$(dirname "${(%):-%N}")" && pwd)"
fi

# 模块化加载函数（带容错处理）
load_zsh_config() {
    local config_file="$1"
    if [[ -r "$config_file" ]]; then
        source "$config_file"
        # echo "✅ 已加载: $(basename "$config_file")"  # 调试时可取消注释
    else
        echo "⚠️  配置文件不存在: $config_file"
    fi
}

# ------------------------------------------------------------------------------
# 2. 预加载基础配置（在 Oh My Zsh 之前）
# ------------------------------------------------------------------------------
# 优先加载路径配置，确保工具能正确找到
load_zsh_config "$DOTFILES/zsh/path.zsh"

# 加载基础环境变量
load_zsh_config "$DOTFILES/zsh/exports.zsh"

# ------------------------------------------------------------------------------
# 3. Oh My Zsh 配置
# ------------------------------------------------------------------------------
# 检查 Oh My Zsh 是否已安装
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    export ZSH="$HOME/.oh-my-zsh"
    
    # 选择主题
    ZSH_THEME="powerlevel10k/powerlevel10k"
    # 备选主题（如果 Powerlevel10k 未安装）
    # ZSH_THEME="robbyrussell"
    
    # 插件配置
    plugins=(
        git                     # Git 命令增强
        zsh-syntax-highlighting # 语法高亮（需要安装）
        zsh-autosuggestions    # 自动建议（需要安装）
        autojump               # 智能跳转
        extract                # 解压缩工具
        docker                 # Docker 命令补全
        node                   # Node.js 相关
        brew                   # Homebrew 补全
        macos                  # macOS 特有命令
    )
    
    # 加载 Oh My Zsh
    source $ZSH/oh-my-zsh.sh
    
    # 只在调试模式下显示
    [[ -n "$DOTFILES_DEBUG" ]] && echo "✅ Oh My Zsh 加载完成"
else
    [[ -n "$DOTFILES_DEBUG" ]] && echo "⚠️  Oh My Zsh 未安装，使用基础 Zsh 配置"
    # 基础 Zsh 配置（无 Oh My Zsh 时的备选方案）
    autoload -Uz compinit
    compinit
    
    # 简单提示符
    PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f%# '
fi

# ------------------------------------------------------------------------------
# 4. 模块化配置加载（在 Oh My Zsh 之后）
# ------------------------------------------------------------------------------
# 加载别名配置
load_zsh_config "$DOTFILES/zsh/aliases.zsh"

# 加载自定义函数
load_zsh_config "$DOTFILES/zsh/functions.zsh"

# 加载本地个人配置（不被版本控制）
[[ -f "$HOME/.extra" ]] && load_zsh_config "$HOME/.extra"

# ------------------------------------------------------------------------------
# 5. 历史记录配置
# ------------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# 历史记录选项
setopt HIST_VERIFY              # 执行历史命令前确认
setopt SHARE_HISTORY            # 多终端共享历史
setopt APPEND_HISTORY           # 增量追加模式
setopt INC_APPEND_HISTORY       # 实时追加历史
setopt HIST_IGNORE_DUPS         # 忽略重复命令
setopt HIST_IGNORE_ALL_DUPS     # 删除所有重复
setopt HIST_REDUCE_BLANKS       # 移除多余空格
setopt HIST_IGNORE_SPACE        # 忽略以空格开头的命令

# 智能历史搜索
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# ------------------------------------------------------------------------------
# 6. Zsh 增强配置
# ------------------------------------------------------------------------------
# 目录导航
setopt AUTO_CD                  # 输入目录名直接进入
setopt AUTO_PUSHD               # 自动添加到目录栈
setopt PUSHD_IGNORE_DUPS        # 忽略重复目录
setopt PUSHD_SILENT             # 静默 pushd

# 补全增强
setopt COMPLETE_ALIASES         # 别名补全
setopt AUTO_LIST                # 自动列出选择
setopt AUTO_MENU                # 自动菜单补全
setopt COMPLETE_IN_WORD         # 单词中间也能补全

# 补全样式
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select

# 错误纠正
setopt CORRECT                  # 纠正命令
# setopt CORRECT_ALL            # 纠正所有参数（可能过于激进）

# 其他实用选项
setopt INTERACTIVE_COMMENTS     # 允许注释
setopt MULTIOS                  # 多重重定向
setopt PROMPT_SUBST             # 提示符变量替换

# ------------------------------------------------------------------------------
# 7. 工具初始化
# ------------------------------------------------------------------------------
# Homebrew 补全
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# NVM 初始化（Node Version Manager）
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    source "$HOME/.nvm/nvm.sh"
    [[ -s "$HOME/.nvm/bash_completion" ]] && source "$HOME/.nvm/bash_completion"
fi

# 自定义脚本目录
if [[ -d "$HOME/scripts" ]]; then
    export PATH="$HOME/scripts:$PATH"
fi

# ------------------------------------------------------------------------------
# 8. 终端优化
# ------------------------------------------------------------------------------
# 终端标题显示当前目录
precmd() {
    print -Pn "\e]0;%n@%m: %~\a"
}

# 颜色支持
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# ------------------------------------------------------------------------------
# 9. 性能优化
# ------------------------------------------------------------------------------
# 延迟加载一些不常用的功能
# 可以根据需要添加更多的延迟加载逻辑

# ------------------------------------------------------------------------------
# 10. 调试和信息
# ------------------------------------------------------------------------------
# 启动信息（可选）
if [[ -n "$DOTFILES_DEBUG" ]]; then
    echo "🐚 Zsh 配置加载完成"
    echo "📁 Dotfiles: $DOTFILES"
    echo "🎨 主题: $ZSH_THEME"
    echo "🔌 插件: ${plugins[*]}"
fi

# ------------------------------------------------------------------------------
# End of ~/.zshrc
# ------------------------------------------------------------------------------

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
