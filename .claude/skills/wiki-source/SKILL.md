---
name: wiki-source
description: "重量资料导入：将 source/ 中的文件转为 markdown，然后并行读取生成书籍骨架和学习规划。当用户说「处理资料」「导入书」「wiki-source」时触发。参数：[文档名]（必填）。"
---

# /wiki-source — 重量资料导入

将 source/ 中的文件转为 markdown，然后并行读取生成书籍骨架和学习规划。

## 触发方式

用户说 `/wiki-source [文档名]`，或说「处理 source」「导入书」等。

文档名参数是**必填的**，用于命名 learning/ 下的文件夹。

## 执行流程

### 第一步：文件转换

1. 列出 source/ 中的所有文件
2. 如果 source/ 为空，提示用户先放入文件
3. 对每个文件判断：
   - 扩展名是 .md / .markdown / .txt → 直接移动到 raw/
   - 其他格式 → 调用 markitdown 转换：
     ```bash
     bash .claude/scripts/markitdown-convert.sh "文件路径" "raw/输出文件名.md"
     ```
   - 转换成功后删除 source/ 中的原始文件
   - 如果转换失败，报告错误但不删除原始文件
4. 确认 raw/ 中有新的 .md 文件

### 第二步：并行读取生成骨架

1. 读取 raw/ 中新转换的 .md 文件的 heading 结构（## 级别）
2. 按章节分组（每组 2-3 章），启动 2-4 个 sub-agent 并行读取
3. 每个 sub-agent 使用 `book-reader` agent（定义见 `.claude/agents/book-reader.md`），提示词包含：
   - 分配的章节范围（行号）
   - 指定输出格式见 book-reader.md
4. 收集所有 agent 的产出

### 第三步：生成学习文件

1. 创建目录 `learning/[文档名]/notes/`
2. 汇总所有 agent 产出 → 生成 `learning/[文档名]/骨架.md`
   - 包含：完整章节结构、每个知识点、知识点之间的依赖关系
3. 基于骨架生成 `learning/[文档名]/学习档案.md`
   - 包含：所有涉及的知识点总览、分类、预估难度
4. 基于骨架生成 `learning/[文档名]/学习地图.md`
   - 包含：推荐的学习顺序（考虑依赖关系，不照搬原书目录）
   - 每个阶段标注目标和预期时长
5. 生成 `learning/[文档名]/progress.md`
   - 所有单元标记为「未开始」

### 第四步：更新索引和日志

1. 更新 index.md
2. 追加 log.md

### 第五步：向用户汇报

告诉用户：
- 转换了多少个文件
- 骨架中有多少个章节、多少个知识点
- 学习地图的推荐顺序
- 提示用户开始自学第一个单元
