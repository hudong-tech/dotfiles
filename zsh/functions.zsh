#!/usr/bin/env zsh
# ==============================================================================
# 自定义 Shell 函数
# ==============================================================================

# 文件和目录操作
# --------------------------------------------------

# 创建目录并进入
# 使用方法: mkcd <目录名>
# 示例:
#   mkcd my-project          # 创建 my-project 目录并进入
#   mkcd path/to/new/dir     # 创建多级目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 查找文件
# 使用方法: ff <文件名模式>
# 示例:
#   ff "*.js"               # 查找所有 JavaScript 文件
#   ff "config"             # 查找文件名包含 config 的文件
#   ff "README"             # 查找 README 相关文件
ff() {
    find . -type f -name "*$1*"
}

# 查找目录
# 使用方法: fd <目录名模式>
# 示例:
#   fd "node_modules"       # 查找 node_modules 目录
#   fd "src"                # 查找 src 目录
#   fd "test"               # 查找测试相关目录
fd() {
    find . -type d -name "*$1*"
}

# 提取压缩文件（智能识别格式）
# 使用方法: extract <压缩文件>
# 支持格式: .tar.bz2, .tar.gz, .bz2, .rar, .gz, .tar, .tbz2, .tgz, .zip, .Z, .7z
# 示例:
#   extract archive.zip      # 解压 ZIP 文件
#   extract project.tar.gz   # 解压 tar.gz 文件
#   extract backup.7z        # 解压 7z 文件
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' 无法被提取" ;;
        esac
    else
        echo "'$1' 不是有效文件"
    fi
}

# 文件大小（人类可读）
# 使用方法: filesize <文件或目录>
# 示例:
#   filesize .              # 查看当前目录大小
#   filesize large-file.zip # 查看文件大小
#   filesize ~/Downloads    # 查看下载目录大小
filesize() {
    if [[ -n "$1" ]]; then
        du -sh "$1"
    else
        echo "请提供文件或目录路径"
    fi
}

# Git 相关函数
# --------------------------------------------------

# Git 提交并推送
# 使用方法: gcp "<提交信息>"
# 示例:
#   gcp "fix: 修复登录问题"           # 提交并推送
#   gcp "feat: 添加用户管理功能"      # 功能提交
#   gcp "docs: 更新 README"          # 文档更新
gcp() {
    if [[ -z "$1" ]]; then
        echo "请提供提交信息"
        return 1
    fi
    git add . && git commit -m "$1" && git push
}

# 快速切换 Git 分支
# 使用方法: gco [分支名]
# 示例:
#   gco                     # 显示所有分支
#   gco main                # 切换到 main 分支
#   gco feature/user-auth   # 切换到功能分支
#   gco -b new-feature      # 创建并切换到新分支
gco() {
    if [[ -z "$1" ]]; then
        git branch -a
        return
    fi
    git checkout "$1"
}

# 查看 Git 日志（美化版）
# 使用方法: glg [选项]
# 示例:
#   glg                     # 显示美化的提交历史
#   glg --since="1 week"    # 显示最近一周的提交
#   glg -10                 # 显示最近10次提交
glg() {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all
}

# 系统信息函数
# --------------------------------------------------

# 系统信息概览
# 使用方法: sysinfo
# 示例:
#   sysinfo                 # 显示完整的系统信息
# 输出信息包括：操作系统、内核版本、主机名、用户、Shell、终端、macOS版本、CPU、内存等
sysinfo() {
    echo "系统信息概览："
    echo "===================="
    echo "操作系统: $(uname -s)"
    echo "内核版本: $(uname -r)"
    echo "主机名: $(hostname)"
    echo "用户: $(whoami)"
    echo "当前目录: $(pwd)"
    echo "Shell: $SHELL"
    echo "终端: $TERM"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS 版本: $(sw_vers -productVersion)"
        echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
        echo "内存: $(system_profiler SPHardwareDataType | grep "Memory:" | cut -d: -f2 | xargs)"
    fi
}

