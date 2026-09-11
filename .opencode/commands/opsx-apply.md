---
description: 按 tasks.md 实现变更代码
---

先加载 skill：`openspec-apply-change`。

对变更「$ARGUMENTS」（可省略，自动推断）执行实现：
1. 用 openspec CLI 读取变更状态、apply 指令及上下文文件
2. 逐任务实现代码，完成后更新 tasks.md 复选框
3. 全程展示进度；遇阻塞、歧义立即暂停询问
4. 全部完成则提示归档

遵守 skill 中的 guardrails；按 openspec status/instructions 的返回值执行，不臆造文件名。