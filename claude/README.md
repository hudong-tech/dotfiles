# 🤖 Claude API 配置管理

Claude API 配置切换和管理模块，支持在官方API和代理API之间快速切换。

## 📁 目录结构

```
claude/
├── claude.zsh              # 主要功能函数
├── profiles/               # API配置文件目录
│   ├── official.env.template   # 官方API配置模板
│   ├── proxy.env.template      # 代理API配置模板
│   ├── official.env            # 官方API实际配置（不被版本控制）
│   └── proxy.env               # 代理API实际配置（不被版本控制）
└── README.md               # 本文档
```

## 🚀 快速开始

### 1. 创建配置文件

```bash
# 进入配置目录
cd ~/dotfiles/claude/profiles

# 创建官方API配置
cp official.env.template official.env
# 编辑并填入你的官方API密钥
vim official.env

# 创建代理API配置
cp proxy.env.template proxy.env
# 编辑并填入你的代理API配置
vim proxy.env
```

### 2. 使用配置切换功能

```bash
# 切换到官方API
claude-use official

# 切换到代理API
claude-use proxy

# 查看当前配置状态
claude-use status

# 显示使用帮助
claude-use
```

## 🔧 可用函数

### `claude-use [profile]`
主要的配置切换函数

**参数：**
- `official` - 切换到官方API
- `proxy` - 切换到代理API  
- `status` - 显示当前配置状态
- 无参数 - 显示使用帮助

### `claude-status`
显示当前Claude配置状态，包括：
- API基础URL
- 配置类型（官方/代理）
- API密钥（脱敏显示）

### `claude-with-status [args...]`
执行claude命令前先显示当前配置状态

### `claude-init`
自动初始化Claude配置文件，从模板文件创建实际配置文件

### `claude-set-gui-env`
为GUI应用程序（如Cursor、VS Code等）设置环境变量

### `claude-remove`
彻底删除Claude API配置，清除所有相关环境变量

## 📝 配置说明

### 环境变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `ANTHROPIC_API_KEY` | Claude API密钥 | `sk-ant-api03-...` |
| `ANTHROPIC_BASE_URL` | API基础URL | `https://api.anthropic.com` |
| `ANTHROPIC_MODEL` | 默认模型 | `claude-3-sonnet-20240229` |
| `ANTHROPIC_MAX_TOKENS` | 最大输出token数 | `4096` |

### 配置文件格式

配置文件使用标准的shell环境变量格式：

```bash
# 必需配置
export ANTHROPIC_API_KEY="your_api_key_here"
export ANTHROPIC_BASE_URL="https://api.anthropic.com"

# 可选配置
export ANTHROPIC_MODEL="claude-3-sonnet-20240229"
export ANTHROPIC_MAX_TOKENS="4096"
```

## 🔒 安全注意事项

1. **API密钥保护**：实际的 `.env` 配置文件已被 `.gitignore` 排除，不会被提交到版本控制
2. **模板文件**：只提交 `.template` 模板文件到版本控制
3. **权限控制**：建议设置配置文件权限为 `600`

```bash
chmod 600 ~/dotfiles/claude/profiles/*.env
```

## 🔄 迁移现有配置

如果你之前使用 `~/.claude-profiles/` 目录：

```bash
# 复制现有配置到新位置
cp ~/.claude-profiles/official.env ~/dotfiles/claude/profiles/
cp ~/.claude-profiles/proxy.env ~/dotfiles/claude/profiles/

# 删除旧目录（可选）
rm -rf ~/.claude-profiles/
```

## 🖥️ GUI应用程序支持

### 问题说明
GUI应用程序（如Cursor、VS Code等）无法直接访问终端中设置的环境变量。这是因为：
- **终端应用程序**：从shell配置文件获取环境变量
- **GUI应用程序**：从macOS的`launchd`系统获取环境变量

### 解决方案

#### 方法1：使用函数设置（推荐）
```bash
# 先切换到想要的配置
claude-use proxy

# 为GUI应用程序设置环境变量
claude-set-gui-env

# 重启GUI应用程序（如Cursor）
```

#### 方法2：从终端启动GUI应用程序
```bash
# 从终端启动Cursor（会继承终端的环境变量）
/Applications/Cursor.app/Contents/MacOS/Cursor

# 从终端启动VS Code
code
```

### 验证设置
```bash
# 检查GUI环境变量是否正确设置
launchctl getenv ANTHROPIC_BASE_URL
launchctl getenv ANTHROPIC_API_KEY
```

## 🔄 代理管理

Claude配置中集成了代理管理功能，方便在需要代理访问API时使用：

```bash
# 开启代理
proxy_on

# 关闭代理
proxy_off

# 查看代理状态
proxy_status
```

## 🎯 使用示例

### 基本配置切换
```bash
# 查看当前状态
$ claude-use status
🔍 当前Claude配置：
  API地址: https://api.anthropic.com (默认)
  配置类型: 官方API
  API密钥: sk-ant-api03-xxxxxxxx...

# 切换到代理API
$ claude-use proxy
✅ 已切换到代理API

# 带状态信息执行命令
$ claude-with-status "Hello Claude!"
🔍 当前Claude配置：
  API地址: https://proxy.example.com/v1
  配置类型: 代理API
  API密钥: pk-proxy-xxxxxxxx...

Hello! How can I help you today?
```

