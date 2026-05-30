# LLM Wiki Schema

## 概述

这是一个**通用知识库框架**，使用 LLM Wiki 模式构建。LLM 负责所有 wiki 页面的创建和维护，用户负责资料收集、提问和方向引导。

具体的学习领域和知识地图见 `overview.md`。

## 核心 UX 原则

**一步触发，全程自动。** 每个命令只需调用一次，LLM 自动完成全部流程（包括最终的沉淀），用户不需要再调第二次。

## 目录结构

```
.
├── source/                # 用户丢原始文件的地方（PDF、docx 等）
├── raw/                   # 转换后的 markdown 源文件（不可变）
├── Clippings/             # Web Clipper 剪藏的网页
├── learning/              # 学习过程文件（按资料分子文件夹）
│   └── [doc-name]/
│       ├── 骨架.md         # 书籍结构 + 知识点清单 + 依赖关系
│       ├── 学习档案.md     # 涉及知识点总览
│       ├── 学习地图.md     # 定制学习顺序
│       ├── progress.md     # 学习进度记录
│       ├── 全书总结.md     # 学完后生成
│       └── notes/          # 各单元沉淀笔记
├── wiki/                  # 沉淀后的知识（永久产出）
│   ├── entities/          # 实体页：书籍、工具、人物、公司
│   ├── concepts/          # 概念页：技术概念、设计模式、理论
│   ├── sources/           # 资料摘要页
│   ├── comparisons/       # 对比页：方案对比、技术选型
│   └── meta/              # 元数据：学习路径、技能树、知识地图
├── attachments/           # 图片和附件
├── index.md               # wiki 内容索引（按分类）
├── log.md                 # 操作日志（按时间）
├── overview.md            # 领域内容：知识地图、使用指南
└── CLAUDE.md              # 本文件：通用 wiki 框架规范
```

## 页面类型与模板

### 实体页 (`wiki/entities/`)

用于：书籍、工具、框架、人物、公司、作品等具体事物

```markdown
---
type: entity
category: book|tool|framework|person|company|work
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: []
tags: []
---

# 实体名称

## 概述
一句话介绍

## 详细信息
关键事实、版本、特点等

## 与其他知识的关联
- 与哪些概念相关
- 与哪些工具配合使用
- 在哪些场景中出现

## 参考资料
- [[source-name]]: 相关描述
```

### 概念页 (`wiki/concepts/`)

用于：抽象的技术概念、理论、设计模式、算法等

```markdown
---
type: concept
domain: 根据领域自定义
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: []
tags: []
---

# 概念名称

## 定义
简洁清晰的解释

## 核心要点
- 关键特征和原理

## 实际应用
具体用法和场景

## 相关概念
- [[related-concept]]: 关系说明

## 参考资料
- [[source-name]]: 页码/章节
```

### 资料摘要页 (`wiki/sources/`)

用于：每份导入资料的结构化摘要

```markdown
---
type: source
format: book|article|video|tutorial|paper|course
title: 资料标题
author: 作者
date: YYYY-MM-DD
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
---

# 资料标题

## 概述
这份资料讲了什么，核心观点是什么

## 关键要点
- 逐条列出最有价值的内容

## 涉及的概念
- [[concept-1]]: 在这份资料中的具体讨论

## 涉及的实体
- [[entity-1]]: 关系说明

## 个人笔记
用户的想法、疑问、启发
```

### 对比页 (`wiki/comparisons/`)

用于：方案对比、技术选型

```markdown
---
type: comparison
created: YYYY-MM-DD
updated: YYYY-MM-DD
items: [对比项1, 对比项2]
criteria: [对比维度]
sources: []
tags: []
---

# A vs B

## 对比维度

| 维度 | A | B |
|------|---|---|
| ... | ... | ... |

## 总结
适合什么场景选什么方案

## 参考资料
- [[source-name]]
```

### 元数据页 (`wiki/meta/`)

用于：学习路径、技能树、知识地图、项目规划

```markdown
---
type: meta
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
---

# 标题

## 内容
结构化的规划或地图

## 相关页面
- [[related-page]]
```

## 6 个命令（Skills）

### `/wiki-source [文档名]` — 重量资料导入

