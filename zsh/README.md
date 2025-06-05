# 🐚 Zsh 配置模块

这是一个**模块化、功能完善**的 Zsh 配置方案，结合了 Oh My Zsh 的强大插件生态和自定义的实用功能。

## 📁 目录结构

``` 
zsh/
├── README.md # 本文档 - Zsh 配置详细说明
├── aliases.zsh # 命令别名配置
├── exports.zsh # 环境变量和代理设置
├── functions.zsh # 自定义 Shell 函数
├── path.zsh # PATH 路径管理
└── p10k.zsh # Powerlevel10k 主题配置（终端提示符美化）
``` 

## 🚀 主配置文件 (.zshrc)

位于 `~/dotfiles/.zshrc`，这是整个配置的**入口点**，负责：

### 核心功能
- **🔍 智能路径检测**：自动找到 dotfiles 目录位置
- **🛡️ 安全加载机制**：`load_zsh_config` 函数带容错处理
- **🎨 Oh My Zsh 集成**：配置了 Powerlevel10k 主题和多个实用插件
- **📦 模块化加载**：按依赖顺序加载各配置模块
- **⚡ Zsh 增强功能**：历史记录、补全、目录导航等优化

### 插件配置
```bash
plugins=(
    git                     # Git 命令增强
    zsh-syntax-highlighting # 语法高亮
    zsh-autosuggestions    # 智能建议
    autojump               # 智能目录跳转
    extract                # 解压缩工具
    docker                 # Docker 补全
    node                   # Node.js 支持
    brew                   # Homebrew 补全
    macos                  # macOS 特有命令
)
```

## 🔗 功能模块详解

### 📝 aliases.zsh - 命令别名

一个全面的命令别名集合，按功能分类：

#### 基础命令增强
```bash
alias ll='ls -alF'              # 详细列表
alias la='ls -A'                # 显示隐藏文件
alias ..='cd ..'                # 快速返回上级
alias mkdir='mkdir -pv'         # 递归创建目录
```

#### Git 快捷命令
```bash
alias gs='git status'           # 查看状态
alias ga='git add'              # 添加文件
alias gc='git commit'           # 提交
alias gp='git push'             # 推送
alias gpl='git pull'            # 拉取
```

#### 开发工具别名
```bash
# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'

# Node.js/npm
alias ni='npm install'
alias nr='npm run'
alias ns='npm start'

# Python
alias py='python3'
alias pip='pip3'
alias serve='python3 -m http.server'
```

#### 代理管理别名 ⭐
```bash
alias pon='proxy_on'            # 开启代理
alias poff='proxy_off'          # 关闭代理
alias pst='proxy_status'        # 查看代理状态
alias ptest='proxy_test'        # 测试代理连接
alias pauto='proxy_auto'        # 智能代理切换
alias ip='myip'                 # 查看IP地址
```

### 🌐 exports.zsh - 环境变量

#### 基础环境配置
```bash
export LANG="en_US.UTF-8"       # 语言设置
export EDITOR="vim"             # 默认编辑器
export VISUAL="code"            # GUI 编辑器
```

#### 开发环境变量
- **Node.js**: NVM 配置
- **Java**: 自动检测最新版本
- **Go**: GOPATH 和模块支持
- **Python**: 用户安装路径
- **Rust**: 源码路径配置

#### 🔥 Clash Verge 代理配置

**完整的混合端口代理设置（端口 7897）**：

```bash
# HTTP/HTTPS 代理
export HTTP_PROXY="http://127.0.0.1:7897"
export HTTPS_PROXY="http://127.0.0.1:7897"

# SOCKS5 全局代理
export ALL_PROXY="socks5://127.0.0.1:7897"

# 本地地址排除
export NO_PROXY="127.0.0.1,localhost,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12"

# Git 代理自动配置
git config --global http.proxy "$HTTP_PROXY"
git config --global https.proxy "$HTTPS_PROXY"
```

#### 代理管理函数
- `proxy_on()`: 开启代理
- `proxy_off()`: 关闭代理  
- `proxy_status()`: 查看代理状态

### ⚙️ functions.zsh - 自定义函数

包含 **20+ 个实用函数**，每个都有详细的使用示例：

#### 📁 文件和目录操作
```bash
mkcd <目录名>               # 创建目录并进入
ff <文件名模式>             # 查找文件
fd <目录名模式>             # 查找目录
extract <压缩文件>          # 智能解压
backup <文件或目录>         # 自动备份
```

#### 🌿 Git 增强功能
```bash
gcp "<提交信息>"            # 提交并推送
gco [分支名]               # 快速切换分支
glg                        # 美化的提交历史
```

