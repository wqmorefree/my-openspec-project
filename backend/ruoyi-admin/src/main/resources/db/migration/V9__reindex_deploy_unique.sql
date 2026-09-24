-- V9: 部署节点唯一索引由 (asset_id, sys_env, ip_address) 改为 (asset_id, deploy_app)
-- 唯一判断依据变更为「部署应用」名称，同一系统下不允许重复的部署应用

-- 删除旧索引
DROP INDEX IF EXISTS uk_sys_asset_deploy_env_ip;

-- 创建新索引：同系统下部署应用名称唯一（软删除记录不占名额）
CREATE UNIQUE INDEX IF NOT EXISTS uk_sys_asset_deploy_app
    ON sys_asset_deploy (asset_id, deploy_app) WHERE is_deleted = 0;
