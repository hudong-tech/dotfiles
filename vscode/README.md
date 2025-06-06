# VSCode 配置模块

VSCode 开发环境配置管理，支持快速部署和配置同步。

## 📁 文件说明

```
vscode/
├── settings.json          # 编辑器设置（双向绑定）
├── keybindings.json       # 自定义快捷键配置（双向绑定）
├── snippets/              # 代码片段（双向绑定）
├── extensions.list        # 插件列表（手动维护）
├── install-extensions.sh  # 插件批量安装脚本
└── README.md              # 说明文档
```

---

## 🚀 快速部署

> 在新环境中恢复 VSCode 配置

### 前置要求

确保 VSCode 的 `code` 命令可用：

```bash
# 验证命令
code --version

# 如果不可用，在 VSCode 中执行：
# Cmd+Shift+P → "Shell Command: Install 'code' command in PATH"
```

### 分模块部署

#### 📋 必要配置
```bash
# 编辑器设置
ln -sf ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
```

#### 🧩 可选配置
```bash
# 快捷键配置（如果有自定义快捷键）
ln -sf ~/dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json

# 代码片段（如果有自定义代码片段）
ln -sf ~/dotfiles/vscode/snippets ~/Library/Application\ Support/Code/User/snippets

# 批量安装插件
# 给脚本执行权限
chmod +x install-extensions.sh

# 运行安装
./install-extensions.sh
# 或：cat extensions.list | xargs -L 1 code --install-extension
```

#### 🚀 一键全部部署
```bash
# 创建所有软链接
ln -sf ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -sf ~/dotfiles/vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json  
ln -sf ~/dotfiles/vscode/snippets ~/Library/Application\ Support/Code/User/snippets

# 安装插件
./install-extensions.sh

### 其他平台

```bash
# Linux
ln -sf ~/dotfiles/vscode/settings.json ~/.config/Code/User/settings.json
ln -sf ~/dotfiles/vscode/keybindings.json ~/.config/Code/User/keybindings.json
ln -sf ~/dotfiles/vscode/snippets ~/.config/Code/User/snippets

# Windows (Git Bash)
ln -sf ~/dotfiles/vscode/settings.json "$APPDATA/Code/User/settings.json"
ln -sf ~/dotfiles/vscode/keybindings.json "$APPDATA/Code/User/keybindings.json"
ln -sf ~/dotfiles/vscode/snippets "$APPDATA/Code/User/snippets"
```

---

## 🔄 日常维护

### 更新插件列表

```bash
# 导出当前安装的插件
code --list-extensions > ~/dotfiles/vscode/extensions.list

# 提交更新
git add extensions.list
git commit -m "update vscode extensions"
```



---

## 💡 使用建议

- **推荐修改方式**：优先在 VSCode 设置界面修改，会自动同步到 dotfiles
- **插件管理**：安装新插件后记得更新 `extensions.list`
- **版本控制**：定期提交配置变更，保持跨设备同步

---

## 🔍 常用命令

```bash
# 插件管理
code --list-extensions                    # 列出已安装插件
code --install-extension <extension-id>   # 安装插件
code --uninstall-extension <extension-id> # 卸载插件

# 文件操作
code .                     # 在当前目录打开 VSCode
code --diff file1 file2    # 比较文件

# 更新配置
code --list-extensions > extensions.list  # 更新插件列表
```