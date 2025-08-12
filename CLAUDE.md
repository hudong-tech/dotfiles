# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

## 代码库概述

这是一个 **dotfiles** 代码库，为 macOS 提供模块化的开发环境配置集合。它遵循"核心工具事前规划，探索工具事后整理"的智能包管理和环境设置哲学。

## 核心架构

### 模块化设计结构
- **zsh/**: 由 `.zshrc` 自动加载的 Shell 环境配置
- **homebrew/**: 具有优先级模块的智能 Homebrew 包管理
- **工具专用配置**: git/、vim/、vscode/、idea/、iterm2/ 等
- **系统优化**: macos/ 包含自动化系统偏好设置脚本

### Homebrew 模块系统（核心组件）
homebrew/ 目录实现了一个复杂的包管理系统：

- **基于优先级的安装**: fonts(1) → essential(2) → development(3) → optional(4)
- **模块化 Brewfiles**: `Brewfile.essential`、`Brewfile.development` 等
- **智能安装脚本**: `brew-setup.sh` 具有交互式向导和预定义配置文件
- **管理函数**: `brew-functions.zsh` 提供 30+ 个帮助函数和别名

### 环境配置加载
- 主入口点: `.zshrc` 自动加载所有 `zsh/*.zsh` 模块
- 模块化加载: `path.zsh`、`aliases.zsh`、`exports.zsh`、`functions.zsh`
- 跨工具集成: 每个工具目录都有自己的配置和 README

## 常用命令

### 初始设置（新环境）
```bash
# 克隆代码库
git clone <repo-url> ~/dotfiles

# 创建符号链接
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/vim/vimrc ~/.vimrc

# Claude Code 配置符号链接（自动创建）
ln -sf ~/dotfiles/claude/config/settings.json ~/.claude/settings.json

# 重新加载 shell
source ~/.zshrc
```

### Homebrew 管理（主要开发工作流）
```bash
# 交互式安装向导（推荐新用户使用）
cd ~/dotfiles/homebrew
./brew-setup.sh --interactive

# 预定义配置文件
./brew-setup.sh --profile developer    # Essential + development + fonts
./brew-setup.sh --profile minimal      # 仅 Essential
./brew-setup.sh --profile server       # Essential + development（无 GUI）
./brew-setup.sh --profile full         # 所有模块

# 加载管理函数（安装后）
source ~/dotfiles/homebrew/brew-functions.zsh

# 关键管理函数
brew-list-modules              # 查看所有可用模块及统计信息
brew-install-module <module>   # 安装特定模块
brew-sync                      # 自动检测和组织新包
brew-weekly-maintenance        # 每周更新/清理例程
brew-health-check             # 完整环境健康检查
```

### 日常开发命令
```bash
# 环境同步
cd ~/dotfiles
git pull origin main
source ~/.zshrc

# 包管理维护
brew-weekly-maintenance        # 自动化每周例程
brew-sync                      # 检测未跟踪的包
```

### Claude Code 配置
```bash
# Claude API 配置文件切换
claude-use official            # 切换到官方 API
claude-use proxy              # 切换到代理 API
claude-use status             # 检查当前配置

# GUI 应用程序支持（Cursor、VS Code 等）
claude-set-gui-env            # 为 GUI 应用设置环境变量

# 配置管理
claude-init                   # 从模板初始化配置
claude-remove                 # 删除所有 Claude 配置
```

### Conda 环境管理
```bash
# 位于 conda/ 目录，包含模板和锁定环境
conda env create -f conda/environments/templates/ai-llm.yml
conda activate <env-name>
```

### 系统配置
```bash
# 应用 macOS 优化
./macos/defaults.sh

# iTerm2 主题安装（需要手动导入）
# 使用: iterm2/Dracula.itermcolors
```

## 架构决策

### Homebrew 模块优先级
系统按依赖顺序自动安装包：
1. **fonts** - 为开发工具提供连字支持的编程字体
2. **essential** - 现代 CLI 替代品和核心系统工具（开发必需）
3. **development** - 编程语言、容器和开发工具（依赖 essential）
4. **optional** - 个人偏好工具（独立）

### 配置管理策略
- **基于符号链接**: 配置文件是链接的，而非复制
- **模块化加载**: Shell 配置从模块化文件自动加载
- **版本控制**: 所有配置都有清晰的提交约定进行跟踪
- **工具隔离**: 每个工具维护自己的目录和文档
- **Claude 集成**: API 配置和 MCP 服务器设置通过配置文件管理

### 智能包管理
- **事前规划**: 核心工具通过精选的 Brewfiles 管理
- **事后整理**: 探索工具通过 `brew-sync` 检测并稍后分类
- **自动化**: 90% 的维护任务通过帮助函数自动化
- **团队协作**: 支持团队标准化和个人定制

## 文件结构理解

```
dotfiles/
├── zsh/                    # Shell 环境模块（自动加载）
├── homebrew/               # 高级包管理系统
│   ├── Brewfile.*         # 模块化包定义
│   ├── brew-setup.sh      # 智能安装脚本
│   └── brew-functions.zsh # 管理帮助函数
├── claude/                 # Claude Code 配置管理
│   ├── config/settings.json     # Claude Code 权限和设置
│   ├── mcp-servers.json         # MCP 服务器配置注册表
│   ├── profiles/               # API 配置文件
│   └── claude.zsh             # API 切换函数
├── git/gitconfig          # Git 全局配置
├── vim/vimrc             # Vim 编辑器设置
├── vscode/               # VSCode 设置和扩展
├── idea/                 # JetBrains IDE 配置
├── work-system/          # 项目组织模板
└── conda/                # Python 环境管理
```

## 集成要点

### Shell 集成
- 正确加载时，`homebrew/brew-functions.zsh` 中的所有函数都可用
- `zsh/exports.zsh` 中的环境变量影响所有工具
- `zsh/path.zsh` 中的路径管理优先考虑本地二进制文件

### 跨工具配置
- Git 设置影响所有开发工作流
- VSCode 和 IntelliJ 配置引用一致的代码样式
- 终端/iTerm2 主题与编辑器主题协调
- Claude Code 设置通过符号链接自动同步到 `~/.claude/settings.json`

### 工作系统集成
- `work-system/` 提供标准化项目脚手架
- 模板包含一致的结构: code/、doc/、data/、tests/
- 使用 `init_project.sh` 自动化项目初始化

## 重要说明

- 这是一个**个人 dotfiles 代码库**，而非应用程序源代码
- 专注于**配置管理**和**环境设置**
- 没有传统的构建/测试/部署周期 - 更改通过符号链接和 shell 重载生效
- 包安装通过 Homebrew 的 bundle 系统管理，而非传统包管理器
- 系统级配置需要 macOS 环境
- Claude Code 设置通过符号链接自动同步到 `~/.claude/settings.json`
- MCP 服务器配置在 `claude/mcp-servers.json` 中定义，便于管理