### 初始化配置
```bash
# 初始化Claude配置文件
$ claude-init
🚀 Claude配置初始化
📁 配置目录: /Users/phil/dotfiles/claude/profiles

✅ 已创建官方API配置文件: official.env
📝 请编辑文件填入你的API密钥: vim /Users/phil/dotfiles/claude/profiles/official.env
✅ 已创建代理API配置文件: proxy.env
📝 请编辑文件填入你的API配置: vim /Users/phil/dotfiles/claude/profiles/proxy.env

🎯 下一步：
  1. 编辑配置文件填入实际的API密钥
  2. 使用 'claude-use official' 或 'claude-use proxy' 切换配置
  3. 使用 'claude-use status' 查看当前状态
```

### GUI应用程序配置
```bash
# 切换到代理配置
$ claude-use proxy
✅ 已切换到代理API

# 为GUI应用程序设置环境变量
$ claude-set-gui-env
✅ GUI 环境变量已设置完成
💡 请重启 Cursor 应用程序以使环境变量生效

# 验证GUI环境变量
$ launchctl getenv ANTHROPIC_BASE_URL
https://r1119.dpdns.org/api

$ launchctl getenv ANTHROPIC_API_KEY
cr_45286af2497dad03de71dcf3dc1a5e80920148eb7deeb2f5e06ee7deb1346d9c
```

### 删除Claude配置
```bash
# 彻底删除Claude API配置
$ claude-remove
🗑️  Claude API 配置已彻底删除
   ✅ 终端环境变量已清除
   ✅ GUI应用程序环境变量已清除

💡 提示：
   - 请重启GUI应用程序以确保设置完全清除
   - 如需重新配置，请使用 'claude-use official' 或 'claude-use proxy'
   - 配置文件仍保留在 ~/dotfiles/claude/profiles/ 目录中

# 验证删除结果
$ claude-use status
🔍 当前Claude配置：
  API地址: https://api.anthropic.com (默认)
  配置类型: 官方API
  API密钥: ...

# 检查GUI环境变量是否已清除
$ launchctl getenv ANTHROPIC_BASE_URL
# (无输出，表示已清除)

$ launchctl getenv ANTHROPIC_API_KEY
# (无输出，表示已清除)
```

### 代理管理
```bash
# 检查代理状态
$ proxy_status
🟢 代理状态: 开启
   HTTP/HTTPS: http://127.0.0.1:7897
   SOCKS5: socks5://127.0.0.1:7897
   排除地址: 127.0.0.1,localhost,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12

# 关闭代理
$ proxy_off
✅ 代理已关闭

# 重新开启代理
$ proxy_on
✅ 代理已开启 (HTTP: http://127.0.0.1:7897, SOCKS5: socks5://127.0.0.1:7897)
```

## ❓ 常见问题

### Q: 为什么Cursor中的Claude Code无法使用我的API配置？
**A:** 这是因为GUI应用程序无法访问终端的环境变量。解决方案：
1. 使用 `claude-set-gui-env` 设置GUI环境变量
2. 重启Cursor应用程序
3. 或者从终端启动：`/Applications/Cursor.app/Contents/MacOS/Cursor`

### Q: 如何检查当前使用的是哪个配置？
**A:** 使用 `claude-use status` 或 `claude-status` 查看当前配置状态

### Q: 代理设置不生效怎么办？
**A:** 
1. 检查代理状态：`proxy_status`
2. 重新开启代理：`proxy_off && proxy_on`
3. 确认代理软件（如Clash Verge）正在运行且端口正确

### Q: 配置文件丢失怎么办？
**A:** 使用 `claude-init` 重新创建配置文件模板，然后填入你的API信息

### Q: 如何彻底删除Claude API配置？
**A:** 使用 `claude-remove` 可以：
1. 清除终端中的所有Claude环境变量
2. 清除GUI应用程序中的Claude环境变量  
3. 保留配置文件以便将来重新使用

## 🔧 故障排除

### 环境变量未生效
```bash
# 检查终端环境变量
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_API_KEY

# 检查GUI环境变量
launchctl getenv ANTHROPIC_BASE_URL
launchctl getenv ANTHROPIC_API_KEY

# 重新设置GUI环境变量
claude-set-gui-env
```

### 彻底清除Claude配置
```bash
# 完全删除Claude配置
claude-remove

# 验证删除结果
claude-use status
launchctl getenv ANTHROPIC_BASE_URL
launchctl getenv ANTHROPIC_API_KEY

# 重新配置（如果需要）
claude-use proxy
claude-set-gui-env
```

### 配置切换失败
```bash
# 检查配置文件是否存在
ls -la ~/dotfiles/claude/profiles/

# 重新初始化配置
claude-init

# 检查配置文件权限
chmod 600 ~/dotfiles/claude/profiles/*.env
```

### 代理连接问题
```bash
# 测试代理连接
curl -x http://127.0.0.1:7897 https://api.anthropic.com

# 检查代理配置
proxy_status

# 重启代理
proxy_off && proxy_on
```

## 🤝 贡献

欢迎提交改进建议和功能请求！
