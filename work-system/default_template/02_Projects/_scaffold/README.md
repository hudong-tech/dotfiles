# _scaffold 项目脚手架工具

> **"标准化是效率的开始，自动化是效率的终点。"**
>  让项目创建从手工作坊升级为工业化生产线 🏭

## 🎯 工具价值

### 解决的问题

- ❌ **手动创建项目** - 目录结构不一致，容易遗漏重要文件
- ❌ **重复性工作** - 每次都要复制粘贴相同的模板文件
- ❌ **标准化缺失** - 团队成员各自为政，项目结构千差万别
- ❌ **元数据管理** - 项目信息散乱，难以统一管理和统计

### 带来的收益

- ✅ **一致性保障** - 所有项目遵循统一标准，降低认知负担
- ✅ **效率提升** - 30秒完成标准项目创建，专注核心业务开发
- ✅ **质量提升** - 内置最佳实践，避免常见的结构设计错误
- ✅ **可维护性** - 标准化的项目结构便于长期维护和交接

## 📁 目录结构

```
_scaffold/
│
├── init_project.sh           # 🚀 项目初始化脚本（主工具）
│
└── templates/                # 📝 项目模板库
    └── default_project/      # 📋 默认项目模板
        ├── CHANGELOG.md      # 变更记录模板
        ├── project.yaml      # 项目元数据配置
        ├── README.md         # 项目说明文档模板
        ├── code/             # 源码目录
        ├── data/             # 数据文件目录  
        ├── design/           # 设计资源目录
        ├── doc/              # 文档目录
        ├── infra/            # 基础设施脚本目录
        ├── output/           # 交付物目录
        └── tests/            # 测试用例目录
```

## 🚀 快速开始

### 基础用法

```bash
# 进入脚手架目录
cd /work/02_Projects/_scaffold

# 创建项目（最简用法）
./init_project.sh proj-ai-beacon

# 创建项目（带描述）
./init_project.sh proj-crm-lite "轻量级CRM系统"

# 创建项目（完整参数）
./init_project.sh proj-data-pipeline "数据处理管道" "@alice"
```

### 查看帮助

```bash
./init_project.sh --help
```

### 执行效果预览

```
🚀 项目初始化脚本 v1.0
          
让项目创建变得简单而标准化 ✨

ℹ️  开始初始化项目: proj-ai-beacon

Step 1/3: 验证项目名称
✅ 项目名称验证通过

Step 2/3: 创建目录结构  
ℹ️  创建项目目录: ../01_Active/proj-ai-beacon
✅ 目录结构创建完成

Step 3/3: 处理模板文件
📊 进度: [██████████████████████████████] 100% (3/3)
✅ 模板处理完成

📈 项目创建统计
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 项目名称: proj-ai-beacon
📂 项目路径: ../01_Active/proj-ai-beacon  
🗂️  创建目录: 10 个
📄 创建文件: 4 个
🔧 处理模板: 3 个
⏱️  执行时间: 2s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉 项目创建成功！
```

## 📋 模板详解

### 核心模板文件

| 文件           | 作用           | 占位符                                                       |
| -------------- | -------------- | ------------------------------------------------------------ |
| `README.md`    | 项目说明文档   | `PROJECT_NAME`                                               |
| `project.yaml` | 项目元数据配置 | `PROJECT_NAME`, `PROJECT_DESC`, `__START_DATE__`, `__DUE_DATE__` |
| `CHANGELOG.md` | 变更记录       | `PROJECT_NAME`, `$(date +%F)`                                |

### 目录结构说明

| 目录      | 用途     | 建议内容                      |
| --------- | -------- | ----------------------------- |
| `code/`   | 源代码   | 按语言或模块分子目录          |
| `data/`   | 数据文件 | 样本数据、测试数据、配置文件  |
| `design/` | 设计资源 | 原型图、UI设计、图标资源      |
| `doc/`    | 项目文档 | 需求文档、技术方案、会议纪要  |
| `infra/`  | 基础设施 | Docker文件、K8s配置、部署脚本 |
| `output/` | 交付物   | 编译产物、报告、演示文件      |
| `tests/`  | 测试代码 | 单元测试、集成测试、e2e测试   |

## 🔧 自定义模板

### 创建新模板类型

```bash
# 1. 复制默认模板
cp -r templates/default_project templates/web_app_project

# 2. 修改新模板的结构和内容
# 3. 更新 init_project.sh 脚本支持模板选择（可选）
```

### 修改占位符

在模板文件中使用以下占位符，脚本会自动替换：

