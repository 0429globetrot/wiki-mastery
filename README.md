# Wiki Knowledge Base — LLM 知识库框架

一个基于 Claude Code 的通用知识库框架。LLM 负责所有 wiki 页面的创建和维护，用户负责资料收集、提问和方向引导。

## 功能

- **资料导入** — 支持 PDF、docx、epub 等格式自动转为 markdown
- **骨架生成** — 并行读取书籍章节，自动提取知识点和依赖关系
- **苏格拉底问答** — 自学后通过问答加深理解，自动沉淀笔记
- **知识沉淀** — 学习成果自动整理为结构化 wiki 页面
- **知识查询** — 基于已有 wiki 内容回答问题，有价值的内容自动沉淀
- **健康检查** — 检测孤立页面、缺失引用、矛盾内容

## 快速开始

```bash
# 1. 克隆仓库
git clone <your-repo-url> ~/my-wiki

# 2. 进入目录，启动 Claude Code
cd ~/my-wiki
claude

# 3. 初始化（首次使用，安装依赖 + 使用指南）
/wiki-init

# 4. 开始使用！
# 编辑 overview.md 填写你的知识地图，把资料放入 source/，然后：
/wiki-source 你的书名
```

## 命令列表

| 命令 | 说明 |
|------|------|
| `/wiki-init` | 初始化环境（首次使用） |
| `/wiki-source [文档名]` | 重量资料导入（书籍等大型文档） |
| `/wiki-ingest` | 轻量资料导入（文章、网页剪藏） |
| `/wiki-learning-unit [文档名] [单元名]` | 苏格拉底问答学习 |
| `/wiki-learning-over [文档名]` | 全书学习完成，生成总结并沉淀 |
| `/wiki-query [问题]` | 基于 wiki 内容查询 |
| `/wiki-lint` | wiki 健康检查 |

## 典型工作流

```
1. 编辑 overview.md 填写你的知识地图
2. 把学习资料放入 source/
3. /wiki-source C#入门教程     ← 导入资料，生成骨架
4. 自学第一个单元
5. /wiki-learning-unit C#入门教程 面向对象  ← 问答 + 沉淀
6. 重复 4-5 直到学完
7. /wiki-learning-over C#入门教程  ← 全书总结，沉淀到 wiki
8. /wiki-query 什么是多态？     ← 查询已有知识
9. /wiki-lint                    ← 检查 wiki 健康度
```

## 目录结构

```
your-wiki/
├── source/           # 原始资料（PDF、docx 等）
├── raw/              # 转换后的 markdown（不可变）
├── Clippings/        # Web Clipper 剪藏
├── learning/         # 学习过程文件
├── wiki/             # 沉淀后的知识
│   ├── entities/     # 实体页
│   ├── concepts/     # 概念页
│   ├── sources/      # 资料摘要页
│   ├── comparisons/  # 对比页
│   └── meta/         # 元数据
├── attachments/      # 图片和附件
├── .claude/
│   ├── agents/       # Sub-agent 定义
│   ├── commands/     # 斜杠命令
│   ├── skills/       # Skill 定义（6 个命令）
│   └── scripts/      # 工具脚本（markitdown）
├── CLAUDE.md         # 项目指令
├── overview.md       # 知识地图
├── index.md          # wiki 索引
└── log.md            # 操作日志
```

## 依赖

- [Claude Code](https://claude.ai/code)
- [markitdown](https://github.com/microsoft/markitdown) — 文档格式转换（`/wiki-init` 自动安装）
- Python 3 — markitdown 运行时需要
