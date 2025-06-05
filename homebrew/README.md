# 🍺 Homebrew 包管理模块

这是一个**智能化、混合维护**的 Homebrew 包管理方案，支持"核心工具事前规划，探索工具事后整理"的灵活工作流。

## 📁 目录结构
```
homebrew/
├── README.md # 本文档 - Homebrew 包管理详细说明
├── Brewfile.essential # 基础必需工具
├── Brewfile.development # 开发环境工具
├── Brewfile.fonts # 编程字体 (支持连字的等宽字体)
├── Brewfile.optional # 可选工具
├── brew-setup.sh  # 一键环境设置脚本 (交互式安装向导)
└── brew-functions.zsh # 管理函数集合 (日常维护和管理工具)
```

## 🎯 核心理念

**"核心工具事前规划，探索工具事后整理"**

### 设计哲学
- **🎯 核心稳定**：必需工具标准化管理，确保环境一致性
- **🔬 探索灵活**：试用工具快速安装，定期整理决定去留
- **🤖 自动智能**：减少手动操作，智能同步和清理
- **👥 团队友好**：支持团队标准化和个人定制化

### 🎯 核心策略：8-2-90 原则

- **80% 核心工具** → 事前规划（编辑 Brewfile）
- **20% 探索工具** → 事后整理（定期同步）
- **90% 自动化** → 脚本辅助维护

### 🔧 具体实施

1. **模块化 Brewfile**（按功能分类管理）
2. **智能化脚本**（一键安装、自动检测、错误处理）
3. **定期维护流程**（每周同步、健康检查）
4. **团队协作机制**（PR review、环境标准化）

## 📋 模块详细说明

> **🔄 智能安装顺序**：系统将按 `fonts → essential → development → optional` 的优先级顺序安装，确保依赖关系和最佳兼容性。

### 🔤 fonts - 编程字体 (优先级: 1)
**专为编程优化的字体集合，优先安装确保开发环境字体支持**

```ruby
font-fira-code        # 支持连字的现代编程字体
font-jetbrains-mono   # JetBrains 官方字体  
font-source-code-pro  # Adobe 开源编程字体
font-cascadia-code    # Microsoft 编程字体
```

**特点：**
- 支持编程连字符
- 等宽设计  
- 提升代码可读性
- **优先安装**：为后续开发工具提供字体支持

### 📦 essential - 基础必需工具 (优先级: 2)
**任何 Mac 用户都需要的现代化系统工具，核心基础设施**

```ruby
# Shell 和终端增强 (现代化替代品)
autojump, fzf, bat, eza, ripgrep, fd, tree

# 基础系统工具
git, curl, wget, htop, neofetch

# 数据处理工具
jq, yq

# 网络工具
httpie, nmap, netcat, telnet

# 文件处理
p7zip, unrar, keka, imagemagick, ffmpeg

# 安全工具
gnupg
```

**特点：**
- 现代化的命令行工具替代品
- 提升原生工具的使用体验
- 任何环境都适用
- **必需基础**：为开发工具提供基础命令支持

### 💻 development - 开发环境工具 (优先级: 3)  
**软件开发者的核心工具链，依赖基础工具正常运行**

```ruby
# 编程语言运行时
Node.js 生态: node, yarn, pnpm
Java 生态: openjdk@8/11/17/21, maven, gradle, jenv
Go 语言: go, golangci-lint
Python 工具: pipx

# 容器和编排
docker, docker-compose, kubectl, k9s, helm

# API 和调试
grpcurl, wireshark

# 代码质量
shellcheck, hadolint, markdownlint-cli

# 文档工具
pandoc
```

**特点：**
- 覆盖主流编程语言
- 容器化开发支持
- 代码质量保证工具
- **依赖基础**：需要 essential 模块的命令行工具支持

### 🎨 optional - 可选工具 (优先级: 4)
**个人偏好和特殊需求工具，最后安装避免冲突**

- 模块设计为空，支持个人定制
- 通过 `brew-sync` 自动添加未分类工具
- 完全个人化选择

## 🚀 快速开始

### 方式一：一键智能安装（推荐新用户）

> **✨ 新功能**：支持智能安装顺序优化和详细安装统计

```bash
# 进入 homebrew 目录
cd ~/dotfiles/homebrew

# 启动交互式安装向导（自动优化安装顺序）
./brew-setup.sh --interactive

# 或使用预定义方案（按优先级自动排序）
./brew-setup.sh --profile developer    # fonts → essential → development
./brew-setup.sh --profile minimal      # essential only
./brew-setup.sh --profile server       # essential → development  
./brew-setup.sh --profile full         # fonts → essential → development → optional
```

**安装特性：**
- 🔄 **智能排序**：自动按优先级安装（fonts → essential → development → optional）
- 📊 **详细统计**：显示每个模块的成功/失败软件包数量
- 🔍 **失败诊断**：提供具体失败包名称和处理建议
- ⏱️ **时间统计**：显示每个模块安装时间和总体效率

### 方式二：直接模块安装

