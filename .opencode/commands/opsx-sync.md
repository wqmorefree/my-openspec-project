---
description: 将变更的 delta 规范同步到主规范
---

先加载 skill：`openspec-sync-specs`。

将变更「$ARGUMENTS」（可省略，自动推断）的 delta 规范智能合并到主规范：
1. 读取 delta 与主 spec，按 ADDED/MODIFIED/REMOVED/RENAMED 合并
2. 保留未被提及的内容，禁止把 delta 原样拷入主 spec
3. 结束后运行 openspec validate --specs 校验

遵守 skill 中的 guardrails；同步需幂等，重复执行结果一致。