#### 🖥️ 系统信息与监控
```bash
sysinfo                    # 系统信息概览
port <端口号>              # 检查端口占用
killport <端口号>          # 终止端口进程
nettest                    # 网络连接测试
```

#### 🚀 开发环境
```bash
devstart                   # 智能启动开发环境
initproject <项目名>       # 项目初始化
codecount                  # 代码行数统计
```

#### 🌐 代理智能管理 ⭐
```bash
proxy_test                 # 完整代理测试
myip                       # IP地址对比
proxy_auto                 # 智能代理切换
```

#### 🛠️ 实用工具
```bash
calc "<数学表达式>"         # 计算器
genpass [长度]             # 随机密码生成
qr "<内容>"                # 二维码生成
weather [城市名]           # 天气查询
note [内容]                # 快速笔记
```

### 🛤️ path.zsh - 路径管理

采用**智能优先级设计**：

#### 路径优先级
1. `$HOME/bin`, `$HOME/.local/bin` (最高优先级)
2. Homebrew 路径 (Apple Silicon 或 Intel Mac)
3. 开发工具路径 (Go, Python, Rust, Cargo)
4. 系统默认路径

#### 自动检测功能
- 自动识别 Apple Silicon 或 Intel Mac
- 动态添加已安装的开发工具路径
- 使用 `typeset -U` 避免路径重复

## 🌟 项目亮点

### 1. 🧩 模块化设计优秀

- **功能分离清晰**: 每个模块职责单一
- **加载机制安全**: 容错处理，文件不存在不报错
- **依赖关系明确**: 按顺序加载，避免冲突
- **便于维护定制**: 修改某个功能不影响其他模块

### 2. 🔄 代理管理功能完善

提供了完整的代理解决方案：

- **一键开关**: `pon`/`poff` 快速切换
- **状态监控**: `pst` 查看当前配置
- **连接测试**: `ptest` 测试代理性能
- **智能切换**: `pauto` 根据网络环境自动选择
- **IP 对比**: `ip` 显示直连和代理的外网 IP

### 3. 🔧 开发工具支持全面

涵盖了主流开发技术栈：
- **版本控制**: Git 增强命令
- **容器化**: Docker/Docker Compose
- **前端开发**: Node.js/npm 快捷操作
- **后端语言**: Python, Go, Rust, Java
- **系统工具**: 端口管理、进程监控

### 4. 👨‍💻 用户体验友好

- **丰富的命令别名**: 减少输入，提高效率
- **实用的自定义函数**: 解决日常开发痛点
- **详细的状态提示**: 操作结果清晰反馈
- **完整的使用文档**: 每个函数都有示例

## 📖 使用指南

### 🚀 快速开始

1. **确保软链接正确**:
   ```bash
   ln -sf ~/dotfiles/.zshrc ~/.zshrc
   ```

2. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

3. **验证模块加载**:
   ```bash
   # 查看别名
   alias | grep "alias g"
   
   # 测试函数
   sysinfo
   
   # 检查代理配置
   pst
   ```

### ⚙️ 个性化配置

#### 添加自定义别名
编辑 `aliases.zsh`，在末尾添加：
```bash
# 你的个人别名
alias myproject='cd ~/Projects/my-important-project'
alias startdev='docker-compose up -d && npm start'
```

#### 配置环境变量
编辑 `exports.zsh`，添加项目相关变量：
```bash
# 项目相关环境变量
export PROJECT_ENV="development"
export API_BASE_URL="http://localhost:8080"
```

#### 创建自定义函数
编辑 `functions.zsh`，添加专用函数：
```bash
# 项目特定函数
deploy() {
    echo "🚀 部署到生产环境..."
    git push origin main
    ssh production-server "cd /app && git pull && npm install && pm2 restart all"
}
```

### 🌐 代理使用最佳实践

#### 日常使用流程
```bash
# 1. 智能切换（推荐）
pauto                       # 自动检测并配置代理

# 2. 手动管理
pon                         # 开启代理
ptest                       # 测试连接
ip                          # 查看IP变化
poff                        # 关闭代理

# 3. 状态检查
pst                         # 查看当前代理状态
```

#### 开发环境代理配置
```bash
# Git 操作（自动使用代理）
git clone https://github.com/user/repo.git

# npm/yarn（自动使用代理）
npm install

# Docker（自动使用代理）
docker pull nginx
```

### 🔍 故障排除

#### 常见问题

1. **代理无法连接**:
   ```bash
   # 检查 Clash 是否运行
   port 7897
   
   # 测试代理连接
   ptest
   ```

2. **函数未加载**:
   ```bash
   # 检查文件是否存在
   ls -la ~/dotfiles/zsh/
   
   # 重新加载配置
   source ~/.zshrc
   ```

