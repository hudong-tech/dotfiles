# iTerm2 配置文件

这个目录包含了 iTerm2 终端的配置文件和主题文件。

## 文件说明

### 文件列表
- `com.googlecode.iterm2.plist` - iTerm2 主配置文件，包含终端设置、键盘映射、状态栏配置等
- `Dracula.itermcolors` - Dracula 主题的颜色配置文件
- `README.md` - 本说明文件

## 安装使用方法

### 1. 安装主配置文件 (com.googlecode.iterm2.plist)

**方法一：通过 iTerm2 界面导入**
1. 打开 iTerm2
2. 进入 `iTerm2` → `Preferences` (或按 `⌘,`)
3. 选择 `Profiles` 标签
4. 点击左下角的 `Other Actions...` 按钮
5. 选择 `Import JSON Profiles...`
6. 选择 `com.googlecode.iterm2.plist` 文件

**方法二：直接替换配置文件**
```bash
# 备份当前配置
cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist.backup

# 复制新配置文件
cp com.googlecode.iterm2.plist ~/Library/Preferences/

# 重启 iTerm2 使配置生效
```

### 2. 安装 Dracula 主题 (Dracula.itermcolors)

**方法一：双击安装**
1. 双击 `Dracula.itermcolors` 文件
2. iTerm2 会自动导入该颜色方案

**方法二：通过 iTerm2 界面导入**
1. 打开 iTerm2 偏好设置 (`⌘,`)
2. 选择 `Profiles` 标签
3. 在右侧选择 `Colors` 标签
4. 点击右下角的 `Color Presets...` 下拉菜单
5. 选择 `Import...`
6. 选择 `Dracula.itermcolors` 文件
7. 导入后，再次点击 `Color Presets...` 选择 `Dracula` 主题

## 配置特性

### 主要配置包含：

#### 🎨 外观设置
- **主题**：Dracula 深色主题
- **字体**：Monaco 12pt
- **透明度**：无透明度
- **状态栏**：启用并配置了多个组件

#### ⌨️ 键盘映射
- 自定义了方向键、功能键的行为
- 支持 Ctrl/Shift/Option 组合键
- 针对终端使用优化的键盘快捷键

#### 📊 状态栏组件
配置了以下状态栏组件（从左到右）：
- 工作目录显示
- 当前任务/进程
- Git 状态信息
- CPU 使用率
- 内存使用率
- 网络使用率
- 搜索字段

#### 🖱️ 鼠标操作
- 右键：显示上下文菜单
- 中键：粘贴剪贴板内容
- 三指滑动：切换标签页和窗口

#### 🔔 通知设置
- 关闭了蜂鸣声
- 启用了视觉提示

## 主题颜色方案

Dracula 主题使用以下颜色：
- **背景色**：深灰色 (#1E1F29)
- **前景色**：浅灰色 (#E6E6E6)
- **光标颜色**：灰色
- **选择颜色**：深蓝灰色
- **ANSI 颜色**：完整的 16 色方案，支持彩色输出

## 恢复默认设置

如需恢复到默认设置：

```bash
# 删除配置文件（iTerm2 会重新创建默认配置）
rm ~/Library/Preferences/com.googlecode.iterm2.plist

# 或者从备份恢复
cp ~/Library/Preferences/com.googlecode.iterm2.plist.backup ~/Library/Preferences/com.googlecode.iterm2.plist
```

## 注意事项

1. **备份重要**：安装前请备份现有配置
2. **重启生效**：某些设置可能需要重启 iTerm2 才能生效
3. **版本兼容**：配置文件适用于较新版本的 iTerm2
4. **个性化**：导入后可以根据个人需要进一步调整设置

## 故障排除

### 如果导入后设置没有生效：
1. 确保完全退出 iTerm2 后重新打开
2. 检查文件权限：`chmod 644 ~/Library/Preferences/com.googlecode.iterm2.plist`
3. 重置 iTerm2 偏好设置缓存

### 如果颜色主题显示异常：
1. 确认终端类型设置为 `xterm-256color`
2. 检查是否正确选择了 Dracula 颜色预设
3. 重新导入 `Dracula.itermcolors` 文件

---

**享受更好的终端体验！** 🚀 