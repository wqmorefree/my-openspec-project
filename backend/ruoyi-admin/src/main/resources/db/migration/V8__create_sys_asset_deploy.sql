-- V8：系统部署节点子表 sys_asset_deploy（部署信息 Tab）
-- 需求以原型 docs/prototype/系统技术资产登记表原型-v2.html 为准：
-- 32 个业务字段（去掉序号），一行 = 一个部署节点；表格显 10 列，完整字段走查看详情。
-- 字段全小写下划线，时间类型 TIMESTAMP，金仓兼容。

-- 1. 部署节点子表（字段顺序对齐原型 FIELD_DEFS.deploy，去掉序号）
CREATE TABLE IF NOT EXISTS sys_asset_deploy (
    id                      VARCHAR(64) PRIMARY KEY,
    asset_id                VARCHAR(64)   NOT NULL,
    module_name             VARCHAR(128)  NOT NULL,
    deploy_app              VARCHAR(128)  NOT NULL,
    host_name               VARCHAR(128)  NOT NULL,
    ip_address              VARCHAR(64)   NOT NULL,
    container_ip            VARCHAR(64),
    link_template           VARCHAR(256),
    idc                     VARCHAR(128),
    cpu_cores               SMALLINT,
    memory_gb               NUMERIC(8,2),
    sys_disk_gb             NUMERIC(8,2),
    data_disk_gb            NUMERIC(8,2),
    os_info                 VARCHAR(128),
    snapshot_need           VARCHAR(256),
    server_type             VARCHAR(64),
    node_count              SMALLINT,
    tenant                  VARCHAR(64),
    vpc                     VARCHAR(128),
    security_group          VARCHAR(256),
    app_desc                TEXT,
    sys_env                 SMALLINT      NOT NULL,
    runtime_env             VARCHAR(128),
    deploy_subnet           VARCHAR(128),
    path_info               VARCHAR(256),
    file_mount              VARCHAR(256),
    batch_op_flag           SMALLINT      NOT NULL DEFAULT 0,
    batch_sched_platform    VARCHAR(128),
    app_monitor_flag        SMALLINT      NOT NULL DEFAULT 0,
    network_qos             VARCHAR(256),
    domain_name             VARCHAR(256),
    domestic_flag           SMALLINT      NOT NULL DEFAULT 0,
    etl_tool                VARCHAR(128),
    remark                  VARCHAR(256),
    created_user            VARCHAR(64),
    updated_user            VARCHAR(64),
    created_time            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time            TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_deleted              SMALLINT      NOT NULL DEFAULT 0,
    deleted_time            TIMESTAMP
);