3. **路径问题**:
   ```bash
   # 检查 PATH 配置
   echo $PATH
   
   # 查看 dotfiles 路径
   echo $DOTFILES
   ```

#### 调试模式

启用调试模式查看加载过程：
```bash
export DOTFILES_DEBUG=1
source ~/.zshrc
```

## 🔄 更新和维护

### 同步更新
```bash
# 进入 dotfiles 目录
dotfiles

# 拉取最新配置
git pull origin main

# 重新加载
zshreload
```

### 版本管理
```bash
# 查看配置变更
git log --oneline

# 备份当前配置
backup ~/.zshrc

# 回滚到之前版本
git checkout HEAD~1 -- zsh/
```

## 🎯 进阶技巧

### 条件加载
```bash
# 在 exports.zsh 中根据环境加载不同配置
if [[ "$USER" == "work" ]]; then
    export WORK_SPECIFIC_VAR="value"
fi
```

### 性能优化
```bash
# 延迟加载重型工具
lazy_load_nvm() {
    unset -f nvm
    source "$NVM_DIR/nvm.sh"
    nvm "$@"
}
alias nvm=lazy_load_nvm
```

### 项目特定配置
```bash
# 在项目目录创建 .envrc 文件
echo 'export PROJECT_NAME="my-app"' > .envrc
```

---

## 🤝 贡献指南

1. **Fork 项目**并创建功能分支
2. **测试新功能**确保不破坏现有配置
3. **添加文档**说明新功能的使用方法
4. **提交 PR**并描述变更内容

## 📄 许可证

MIT License - 详见根目录 [LICENSE](../LICENSE) 文件

---

**Happy Coding!** 🎉

> 这个配置方案经过精心设计和测试，旨在提供高效、稳定的开发环境。如有问题或建议，欢迎提交 Issue！

### 🎨 终端美化

- **Powerlevel10k**：现代化的 Zsh 主题，提供快速、美观的提示符
  - **Lean 风格**：简洁的单行提示符设计
  - **智能显示**：根据项目类型动态显示相关信息
  - **Git 集成**：详细的版本控制状态指示
  - **开发工具支持**：Node.js、Python、Go、Docker 等环境信息
  - **性能优化**：使用 gitstatus 插件提供毫秒级响应
- **iTerm2**：Dracula 主题配置
- **颜色方案**：统一的终端配色体验

#### Powerlevel10k 配置详解

`zsh/p10k.zsh` 提供了完整的主题配置：

**左侧提示符元素**：
- `dir`: 当前目录（智能缩短，支持锚点文件）
- `vcs`: Git 状态（分支、提交状态、文件变更）
- `prompt_char`: 提示符（成功/失败状态颜色）

**右侧提示符元素**：
- `status`: 命令退出状态
- `command_execution_time`: 命令执行时间（>3秒显示）
- `background_jobs`: 后台任务指示
- `virtualenv/anaconda/pyenv`: Python 环境信息
- `nvm/nodenv/node_version`: Node.js 版本信息
- `kubecontext`: Kubernetes 集群上下文
- `aws/azure/gcloud`: 云服务配置
- `time`: 当前时间

**智能功能**：
- **项目识别**：根据 `package.json`、`go.mod`、`.git` 等文件自动显示相关信息
- **环境检测**：自动识别虚拟环境、Docker 容器等
- **性能优化**：异步加载，不影响终端响应速度
- **自定义图标**：使用 Nerd Fonts 提供丰富的图标支持

**个性化配置**：
```bash
# 重新配置主题（交互式向导）
p10k configure

# 编辑配置文件
vim ~/dotfiles/zsh/p10k.zsh

# 重新加载配置
source ~/.zshrc
```

## 2. Git Commit 消息

基于您提供的风格，以下是建议的 commit 消息：

feat: 完善 Powerlevel10k 主题配置和 Zsh 模块化架构

- 新增完整的 Powerlevel10k 配置文件 (zsh/p10k.zsh) 支持现代化终端体验
- 优化 .zshrc 模块化加载机制，采用智能路径检测和安全加载函数
- 集成 Oh My Zsh 插件生态 (语法高亮/智能建议/Git增强/Docker支持)
- 配置 lean 风格单行提示符，支持 Git 状态和开发环境智能显示
- 支持 20+ 开发工具检测 (Node.js/Python/Go/Docker/K8s/云服务)
- 实现异步 Git 状态更新，提供毫秒级终端响应性能
- 提供完整的历史记录和 Zsh 增强功能配置
- 支持智能目录导航、命令补全和错误纠正机制


