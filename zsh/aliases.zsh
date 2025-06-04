#!/usr/bin/env zsh
# ==============================================================================
# 命令别名配置
# ==============================================================================

# 基础命令增强
# --------------------------------------------------
alias ls='ls -G'                    # 彩色输出
alias ll='ls -alF'                  # 详细列表
alias la='ls -A'                    # 显示隐藏文件
alias l='ls -CF'                    # 简洁列表
alias ..='cd ..'                    # 返回上级
alias ...='cd ../..'               # 返回上上级
alias ....='cd ../../..'           # 返回上上上级

# 安全别名
alias rm='rm -i'                   # 删除确认
alias cp='cp -i'                   # 复制确认
alias mv='mv -i'                   # 移动确认

# 文件操作
alias mkdir='mkdir -pv'             # 创建目录（递归+详细）
alias du='du -h'                   # 人类可读的磁盘使用量
alias df='df -h'                   # 人类可读的磁盘空间
alias free='top -l 1 -s 0 | grep PhysMem'  # 内存使用情况

# Git 别名 (常用)
# --------------------------------------------------
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git log --oneline'
alias gll='git log --oneline --graph --all'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gr='git reset'
alias grh='git reset --hard'
alias gst='git stash'
alias gstp='git stash pop'

# 开发工具别名
# --------------------------------------------------
# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias drm='docker rm'
alias drmi='docker rmi'
alias dprune='docker system prune -f'

# Node.js / npm
alias ni='npm install'
alias nis='npm install --save'
alias nid='npm install --save-dev'
alias nig='npm install --global'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nu='npm update'

# Python
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias serve='python3 -m http.server'

# 系统监控
# --------------------------------------------------
alias top='htop'                   # 更好的 top
alias ports='netstat -tulanp'      # 显示端口
alias psg='ps aux | grep -v grep | grep -i -E'  # 搜索进程

# 网络工具
# --------------------------------------------------
alias ping='ping -c 5'             # ping 5次后停止
alias myip='curl -s checkip.dyndns.org | grep -Eo "[0-9.]+"'  # 外网IP
alias localip='ifconfig | grep -Eo "inet (addr:)?([0-9]*\.){3}[0-9]*" | grep -v "127.0.0.1"'

# macOS 特定别名
# --------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias finder='open -a Finder'     # 在 Finder 中打开
    alias flushdns='sudo dscacheutil -flushcache'  # 刷新DNS
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
    alias battery='pmset -g batt'      # 电池状态
    alias sleep='pmset sleepnow'       # 立即休眠
    alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
fi

# 快捷编辑配置文件
# --------------------------------------------------
alias zshrc='$EDITOR ~/.zshrc'
alias zshreload='source ~/.zshrc'
alias vimrc='$EDITOR ~/.vimrc'
alias gitconfig='$EDITOR ~/.gitconfig'

# 目录跳转
# --------------------------------------------------
alias home='cd ~'
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias documents='cd ~/Documents'
alias dotfiles='cd ~/dotfiles'
alias projects='cd ~/Projects'      # 根据你的项目目录调整

# 实用工具
# --------------------------------------------------
alias weather='curl wttr.in'        # 天气预报
alias map='telnet mapscii.me'       # ASCII 地图
alias clock='tty-clock -c'          # 终端时钟
alias calendar='cal'                # 日历
alias week='date +%V'               # 当前周数

# 清理别名
# --------------------------------------------------
alias clean='find . -type f -name "*.DS_Store" -delete'  # 清理 .DS_Store
alias cleanup='brew cleanup && npm cache clean --force'   # 清理缓存

# 快速服务器
# --------------------------------------------------
alias webserver='python3 -m http.server 8000'           # HTTP 服务器
alias jsonserver='json-server --watch db.json --port 3001'  # JSON API 服务器

# 定制别名（个人偏好）
# --------------------------------------------------
# 代理管理
alias pon='proxy_on'                # 开启代理
alias poff='proxy_off'              # 关闭代理
alias pst='proxy_status'            # 查看代理状态
alias proxytest='curl -I --connect-timeout 5 https://google.com'  # 测试代理连接
alias ptest='proxy_test'            # 完整代理测试
alias pauto='proxy_auto'            # 智能代理切换
alias ip='myip'                     # 查看IP地址（覆盖原有的myip别名）

# Git 代理管理
alias gitproxy='git config --global http.proxy && git config --global https.proxy'  # 查看Git代理设置
alias gitproxyoff='git config --global --unset http.proxy && git config --global --unset https.proxy'  # 单独关闭Git代理

# 在这里添加你的个人别名
# alias myalias='your command here'