COMMENT ON TABLE sys_asset_deploy IS '系统部署节点子表（部署信息 Tab）';
COMMENT ON COLUMN sys_asset_deploy.id IS '主键ID（UUID）';
COMMENT ON COLUMN sys_asset_deploy.asset_id IS '所属系统ID（逻辑外键，指向 sys_asset.id）';
COMMENT ON COLUMN sys_asset_deploy.module_name IS '模块名称';
COMMENT ON COLUMN sys_asset_deploy.deploy_app IS '部署应用';
COMMENT ON COLUMN sys_asset_deploy.host_name IS '主机名';
COMMENT ON COLUMN sys_asset_deploy.ip_address IS 'IP地址';
COMMENT ON COLUMN sys_asset_deploy.container_ip IS '容器IP';
COMMENT ON COLUMN sys_asset_deploy.link_template IS '链接模版';
COMMENT ON COLUMN sys_asset_deploy.idc IS '机房';
COMMENT ON COLUMN sys_asset_deploy.cpu_cores IS 'CPU（核）';
COMMENT ON COLUMN sys_asset_deploy.memory_gb IS '内存（G）';
COMMENT ON COLUMN sys_asset_deploy.sys_disk_gb IS '系统盘（G）';
COMMENT ON COLUMN sys_asset_deploy.data_disk_gb IS '数据盘（G）';
COMMENT ON COLUMN sys_asset_deploy.os_info IS '操作系统';
COMMENT ON COLUMN sys_asset_deploy.snapshot_need IS '快照备份需求';
COMMENT ON COLUMN sys_asset_deploy.server_type IS '服务器类型';
COMMENT ON COLUMN sys_asset_deploy.node_count IS '节点数量';
COMMENT ON COLUMN sys_asset_deploy.tenant IS '租户';
COMMENT ON COLUMN sys_asset_deploy.vpc IS 'VPC';
COMMENT ON COLUMN sys_asset_deploy.security_group IS '安全组';
COMMENT ON COLUMN sys_asset_deploy.app_desc IS '应用描述';
COMMENT ON COLUMN sys_asset_deploy.sys_env IS '系统环境 1-生产 2-测试 3-开发';
COMMENT ON COLUMN sys_asset_deploy.runtime_env IS '运行环境';
COMMENT ON COLUMN sys_asset_deploy.deploy_subnet IS '部署网段';
COMMENT ON COLUMN sys_asset_deploy.path_info IS '路径信息';
COMMENT ON COLUMN sys_asset_deploy.file_mount IS '文件挂载';
COMMENT ON COLUMN sys_asset_deploy.batch_op_flag IS '是否涉及批量操作 0-否 1-是';
COMMENT ON COLUMN sys_asset_deploy.batch_sched_platform IS '批量调度平台';
COMMENT ON COLUMN sys_asset_deploy.app_monitor_flag IS '是否纳入应用监控 0-否 1-是';
COMMENT ON COLUMN sys_asset_deploy.network_qos IS '网络QoS策略';
COMMENT ON COLUMN sys_asset_deploy.domain_name IS '域名';
COMMENT ON COLUMN sys_asset_deploy.domestic_flag IS '国产化 0-否 1-是';
COMMENT ON COLUMN sys_asset_deploy.etl_tool IS 'ETL工具';
COMMENT ON COLUMN sys_asset_deploy.remark IS '备注';
COMMENT ON COLUMN sys_asset_deploy.created_user IS '创建人';
COMMENT ON COLUMN sys_asset_deploy.updated_user IS '更新人';
COMMENT ON COLUMN sys_asset_deploy.created_time IS '创建时间';
COMMENT ON COLUMN sys_asset_deploy.updated_time IS '更新时间';
COMMENT ON COLUMN sys_asset_deploy.is_deleted IS '是否删除 0-否 1-是';
COMMENT ON COLUMN sys_asset_deploy.deleted_time IS '删除时间（软删除）';

-- 2. 索引：按系统查询 + 同系统同环境 IP 部分唯一索引（兼容逻辑删除）
CREATE INDEX IF NOT EXISTS idx_sys_asset_deploy_asset_id
    ON sys_asset_deploy (asset_id);
CREATE UNIQUE INDEX IF NOT EXISTS uk_sys_asset_deploy_env_ip
    ON sys_asset_deploy (asset_id, sys_env, ip_address) WHERE is_deleted = 0;

-- 3. 系统环境字典 deploy_sys_env：生产（红）/测试（蓝）/开发（绿）
INSERT INTO sys_dict_type (dict_id, dict_name, dict_type, create_dept, create_by, create_time, update_by, update_time, remark)
VALUES (1761500000000000014, '系统环境', 'deploy_sys_env', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, '部署节点系统环境');

INSERT INTO sys_dict_data (dict_code, dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, create_dept, create_by, create_time, update_by, update_time, remark) VALUES
(1761600000000000043, 1, '生产', '1', 'deploy_sys_env', '', 'danger',  'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, '生产'),
(1761600000000000044, 2, '测试', '2', 'deploy_sys_env', '', 'primary', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, '测试'),
(1761600000000000045, 3, '开发', '3', 'deploy_sys_env', '', 'success', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, '开发');