# 端口占用检查
# 使用方法: port <端口号>
# 示例:
#   port 3000               # 检查3000端口占用情况
#   port 8080               # 检查8080端口
#   port 22                 # 检查SSH端口
port() {
    if [[ -z "$1" ]]; then
        echo "使用方法: port <端口号>"
        return 1
    fi
    lsof -i :"$1"
}

# 杀死端口进程
# 使用方法: killport <端口号>
# 警告: 此操作会强制终止进程，请谨慎使用
# 示例:
#   killport 3000           # 强制终止占用3000端口的进程
#   killport 8080           # 终止8080端口进程
killport() {
    if [[ -z "$1" ]]; then
        echo "使用方法: killport <端口号>"
        return 1
    fi
    lsof -ti:"$1" | xargs kill -9
}

# 网络相关函数
# --------------------------------------------------

# 网络连接测试
# 使用方法: nettest
# 示例:
#   nettest                 # 执行完整的网络连接测试
# 测试内容：本地IP、外网IP、DNS解析（Google、百度）
nettest() {
    echo "测试网络连接..."
    echo "===================="
    echo "本地IP: $(ifconfig | grep -E 'inet.*broadcast' | awk '{print $2}')"
    echo "外网IP: $(curl -s checkip.dyndns.org | grep -Eo '[0-9.]+')"
    echo ""
    echo "DNS 测试："
    echo "Google: $(ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo '✅ 可达' || echo '❌ 不可达')"
    echo "百度: $(ping -c 1 baidu.com >/dev/null 2>&1 && echo '✅ 可达' || echo '❌ 不可达')"
}

# 开发相关函数
# --------------------------------------------------

# 快速启动开发环境
# 使用方法: devstart
# 支持项目类型: Node.js (package.json), Rust (Cargo.toml), Django (manage.py), Flask (app.py)
# 示例:
#   cd my-react-app && devstart     # 在React项目中启动开发服务器
#   cd rust-project && devstart     # 在Rust项目中运行cargo run
#   cd django-app && devstart       # 在Django项目中启动开发服务器
devstart() {
    if [[ -f "package.json" ]]; then
        echo "🚀 启动 Node.js 项目..."
        npm start
    elif [[ -f "Cargo.toml" ]]; then
        echo "🦀 启动 Rust 项目..."
        cargo run
    elif [[ -f "manage.py" ]]; then
        echo "🐍 启动 Django 项目..."
        python manage.py runserver
    elif [[ -f "app.py" ]]; then
        echo "🐍 启动 Flask 项目..."
        python app.py
    else
        echo "❓ 未识别的项目类型"
    fi
}

# 项目初始化
# 使用方法: initproject <项目名>
# 示例:
#   initproject my-new-app          # 创建新项目目录
#   initproject "My Project"        # 项目名包含空格
#   initproject mobile-app          # 移动应用项目
# 功能: 创建目录、初始化Git仓库、创建README.md
initproject() {
    if [[ -z "$1" ]]; then
        echo "使用方法: initproject <项目名>"
        return 1
    fi
    
    mkdir -p "$1"
    cd "$1"
    git init
    echo "# $1" > README.md
    echo "项目 $1 初始化完成！"
}

# 代码统计
# 使用方法: codecount
# 支持文件类型: .js, .ts, .jsx, .tsx, .py, .go, .rs, .java, .c, .cpp, .h
# 示例:
#   codecount               # 统计当前目录及子目录的代码行数
#   cd project && codecount # 在项目目录中统计代码
codecount() {
    echo "代码行数统计："
    echo "===================="
    find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" | xargs wc -l | sort -n
}

# 实用工具函数
# --------------------------------------------------

