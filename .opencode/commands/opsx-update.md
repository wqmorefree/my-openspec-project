---
description: 修订变更规划产物并保持一致性
---

先加载 skill：`openspec-update-change`。

修订变更「$ARGUMENTS」（可省略，自动推断）的规划产物：
1. 先做一致性审查，找出矛盾、缺失、重复
2. 每个修订先展示再写入，需用户确认
3. 只改已存在的文件，不新增产物（那是 /opsx-continue 的职责）
4. 不修改任何业务代码

遵守 skill 中的 guardrails；规划改动不越过边界。