-- V2: 将存量 sys_user 密码统一升级为 SM3 三次迭代哈希（Task 14 规则），与登录校验对齐
-- 摘要为默认初始密码 123456 的 SM3³ 值；命中即跳过，保证幂等
UPDATE sys_user
SET password = '52de560f88d6fcc00899a4631b7d7623d1a730238f0af19d91d8e1ef6b820448'
WHERE password <> '52de560f88d6fcc00899a4631b7d7623d1a730238f0af19d91d8e1ef6b820448';