# 计算器
# 使用方法: calc <数学表达式>
# 示例:
#   calc "2 + 3"            # 简单加法: 5.000
#   calc "10 / 3"           # 除法: 3.333
#   calc "2^10"             # 幂运算: 1024.000
#   calc "sqrt(16)"         # 平方根: 4.000
#   calc "sin(3.14159/2)"   # 三角函数
calc() {
    echo "scale=3; $*" | bc -l
}

# 随机密码生成
# 使用方法: genpass [长度]
# 示例:
#   genpass                 # 生成12位随机密码
#   genpass 8               # 生成8位密码
#   genpass 20              # 生成20位密码
genpass() {
    local length=${1:-12}
    openssl rand -base64 $length | cut -c1-$length
}

# QR 码生成（需要安装 qrencode）
# 使用方法: qr "<内容>"
# 安装: brew install qrencode
# 示例:
#   qr "https://github.com"         # 生成GitHub链接的二维码
#   qr "Hello World"                # 生成文本二维码
#   qr "wifi:WPA;T:WPA;S:MyWiFi;P:password;;"  # WiFi二维码
qr() {
    if command -v qrencode >/dev/null 2>&1; then
        qrencode -t UTF8 "$1"
    else
        echo "请安装 qrencode: brew install qrencode"
    fi
}

# 天气查询
# 使用方法: weather [城市名]
# 示例:
#   weather                 # 查询当前位置天气
#   weather "Beijing"       # 查询北京天气
#   weather "New York"      # 查询纽约天气
#   weather "Shanghai"      # 查询上海天气
weather() {
    local city=${1:-}
    curl -s "wttr.in/$city?format=3"
}

# 备份函数
# 使用方法: backup <文件或目录>
# 示例:
#   backup important.txt            # 备份单个文件
#   backup ~/Documents/project      # 备份项目目录
#   backup .                        # 备份当前目录
# 备份格式: 原名_backup_YYYYMMDD_HHMMSS
backup() {
    if [[ -z "$1" ]]; then
        echo "使用方法: backup <文件或目录>"
        return 1
    fi
    
    local source="$1"
    local backup_name="${source%/}_backup_$(date +%Y%m%d_%H%M%S)"
    
    if [[ -d "$source" ]]; then
        cp -r "$source" "$backup_name"
    else
        cp "$source" "$backup_name"
    fi
    
    echo "✅ 已备份到: $backup_name"
}

# 快速笔记
# 使用方法: note [内容]
# 示例:
#   note                            # 查看所有笔记
#   note "记住买牛奶"               # 添加新笔记
#   note "会议时间: 明天下午3点"     # 添加提醒
#   note "学习Docker容器化部署"      # 学习笔记
# 笔记文件位置: ~/quick_notes.md
note() {
    local note_file="$HOME/quick_notes.md"
    if [[ -z "$1" ]]; then
        # 显示现有笔记
        if [[ -f "$note_file" ]]; then
            cat "$note_file"
        else
            echo "暂无笔记"
        fi
    else
        # 添加新笔记
        echo "$(date): $*" >> "$note_file"
        echo "✅ 笔记已添加"
    fi
}

# macOS 特定函数
# --------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    # 清理下载目录
    # 使用方法: cleandownloads
    # 示例:
    #   cleandownloads          # 清理30天前的下载文件
    # 注意: 此操作不可恢复，请谨慎使用
    cleandownloads() {
        echo "清理下载目录..."
        find ~/Downloads -type f -mtime +30 -delete
        echo "✅ 30天前的文件已清理"
    }
    
    # 显示隐藏文件
    # 使用方法: showhidden
    # 示例:
    #   showhidden              # 在Finder中显示隐藏文件
    # 效果: .DS_Store, .git等隐藏文件将可见
    showhidden() {
        defaults write com.apple.finder AppleShowAllFiles YES
        killall Finder
        echo "✅ 隐藏文件现在可见"
    }
    
    # 隐藏隐藏文件
    # 使用方法: hidehidden
    # 示例:
    #   hidehidden              # 在Finder中隐藏隐藏文件
    # 效果: 恢复默认的文件显示状态
    hidehidden() {
        defaults write com.apple.finder AppleShowAllFiles NO
        killall Finder
        echo "✅ 隐藏文件现在不可见"
    }
