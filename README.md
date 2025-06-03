# 🏠 DotFiles

开发环境配置文件集合，采用模块化设计，支持快速部署和同步开发环境配置。

## ✨ 特性

- 🧩 **模块化设计**：配置文件按功能分类，便于维护和定制
- ⚡ **快速部署**：一键安装脚本，快速同步到新环境
- 🎨 **美观实用**：精心调优的主题和配置，提升开发体验
- 🔧 **工具齐全**：覆盖主流开发工具和编辑器配置
- 📦 **版本管理**：所有配置纳入版本控制，变更可追溯

## 📁 目录结构

``` 
dotfiles/
├── .zshrc # Zsh 配置主入口，负责加载 zsh/ 下所有模块
├── zsh/ # 所有 shell 环境配置的模块化文件夹
│ ├── path.zsh # 配置 PATH 路径优先级（如本地 bin）
│ ├── aliases.zsh # 命令别名（如 gs='git status'）
│ ├── exports.zsh # 环境变量导出（如 LANG、EDITOR）
│ └── functions.zsh # 自定义 shell 函数
├── git/
│ └── gitconfig # Git 全局配置文件（用户名、别名、颜色等）
├── idea/ # JetBrains 系列 IDE 的配置项
│ ├── ideavimrc # IdeaVim 插件配置（类似 .vimrc）
│ ├── codestyles/ # 导出的代码风格 XML 文件
│ ├── keymaps/ # 自定义快捷键配置
│ └── templates/ # File Templates 模板
├── vim/
│ └── vimrc # Vim 编辑器配置（如语法高亮、缩进）
├── vscode/
│ ├── settings.json # VSCode 编辑器的用户设置
│ └── extensions.list # VSCode 插件列表（用于自动恢复）
├── iterm2/
│ ├── com.googlecode.iterm2.plist # iTerm2 主要配置文件（包含主题、快捷键等）
│ ├── README.md # iTerm2 配置说明文档
│ └── Dracula.itermcolors # iTerm2 主题配置文件（可导入）
├── macos/
│ └── defaults.sh # macOS 系统偏好设置脚本（如隐藏文件显示）
├── install.md # 安装说明文档，说明如何手动软链接及初始化
└── README.md # 仓库介绍及模块使用说明
```


## 🚀 快速开始

### 克隆仓库

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 安装配置

详细的安装步骤请参考 [install.md](install.md)

```bash
# 创建软链接
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/vim/vimrc ~/.vimrc

# 重新加载 shell 配置
source ~/.zshrc
```

## 📋 功能模块

### 🐚 Shell 环境 (Zsh)

- **模块化加载**：`.zshrc` 自动加载 `zsh/` 目录下的所有配置模块
- **路径管理**：优化 PATH 路径优先级，本地 bin 目录优先
- **命令别名**：常用 Git 命令和系统操作的快捷别名
- **环境变量**：统一管理开发环境相关的环境变量
- **自定义函数**：提供便捷的 shell 辅助函数

### 🌿 Git 配置

- 全局用户配置和邮箱设置
- 实用的 Git 命令别名
- 美观的输出颜色配置
- 合并和差异工具配置

### 💡 编辑器配置

#### Vim
- 语法高亮和代码缩进
- 插件管理配置
- 键位映射优化

#### VSCode
- 编辑器个性化设置
- 插件列表自动化管理
- 工作区和用户级别配置

#### JetBrains IDEs
- IdeaVim 插件配置，在 IDE 中使用 Vim 键位
- 统一的代码风格配置
- 自定义快捷键映射
- 代码模板和 Live Templates

### 🎨 终端美化

- **iTerm2**：Dracula 主题配置
- **颜色方案**：统一的终端配色体验

### 🍎 macOS 优化

- 系统偏好设置自动化脚本
- 隐藏文件显示等开发友好配置
- Dock 和 Finder 行为优化

## 🔧 自定义配置

### 添加新的别名

编辑 `zsh/aliases.zsh` 文件：

```bash
# 添加你的自定义别名
alias myalias='your command here'
```

### 配置环境变量

编辑 `zsh/exports.zsh` 文件：

```bash
# 添加新的环境变量
export YOUR_VAR="your_value"
```

### 添加自定义函数

编辑 `zsh/functions.zsh` 文件：

```bash
# 添加新的 shell 函数
your_function() {
    # 函数实现
}
```

## 🔄 同步更新

```bash
# 拉取最新配置
cd ~/dotfiles
git pull origin main

# 重新加载配置
source ~/.zshrc
```

## 📝 注意事项

1. **备份现有配置**：安装前请备份你现有的配置文件
2. **个人信息**：记得修改 Git 配置中的用户名和邮箱
3. **路径调整**：根据你的系统环境调整相关路径配置
4. **权限设置**：某些脚本可能需要执行权限

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个配置集合！

## 🙏 致谢与参考

本项目在设计和实现过程中参考了以下优秀的开源项目：

- **[mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)** - 经典的 macOS dotfiles 项目，提供了大量实用的系统默认设置和配置灵感
- 感谢开源社区中所有分享dotfiles配置的开发者们

特别推荐查看 mathiasbynens 的项目来了解更多 macOS 系统优化技巧！

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

**享受你的开发环境！** 🎉