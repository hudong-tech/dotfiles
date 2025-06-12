# Templates 目录设计文档

> 🎯 **灵活模板，用于开发测试** - 在不可能三角中优先选择灵活性

## 📋 目录

- [概述](#概述)
- [模板列表](#模板列表)
- [使用场景](#使用场景)
- [快速开始](#快速开始)
- [使用流程](#使用流程)
- [核心设计原则](#核心设计原则)
- [技术方案](#技术方案)
- [设计权衡](#设计权衡)
- [依赖解析机制](#依赖解析机制)
- [版本支持策略](#版本支持策略)
- [最佳实践](#最佳实践)
- [故障排除](#故障排除)

---

## 🎯 概述

Templates 目录提供**灵活的 Python 环境模板**，专门用于开发测试场景。

### 核心特点

- 🔧 **参数化设计**：单一模板支持 Python 3.9/3.10/3.11
- ⚡ **完整工具链**：开箱即用的开发环境，无需额外配置
- 🔄 **版本灵活**：自动获得最新兼容版本，享受最新特性
- 🛠️ **功能完整**：包含测试、调试、格式化等全套开发工具
- 📦 **开发优化**：针对开发测试场景优化的包选择

### 在多层次架构中的定位

```
📁 templates/   ← 灵活模板（开发测试用）
📁 locked/      ← 锁定模板（生产环境用）  
📁 minimal/     ← 最小模板（快速实验用）
```

**Templates 的优先级**：**灵活性 > 维护性 > 可重现性**

---

## 📦 模板列表

> **Python 版本支持**: 所有 templates 模板统一支持 `Python 3.9, 3.10, 3.11`

### 🔥 高优先级（必须有）

| 模板名 | 用途 | 主要包 | 估计大小 |
|--------|------|---------|----------|
| **python-basic** | 通用Python开发 | pytest, black, mypy, requests | ~500MB |
| **datascience** | 数据科学全家桶 | numpy, pandas, matplotlib, seaborn, jupyter | ~1.5GB |
| **web-fastapi** | 现代API开发 | fastapi, uvicorn, pydantic, sqlalchemy | ~600MB |
| **machinelearning** | 机器学习环境 | scikit-learn, xgboost, lightgbm, optuna | ~1.2GB |

### ⭐ 中优先级（很有用）

| 模板名 | 用途 | 主要包 | 估计大小 |
|--------|------|---------|----------|
| **deeplearning-pytorch** | PyTorch深度学习 | pytorch, torchvision, transformers, wandb | ~2.8GB |
| **web-django** | Django Web开发 | django, drf, celery, redis-py | ~1.2GB |
| **ai-llm** | 大模型AI开发 | transformers, accelerate, vllm, langchain | ~2.5GB |

### 🏢 企业级专用（高级需求）

| 模板名 | 用途 | 主要包 | 估计大小 |
|--------|------|---------|----------|
| **enterprise-devops** | 企业级DevOps | terraform, kubernetes, docker, ansible | ~2.2GB |
| **enterprise-webscraping** | 企业级网络爬虫 | playwright, scrapy, aiohttp, celery | ~2.5GB |

### 💡 特殊需求（专业领域）

| 模板名 | 用途 | 主要包 | 估计大小 |
|--------|------|---------|----------|
| **research** | 科学研究环境 | scipy, sympy, networkx, biopython, rdkit | ~3.8GB |
| **minimal** | 最小化环境 | ipython, requests, black, typer, rich | ~150MB |

### 🚀 GPU加速版本（扩展计划）

| 模板名 | 用途 | 特殊要求 | 估计大小 |
|--------|------|----------|----------|
| **machinelearning-gpu** | GPU机器学习 | CUDA 11.8+ | ~3GB |
| **deeplearning-pytorch-gpu** | PyTorch GPU版 | CUDA 11.8+ | ~4GB |
| **ai-llm-gpu** | 大模型GPU推理 | CUDA 11.8+, 24GB+ VRAM | ~5GB |

---

## 🎯 使用场景

### ✅ 适合的场景

| 场景 | 描述 | 典型用例 | 为什么选择 Templates |
|------|------|----------|---------------------|
| **🔧 功能开发** | 需要完整工具链的正式开发 | 新功能开发、重构项目 | 工具齐全，版本新 |
| **🧪 原型验证** | 快速试验想法和技术方案 | POC开发、技术调研 | 创建快速，功能完整 |
| **🔍 依赖测试** | 测试包的兼容性和版本升级 | 依赖升级验证、兼容性测试 | 版本灵活，易于测试 |
| **👥 团队开发** | 提供一致的开发基础环境 | 团队协作、新人onboarding | 标准化环境，减少配置 |
| **📚 学习探索** | 尝试不同库和工具的组合 | 技术学习、工具评估 | 包全面，便于探索 |

### ❌ 不适合的场景

| 场景 | 问题 | 推荐方案 | 原因 |
|------|------|----------|------|
| **🚀 生产部署** | 版本不稳定，可重现性差 | 使用 `locked/` 模板 | 生产需要精确版本 |
| **⚡ 快速实验** | 环境过重，创建时间长 | 使用 `minimal` 模板 | 实验只需核心功能 |
| **🔒 严格可重现** | 版本会随时间漂移 | 使用 `locked/` 模板 | 科研等需要精确重现 |
| **📦 容器化环境** | Docker 更适合容器部署 | 考虑 Docker 多阶段构建 | 容器有更好的隔离性 |
| **🎯 特定用途** | 通用环境包含不必要的包 | 使用专门的自定义模板 | 避免环境臃肿 |

---

## ⚡ 快速开始

### 立即上手

```bash
# 1️⃣ 查看可用模板
ls conda/environments/templates/

# 2️⃣ 创建开发环境
conda_create_from_template python-basic myenv 3.10

# 3️⃣ 激活环境
conda activate myenv

# 4️⃣ 验证环境
python --version    # Python 3.10.x
pytest --version    # 已安装测试框架
black --version     # 已安装代码格式化
```

### 5分钟体验

```bash
# 创建项目目录
mkdir my-project && cd my-project

# 初始化 git 仓库
git init

# 创建示例代码
cat > hello.py << EOF
def greet(name: str) -> str:
    """返回问候语"""
    return f"Hello, {name}!"

if __name__ == "__main__":
    print(greet("World"))
EOF

# 创建测试文件
cat > test_hello.py << EOF
from hello import greet

def test_greet():
    assert greet("Alice") == "Hello, Alice!"
EOF

# 运行测试
pytest test_hello.py           # ✅ 测试通过

# 格式化代码
black hello.py                 # ✅ 代码格式化

# 类型检查
mypy hello.py                  # ✅ 类型检查通过
```

### 常用命令

```bash
# 不同 Python 版本
conda_create_from_template python-basic env-39 3.9
conda_create_from_template python-basic env-310 3.10
conda_create_from_template python-basic env-311 3.11

# 不同模板类型
conda_create_from_template datascience ds-env 3.10
conda_create_from_template web-fastapi api-env 3.10
conda_create_from_template machinelearning ml-env 3.11
conda_create_from_template minimal experiment 3.11

# 企业级模板
conda_create_from_template enterprise-devops devops-env 3.10
conda_create_from_template enterprise-webscraping crawler-env 3.10

# 预览模式（不实际创建）
conda_create_from_template python-basic test-env 3.10 --dry-run
```

### 📋 模板选择指导

```bash
# 📊 项目类型 → 模板选择
通用开发           → python-basic
最小实验           → minimal  
数据分析          → datascience  
机器学习          → machinelearning
深度学习          → deeplearning-pytorch
大模型开发        → ai-llm
REST API         → web-fastapi
Web应用          → web-django
企业DevOps       → enterprise-devops
网络爬虫          → enterprise-webscraping
科学研究          → research

# 🎯 特殊需求处理
GPU计算           → 使用 *-gpu 版本模板（规划中）
遗留Python版本    → 使用 *-legacy 版本模板（按需创建）
实验性版本        → 使用 *-modern 版本模板（按需创建）
```

---

## 🔄 使用流程

### 开发者典型工作流程

```bash
# 🚀 阶段一：选择合适的模板
# 快速实验 - 使用 minimal 模板
conda_create_from_template minimal experiment 3.11

# 通用开发 - 使用 python-basic 模板  
conda_create_from_template python-basic dev-env 3.10

# 企业项目 - 使用企业级模板
conda_create_from_template enterprise-devops ops-env 3.10
conda_create_from_template enterprise-webscraping scraper-env 3.10

# ✅ 此时你已拥有：
# - Python 3.10.x（最新补丁版本）
# - 完整的开发工具链（pytest, black, mypy, ipython...）
# - 常用库的最新兼容版本（requests, pydantic, click...）
# - 预配置的环境变量和工具设置

# 🔧 阶段二：进行开发工作
# - 所有开发工具已就绪，无需额外安装
# - 版本是当前最新的兼容版本，享受最新特性
# - 跨平台一致的开发体验

# 📊 阶段三：依赖管理（开发过程中）
pip install new-package        # 安装新依赖
pip freeze > requirements.txt  # 导出当前环境

# 🚀 阶段四：准备发布（使用 locked/）
conda_create_from_template python-basic prod-env --locked 2024Q2
# ✅ 获得精确的版本锁定，保证可重现性
```

### 团队协作流程

```bash
# 👥 团队负责人：设置项目标准
conda_create_from_template python-basic project-env 3.10
conda activate project-env
pip freeze > requirements-dev.txt

# 📋 团队成员：复制开发环境
conda_create_from_template python-basic my-dev-env 3.10
conda activate my-dev-env
# 注意：版本可能略有不同（templates 的特点）

# 🔄 定期同步：使用 locked 版本
# 每月/每季度创建 locked 环境确保团队一致性
conda_create_from_template python-basic team-sync --locked 2024Q2
```

### 企业级使用流程

```bash
# 🏢 企业DevOps团队
conda_create_from_template enterprise-devops platform-dev 3.10
conda activate platform-dev

# 现在可以直接使用：
terraform --version         # 基础设施即代码
kubectl get nodes          # Kubernetes 集群管理  
docker --version           # 容器化部署
ansible --version          # 自动化配置管理

# 🕷️ 数据团队网络爬虫
conda_create_from_template enterprise-webscraping data-collector 3.10
conda activate data-collector

# 现在可以直接使用：
playwright install          # 现代浏览器自动化
scrapy startproject myspider # 分布式爬虫框架
python -c "import aiohttp"   # 异步HTTP客户端
```

### 命令行接口详解

```bash
# 基础语法
conda_create_from_template <template_name> <env_name> <python_version> [options]

# 参数说明
<template_name>     # 模板名称（不含.yml后缀）
<env_name>          # 新环境名称
<python_version>    # Python版本（3.9, 3.10, 3.11）

# 高级选项
--dry-run          # 预览不执行，显示将要安装的包
--force            # 强制覆盖同名环境
--offline          # 离线模式，仅使用本地缓存
--verbose          # 详细输出，显示解析过程

# 示例
conda_create_from_template python-basic myenv 3.10 --dry-run --verbose
```

---

## 🎯 核心设计原则

### 设计定位

**Templates** 目录是多层次 Conda 环境管理架构中的**灵活层**，在环境管理的**不可能三角**中做出明确选择：

```
        灵活性
         /\
        /  \
       /    \
      /  📁  \
     / templates \
    /____________\
维护性          可重现性
```

**优先级排序**: **灵活性 > 维护性 > 可重现性**

### 核心原则

1. **🔧 开发友好**
   - 提供完整的开发工具链
   - 预配置常用工具设置
   - 优化开发体验

2. **⚡ 快速迭代**
   - 支持原型开发和功能验证
   - 一条命令创建完整环境
   - 减少环境配置时间

3. **🔄 版本灵活**
   - 自动适配最新兼容版本
   - 获得最新特性和bug修复
   - 支持多Python版本

4. **🛠️ 工具完备**
   - 包含测试、调试、格式化等全套工具
   - 涵盖代码质量保证工具
   - 提供性能分析和安全检查

5. **📦 功能完整**
   - 一次创建，即刻可用
   - 无需手动安装额外依赖
   - 标准化的开发环境

### 设计分层和职责

**基础层 (Foundation)**
- `minimal` - 最小化Python环境，快速实验用
- `python-basic` - 通用Python开发基础

**应用层 (Application)**  
- `web-fastapi` / `web-django` - Web应用开发
- `datascience` / `machinelearning` - 数据科学和ML
- `deeplearning-pytorch` / `ai-llm` - AI和深度学习

**企业层 (Enterprise)**
- `enterprise-devops` - 企业级运维和基础设施
- `enterprise-webscraping` - 企业级数据采集

**研究层 (Research)**
- `research` - 跨学科科学研究和学术

### 设计哲学

**"完整性优于最小性"**：Templates 选择提供完整的功能集，而不是最小化依赖。理由：
- 开发阶段需要各种工具，完整环境避免频繁安装
- 团队协作需要一致的工具链
- 快速原型开发需要丰富的库支持

**"新特性优于稳定性"**：在开发测试阶段，优先获得最新特性：
- 版本范围策略让环境获得最新兼容版本
- 开发者可以及早发现和解决兼容性问题
- 为正式发布做好准备

---

## 🛠️ 技术方案

### 1. 参数化设计

**核心特性**: 单一模板文件支持多个 Python 版本

```yaml
# 模板文件示例
name: python-basic-{{PYTHON_VERSION}}
dependencies:
  - python={{PYTHON_VERSION}}.*
  - numpy>=1.20,<1.26
  - requests>=2.28,<3.0
```

**实现机制**:
```bash
# 用户命令
conda_create_from_template python-basic myenv 3.10

# 内部处理
# 1. 读取 templates/python-basic.yml
# 2. 替换 {{PYTHON_VERSION}} -> 3.10
# 3. 生成实际的环境配置
# 4. 调用 conda create
```

**优势**:
- ✅ 减少模板文件数量（1个文件 vs 3个文件）
- ✅ 保证多版本间的一致性
- ✅ 简化维护工作

### 2. 版本范围策略

**原则**: 使用版本范围而非精确版本，平衡新特性和稳定性

| 包类型 | 版本范围策略 | 示例 | 理由 |
|--------|-------------|------|------|
| **核心包** | 精确主版本 | `python={{PYTHON_VERSION}}.*` | 确保环境一致性 |
| **基础库** | 保守范围 | `numpy>=1.20,<1.26` | 稳定性优先 |
| **开发工具** | 较宽范围 | `black>=23.0,<25.0` | 获得新特性 |
| **实用库** | 主版本锁定 | `requests>=2.28,<3.0` | 避免破坏性更新 |
| **新兴库** | 次版本锁定 | `pydantic>=2.0,<2.2` | 控制快速迭代风险 |

**版本范围制定原则**:
```yaml
# 成熟稳定的库 - 较宽范围
numpy>=1.20,<1.26          # 跨越多个次版本

# 快速迭代的库 - 较窄范围  
fastapi>=0.100,<0.105      # 控制在几个次版本内

# 工具类库 - 激进更新
black>=23.0,<25.0          # 工具改进通常向后兼容
```

### 3. 完整工具链集成

**设计哲学**: 开箱即用，无需额外配置

```yaml
dependencies:
  # 🔧 代码质量工具
  - black>=23.0,<25.0            # 代码格式化
  - ruff>=0.1.0,<1.0             # 快速Python代码检查器
  - mypy>=1.0,<2.0               # 静态类型检查
  - pre-commit>=3.0,<4.0         # Git hooks 管理
  
  # 🧪 测试框架  
  - pytest>=7.2,<8.0            # 测试框架
  - pytest-cov>=4.0,<5.0        # 测试覆盖率
  - coverage>=7.2,<8.0           # 覆盖率报告
  
  # 🔍 调试工具
  - ipython>=8.10,<9.0           # 增强的交互式 Python
  - rich>=13.0,<14.0             # 美化终端输出
  
  # pip 依赖
  - pip:
    - ipdb>=0.13.13,<1.0         # IPython 调试器
```

### 4. 智能环境配置

**预配置环境变量**:
```yaml
variables:
  # Python 运行时优化
  PYTHONUNBUFFERED: "1"          # 禁用输出缓冲
  PYTHONDONTWRITEBYTECODE: "1"   # 禁用 .pyc 文件生成
  PYTHONHASHSEED: "random"       # 随机化 hash 种子
  
  # 开发工具配置
  PIP_DISABLE_PIP_VERSION_CHECK: "1"  # 禁用 pip 版本检查
  PRE_COMMIT_COLOR: "always"          # pre-commit 彩色输出
  
  # 测试配置
  PYTEST_ADDOPTS: "--tb=short --strict-markers"
  COVERAGE_CORE: "sysmon"             # 覆盖率监控模式
```

---

## ⚖️ 设计权衡

### ✅ 优势

| 特性 | 具体表现 | 开发者收益 | 量化指标 |
|------|----------|------------|----------|
| **快速启动** | 一个命令创建完整环境 | 节省配置时间 | 从2小时配置减少到5分钟 |
| **版本灵活** | 自动适配最新兼容版本 | 获得最新特性和bug修复 | 比手动管理新6-12个月 |
| **功能完整** | 包含开发所需全部工具 | 无需手动安装额外依赖 | 减少50+个包的手动安装 |
| **易于维护** | 单文件参数化设计 | 减少模板维护成本 | 3个Python版本共用1个模板 |
| **跨平台兼容** | Windows/macOS/Linux一致体验 | 团队环境统一 | 100%跨平台兼容性 |
| **分层设计** | 从minimal到enterprise的完整梯度 | 精确匹配需求 | 11个专业模板覆盖90%场景 |

### ⚠️ 代价

| 权衡点 | 具体影响 | 影响程度 | 缓解策略 |
|--------|----------|----------|----------|
| **环境漂移** | 不同时间创建的环境版本可能不同 | 中等 | 使用 `locked/` 模板进行生产部署 |
| **依赖冲突** | 版本范围可能导致包冲突 | 低 | 持续测试和版本约束优化 |
| **体积较大** | 完整功能集占用更多空间 | 中等 | 提供 `minimal` 模板作为轻量选择 |
| **创建时间** | 需要解析依赖和下载包 | 低 | 通过缓存和预构建优化（3-5分钟） |
| **选择困难** | 11个模板可能让新用户困惑 | 低 | 提供清晰的选择指导和决策树 |
| **维护成本** | 更多模板意味着更多维护工作 | 中等 | 自动化测试和社区参与 |

### 权衡决策说明

**为什么选择版本范围而不是精确版本？**
- ✅ **开发阶段的优势更大**：能及时发现兼容性问题，为生产做准备
- ✅ **减少维护成本**：不需要频繁更新精确版本号
- ⚠️ **可重现性损失可接受**：开发测试阶段的版本差异在可控范围内

**为什么包含这么多工具？**
- ✅ **开发效率优先**：避免开发过程中频繁安装工具
- ✅ **团队标准化**：确保所有人使用相同的工具链
- ⚠️ **体积增大可接受**：现代开发机器存储充足，网络带宽改善

**为什么创建这么多模板？**
- ✅ **精确匹配需求**：避免通用模板的"一刀切"问题
- ✅ **专业性保证**：每个领域都有最佳实践的工具组合
- ⚠️ **维护成本可控**：通过自动化测试和社区协作分担

---

## 🧠 依赖解析机制

### Conda 依赖解析机制

**工作原理**

当你运行：
```bash
conda_create_from_template python-basic myenv 3.10
```

Conda 会执行以下步骤：

1. **锁定 Python 版本**
   ```yaml
   python=3.10.*  # 锁定为 Python 3.10.x（如 3.10.12）
   ```

2. **依赖解析计算**
   ```yaml
   numpy>=1.20,<1.26  # 在此范围内找与 Python 3.10 兼容的版本
   ```

3. **自动版本选择**
   - Conda 查找所有包的依赖关系
   - 选择满足所有约束的最新兼容版本组合

### 📊 **实际示例对比**

假设当前时间是 2024年12月，相同的 `python-basic.yml` 在不同 Python 版本下：

| 包名 | Python 3.9 | Python 3.10 | Python 3.11 | 版本范围 |
|------|-------------|--------------|-------------|----------|
| **numpy** | 1.24.3 | 1.24.4 | 1.25.1 | `>=1.20,<1.26` |
| **pandas** | 2.0.2 | 2.0.3 | 2.0.3 | `>=1.5,<3.0` |
| **black** | 23.3.0 | 23.7.0 | 23.7.0 | `>=23.0,<25.0` |
| **pytest** | 7.3.1 | 7.4.0 | 7.4.0 | `>=7.2,<8.0` |

### 🎯 **版本选择的影响因素**

#### **1. Python 版本兼容性**
```yaml
# 某些包对新 Python 版本有优化
scikit-learn>=1.2,<2.0
# Python 3.11: 可能选择 1.3.1 (包含 3.11 优化)
# Python 3.9:  可能选择 1.2.8 (稳定版本)
```

#### **2. 包的发布时间**
```yaml
# 较新的包版本可能只支持新 Python 版本
pydantic>=2.0,<3.0
# Python 3.11: 可能选择 2.1.1 (最新版)
# Python 3.9:  可能选择 2.0.3 (兼容版)
```

#### **3. 依赖链约束**
```yaml
# A 包依赖 B 包，B 包依赖 C 包
# Python 版本影响整个依赖链的版本选择
```

这正是 Templates 设计的**灵活性体现**：让每个 Python 版本都能获得最适合的包版本组合。

---

## 📈 版本支持策略

### 当前支持范围

**支持的Python版本**: `3.9, 3.10, 3.11`

| 版本 | 发布时间 | EOL时间 | 状态 | 选择理由 |
|------|----------|---------|------|----------|
| **3.9** | 2020-10 | 2025-10 | ✅ 活跃支持 | 广泛采用的稳定版本 |
| **3.10** | 2021-10 | 2026-10 | ✅ 活跃支持 | 主流版本，新特性成熟 |
| **3.11** | 2022-10 | 2027-10 | ✅ 活跃支持 | 最新稳定版，性能提升 |

### 未支持版本说明

| 版本 | 状态 | 不支持原因 | 备注 |
|------|------|------------|------|
| **3.6** | ❌ EOL (2021-12) | 生命周期结束，包兼容性差 | 考虑遗留模板 |
| **3.7** | ❌ EOL (2023-06) | 生命周期结束，现代包不支持 | 考虑遗留模板 |
| **3.8** | ❌ EOL (2024-10) | 已结束生命周期 | 观察迁移需求 |
| **3.12** | 🚧 最新版 | 生态系统兼容性待验证 | 考虑实验性支持 |

### 版本选择指导

**Python 3.9 - 保守选择**
```yaml
推荐场景:
  - 企业环境，需要最大兼容性
  - 关键项目，稳定性优先
  - 团队中有成员使用较老系统

特点:
  - 包兼容性最好
  - 社区支持最广泛
  - 已知问题最少
```

**Python 3.10 - 平衡选择**
```yaml
推荐场景:
  - 新项目开发
  - 团队协作项目
  - 需要现代特性但要控制风险

特点:
  - 新特性成熟（match语句、更好的错误信息）
  - 包生态完善
  - 性能提升明显
```

**Python 3.11 - 前沿选择**
```yaml
推荐场景:
  - 性能敏感应用
  - 个人项目或小团队
  - 愿意承担少量兼容风险

特点:
  - 性能提升显著（10-60%）
  - 错误信息大幅改进
  - 某些包可能兼容性待验证
```

---

## 💡 最佳实践

### 开发者使用建议

#### **1. 环境选择策略**

```bash
# 🔧 日常开发选择
项目类型                   推荐模板
通用Python开发            → python-basic
快速脚本/实验             → minimal  
数据分析                  → datascience
机器学习                  → machinelearning
深度学习                  → deeplearning-pytorch
大模型开发                → ai-llm
Web API                  → web-fastapi
Web应用                  → web-django
企业运维                  → enterprise-devops
网络爬虫                  → enterprise-webscraping
科学研究                  → research

# 🎯 按项目复杂度选择
简单脚本      → minimal
个人项目      → python-basic + 专业模板
团队项目      → 专业模板 + locked版本定期同步
企业项目      → 企业级模板 + 严格版本控制
```

#### **2. 版本选择指导**

| 项目类型 | 推荐Python版本 | 理由 |
|----------|---------------|------|
| **企业级应用** | 3.9 或 3.10 | 稳定性和兼容性优先 |
| **新项目开发** | 3.10 或 3.11 | 平衡新特性和稳定性 |
| **性能敏感应用** | 3.11 | 显著的性能提升 |
| **学习/实验项目** | 3.11 | 体验最新特性 |
| **开源项目** | 3.9-3.11 | 最大用户覆盖范围 |
| **科学计算** | 3.10 或 3.11 | 数值计算性能优化 |

### 团队协作最佳实践

#### **1. 团队环境标准化**

```bash
# 📋 项目开始时 - 设定团队标准
# 1. 选择Python版本和模板
conda_create_from_template python-basic project-std 3.10

# 2. 记录环境信息
conda activate project-std
conda list > docs/environment-baseline.txt
pip freeze > docs/requirements-baseline.txt

# 3. 创建项目文档
cat > docs/environment.md << EOF
# 项目环境标准

## 创建开发环境
\`\`\`bash
conda_create_from_template python-basic your-name-dev 3.10
conda activate your-name-dev
\`\`\`

## 环境要求
- Python: 3.10
- 模板: python-basic (templates/)
- 创建时间: $(date)
EOF
```

#### **2. 企业级项目管理**

```bash
# 🏢 大型企业项目环境管理

# 开发阶段 - 使用灵活模板获得最新特性
conda_create_from_template enterprise-devops dev-platform 3.10

# 测试阶段 - 锁定版本确保一致性
conda_create_from_template enterprise-devops test-platform --locked 2024Q4

# 生产阶段 - 严格版本控制
conda_create_from_template enterprise-devops prod-platform --locked 2024Q4

# 安全更新 - 定期升级基线
conda_create_from_template enterprise-devops security-baseline --locked 2024Q4-patch1
```

### 性能优化建议

#### **1. 创建速度优化**

```bash
# 🚀 使用中国镜像源（中国用户）
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/

# 启用并行下载和缓存优化
conda config --set channel_priority strict
conda config --set default_threads 4
conda config --set use_only_tar_bz2 false

# 使用 libmamba 求解器（更快的依赖解析）
conda install conda-libmamba-solver
conda config --set solver libmamba
```

#### **2. 存储空间优化**

```bash
# 🧹 定期清理和优化
# 清理包缓存
conda clean --all --yes

# 检查环境大小
du -sh ~/.conda/envs/*

# 删除不需要的环境
conda env list
conda env remove --name unused-env

# 使用硬链接节省空间（Linux/macOS）
conda config --set use_only_tar_bz2 false
```

### 环境管理最佳实践

#### **1. 环境命名规范**

```bash
# 📝 推荐命名规范
个人开发环境:     ${USER}-${PROJECT}-dev
实验环境:        ${PROJECT}-exp-${FEATURE}
测试环境:        ${PROJECT}-test-${VERSION}
共享环境:        ${PROJECT}-shared-${DATE}

# 示例
alice-myapp-dev                    # Alice的myapp开发环境
myapp-exp-webscraping              # myapp的网络爬虫实验
myapp-test-py311                   # myapp在Python3.11的测试
myapp-shared-202412                # myapp 2024年12月共享环境
enterprise-platform-prod-v2.1     # 企业平台生产环境v2.1
```

#### **2. 环境生命周期管理**

```bash
# 🔄 完整的环境生命周期
# 创建 → 开发 → 测试 → 发布 → 维护 → 归档

# 1. 开发阶段（频繁更新）
conda_create_from_template python-basic myapp-dev 3.10

# 2. 功能分支测试
conda_create_from_template python-basic myapp-feature-auth 3.10

# 3. 集成测试环境
conda_create_from_template python-basic myapp-integration --locked 2024Q4

# 4. 预生产环境  
conda_create_from_template python-basic myapp-staging --locked 2024Q4

# 5. 生产环境
conda_create_from_template python-basic myapp-prod --locked 2024Q4

# 6. 环境归档
conda env export --name myapp-prod > archive/myapp-prod-v1.0-$(date +%Y%m%d).yml

# 7. 环境清理
conda env remove --name myapp-old-dev
```

#### **3. 多项目环境隔离**

```bash
# 🏗️ 项目环境隔离策略

# 方案1: 按项目完全隔离
conda_create_from_template datascience project-a-analysis 3.10
conda_create_from_template web-fastapi project-b-api 3.10
conda_create_from_template enterprise-devops project-c-infra 3.10

# 方案2: 共享基础环境 + 项目特定依赖
conda_create_from_template python-basic base-python310 3.10

# 然后为每个项目创建基于基础环境的扩展
conda create --name project-a --clone base-python310
conda activate project-a
pip install -r project-a-requirements.txt

# 方案3: 使用环境前缀组织
conda_create_from_template python-basic team-backend-alice 3.10
conda_create_from_template datascience team-ml-bob 3.10  
conda_create_from_template web-django team-frontend-charlie 3.10
```

---

## 🔧 故障排除

### 常见问题与解决方案

#### **Q1: 为什么不同时间创建的环境包版本不同？**

**现象**：
```bash
# 6月份创建
conda_create_from_template python-basic env1 3.10
# numpy=1.24.3, requests=2.30.0

# 12月份创建  
conda_create_from_template python-basic env2 3.10
# numpy=1.24.4, requests=2.31.0
```

**原因**：这是 Templates 的设计特性。使用版本范围允许获得最新兼容版本。

**解决方案**：
```bash
# 如需精确重现，使用 locked/ 模板
conda_create_from_template python-basic env-stable --locked 2024Q4

# 或导出现有环境精确配置
conda env export --name env1 > env1-exact.yml
conda env create --file env1-exact.yml --name env1-copy
```

#### **Q2: 如何在minimal和其他模板之间选择？**

**决策树**：
```bash
需要完整开发环境? 
├── 否 → minimal (150MB, 2分钟)
└── 是 → 
    ├── 通用开发 → python-basic
    ├── 数据分析 → datascience  
    ├── 机器学习 → machinelearning
    ├── Web开发 → web-fastapi/web-django
    ├── 企业运维 → enterprise-devops
    ├── 网络爬虫 → enterprise-webscraping
    └── 科学研究 → research
```

**实际对比**：
```bash
# minimal模板 - 快速实验
conda_create_from_template minimal experiment 3.11
# 包含: python, ipython, requests, black, typer, rich
# 大小: ~150MB, 时间: 2分钟

# python-basic模板 - 完整开发
conda_create_from_template python-basic development 3.11  
# 包含: 上述 + pytest, mypy, pre-commit, 等50+个包
# 大小: ~500MB, 时间: 5分钟
```

#### **Q3: 企业级模板太大怎么办？**

**现象**：
```bash
# enterprise-devops 模板占用 2.2GB+
# enterprise-webscraping 模板占用 2.5GB+
```

**解决方案**：

**方案1: 分阶段安装**
```bash
# 先创建基础环境
conda_create_from_template python-basic base-enterprise 3.10

# 按需安装企业级工具
conda activate base-enterprise
pip install terraform kubernetes docker ansible  # DevOps工具
# 或
pip install playwright scrapy aiohttp celery    # 爬虫工具
```

**方案2: 选择性组件**
```bash
# 只安装需要的组件
conda create -n custom-devops python=3.10
pip install terraform kubernetes  # 只安装K8s相关
```

**方案3: 容器化方案**
```bash
# 考虑使用Docker镜像
docker run -it python:3.10-slim
pip install terraform kubernetes
```

#### **Q4: 如何处理包版本冲突？**

**现象**：
```
UnsatisfiableError: The following specifications were found to be in conflict:
  - numpy>=1.20,<1.26
  - some-package -> numpy>=1.26
```

**诊断步骤**：
```bash
# 1. 查看冲突详情
conda_create_from_template python-basic test 3.10 --dry-run

# 2. 检查具体包约束  
conda search "numpy>=1.20,<1.26"
conda search some-package

# 3. 查看依赖关系
conda search some-package --info
```

**解决方案**：
```bash
# 方案1: 调整版本范围（临时）
# 编辑模板文件，放宽numpy约束
numpy>=1.20,<1.27

# 方案2: 排除冲突包
# 不在基础模板中包含，后续手动安装

# 方案3: 创建专用模板
# 为特殊需求创建定制模板

# 方案4: 使用pip安装冲突包
conda_create_from_template python-basic base-env 3.10
conda activate base-env
pip install some-package  # pip更灵活处理依赖
```

#### **Q5: 在离线环境如何使用？**

**准备阶段**（联网环境）：
```bash
# 1. 下载所有依赖包
conda_create_from_template python-basic test-env 3.10 --download-only

# 2. 打包conda缓存
tar -czf conda-cache.tar.gz ~/.conda/pkgs/

# 3. 导出环境配置
conda env export --name test-env > offline-env.yml
```

**离线使用**：
```bash
# 1. 解压缓存
tar -xzf conda-cache.tar.gz -C ~/.conda/

# 2. 创建环境
conda env create --file offline-env.yml --offline

# 或使用离线标志
conda_create_from_template python-basic offline-env 3.10 --offline
```

### 诊断工具和技巧

#### **1. 环境信息收集**

```bash
# 📊 系统信息
conda info                    # Conda版本和配置
conda config --show           # 所有配置项
python -m site                # Python路径信息

# 📦 环境信息
conda list                    # 已安装包列表
conda list --export > packages.txt  # 导出包列表
pip list --format=freeze      # pip包列表

# 🔍 依赖分析
conda depends numpy           # 查看numpy依赖
conda depends --tree numpy    # 树状依赖关系
pipdeptree                    # pip依赖树（需安装pipdeptree）
```

#### **2. 环境对比分析**

```bash
# 🔄 对比两个环境
conda list --name env1 > env1.txt
conda list --name env2 > env2.txt
diff env1.txt env2.txt

# 或使用专门工具
conda-env-diff env1 env2      # 需要conda-env插件
```

#### **3. 性能诊断**

```bash
# ⏱️ 创建时间分析
time conda_create_from_template python-basic test-env 3.10

# 📈 空间使用分析
du -sh ~/.conda/envs/*/       # 各环境大小
conda clean --dry-run --all   # 可清理的缓存大小

# 🌐 网络诊断
conda config --set verbosity 3  # 详细输出
conda search numpy              # 测试网络连接
```

### 获取帮助

#### **报告问题**

**提供以下信息**：
```bash
# 1. 系统环境
uname -a                      # 操作系统信息
conda --version               # Conda版本
python --version              # Python版本

# 2. 完整命令和错误
conda_create_from_template python-basic myenv 3.10 2>&1 | tee error.log

# 3. 相关配置
conda config --show-sources   # 配置来源
conda info                    # 环境信息
```

#### **贡献改进**

**提交改进建议**：
1. 🔍 **问题描述**：清晰描述遇到的问题
2. 🔄 **重现步骤**：提供完整的重现命令
3. 💡 **改进建议**：说明期望的行为
4. 🧪 **测试验证**：在多个Python版本上测试
5. 📝 **文档更新**：更新相关文档

**模板改进流程**：
```bash
# 1. Fork 仓库
git clone your-fork

# 2. 创建改进分支
git checkout -b improve-python-basic

# 3. 修改模板
edit templates/python-basic.yml

# 4. 测试改进
conda_create_from_template python-basic test-39 3.9
conda_create_from_template python-basic test-310 3.10  
conda_create_from_template python-basic test-311 3.11

# 5. 提交PR
git commit -m "feat: improve python-basic template"
git push origin improve-python-basic
```

---

## 📚 参考资料

### 官方文档

- [Conda 用户指南](https://docs.conda.io/projects/conda/en/latest/user-guide/) - Conda基础使用
- [Conda 环境管理](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html) - 环境创建和管理
- [Conda-forge 贡献指南](https://conda-forge.org/docs/maintainer/adding_pkgs.html) - 包维护最佳实践

### Python 相关

- [Python 版本支持策略](https://devguide.python.org/#status-of-python-branches) - Python版本生命周期
- [Python 包索引 (PyPI)](https://pypi.org/) - Python包搜索
- [包版本语义化规范](https://semver.org/) - 版本号约定

### 开发工具

- [Black 代码格式化](https://black.readthedocs.io/) - Python代码格式化工具
- [pytest 测试框架](https://docs.pytest.org/) - Python测试框架
- [MyPy 静态类型检查](https://mypy.readthedocs.io/) - Python类型检查工具
- [pre-commit](https://pre-commit.com/) - Git提交钩子管理

### 社区资源

- [Conda Community](https://github.com/conda/conda) - Conda开源社区
- [Python环境管理最佳实践](https://realpython.com/python-virtual-environments-a-primer/) - 环境管理指南

*🌟 Templates目录：让Python开发环境创建变得简单、一致、可靠。*