fi

# 代理相关函数
# --------------------------------------------------

# 测试代理连接
# 使用方法: proxy_test
# 示例:
#   proxy_test              # 执行完整的代理连接测试
# 测试内容: 直连速度、代理访问Google、代理访问GitHub
# 前提条件: 需要配置代理环境变量
proxy_test() {
    echo "🌐 测试代理连接..."
    echo "===================="
    
    # 测试直连
    echo "直连测试:"
    local direct_time=$(curl -o /dev/null -s -w "%{time_total}" --connect-timeout 5 https://www.baidu.com)
    if [[ $? -eq 0 ]]; then
        echo "✅ 百度直连: ${direct_time}s"
    else
        echo "❌ 百度直连失败"
    fi
    
    # 测试代理
    if [[ -n "$HTTP_PROXY" ]]; then
        echo ""
        echo "代理测试 ($HTTP_PROXY):"
        local proxy_time=$(curl -o /dev/null -s -w "%{time_total}" --connect-timeout 10 --proxy "$HTTP_PROXY" https://www.google.com)
        if [[ $? -eq 0 ]]; then
            echo "✅ Google 代理访问: ${proxy_time}s"
        else
            echo "❌ Google 代理访问失败"
        fi
        
        # 测试 GitHub
        local github_time=$(curl -o /dev/null -s -w "%{time_total}" --connect-timeout 10 --proxy "$HTTP_PROXY" https://github.com)
        if [[ $? -eq 0 ]]; then
            echo "✅ GitHub 代理访问: ${github_time}s"
        else
            echo "❌ GitHub 代理访问失败"
        fi
    else
        echo ""
        echo "❌ 未检测到代理配置"
    fi
}

# 获取当前 IP 地址（区分直连和代理）
# 使用方法: myip
# 示例:
#   myip                    # 显示直连和代理的IP地址
# 功能: 对比直连IP和代理IP，验证代理是否生效
# 别名: ip
myip() {
    echo "🌍 IP 地址信息："
    echo "===================="
    
    # 直连IP
    echo "直连 IP:"
    local direct_ip=$(curl -s --connect-timeout 5 --max-time 10 ifconfig.me)
    if [[ -n "$direct_ip" ]]; then
        echo "  $direct_ip"
    else
        echo "  获取失败"
    fi
    
    # 代理IP（如果配置了代理）
    if [[ -n "$HTTP_PROXY" ]]; then
        echo ""
        echo "代理 IP ($HTTP_PROXY):"
        local proxy_ip=$(curl -s --connect-timeout 10 --max-time 15 --proxy "$HTTP_PROXY" ifconfig.me)
        if [[ -n "$proxy_ip" ]]; then
            echo "  $proxy_ip"
        else
            echo "  获取失败"
        fi
    fi
}

# 智能代理切换（根据网络环境）
# 使用方法: proxy_auto
# 示例:
#   proxy_auto              # 自动检测网络环境并切换代理
# 逻辑: 如果能直连Google则关闭代理，否则开启代理
# 别名: pauto
proxy_auto() {
    echo "🔄 自动检测网络环境..."
    
    # 测试是否能直连 Google
    if curl -s --connect-timeout 3 --max-time 5 https://www.google.com >/dev/null 2>&1; then
        echo "✅ 网络环境良好，关闭代理"
        proxy_off
    else
        echo "⚠️  网络受限，开启代理"
        proxy_on
        # 验证代理是否有效
        if curl -s --connect-timeout 10 --max-time 15 --proxy "$HTTP_PROXY" https://www.google.com >/dev/null 2>&1; then
            echo "✅ 代理连接成功"
        else
            echo "❌ 代理连接失败，请检查 Clash 是否运行"
        fi
    fi
}