```bash
# 安装单个模块
./brew-setup.sh essential
./brew-setup.sh development fonts

# 安装多个模块
./brew-setup.sh essential development fonts
```

### 方式三：使用 brew bundle

```bash
# 安装所有模块（通过主 Brewfile）
brew bundle install

# 安装指定模块
brew bundle install --file=Brewfile.essential
brew bundle install --file=Brewfile.development
```

## 🛠️ 管理函数详解

### 加载管理函数

```bash
# 在 zsh/functions.zsh 中添加
[[ -f ~/dotfiles/homebrew/brew-functions.zsh ]] && source ~/dotfiles/homebrew/brew-functions.zsh

# 重新加载配置
source ~/.zshrc
```

### 核心管理函数

```bash
# 模块管理（支持详细统计）
brew-list-modules                    # 列出所有可用模块（含统计信息）
brew-install-module <module>         # 安装指定模块（显示详细进度）
brew-install-modules <modules...>    # 批量安装模块（智能排序 + 详细统计）
brew-check-module <module>           # 检查模块同步状态
brew-preview-module <module>         # 预览模块内容

# 智能安装方案（优化安装顺序）
brew-auto-setup                      # 智能环境检测安装
brew-install-developer               # 按优化顺序安装开发环境
brew-install-full                    # 按优化顺序安装完整环境

# 同步和维护
brew-sync                            # 智能同步（检测未记录软件）
brew-health-check                    # 全面健康检查
brew-weekly-maintenance              # 每周维护任务

# 实用工具
brew-search-enhanced <keyword>       # 增强搜索功能
brew-info-enhanced <package>         # 增强包信息显示
```

**📊 新增统计功能：**
- **模块级统计**：成功安装X个，失败Y个模块
- **软件包级详情**：具体显示哪些包安装成功/失败
- **时间分析**：每个模块安装时间和成功率分析
- **错误诊断**：失败包的具体错误信息和处理建议

### 便捷别名

```bash
# 模块管理
blm     # brew-list-modules
bim     # brew-install-module
bcm     # brew-check-module
bims    # brew-install-modules
bpm     # brew-preview-module

# 一键安装
bas     # brew-auto-setup
bmin    # brew-install-minimal
bdev    # brew-install-developer
bsrv    # brew-install-server
bfull   # brew-install-full

# 维护工具
bsy     # brew-sync
bhc     # brew-health-check
bwm     # brew-weekly-maintenance

# 搜索工具
bse     # brew-search-enhanced
bie     # brew-info-enhanced
```

## 📖 使用指南

### 🚀 新环境快速部署

**推荐流程（智能检测）：**

```bash
# 1. 运行智能安装向导
cd ~/dotfiles/homebrew
./brew-setup.sh --interactive

# 2. 加载管理函数
source ~/.zshrc

# 3. 验证安装
brew-health-check
```

**手动选择方案：**

```bash
# 开发者完整环境
./brew-setup.sh --profile developer

# 服务器环境（无 GUI）
./brew-setup.sh --profile server

# 最小环境
./brew-setup.sh --profile minimal
```

### ⚙️ 日常维护

#### 每周维护（15分钟自动化）

```bash
# 一键每周维护
brew-weekly-maintenance

# 包含以下步骤：
# 1. 更新 Homebrew
# 2. 升级所有软件包
# 3. 智能同步检查
# 4. 清理缓存
# 5. 健康检查
```

#### 探索新工具流程

```bash
# 1. 直接安装试用
brew install new-cool-tool

# 2. 使用一段时间评估

# 3. 定期整理（智能同步）
brew-sync                    # 自动检测未记录工具
                             # 提供添加到 Brewfile.optional 选项

# 4. 手动分类（如果需要）
# 编辑对应的 Brewfile 模块
```

### 🔧 高级配置

#### 环境变量配置

```bash
# 在 zsh/exports.zsh 中设置
export HOMEBREW_NO_ANALYTICS=1       # 禁用分析
export HOMEBREW_NO_AUTO_UPDATE=1     # 禁用自动更新  
export HOMEBREW_MODULE_DIR="$HOME/dotfiles/homebrew"  # 自定义模块目录
```

#### 创建自定义模块

```bash
# 为特定项目创建模块
cat > ~/dotfiles/homebrew/Brewfile.web-project << 'EOF'
# Web 项目特定工具
brew "postgresql"
brew "redis"
brew "nginx"
EOF

# 安装项目特定工具
brew-install-module web-project
```

#### 团队环境同步

```bash
# 新团队成员环境搭建
git clone <team-dotfiles-repo>
cd dotfiles/homebrew
./brew-setup.sh --profile developer

# 现有成员同步更新
git pull origin main
brew-sync                    # 检查并安装新增工具
```

### 🔍 故障排除

#### 常见问题

1. **安装失败**：
   ```bash
   # 检查网络连接
   ./brew-setup.sh --help     # 查看所有选项
   
   # 检查系统状态
   brew doctor
   
   # 重试安装
   brew-install-module essential --verbose
   ```