将 source/ 中的文件转为 markdown，然后并行读取生成书籍骨架和学习规划。

**参数：** `[文档名]`（必填），用于命名 learning/ 下的文件夹

**示例：** `/wiki-source C#入门教程`

**执行流程：**
1. 检查 source/ 中的文件
2. 非 .md 文件 → 调用 markitdown 转换（见下方工具规范）
   - 已是 .md/.markdown/.txt → 直接移动到 raw/
   - 转换成功 → .md 放入 raw/，删除 source/ 中的原始文件
3. 创建 `learning/[文档名]/notes/` 目录
4. 启动 sub-agent 并行读取 raw/ 中的资料（见下方策略）
5. 汇总所有 agent 产出 → 生成 `learning/[文档名]/骨架.md`
6. 基于骨架生成：
   - `learning/[文档名]/学习档案.md`
   - `learning/[文档名]/学习地图.md`
   - `learning/[文档名]/progress.md`（初始状态：所有单元标记为「未开始」）
7. 更新 index.md、追加 log.md

### `/wiki-ingest` — 轻量资料导入

快速处理一篇文章或网页剪藏，跳过学习流程，直接沉淀到 wiki。

**执行流程：**
1. 读取 raw/ 或 Clippings/ 中的指定文件
2. 创建 wiki/sources/ 资料摘要页
3. 为新出现的概念创建 wiki/concepts/ 概念页
4. 为新出现的实体创建 wiki/entities/ 实体页
5. 更新已有页面的交叉引用
6. 更新 index.md、追加 log.md

### `/wiki-learning-unit [文档名] [单元名]` — 学习单元

苏格拉底式问答学习，完成后自动沉淀笔记。全程一个对话，不需要第二次触发。

**示例：** `/wiki-learning-unit C#入门教程 面向对象`

**执行流程：**
1. 读取 `learning/[文档名]/progress.md` 确认当前状态
2. 读取 `learning/[文档名]/骨架.md` 找到该单元的知识点
3. 读取 `learning/[文档名]/notes/` 中已有的笔记（如有）
4. 提示用户开始自学该单元内容
5. 用户确认自学完成后，开始苏格拉底问答（见下方规范）
6. 所有知识点问答完毕 → 自动沉淀：
   - 写入 `learning/[文档名]/notes/[单元名].md`
   - 重点展开标记的卡住点
   - 记录哪些知识点答得好、哪些需要加强
7. 更新 `learning/[文档名]/progress.md`（标记该单元完成）
8. 提示下一个推荐单元

### `/wiki-learning-over [文档名]` — 全书学习完成

生成全书总结，将学习成果沉淀到 wiki。全程自动，不需要第二次触发。

**示例：** `/wiki-learning-over C#入门教程`

**执行流程：**
1. 读取 `learning/[文档名]/progress.md`，确认所有单元完成（如有未完成，提醒用户）
2. 读取所有 `learning/[文档名]/notes/` 中的单元笔记
3. 生成全书总结：
   - 梳理跨单元的知识关联
   - 优化沉淀内容之间的关系
   - 标记整本书的核心主线
   - 写入 `learning/[文档名]/全书总结.md`
4. 沉淀到 wiki/（跨资料关联机制）：
   - 章节摘要 → wiki/sources/[文档名].md
   - 知识点 → 检查 wiki/concepts/ 是否已有同名页面：
     - 已有 → 更新已有页面，补充本资料的视角（不重复创建）
     - 没有 → 创建新页面
   - 实体 → 同上逻辑检查 wiki/entities/
   - 所有页面用 wiki-link 互相引用
   - 更新 wiki/meta/ 长期知识地图
5. 更新 index.md、追加 log.md

### `/wiki-query` — 知识查询

基于已有 wiki 内容回答问题。有价值的回答自动沉淀为新页面。

**执行流程：**
1. 读取 index.md 找到相关页面
2. 读取相关 wiki/ 页面，综合信息
3. 给出回答，附来源引用
4. 如果回答有价值 → 沉淀为新 wiki 页面（概念页、对比页等）
5. 更新 index.md、追加 log.md

### `/wiki-lint` — 健康检查

检查 wiki 的健康度，输出问题报告和修复建议。