| 占位符           | 替换内容     | 示例             |
| ---------------- | ------------ | ---------------- |
| `PROJECT_NAME`   | 项目名称     | `proj-ai-beacon` |
| `PROJECT_DESC`   | 项目描述     | `AI媒体追踪平台` |
| `__START_DATE__` | 项目开始日期 | `2025-07-21`     |
| `__DUE_DATE__`   | 项目截止日期 | `2025-08-20`     |
| `@yourname`      | 项目负责人   | `@alice`         |

### 添加新占位符

1. 在模板文件中使用 `__YOUR_PLACEHOLDER__` 格式

2. 在 

   ```
   init_project.sh
   ```

    的 

   ```
   process_templates()
   ```

    函数中添加替换规则：

   ```bash
   sed -e "s/__YOUR_PLACEHOLDER__/$your_variable/g" \
   ```

## 📏 项目命名规范

### ✅ 正确格式

```
proj-<business>-<keyword>
```

### 📝 命名示例

| 业务领域    | 推荐命名             | 说明              |
| ----------- | -------------------- | ----------------- |
| AI/机器学习 | `proj-ai-beacon`     | AI + 具体功能     |
| 增长营销    | `proj-growth-funnel` | growth + 具体场景 |
| CRM系统     | `proj-crm-lite`      | crm + 版本特性    |
| 数据处理    | `proj-data-pipeline` | data + 处理类型   |
| 基础设施    | `proj-infra-monitor` | infra + 功能      |

### ❌ 常见错误

- `ai-beacon` - 缺少 `proj-` 前缀
- `proj_ai_beacon` - 使用下划线而非连字符
- `Proj-AI-Beacon` - 包含大写字母
- `proj-ai-beacon-system-v2` - 名称过长

## 🛠️ 高级用法

### 批量创建项目

```bash
# 创建批量创建脚本
cat > batch_create.sh << 'EOF'
#!/bin/bash
projects=(
    "proj-user-service:用户服务:@backend-team"
    "proj-order-service:订单服务:@backend-team" 
    "proj-payment-gateway:支付网关:@payment-team"
)

for project in "${projects[@]}"; do
    IFS=':' read -r name desc owner <<< "$project"
    ./init_project.sh "$name" "$desc" "$owner"
done
EOF

chmod +x batch_create.sh
./batch_create.sh
```

### 项目状态管理

```bash
# 创建项目后移动到不同状态目录
./init_project.sh proj-new-feature "新功能开发"

# 移动到规划阶段
mv ../01_Active/proj-new-feature ../02_Planning/

# 移动到开发阶段  
mv ../02_Planning/proj-new-feature ../01_Active/
```

## 🔍 故障排除

### 常见问题

**Q: 脚本执行权限不足**

```bash
# 解决方案：添加执行权限
chmod +x init_project.sh
```

**Q: 项目已存在无法创建**

```bash
# 脚本会自动跳过已存在的项目，这是正常行为
# 如需重新创建，请先删除现有项目目录
rm -rf ../01_Active/proj-existing-name
```

**Q: 模板文件缺失**

```bash
# 检查模板目录完整性
tree templates/default_project/

# 从Git恢复模板（如果使用版本控制）
git checkout templates/default_project/
```

**Q: 日期格式在 macOS 上报错**

```bash
# 脚本已内置跨平台兼容性，自动处理 macOS 和 Linux 差异
# 无需手动处理
```

### 调试模式

```bash
# 启用详细输出
bash -x ./init_project.sh proj-debug-test
```

## 📊 使用统计

脚本自动提供以下统计信息：

- 📁 创建目录数量
- 📄 创建文件数量
- 🔧 处理模板数量
- ⏱️ 执行耗时
- 📂 项目最终路径

## 🚀 最佳实践

### 团队协作

1. **统一使用脚手架** - 团队成员都通过脚手架创建项目
2. **定期更新模板** - 根据团队实践优化模板内容
3. **版本控制** - 将脚手架纳入Git管理，保持团队同步

### 模板维护

1. **保持简洁** - 模板只包含必要的基础结构
2. **文档齐全** - 每个目录都有清晰的用途说明
3. **示例丰富** - 在README模板中提供使用示例

### 自动化集成

1. **CI/CD集成** - 在流水线中自动创建分支对应的项目目录
2. **项目看板** - 基于 project.yaml 自动生成项目状态看板
3. **定期归档** - 脚本化处理完成项目的归档

------

**记住："好的工具不仅节省时间，更重要的是建立标准。"**

这个脚手架工具让你的项目创建过程标准化、自动化、可维护化。每次使用都是对最佳实践的强化，长期积累将带来巨大的效率提升！🚀