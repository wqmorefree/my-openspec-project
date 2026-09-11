---
description: 创建变更提案 + 规范文档
---

先加载 skill：`openspec-propose`。

为用户的描述「$ARGUMENTS」创建一份完整变更提案：
1. 从描述推导 kebab-case 变更名，信息不足先向用户确认
2. 按 skill 流程依次产出 proposal.md、specs/、design.md、tasks.md
3. 完成后展示摘要与产物列表，等待用户审阅

规划边界：只产出规划文档，禁止修改任何业务代码，不要自行开始实现。