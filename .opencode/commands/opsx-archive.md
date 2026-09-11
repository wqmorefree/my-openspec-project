---
description: 归档已完成变更，必要时先同步主规范
---

先加载 skill：`openspec-archive-change`。

归档变更「$ARGUMENTS」（可省略，自动推断）：
1. 检查产物与任务完成度，有未完成项先警告并征求确认
2. 若存在 delta 规范，评估是否需要同步主规范（默认先同步）
3. 按日期命名移入 openspec/changes/archive/
4. 输出归档摘要

依赖 openspec-sync-specs skill 内联同步，勿在后台进行。