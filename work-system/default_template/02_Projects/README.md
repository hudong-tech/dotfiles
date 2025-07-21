# 02_Projects 项目管理中心

> **"项目的状态，不应该藏在文件里，而应该写在路径上。"** —— 亦仁益语  
> **"扁平命名 + 模版生成 + 元数据驱动"** 让项目管理可扫描、可脚本化、可扩展。

## 📁 目录结构

```
02_Projects/
│
├─ _scaffold/              # 项目脚手架和模板
│   ├─ init_project.sh    # 项目初始化脚本
│   ├─ README.md          # 脚手架说明
│   └─ templates/         # 项目模板
│       └─ default_project/
│
├─ 01_Active/             # 当前进行中项目（工作台）
│   └─ proj-ai-isolaze-beacon/
│
├─ 02_Planning/           # 立项准备阶段
│
├─ 03_Paused/             # 暂时停摆项目
│
└─ 04_Done/               # 已完结项目（待归档）
```

## 🎯 设计理念

### 状态驱动的项目管理
| 状态目录 | 含义 | 典型场景 |
|----------|------|----------|
| `01_Active/` | 当前工作重点，正在推进 | 每日 standup 关注的项目 |
| `02_Planning/` | 立项准备，需求调研阶段 | 等待资源投入或技术预研 |
| `03_Paused/` | 临时暂停，等待条件成熟 | 等待外部依赖或战略调整 |
| `04_Done/` | 已完结交付，准备归档 | 可移入 `/99_Archive/` |

### 核心原则
- **单一职责**：每个状态目录只承载相应阶段的项目
- **状态可视**：目录名即状态标识，一目了然
- **流转简单**：`mv` 命令即可完成状态迁移
- **脚本友好**：所有操作可自动化

## 📝 项目命名规范

### 命名模板
```
proj-<business>-<keyword>
```

### 命名规则
| 规则 | 示例 | 说明 |
|------|------|------|
| 前缀 `proj-` | `proj-growth-hacking` | 一眼辨识"这是项目" |
| 业务关键词 | `proj-crm-lite` | 不用技术栈做名字 |
| 可选版本分支 | `proj-crm-lite-v2` | 真正**大改版**才加 |
| 全小写、短横线 | `proj-data-pipeline` | 避免空格、驼峰、中文路径 |

> 🌱 *亦仁益语*：**"名字越长，未来越痛。"**——三秒看不懂的目录迟早被弃坑。

## 🔤 业务线英文命名词库

| 中文语义 | 推荐命名 | 延伸命名 |
|----------|----------|----------|
| 人工智能 | `ai` | `aimedia`, `aicore`, `ailab` |
| 增长/营销 | `growth` | `mkt`, `funnel`, `conversion` |
| CRM/客户关系 | `crm` | `crm-lite`, `crm-plus` |
| 教育类产品 | `edu` | `learning`, `classroom` |
| 内容中台 | `content` | `ugc`, `recommend`, `cms` |
| 数据中台 | `dataplat` | `dwh`, `etl`, `bi` |
| 运维系统 | `ops` | `devops`, `monitor`, `sre` |
| 基础设施 | `infra` | `platform`, `k8s`, `cloud` |
| API 聚合 | `gateway` | `apihub`, `proxy`, `backend` |

## 🚀 快速开始

### 创建新项目
```bash
cd /work/02_Projects
_scaffold/init_project.sh proj-example "项目描述"
```

### 项目状态流转
```bash
# 从规划阶段转入开发
mv 02_Planning/proj-example 01_Active/

# 项目暂停
mv 01_Active/proj-example 03_Paused/

# 项目完结
mv 01_Active/proj-example 04_Done/
```

## 📄 项目标准结构

每个项目都应包含以下标准结构：
```
proj-example/
├─ README.md          # 30秒明白这个项目
├─ project.yaml       # 元数据（状态、负责人、时间线）
├─ CHANGELOG.md       # 版本变更记录
├─ code/              # 源码
├─ infra/             # 基础设施脚本
├─ doc/               # 需求、会议纪要
├─ design/            # 视觉、原型
├─ data/              # 样例数据
├─ tests/             # 测试用例
└─ output/            # 可交付物
```

## 🔧 project.yaml 元数据标准

```yaml
name: proj-ai-isolaze-beacon
status: active              # active / planning / paused / done
business_domain: ai         # 业务线
owner: "@alice"
start_date: 2025-07-21
due_date: 2025-08-31
priority: P1                # P0 / P1 / P2 / P3
stack:
  backend: python
  frontend: nextjs
  infra: docker
tags:
  - beacon
  - ai
  - media
desc: "AI 媒体追踪平台 Beacon，用于分发追踪与效果归因"
links:
  prod: ""               # 生产环境地址
  doc: ""                # 文档链接
```

## 🛠️ 自动化工具

### 推荐脚本（放在 `_scaffold/` 或 `/work/04_Tools/`）
| 脚本 | 功能 |
|------|------|
| `list_projects.sh` | 生成项目状态总览表格 |
| `project_switch.sh` | 快速切换项目状态 |
| `gen_readme.sh` | 自动生成各状态目录的项目清单 |
| `sync_project_yaml.sh` | 同步目录状态到 project.yaml |

### 元数据驱动的自动化
基于 `project.yaml` 可以实现：
- **每日仪表盘**：列出 `status=active` 项目
- **过期提醒**：距 `due_date` 7 天发钉钉
- **归档脚本**：`status=done && lastCommit>90d` → 移入 `/99_Archive/`
- **技术栈统计**：当前活跃项目的语言占比

## 📊 项目状态流转图

```
Planning → Active → Done → Archive
   ↑         ↓        ↓       ↓
 新想法    执行中   待归档   季度存档
   ↓         ↓
 Paused   临时暂停
```

## 📋 最佳实践

### 项目生命周期管理
1. **新需求评估**：先在 `02_Planning/` 立项调研
2. **资源投入**：移入 `01_Active/` 正式开发
3. **临时暂停**：移入 `03_Paused/` 等待条件
4. **交付完成**：移入 `04_Done/` 准备归档
5. **季度归档**：移入 `/99_Archive/2025/Q3/`

### 维护节奏
| 频率 | 动作 |
|------|------|
| **每日** | 查看 `01_Active/` 当前工作重点 |
| **每周** | 整理各状态目录，更新项目清单 |
| **每月** | 将 `04_Done/` 中的项目移至归档区 |
| **每季度** | 审查 `03_Paused/` 项目是否需要重启或取消 |

### 常见问题处理
| 疑问 | 处理建议 |
|------|----------|
| **一个项目有多个微服务** | 单仓管理，`code/service-a/`, `code/service-b/` |
| **PoC/Spike 项目** | 先放 `/98_Sandbox/`，验证后再移入正式项目 |
| **V1 与 V2 并行维护** | 同项目内建 `branches/v1`, `branches/v2` |

## 🎯 口袋决策卡

```
┌─ 新需求来了！
│
├─ 它会不会上线面对用户？
│       └─ No → /98_Sandbox
│       └─ Yes
│
├─ 已有项目可容纳？
│       └─ Yes → 写进现有项目
│       └─ No
│
└─ _scaffold/init_project.sh 一键生成
        └─ 选择合适状态目录
        └─ 填写 project.yaml
        └─ 开始推进！
```

---

**记住："项目目录是战场指北，README 是地图，project.yaml 是军情。"**

让你的项目管理不仅**可扫描、可检索**，更要**可自动化**。