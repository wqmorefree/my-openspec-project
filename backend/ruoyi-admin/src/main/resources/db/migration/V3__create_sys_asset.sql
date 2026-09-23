-- V3：系统技术资产主表 sys_asset（含 kbcrypto SM4 国密扩展）
-- 参考 design.md「数据模型」；字段全小写下划线，时间类型 TIMESTAMP，金仓兼容。

-- 1. 加载 kbcrypto 扩展（幂等；提供 sm4() 国密加解密函数）
CREATE EXTENSION IF NOT EXISTS kbcrypto;

-- 2. 系统技术资产主表
CREATE TABLE IF NOT EXISTS sys_asset (
    id              VARCHAR(64) PRIMARY KEY,
    code            VARCHAR(64)   NOT NULL,
    name            VARCHAR(128)  NOT NULL,
    biz_domain      VARCHAR(128)  NOT NULL,
    owner           VARCHAR(64)   NOT NULL,
    status          SMALLINT      NOT NULL DEFAULT 1,
    project_name    VARCHAR(128),
    project_no      VARCHAR(64),
    leader_name     VARCHAR(64),
    leader_mobile   VARCHAR(128),
    pm_name         VARCHAR(64),
    pm_mobile       VARCHAR(128),
    intro           TEXT,
    category        VARCHAR(64),
    svn_doc_url     VARCHAR(256),
    git_code_url    VARCHAR(256),
    module_name     VARCHAR(128),
    branch_name     VARCHAR(128),
    branch_desc     VARCHAR(256),
    branch_url      VARCHAR(256),
    created_user    VARCHAR(64),
    updated_user    VARCHAR(64),
    created_time    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_deleted      SMALLINT      NOT NULL DEFAULT 0,
    deleted_time    TIMESTAMP
);

COMMENT ON TABLE sys_asset IS '系统技术资产主表';
COMMENT ON COLUMN sys_asset.id IS '主键ID（UUID）';
COMMENT ON COLUMN sys_asset.code IS '系统编码（人工维护，不可改）';
COMMENT ON COLUMN sys_asset.name IS '系统名称';
COMMENT ON COLUMN sys_asset.biz_domain IS '所属业务域';
COMMENT ON COLUMN sys_asset.owner IS '负责人';
COMMENT ON COLUMN sys_asset.status IS '状态 1-在建 2-已上线 3-已下线 4-维护中';
COMMENT ON COLUMN sys_asset.project_name IS '项目名称';
COMMENT ON COLUMN sys_asset.project_no IS '项目编号';
COMMENT ON COLUMN sys_asset.leader_name IS '组长';
COMMENT ON COLUMN sys_asset.leader_mobile IS '组长手机（SM4加密）';
COMMENT ON COLUMN sys_asset.pm_name IS '项目经理';
COMMENT ON COLUMN sys_asset.pm_mobile IS '项目经理手机（SM4加密）';
COMMENT ON COLUMN sys_asset.intro IS '系统介绍';
COMMENT ON COLUMN sys_asset.category IS '系统类别';
COMMENT ON COLUMN sys_asset.svn_doc_url IS 'SVN文档地址';
COMMENT ON COLUMN sys_asset.git_code_url IS 'Git代码地址';
COMMENT ON COLUMN sys_asset.module_name IS '模块名';
COMMENT ON COLUMN sys_asset.branch_name IS '分支名';
COMMENT ON COLUMN sys_asset.branch_desc IS '分支描述';
COMMENT ON COLUMN sys_asset.branch_url IS '分支地址';
COMMENT ON COLUMN sys_asset.created_user IS '创建人';
COMMENT ON COLUMN sys_asset.updated_user IS '更新人';
COMMENT ON COLUMN sys_asset.created_time IS '创建时间';
COMMENT ON COLUMN sys_asset.updated_time IS '更新时间';
COMMENT ON COLUMN sys_asset.is_deleted IS '是否删除 0-否 1-是';
COMMENT ON COLUMN sys_asset.deleted_time IS '删除时间（软删除）';

-- 3. 系统编码部分唯一索引（WHERE is_deleted=0，兼容逻辑删除）
CREATE UNIQUE INDEX IF NOT EXISTS uk_sys_asset_code ON sys_asset (code) WHERE is_deleted = 0;