2. **模块同步问题**：
   ```bash
   # 检查模块状态
   brew-check-module essential
   
   # 强制重新安装
   brew bundle install --file=Brewfile.essential --force
   ```

3. **函数无法使用**：
   ```bash
   # 检查函数是否加载
   which brew-list-modules
   
   # 重新加载函数
   source ~/dotfiles/homebrew/brew-functions.zsh
   ```

#### 系统健康检查

```bash
# 全面健康检查
brew-health-check

# 检查内容：
# - Homebrew 本身状态
# - 各模块同步状态  
# - 磁盘使用情况
# - 缓存大小统计
```

#### 调试模式

```bash
# 启用详细输出
export HOMEBREW_DEBUG=1
export HOMEBREW_VERBOSE=1

# 执行调试安装
./brew-setup.sh essential --dry-run    # 预览模式
./brew-setup.sh essential --verbose    # 详细模式
```

## 🎯 最佳实践

### 安装顺序最佳实践

1. **遵循模块优先级**：
   ```bash
   # ✅ 推荐：按优先级安装（自动处理）
   ./brew-setup.sh --profile developer
   
   # ❌ 避免：跳过基础模块直接安装开发工具
   brew-install-module development     # 可能缺少基础命令支持
   ```

2. **理解模块依赖关系**：
   - **fonts**: 为终端和编辑器提供字体支持
   - **essential**: 提供现代化基础命令（development 依赖）
   - **development**: 依赖 essential 的工具链
   - **optional**: 独立工具，最后安装避免冲突

3. **监控安装统计**：
   ```bash
   # 安装后检查统计信息
   brew-health-check                   # 查看整体成功率
   
   # 处理失败的软件包
   brew install <failed-package-name>  # 手动重试失败的包
   ```

### 日常开发习惯

1. **模块化思维**：
   - 新工具先试用：`brew install new-tool`
   - 确定保留后分类：添加到对应模块
   - 定期整理：每周运行 `brew-weekly-maintenance`
   - **注意安装顺序**：新增工具时考虑模块依赖关系

2. **环境区分**：
   - 桌面开发：`developer` 方案
   - 服务器部署：`server` 方案  
   - CI/CD 环境：`minimal` 方案

3. **版本管理**：
   - 重要变更及时提交
   - PR 包含 Brewfile 变更说明
   - 使用语义化提交信息

### 团队协作流程

1. **新工具引入**：
   ```bash
   # 1. 团队讨论确定模块归属
   # 2. 编辑对应 Brewfile
   echo 'brew "new-team-tool"' >> Brewfile.development
   
   # 3. 测试安装
   brew-install-module development
   
   # 4. 提交 PR
   git add Brewfile.development
   git commit -m "feat(homebrew): add new-team-tool for XYZ feature"
   ```

2. **环境同步**：
   ```bash
   # 团队成员定期同步
   git pull origin main
   brew-sync                    # 检查新增工具
   brew-health-check           # 验证环境状态
   ```

### 性能优化

1. **安装优化**：
   - 使用 `--dry-run` 预览安装
   - 分批安装大量软件
   - 避免网络高峰期安装

2. **维护优化**：
   - 定期清理缓存：`brew cleanup`
   - 卸载不需要的工具
   - 监控磁盘使用情况

## 🔄 更新和迁移

### 版本升级

```bash
# 更新脚本和函数
git pull origin main

# 重新加载函数
source ~/.zshrc

# 验证更新
brew-health-check
```

### 环境迁移

```bash
# 导出当前环境
brew bundle dump --file=~/current-env.Brewfile

# 在新环境中
git clone <dotfiles-repo>
cd dotfiles/homebrew
./brew-setup.sh --profile developer
```

## 📊 统计信息

查看当前环境统计：

```bash
# 模块统计
brew-list-modules

# 安装统计  
echo "CLI 工具: $(brew list --formula | wc -l)"
echo "GUI 应用: $(brew list --cask | wc -l)"
echo "缓存大小: $(du -sh $(brew --cache) 2>/dev/null | cut -f1)"
```

## 🤝 贡献指南

1. **功能增强**：
   - Fork 项目并创建功能分支
   - 测试新功能确保兼容性
   - 更新文档说明使用方法
   - 提交 PR 并描述变更内容

2. **模块贡献**：
   - 保持模块职责单一
   - 添加详细的注释说明
   - 测试安装过程无误
   - 考虑不同用户需求

3. **文档改进**：
   - 保持文档与代码同步
   - 提供清晰的使用示例
   - 添加常见问题解答

## 📄 许可证

MIT License - 详见根目录 [LICENSE](../LICENSE) 文件

---

**Happy Brewing!** 🍺✨

> 这个包管理方案通过模块化设计和智能化脚本，实现了高效灵活的开发环境管理。90% 的维护工作都能自动化完成，让你专注于开发本身！

## 🔗 相关链接

- [Homebrew 官方文档](https://docs.brew.sh/)
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)
- [dotfiles 项目主页](../README.md)
