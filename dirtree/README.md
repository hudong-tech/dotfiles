# 🌳 Dirtree - 智能目录结构管理工具

一个强大而优雅的目录结构创建和管理工具，专为现代知识工作者和开发者设计。

## 🎯 核心功能

### 📋 模板系统
- **预置模板**: 提供文档管理、项目结构等常用模板
- **自定义模板**: 支持创建和管理个人模板
- **模板验证**: 自动检查模板文件格式的正确性

### 🚀 目录创建
- **一键创建**: 基于模板快速生成完整目录结构
- **智能检测**: 自动跳过已存在的目录，避免冲突
- **详细反馈**: 提供创建过程的详细状态和统计信息

### 🛠️ 管理工具
- **结构预览**: 可视化查看模板将创建的目录树
- **状态统计**: 分析现有目录结构的详细信息
- **清理工具**: 智能清理空目录和冗余结构
- **备份功能**: 安全备份现有目录结构

## 📦 安装和配置

### 安装
dirtree模块已集成在dotfiles项目中，通过`.zshrc`自动加载：

```bash
# 模块会在shell启动时自动加载
source ~/.zshrc
```

### 目录结构
```
dirtree/
├── functions.zsh         # 核心功能函数库
├── build_dir_tree.sh     # 交互式界面脚本
├── templates/            # 模板文件目录
│   └── documents.dirs    # 文档管理模板
└── README.md            # 本文档
```

## 🚀 快速开始

### 1. 查看可用模板
```bash
dirtree_list
```

### 2. 预览模板结构
```bash
dirtree_preview documents
```

### 3. 创建目录结构
```bash
# 在指定目录创建文档管理结构
dirtree_create ~/MyDocuments documents

# 快捷创建到默认文档目录
dirtree_create_docs
```

### 4. 使用交互式界面
```bash
# 启动图形化界面
./build_dir_tree.sh
```

## 📚 详细功能说明

### 核心创建功能

#### `dirtree_create <目标目录> <模板名>`
创建目录结构的主要命令
```bash
# 基本用法
dirtree_create ~/Documents documents
dirtree_create ~/MyProject /path/to/custom.dirs

# 使用绝对路径的模板文件
dirtree_create ~/Workspace /custom/path/template.dirs
```

#### `dirtree_create_docs [目标目录]`
快捷创建文档管理结构
```bash
# 在默认文档目录创建
dirtree_create_docs

# 在指定目录创建  
dirtree_create_docs ~/MyDocs
```

### 模板管理功能

#### `dirtree_list`
列出所有可用模板及其描述信息
- 显示模板名称和描述
- 统计可用模板数量
- 提供使用提示

#### `dirtree_info <模板名>`
显示模板的详细信息
```bash
dirtree_info documents
```
包含：
- 模板基本信息（名称、描述、适用场景）
- 统计数据（目录数量、行数、注释行数）
- 使用建议

#### `dirtree_preview <模板名>`
预览模板将创建的目录结构
```bash
dirtree_preview documents
```
- 树形结构可视化显示
- 目录层级关系清晰
- 不实际创建目录

#### `dirtree_validate <模板名>`
验证模板文件的格式正确性
```bash
dirtree_validate documents
```
检查项目：
- 文件存在性
- 路径格式规范性
- 命名约定合规性
- 结构层次合理性

### 管理和维护功能

#### `dirtree_status <目录路径>`
分析现有目录结构的详细信息
```bash
dirtree_status ~/Documents
```
提供：
- 目录总数和深度统计
- 空目录识别
- 大型目录分析
- 结构健康度评估

#### `dirtree_cleanup <目录路径>`
清理目录结构中的空目录
```bash
dirtree_cleanup ~/Documents
```
功能：
- 递归删除空目录
- 保护重要系统目录
- 提供清理前预览
- 详细操作日志

#### `dirtree_backup <源目录>`
备份现有目录结构
```bash
dirtree_backup ~/Documents  
```
特性：
- 只备份目录结构，不包含文件内容
- 时间戳命名避免冲突
- 压缩存储节省空间
- 提供恢复指令

#### `dirtree_generate_docs <模板名>`
为模板文件生成详细的用途说明文档
```bash
dirtree_generate_docs documents
```

## 📝 模板文件格式

### 基本格式

## 🎨 交互式界面

### 启动界面
```bash
cd ~/dotfiles/dirtree
./build_dir_tree.sh
```

### 功能菜单
1. **快速开始** - 创建目录结构的向导式流程
2. **模板管理** - 模板查看、预览和验证工具  
3. **退出程序** - 安全退出

### 操作流程
1. 选择模板（支持上下键导航）
2. 输入目标目录路径
3. 确认创建配置
4. 执行创建操作
5. 查看结果统计

## ⚙️ 高级配置

### 环境变量
```bash
# 启用调试模式，显示详细日志
export DOTFILES_DEBUG=1

# 自定义模板目录（可选）
export DIRTREE_TEMPLATES_DIR="/custom/templates/path"
```

### 自定义模板
在`templates/`目录下创建`.dirs`文件：
```bash
# 创建新模板文件
vim templates/myproject.dirs

# 验证模板格式
dirtree_validate myproject

# 测试模板
dirtree_preview myproject
```

## 🔧 故障排除

### 常见问题

**Q: 模板文件找不到**
```bash
# 检查模板目录
ls -la ~/dotfiles/dirtree/templates/

# 验证模板路径
dirtree_list
```

**Q: 目录创建失败**
```bash
# 检查目标目录权限
ls -ld /path/to/target/directory

# 确保路径存在
mkdir -p /path/to/parent/directory
```

**Q: 函数命令不存在**
```bash
# 重新加载配置
source ~/.zshrc

# 检查模块加载状态
echo $DIRTREE_DIR
```

### 调试模式
```bash
# 启用详细日志
export DOTFILES_DEBUG=1
dirtree_create ~/test documents

# 查看模块路径
echo "模块目录: $DIRTREE_DIR"
echo "模板目录: $DIRTREE_TEMPLATES_DIR"
```

## 📊 性能特性

- **快速执行**: 纯Shell实现，启动速度快
- **内存友好**: 逐行处理模板文件，内存占用低
- **错误容错**: 完善的错误处理和回滚机制
- **并发安全**: 支持多实例同时运行

## 🤝 贡献指南

### 添加新模板
1. 在`templates/`目录创建`.dirs`文件
2. 遵循命名约定和格式规范
3. 添加详细的模板信息注释
4. 使用`dirtree_validate`验证格式

### 扩展功能
1. 在`functions.zsh`中添加新函数
2. 遵循现有的命名约定（`dirtree_`前缀）
3. 添加完整的错误处理和用户反馈
4. 更新本README文档

## 📄 许可证

本项目遵循与dotfiles主项目相同的许可证。

## 🏷️ 版本历史

- **v1.0** (2025-06-14) - 初始版本，包含核心功能和文档模板

---

💡 **提示**: 这个工具设计用于提高工作效率，通过标准化的目录结构来改善文件组织和管理。建议结合个人或团队的工作流程，定制适合的模板。