**执行流程：**
1. 检查孤立页面（无入链）
2. 检查缺失页面（被多次提及但无专属页）
3. 检查矛盾（页面间冲突说法）
4. 检查过时信息
5. 检查缺失交叉引用
6. 输出问题报告 + 修复建议

## Sub-agent 并行读取策略

用于 `/wiki-source` 中读取大型资料文件。

**Agent 定义：** `.claude/agents/book-reader.md`

```
步骤1：主 agent 读取文件的 heading 结构（## 级别），得到章节列表
步骤2：按章节分组（每组 2-3 章），分配给 2-4 个 sub-agent 并行读取
步骤3：每个 sub-agent 按照 book-reader.md 的指令执行：
  - 读取指定行号范围的内容
  - 输出结构化分析：核心主题、知识点列表、依赖关系、关联关系、重要程度、难度
步骤4：主 agent 汇总所有 agent 产出
  → 生成完整骨架（含所有章节和知识点）
  → 分析跨章节的依赖关系
  → 标注哪些是基础概念、哪些是进阶概念
```

## 苏格拉底问答规范

用于 `/wiki-learning-unit` 中的知识点考察：

**提问深度：** 理解 + 应用 + 辨析
- 理解：「这个概念是什么意思？」
- 应用：「如果不用它会怎样？」「在什么场景下用？」
- 辨析：「它和 XX 的区别是什么？」「为什么不直接用 XX？」

**答对：** 肯定并进入下一个知识点，可以追问更深层的问题

**答错：** 坚持不给直接答案
- 第一次：换个角度重新提问，或把问题拆小
- 第二次：给一个暗示或提示，引导思考方向
- 第三次：给一个更具体的提示，但仍然不直接说答案
- 持续引导直到用户自己想出来

**标记机制：** 记录用户反复卡住的知识点和答错的问题，作为沉淀时的重点内容

## markitdown 转换规范

- 调用方式：`bash .claude/scripts/markitdown-convert.sh "输入文件" "输出文件"`
- 判断逻辑：
  - 扩展名为 .md / .markdown / .txt → 直接移动到 raw/
  - 其他格式 → markitdown 转换后放 raw/，删除 source/ 中原始文件
- 支持的格式：pdf, docx, pptx, xlsx, epub, html, csv, json 等

## 跨资料知识关联机制

多份资料学完后，wiki 通过三层机制保证知识之间的关联：

1. **wiki-link 基础链接** — 沉淀时自然建立（概念页互相引用）
2. **跨资料更新** — `/wiki-learning-over` 沉淀时检查已有页面，更新而非重复创建
3. **lint 补漏** — `/wiki-lint` 扫描发现缺失的交叉引用，提醒补充

## 写作规范

- 使用 Obsidian wiki-link 语法：`[[页面名称]]`
- 每个页面都必须有 YAML frontmatter
- 资料来源必须明确标注在"参考资料"部分
- 概念解释要结合实际场景，不要泛泛而谈
- 对比类内容要给出明确的适用场景建议
- 使用中文撰写所有 wiki 页面
- 技术术语保留英文原文，首次出现时附中文解释

## 索引规范 (index.md)

- 按页面类型分组（实体、概念、资料、对比、元数据）
- 每个条目包含：wiki-link、一句话摘要、创建日期
- 每次操作后必须更新

## 日志规范 (log.md)

- 每条记录格式：`## [YYYY-MM-DD] action | 描述`
- action 类型：`source`（导入）、`ingest`（摄入）、`learn`（学习）、`query`（查询）、`lint`（检查）、`update`（更新）
- 追加写入，不修改历史记录

## 图片处理

- wiki 页面引用的图片保存到 `attachments/`
- 使用 Obsidian embed 语法：`![[image.png]]`
- 如果原始资料中的图片 URL 可能失效，主动下载到本地

## 学习进度文件格式 (progress.md)

```markdown
# 学习进度：[文档名]

| 单元 | 状态 | 完成日期 |
|------|------|----------|
| 第一章：xxx | ✅ 已完成 | 2026-04-28 |
| 第二章：xxx | ⏳ 进行中 | — |
| 第三章：xxx | ⬜ 未开始 | — |
```
