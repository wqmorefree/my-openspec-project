-- V1 init: base tables + find_in_set compat + seed data (KingbaseES)
-- generated from ry_vue.sql, follows docs/rules/database.md

-- find_in_set(str, set) compat function, MySQL semantics (returns position, 0 if absent)
CREATE OR REPLACE FUNCTION find_in_set(text, text) RETURNS int AS $$
    SELECT CASE
        WHEN $1 IS NULL OR $2 IS NULL THEN NULL
        WHEN $2 = '' OR $1 = '' THEN 0
        WHEN $1 = $2 THEN 1
        ELSE COALESCE((
            SELECT ord::int
            FROM regexp_split_to_table($2, ',') WITH ORDINALITY AS t(elem, ord)
            WHERE elem = $1 LIMIT 1
        ), 0)
    END;
$$ LANGUAGE sql IMMUTABLE;

CREATE TABLE IF NOT EXISTS sys_social (
    id bigint           not null,
    user_id bigint           not null,
    auth_id VARCHAR(255)     not null,
    source VARCHAR(255)     not null,
    open_id VARCHAR(255)     default null,
    user_name VARCHAR(30)      not null,
    nick_name VARCHAR(30)      default '',
    email VARCHAR(255)     default '',
    avatar VARCHAR(500)     default '',
    access_token VARCHAR(2000)     not null,
    expire_in INTEGER              default null,
    refresh_token VARCHAR(2000)     default null,
    access_code VARCHAR(255)     default null,
    union_id VARCHAR(255)     default null,
    scope VARCHAR(255)     default null,
    token_type VARCHAR(255)     default null,
    id_token VARCHAR(2000)    default null,
    mac_algorithm VARCHAR(255)     default null,
    mac_key VARCHAR(255)     default null,
    code VARCHAR(255)     default null,
    oauth_token VARCHAR(255)     default null,
    oauth_token_secret VARCHAR(255)     default null,
    create_dept BIGINT,
    create_by BIGINT,
    create_time TIMESTAMP,
    update_by BIGINT,
    update_time TIMESTAMP,
    del_flag CHAR(1)          default '0',
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS sys_dept (
    dept_id BIGINT      not null,
    parent_id BIGINT      default 0,
    ancestors VARCHAR(500)    default '',
    dept_name VARCHAR(30)     default '',
    dept_category VARCHAR(100)    default null,
    order_num INTEGER          default 0,
    leader BIGINT      default null,
    phone VARCHAR(11)     default null,
    email VARCHAR(50)     default null,
    status CHAR(1)         default '0',
    del_flag CHAR(1)         default '0',
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    PRIMARY KEY (dept_id)
);

insert into sys_dept values(1761000000000000100, 0, '0', 'XXX科技', null, 0, null, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
insert into sys_dept values(1761000000000000101, 1761000000000000100, '0,1761000000000000100', '深圳总公司', null, 1, null, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
insert into sys_dept values(1761000000000000102, 1761000000000000100, '0,1761000000000000100', '长沙分公司', null, 2, null, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
insert into sys_dept values(1761000000000000103, 1761000000000000101, '0,1761000000000000100,1761000000000000101', '研发部门', null, 1, 1761100000000000001, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
insert into sys_dept values(1761000000000000104, 1761000000000000101, '0,1761000000000000100,1761000000000000101', '市场部门', null, 2, null, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
insert into sys_dept values(1761000000000000105, 1761000000000000101, '0,1761000000000000100,1761000000000000101', '测试部门', null, 3, null, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
insert into sys_dept values(1761000000000000106, 1761000000000000101, '0,1761000000000000100,1761000000000000101', '财务部门', null, 4, null, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
insert into sys_dept values(1761000000000000107, 1761000000000000101, '0,1761000000000000100,1761000000000000101', '运维部门', null, 5, null, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
insert into sys_dept values(1761000000000000108, 1761000000000000102, '0,1761000000000000100,1761000000000000102', '市场部门', null, 1, null, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
insert into sys_dept values(1761000000000000109, 1761000000000000102, '0,1761000000000000100,1761000000000000102', '财务部门', null, 2, null, '15888888888', 'xxx@qq.com', '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null);
CREATE TABLE IF NOT EXISTS sys_user (
    user_id BIGINT      not null,
    dept_id BIGINT      default null,
    user_name VARCHAR(30)     not null,
    nick_name VARCHAR(30)     not null,
    user_type VARCHAR(10)     default 'sys_user',
    email VARCHAR(50)     default '',
    phone_number VARCHAR(11)     default '',
    gender CHAR(1)         default '0',
    avatar BIGINT,
    password VARCHAR(100)    default '',
    status CHAR(1)         default '0',
    del_flag CHAR(1)         default '0',
    login_ip VARCHAR(128)    default '',
    login_date TIMESTAMP,
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    remark VARCHAR(500)    default null,
    PRIMARY KEY (user_id)
);

insert into sys_user values(1761100000000000001, 1761000000000000103, 'admin', '疯狂的狮子Li', 'sys_user', 'crazyLionLi@163.com', '15888888888', '1', null, '52de560f88d6fcc00899a4631b7d7623d1a730238f0af19d91d8e1ef6b820448', '0', '0', '127.0.0.1', CURRENT_TIMESTAMP, 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '管理员');
insert into sys_user values(1761100000000000003, 1761000000000000108, 'test', '本部门及以下 密码666666', 'sys_user', '', '', '0', null, '52de560f88d6fcc00899a4631b7d7623d1a730238f0af19d91d8e1ef6b820448', '0', '0', '127.0.0.1', CURRENT_TIMESTAMP, 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000003, CURRENT_TIMESTAMP, null);
insert into sys_user values(1761100000000000004, 1761000000000000102, 'test1', '仅本人 密码666666', 'sys_user', '', '', '0', null, '52de560f88d6fcc00899a4631b7d7623d1a730238f0af19d91d8e1ef6b820448', '0', '0', '127.0.0.1', CURRENT_TIMESTAMP, 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000004, CURRENT_TIMESTAMP, null);
CREATE TABLE IF NOT EXISTS sys_post (
    post_id BIGINT      not null,
    dept_id BIGINT      not null,
    post_code VARCHAR(64)     not null,
    post_category VARCHAR(100)    default null,
    post_name VARCHAR(50)     not null,
    post_sort INTEGER          not null,
    status CHAR(1)         not null,
    del_flag CHAR(1)         default '0',
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    remark VARCHAR(500)    default null,
    PRIMARY KEY (post_id)
);

insert into sys_post values(1761200000000000001, 1761000000000000103, 'ceo', null, '董事长', 1, '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_post values(1761200000000000002, 1761000000000000100, 'se', null, '项目经理', 2, '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_post values(1761200000000000003, 1761000000000000100, 'hr', null, '人力资源', 3, '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_post values(1761200000000000004, 1761000000000000100, 'user', null, '普通员工', 4, '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
CREATE TABLE IF NOT EXISTS sys_role (
    role_id BIGINT      not null,
    role_name VARCHAR(30)     not null,
    role_key VARCHAR(100)    not null,
    role_sort INTEGER          not null,
    data_scope CHAR(1)         default '1',
    menu_check_strictly SMALLINT      default 1,
    dept_check_strictly SMALLINT      default 1,
    status CHAR(1)         not null,
    del_flag CHAR(1)         default '0',
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    remark VARCHAR(500)    default null,
    PRIMARY KEY (role_id)
);

insert into sys_role values(1761300000000000001, '超级管理员', 'superadmin', 1, 1, 1, 1, '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '超级管理员');
insert into sys_role values(1761300000000000003, '本部门及以下', 'test1', 3, 4, 1, 1, '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_role values(1761300000000000004, '仅本人', 'test2', 4, 5, 1, 1, '0', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
CREATE TABLE IF NOT EXISTS sys_menu (
    menu_id BIGINT      not null,
    menu_name VARCHAR(50)     not null,
    parent_id BIGINT      default 0,
    order_num INTEGER          default 0,
    path VARCHAR(200)    default '',
    component VARCHAR(255)    default null,
    query_param VARCHAR(255)    default null,
    is_frame CHAR(1)         default 'N',
    is_cache CHAR(1)         default 'Y',
    menu_type CHAR(1)         default '',
    visible CHAR(1)         default 0,
    status CHAR(1)         default 0,
    perms VARCHAR(100)    default null,
    icon VARCHAR(100)    default '#',
    active_menu VARCHAR(255)    default '',
    ext VARCHAR(2000)   default '',
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    remark VARCHAR(500)    default '',
    PRIMARY KEY (menu_id)
);

insert into sys_menu values(1761400000000000001, '系统管理', 0, 1, 'system', null, '', 'N', 'Y', 'M', '0', '0', '', 'system', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '系统管理目录');
insert into sys_menu values(1761400000000000002, '系统监控', 0, 3, 'monitor', null, '', 'N', 'Y', 'M', '0', '0', '', 'monitor', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '系统监控目录');
insert into sys_menu values(1761400000000000003, '系统工具', 0, 4, 'tool', null, '', 'N', 'Y', 'M', '0', '0', '', 'tool', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '系统工具目录');
insert into sys_menu values(1761400000000000005, '测试菜单', 0, 5, 'demo', null, '', 'N', 'Y', 'M', '0', '0', '', 'star', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '测试菜单');
insert into sys_menu values(1761400000000000008, 'AI会话',  0, 8, 'aichat', 'ai/chat/index', '', 'N', 'Y', 'C', '0', '0', '', 'checkbox', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, 'AI聊天菜单');
insert into sys_menu values(1761400000000000004, 'PLUS官网', 0, 9, 'https://gitee.com/dromara/RuoYi-Vue-Plus', null, '', 'Y', 'Y', 'M', '0', '0', '', 'guide', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, 'RuoYi-Vue-Plus官网地址');
insert into sys_menu values(1761400000000000100, '用户管理', 1761400000000000001, 1, 'user', 'system/user/index', '', 'N', 'Y', 'C', '0', '0', 'system:user:list', 'user', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '用户管理菜单');
insert into sys_menu values(1761400000000000101, '角色管理', 1761400000000000001, 2, 'role', 'system/role/index', '', 'N', 'Y', 'C', '0', '0', 'system:role:list', 'peoples', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '角色管理菜单');
insert into sys_menu values(1761400000000000102, '菜单管理', 1761400000000000001, 3, 'menu', 'system/menu/index', '', 'N', 'Y', 'C', '0', '0', 'system:menu:list', 'tree-table', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '菜单管理菜单');
insert into sys_menu values(1761400000000000103, '部门管理', 1761400000000000001, 4, 'dept', 'system/dept/index', '', 'N', 'Y', 'C', '0', '0', 'system:dept:list', 'tree', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '部门管理菜单');
insert into sys_menu values(1761400000000000104, '岗位管理', 1761400000000000001, 5, 'post', 'system/post/index', '', 'N', 'Y', 'C', '0', '0', 'system:post:list', 'post', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '岗位管理菜单');
insert into sys_menu values(1761400000000000105, '字典管理', 1761400000000000001, 6, 'dict', 'system/dict/index', '', 'N', 'Y', 'C', '0', '0', 'system:dict:list', 'dict', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '字典管理菜单');
insert into sys_menu values(1761400000000000106, '参数设置', 1761400000000000001, 7, 'config', 'system/config/index', '', 'N', 'Y', 'C', '0', '0', 'system:config:list', 'edit', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '参数设置菜单');
insert into sys_menu values(1761400000000000107, '通知公告', 1761400000000000001, 8, 'notice', 'system/notice/index', '', 'N', 'Y', 'C', '0', '0', 'system:notice:list', 'message', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '通知公告菜单');
insert into sys_menu values(1761400000000000108, '日志管理', 1761400000000000001, 9, 'log', '', '', 'N', 'Y', 'M', '0', '0', '', 'log', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '日志管理菜单');
insert into sys_menu values(1761400000000000109, '在线用户', 1761400000000000002, 1, 'online', 'monitor/online/index', '', 'N', 'Y', 'C', '0', '0', 'monitor:online:list', 'online', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '在线用户菜单');
insert into sys_menu values(1761400000000000113, '缓存监控', 1761400000000000002, 5, 'cache', 'monitor/cache/index', '', 'N', 'Y', 'C', '0', '0', 'monitor:cache:list', 'redis', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '缓存监控菜单');
insert into sys_menu values(1761400000000000115, '代码生成', 1761400000000000003, 2, 'gen', 'tool/gen/index', '', 'N', 'Y', 'C', '0', '0', 'tool:gen:list', 'code', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '代码生成菜单');
insert into sys_menu values(1761400000000000123, '客户端管理', 1761400000000000001, 11, 'client', 'system/client/index', '', 'N', 'Y', 'C', '0', '0', 'system:client:list', 'international', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '客户端管理菜单');
insert into sys_menu values(1761400000000000116, '修改生成配置', 1761400000000000003, 2, 'gen-edit/index/:tableId', 'tool/gen/editTable', '', 'N', 'N', 'C', '1', '0', 'tool:gen:edit', '#', '/tool/gen', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000000130, '分配用户', 1761400000000000001, 2, 'role-auth/user/:roleId', 'system/role/authUser', '', 'N', 'N', 'C', '1', '0', 'system:role:edit', '#', '/system/role', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000000131, '分配角色', 1761400000000000001, 1, 'user-auth/role/:userId', 'system/user/authRole', '', 'N', 'N', 'C', '1', '0', 'system:user:edit', '#', '/system/user', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000000133, '文件配置管理', 1761400000000000001, 10, 'oss-config/index', 'system/oss/config', '', 'N', 'N', 'C', '1', '0', 'system:ossConfig:list', '#', '/system/oss', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000000117, 'Admin监控', 1761400000000000002, 5, 'Admin', 'monitor/admin/index', '', 'N', 'Y', 'C', '0', '0', 'monitor:admin:list', 'dashboard', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, 'Admin监控菜单');
insert into sys_menu values(1761400000000000118, '文件管理', 1761400000000000001, 10, 'oss', 'system/oss/index', '', 'N', 'Y', 'C', '0', '0', 'system:oss:list', 'upload', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '文件管理菜单');
insert into sys_menu values(1761400000000000120, '任务调度中心', 1761400000000000002, 6, 'snailjob', 'monitor/snailjob/index', '', 'N', 'Y', 'C', '0', '0', 'monitor:snailjob:list', 'job', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, 'SnailJob控制台菜单');
insert into sys_menu values(1761400000000000121, 'AI控制台', 1761400000000000002, 7, 'snailai', 'monitor/snailai/index', '', 'N', 'Y', 'C', '0', '0', 'monitor:snailai:list', 'checkbox', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, 'AI控制台菜单');
insert into sys_menu values(1761400000000000500, '操作日志', 1761400000000000108, 1, 'operlog', 'monitor/operlog/index', '', 'N', 'Y', 'C', '0', '0', 'monitor:operlog:list', 'form', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '操作日志菜单');
insert into sys_menu values(1761400000000000501, '登录日志', 1761400000000000108, 2, 'logininfo', 'monitor/logininfo/index', '', 'N', 'Y', 'C', '0', '0', 'monitor:logininfo:list', 'logininfo', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '登录日志菜单');
insert into sys_menu values(1761400000000001001, '用户查询', 1761400000000000100, 1, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:user:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001002, '用户新增', 1761400000000000100, 2, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:user:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001003, '用户修改', 1761400000000000100, 3, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:user:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001004, '用户删除', 1761400000000000100, 4, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:user:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001005, '用户导出', 1761400000000000100, 5, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:user:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001006, '用户导入', 1761400000000000100, 6, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:user:import', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001007, '重置密码', 1761400000000000100, 7, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:user:resetPwd', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001008, '角色查询', 1761400000000000101, 1, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:role:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001009, '角色新增', 1761400000000000101, 2, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:role:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001010, '角色修改', 1761400000000000101, 3, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:role:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001011, '角色删除', 1761400000000000101, 4, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:role:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001012, '角色导出', 1761400000000000101, 5, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:role:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001013, '菜单查询', 1761400000000000102, 1, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:menu:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001014, '菜单新增', 1761400000000000102, 2, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:menu:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001015, '菜单修改', 1761400000000000102, 3, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:menu:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001016, '菜单删除', 1761400000000000102, 4, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:menu:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001017, '部门查询', 1761400000000000103, 1, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:dept:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001018, '部门新增', 1761400000000000103, 2, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:dept:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001019, '部门修改', 1761400000000000103, 3, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:dept:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001020, '部门删除', 1761400000000000103, 4, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:dept:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001021, '岗位查询', 1761400000000000104, 1, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:post:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001022, '岗位新增', 1761400000000000104, 2, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:post:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001023, '岗位修改', 1761400000000000104, 3, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:post:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001024, '岗位删除', 1761400000000000104, 4, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:post:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001025, '岗位导出', 1761400000000000104, 5, '', '', '', 'N', 'Y', 'F', '0', '0', 'system:post:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001026, '字典查询', 1761400000000000105, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:dict:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001027, '字典新增', 1761400000000000105, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:dict:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001028, '字典修改', 1761400000000000105, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:dict:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001029, '字典删除', 1761400000000000105, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:dict:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001030, '字典导出', 1761400000000000105, 5, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:dict:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001031, '参数查询', 1761400000000000106, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:config:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001032, '参数新增', 1761400000000000106, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:config:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001033, '参数修改', 1761400000000000106, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:config:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001034, '参数删除', 1761400000000000106, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:config:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001035, '参数导出', 1761400000000000106, 5, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:config:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001036, '公告查询', 1761400000000000107, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:notice:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001037, '公告新增', 1761400000000000107, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:notice:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001038, '公告修改', 1761400000000000107, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:notice:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001039, '公告删除', 1761400000000000107, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:notice:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001040, '操作查询', 1761400000000000500, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:operlog:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001041, '操作删除', 1761400000000000500, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:operlog:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001042, '日志导出', 1761400000000000500, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:operlog:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001043, '登录查询', 1761400000000000501, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:logininfo:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001044, '登录删除', 1761400000000000501, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:logininfo:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001045, '日志导出', 1761400000000000501, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:logininfo:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001050, '账户解锁', 1761400000000000501, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:logininfo:unlock', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001046, '在线查询', 1761400000000000109, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:online:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001047, '批量强退', 1761400000000000109, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:online:batchLogout', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001048, '单条强退', 1761400000000000109, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'monitor:online:forceLogout', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001055, '生成查询', 1761400000000000115, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'tool:gen:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001056, '生成修改', 1761400000000000115, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'tool:gen:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001057, '生成删除', 1761400000000000115, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'tool:gen:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001058, '导入代码', 1761400000000000115, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'tool:gen:import', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001059, '预览代码', 1761400000000000115, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'tool:gen:preview', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001060, '生成代码', 1761400000000000115, 5, '#', '', '', 'N', 'Y', 'F', '0', '0', 'tool:gen:code', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001600, '文件查询', 1761400000000000118, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:oss:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001601, '文件上传', 1761400000000000118, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:oss:upload', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001602, '文件下载', 1761400000000000118, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:oss:download', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001603, '文件删除', 1761400000000000118, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:oss:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001620, '配置列表', 1761400000000000118, 5, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:ossConfig:list', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001621, '配置添加', 1761400000000000118, 6, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:ossConfig:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001622, '配置编辑', 1761400000000000118, 6, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:ossConfig:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001623, '配置删除', 1761400000000000118, 6, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:ossConfig:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001061, '客户端管理查询', 1761400000000000123, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:client:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001062, '客户端管理新增', 1761400000000000123, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:client:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001063, '客户端管理修改', 1761400000000000123, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:client:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001064, '客户端管理删除', 1761400000000000123, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:client:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001065, '客户端管理导出', 1761400000000000123, 5, '#', '', '', 'N', 'Y', 'F', '0', '0', 'system:client:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001500, '测试单表', 1761400000000000005, 1, 'demo', 'demo/demo/index', '', 'N', 'Y', 'C', '0', '0', 'demo:demo:list', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '测试单表菜单');
insert into sys_menu values(1761400000000001501, '测试单表查询', 1761400000000001500, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:demo:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001502, '测试单表新增', 1761400000000001500, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:demo:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001503, '测试单表修改', 1761400000000001500, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:demo:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001504, '测试单表删除', 1761400000000001500, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:demo:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001505, '测试单表导出', 1761400000000001500, 5, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:demo:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001506, '测试树表', 1761400000000000005, 1, 'tree', 'demo/tree/index', '', 'N', 'Y', 'C', '0', '0', 'demo:tree:list', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '测试树表菜单');
insert into sys_menu values(1761400000000001507, '测试树表查询', 1761400000000001506, 1, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:tree:query', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001508, '测试树表新增', 1761400000000001506, 2, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:tree:add', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001509, '测试树表修改', 1761400000000001506, 3, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:tree:edit', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001510, '测试树表删除', 1761400000000001506, 4, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:tree:remove', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
insert into sys_menu values(1761400000000001511, '测试树表导出', 1761400000000001506, 5, '#', '', '', 'N', 'Y', 'F', '0', '0', 'demo:tree:export', '#', '', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '');
CREATE TABLE IF NOT EXISTS sys_user_role (
    user_id BIGINT not null,
    role_id BIGINT not null,
    PRIMARY KEY (user_id, role_id)
);

insert into sys_user_role values (1761100000000000001, 1761300000000000001);
insert into sys_user_role values (1761100000000000003, 1761300000000000003);
insert into sys_user_role values (1761100000000000004, 1761300000000000004);
CREATE TABLE IF NOT EXISTS sys_role_menu (
    role_id BIGINT not null,
    menu_id BIGINT not null,
    PRIMARY KEY (role_id, menu_id)
);

insert into sys_role_menu values (1761300000000000003, 1761400000000000001);
insert into sys_role_menu values (1761300000000000003, 1761400000000000005);
insert into sys_role_menu values (1761300000000000003, 1761400000000000100);
insert into sys_role_menu values (1761300000000000003, 1761400000000000101);
insert into sys_role_menu values (1761300000000000003, 1761400000000000102);
insert into sys_role_menu values (1761300000000000003, 1761400000000000103);
insert into sys_role_menu values (1761300000000000003, 1761400000000000104);
insert into sys_role_menu values (1761300000000000003, 1761400000000000105);
insert into sys_role_menu values (1761300000000000003, 1761400000000000106);
insert into sys_role_menu values (1761300000000000003, 1761400000000000107);
insert into sys_role_menu values (1761300000000000003, 1761400000000000108);
insert into sys_role_menu values (1761300000000000003, 1761400000000000118);
insert into sys_role_menu values (1761300000000000003, 1761400000000000123);
insert into sys_role_menu values (1761300000000000003, 1761400000000000130);
insert into sys_role_menu values (1761300000000000003, 1761400000000000131);
insert into sys_role_menu values (1761300000000000003, 1761400000000000133);
insert into sys_role_menu values (1761300000000000003, 1761400000000000500);
insert into sys_role_menu values (1761300000000000003, 1761400000000000501);
insert into sys_role_menu values (1761300000000000003, 1761400000000001001);
insert into sys_role_menu values (1761300000000000003, 1761400000000001002);
insert into sys_role_menu values (1761300000000000003, 1761400000000001003);
insert into sys_role_menu values (1761300000000000003, 1761400000000001004);
insert into sys_role_menu values (1761300000000000003, 1761400000000001005);
insert into sys_role_menu values (1761300000000000003, 1761400000000001006);
insert into sys_role_menu values (1761300000000000003, 1761400000000001007);
insert into sys_role_menu values (1761300000000000003, 1761400000000001008);
insert into sys_role_menu values (1761300000000000003, 1761400000000001009);
insert into sys_role_menu values (1761300000000000003, 1761400000000001010);
insert into sys_role_menu values (1761300000000000003, 1761400000000001011);
insert into sys_role_menu values (1761300000000000003, 1761400000000001012);
insert into sys_role_menu values (1761300000000000003, 1761400000000001013);
insert into sys_role_menu values (1761300000000000003, 1761400000000001014);
insert into sys_role_menu values (1761300000000000003, 1761400000000001015);
insert into sys_role_menu values (1761300000000000003, 1761400000000001016);
insert into sys_role_menu values (1761300000000000003, 1761400000000001017);
insert into sys_role_menu values (1761300000000000003, 1761400000000001018);
insert into sys_role_menu values (1761300000000000003, 1761400000000001019);
insert into sys_role_menu values (1761300000000000003, 1761400000000001020);
insert into sys_role_menu values (1761300000000000003, 1761400000000001021);
insert into sys_role_menu values (1761300000000000003, 1761400000000001022);
insert into sys_role_menu values (1761300000000000003, 1761400000000001023);
insert into sys_role_menu values (1761300000000000003, 1761400000000001024);
insert into sys_role_menu values (1761300000000000003, 1761400000000001025);
insert into sys_role_menu values (1761300000000000003, 1761400000000001026);
insert into sys_role_menu values (1761300000000000003, 1761400000000001027);
insert into sys_role_menu values (1761300000000000003, 1761400000000001028);
insert into sys_role_menu values (1761300000000000003, 1761400000000001029);
insert into sys_role_menu values (1761300000000000003, 1761400000000001030);
insert into sys_role_menu values (1761300000000000003, 1761400000000001031);
insert into sys_role_menu values (1761300000000000003, 1761400000000001032);
insert into sys_role_menu values (1761300000000000003, 1761400000000001033);
insert into sys_role_menu values (1761300000000000003, 1761400000000001034);
insert into sys_role_menu values (1761300000000000003, 1761400000000001035);
insert into sys_role_menu values (1761300000000000003, 1761400000000001036);
insert into sys_role_menu values (1761300000000000003, 1761400000000001037);
insert into sys_role_menu values (1761300000000000003, 1761400000000001038);
insert into sys_role_menu values (1761300000000000003, 1761400000000001039);
insert into sys_role_menu values (1761300000000000003, 1761400000000001040);
insert into sys_role_menu values (1761300000000000003, 1761400000000001041);
insert into sys_role_menu values (1761300000000000003, 1761400000000001042);
insert into sys_role_menu values (1761300000000000003, 1761400000000001043);
insert into sys_role_menu values (1761300000000000003, 1761400000000001044);
insert into sys_role_menu values (1761300000000000003, 1761400000000001045);
insert into sys_role_menu values (1761300000000000003, 1761400000000001050);
insert into sys_role_menu values (1761300000000000003, 1761400000000001061);
insert into sys_role_menu values (1761300000000000003, 1761400000000001062);
insert into sys_role_menu values (1761300000000000003, 1761400000000001063);
insert into sys_role_menu values (1761300000000000003, 1761400000000001064);
insert into sys_role_menu values (1761300000000000003, 1761400000000001065);
insert into sys_role_menu values (1761300000000000003, 1761400000000001500);
insert into sys_role_menu values (1761300000000000003, 1761400000000001501);
insert into sys_role_menu values (1761300000000000003, 1761400000000001502);
insert into sys_role_menu values (1761300000000000003, 1761400000000001503);
insert into sys_role_menu values (1761300000000000003, 1761400000000001504);
insert into sys_role_menu values (1761300000000000003, 1761400000000001505);
insert into sys_role_menu values (1761300000000000003, 1761400000000001506);
insert into sys_role_menu values (1761300000000000003, 1761400000000001507);
insert into sys_role_menu values (1761300000000000003, 1761400000000001508);
insert into sys_role_menu values (1761300000000000003, 1761400000000001509);
insert into sys_role_menu values (1761300000000000003, 1761400000000001510);
insert into sys_role_menu values (1761300000000000003, 1761400000000001511);
insert into sys_role_menu values (1761300000000000003, 1761400000000001600);
insert into sys_role_menu values (1761300000000000003, 1761400000000001601);
insert into sys_role_menu values (1761300000000000003, 1761400000000001602);
insert into sys_role_menu values (1761300000000000003, 1761400000000001603);
insert into sys_role_menu values (1761300000000000003, 1761400000000001620);
insert into sys_role_menu values (1761300000000000003, 1761400000000001621);
insert into sys_role_menu values (1761300000000000003, 1761400000000001622);
insert into sys_role_menu values (1761300000000000003, 1761400000000001623);
insert into sys_role_menu values (1761300000000000003, 1761400000000011616);
insert into sys_role_menu values (1761300000000000003, 1761400000000011618);
insert into sys_role_menu values (1761300000000000003, 1761400000000011619);
insert into sys_role_menu values (1761300000000000003, 1761400000000011622);
insert into sys_role_menu values (1761300000000000003, 1761400000000011623);
insert into sys_role_menu values (1761300000000000003, 1761400000000011629);
insert into sys_role_menu values (1761300000000000003, 1761400000000011632);
insert into sys_role_menu values (1761300000000000003, 1761400000000011633);
insert into sys_role_menu values (1761300000000000003, 1761400000000011638);
insert into sys_role_menu values (1761300000000000003, 1761400000000011639);
insert into sys_role_menu values (1761300000000000003, 1761400000000011640);
insert into sys_role_menu values (1761300000000000003, 1761400000000011641);
insert into sys_role_menu values (1761300000000000003, 1761400000000011642);
insert into sys_role_menu values (1761300000000000003, 1761400000000011643);
insert into sys_role_menu values (1761300000000000003, 1761400000000011701);
insert into sys_role_menu values (1761300000000000004, 1761400000000000005);
insert into sys_role_menu values (1761300000000000004, 1761400000000001500);
insert into sys_role_menu values (1761300000000000004, 1761400000000001501);
insert into sys_role_menu values (1761300000000000004, 1761400000000001502);
insert into sys_role_menu values (1761300000000000004, 1761400000000001503);
insert into sys_role_menu values (1761300000000000004, 1761400000000001504);
insert into sys_role_menu values (1761300000000000004, 1761400000000001505);
insert into sys_role_menu values (1761300000000000004, 1761400000000001506);
insert into sys_role_menu values (1761300000000000004, 1761400000000001507);
insert into sys_role_menu values (1761300000000000004, 1761400000000001508);
insert into sys_role_menu values (1761300000000000004, 1761400000000001509);
insert into sys_role_menu values (1761300000000000004, 1761400000000001510);
insert into sys_role_menu values (1761300000000000004, 1761400000000001511);
CREATE TABLE IF NOT EXISTS sys_role_dept (
    role_id BIGINT not null,
    dept_id BIGINT not null,
    PRIMARY KEY (role_id, dept_id)
);

CREATE TABLE IF NOT EXISTS sys_user_post (
    user_id BIGINT not null,
    post_id BIGINT not null,
    PRIMARY KEY (user_id, post_id)
);

insert into sys_user_post values (1761100000000000001, 1761200000000000001);
CREATE TABLE IF NOT EXISTS sys_oper_log (
    oper_id BIGINT      not null,
    title VARCHAR(50)     default '',
    business_type INTEGER          default 0,
    method VARCHAR(100)    default '',
    request_method VARCHAR(10)     default '',
    operator_type INTEGER          default 0,
    oper_name VARCHAR(50)     default '',
    user_id BIGINT      default null,
    dept_id BIGINT      default null,
    dept_name VARCHAR(50)     default '',
    client_key VARCHAR(32)     default '',
    device_type VARCHAR(32)     default '',
    browser VARCHAR(50)     default '',
    os VARCHAR(50)     default '',
    oper_url VARCHAR(255)    default '',
    oper_ip VARCHAR(128)    default '',
    oper_location VARCHAR(255)    default '',
    oper_param VARCHAR(4000)   default '',
    json_result VARCHAR(4000)   default '',
    status INTEGER          default 0,
    error_msg VARCHAR(4000)   default '',
    oper_time TIMESTAMP,
    cost_time BIGINT      default 0,
    PRIMARY KEY (oper_id)
);

CREATE TABLE IF NOT EXISTS sys_dict_type (
    dict_id BIGINT      not null,
    dict_name VARCHAR(100)    default '',
    dict_type VARCHAR(100)    default '',
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    remark VARCHAR(500)    default null,
    PRIMARY KEY (dict_id),
    UNIQUE (dict_type)
);

insert into sys_dict_type values(1761500000000000001, '用户性别', 'sys_user_gender', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '用户性别列表');
insert into sys_dict_type values(1761500000000000002, '菜单状态', 'sys_show_hide', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '菜单状态列表');
insert into sys_dict_type values(1761500000000000003, '系统开关', 'sys_normal_disable', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '系统开关列表');
insert into sys_dict_type values(1761500000000000006, '系统是否', 'sys_yes_no', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '系统是否列表');
insert into sys_dict_type values(1761500000000000007, '通知类型', 'sys_notice_type', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '通知类型列表');
insert into sys_dict_type values(1761500000000000008, '通知状态', 'sys_notice_status', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '通知状态列表');
insert into sys_dict_type values(1761500000000000009, '操作类型', 'sys_oper_type', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '操作类型列表');
insert into sys_dict_type values(1761500000000000010, '系统状态', 'sys_common_status', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '登录状态列表');
insert into sys_dict_type values(1761500000000000011, '授权类型', 'sys_grant_type', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '认证授权类型');
insert into sys_dict_type values(1761500000000000012, '设备类型', 'sys_device_type', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '客户端设备类型');
CREATE TABLE IF NOT EXISTS sys_dict_data (
    dict_code BIGINT      not null,
    dict_sort INTEGER          default 0,
    dict_label VARCHAR(100)    default '',
    dict_value VARCHAR(100)    default '',
    dict_type VARCHAR(100)    default '',
    css_class VARCHAR(100)    default null,
    list_class VARCHAR(100)    default null,
    is_default CHAR(1)         default 'N',
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    remark VARCHAR(500)    default null,
    PRIMARY KEY (dict_code)
);

insert into sys_dict_data values(1761600000000000001, 1, '男', '0', 'sys_user_gender', '', '', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '性别男');
insert into sys_dict_data values(1761600000000000002, 2, '女', '1', 'sys_user_gender', '', '', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '性别女');
insert into sys_dict_data values(1761600000000000003, 3, '未知', '2', 'sys_user_gender', '', '', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '性别未知');
insert into sys_dict_data values(1761600000000000004, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '显示菜单');
insert into sys_dict_data values(1761600000000000005, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '隐藏菜单');
insert into sys_dict_data values(1761600000000000006, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '正常状态');
insert into sys_dict_data values(1761600000000000007, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '停用状态');
insert into sys_dict_data values(1761600000000000012, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '系统默认是');
insert into sys_dict_data values(1761600000000000013, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '系统默认否');
insert into sys_dict_data values(1761600000000000014, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '通知');
insert into sys_dict_data values(1761600000000000015, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '公告');
insert into sys_dict_data values(1761600000000000016, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '正常状态');
insert into sys_dict_data values(1761600000000000017, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '关闭状态');
insert into sys_dict_data values(1761600000000000029, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '其他操作');
insert into sys_dict_data values(1761600000000000018, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '新增操作');
insert into sys_dict_data values(1761600000000000019, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '修改操作');
insert into sys_dict_data values(1761600000000000020, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '删除操作');
insert into sys_dict_data values(1761600000000000021, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '授权操作');
insert into sys_dict_data values(1761600000000000022, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '导出操作');
insert into sys_dict_data values(1761600000000000023, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '导入操作');
insert into sys_dict_data values(1761600000000000024, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '强退操作');
insert into sys_dict_data values(1761600000000000025, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '生成操作');
insert into sys_dict_data values(1761600000000000026, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '清空操作');
insert into sys_dict_data values(1761600000000000027, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '正常状态');
insert into sys_dict_data values(1761600000000000028, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '停用状态');
insert into sys_dict_data values(1761600000000000030, 0, '密码认证', 'password', 'sys_grant_type', 'el-check-tag', 'default', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '密码认证');
insert into sys_dict_data values(1761600000000000031, 0, '短信认证', 'sms', 'sys_grant_type', 'el-check-tag', 'default', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '短信认证');
insert into sys_dict_data values(1761600000000000032, 0, '邮件认证', 'email', 'sys_grant_type', 'el-check-tag', 'default', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '邮件认证');
insert into sys_dict_data values(1761600000000000033, 0, '小程序认证', 'xcx', 'sys_grant_type', 'el-check-tag', 'default', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '小程序认证');
insert into sys_dict_data values(1761600000000000034, 0, '三方登录认证', 'social', 'sys_grant_type', 'el-check-tag', 'default', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '三方登录认证');
insert into sys_dict_data values(1761600000000000035, 0, 'PC', 'pc', 'sys_device_type', '', 'default', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, 'PC');
insert into sys_dict_data values(1761600000000000036, 0, '安卓', 'android', 'sys_device_type', '', 'default', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '安卓');
insert into sys_dict_data values(1761600000000000037, 0, 'iOS', 'ios', 'sys_device_type', '', 'default', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, 'iOS');
insert into sys_dict_data values(1761600000000000038, 0, '小程序', 'xcx', 'sys_device_type', '', 'default', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '小程序');
CREATE TABLE IF NOT EXISTS sys_config (
    config_id BIGINT      not null,
    config_name VARCHAR(100)    default '',
    config_key VARCHAR(100)    default '',
    config_value VARCHAR(500)    default '',
    config_type CHAR(1)         default 'N',
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    remark VARCHAR(500)    default null,
    PRIMARY KEY (config_id)
);

insert into sys_config values(1761700000000000001, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '初始化密码 123456');
insert into sys_config values(1761700000000000002, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '是否开启注册用户功能（true开启，false关闭）');
insert into sys_config values(1761700000000000003, 'OSS预览列表资源开关', 'sys.oss.previewListResource', 'true', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, 'true:开启, false:关闭');
CREATE TABLE IF NOT EXISTS sys_login_info (
    info_id BIGINT     not null,
    user_name VARCHAR(50)    default '',
    client_key VARCHAR(32)    default '',
    device_type VARCHAR(32)    default '',
    ipaddr VARCHAR(128)   default '',
    login_location VARCHAR(255)   default '',
    browser VARCHAR(50)    default '',
    os VARCHAR(50)    default '',
    status CHAR(1)        default '0',
    msg VARCHAR(255)   default '',
    login_time TIMESTAMP,
    PRIMARY KEY (info_id)
);

CREATE TABLE IF NOT EXISTS sys_notice (
    notice_id BIGINT      not null,
    notice_title VARCHAR(50)     not null,
    notice_type CHAR(1)         not null,
    notice_content BYTEA        default null,
    status CHAR(1)         default '0',
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    remark VARCHAR(255)    default null,
    PRIMARY KEY (notice_id)
);

insert into sys_notice values(1761800000000000001, '温馨提醒：2018-07-01 新版本发布啦', '2', '新版本内容', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '管理员');
insert into sys_notice values(1761800000000000002, '维护通知：2018-07-01 系统凌晨维护', '1', '维护内容', '0', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, null, null, '管理员');
CREATE TABLE IF NOT EXISTS sys_message (
    message_id BIGINT      not null,
    category VARCHAR(20)     not null,
    type VARCHAR(20)     not null,
    source VARCHAR(20)     not null,
    title VARCHAR(100)    default '',
    message VARCHAR(500)    default '',
    content TEXT,
    data_json TEXT,
    path VARCHAR(500)    default null,
    send_user_ids VARCHAR(2000)   not null default '0',
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    PRIMARY KEY (message_id)
);

CREATE TABLE IF NOT EXISTS gen_table (
    table_id BIGINT      not null,
    data_name VARCHAR(200)    default '',
    table_name VARCHAR(200)    default '',
    table_comment VARCHAR(500)    default '',
    class_name VARCHAR(100)    default '',
    tpl_category VARCHAR(200)    default 'crud',
    frontend_type VARCHAR(50)     default 'vue',
    package_name VARCHAR(100),
    module_name VARCHAR(30),
    business_name VARCHAR(30),
    function_name VARCHAR(50),
    function_author VARCHAR(50),
    gen_type CHAR(1)         default '0',
    gen_path VARCHAR(200)    default '/',
    options VARCHAR(1000),
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    remark VARCHAR(500)    default null,
    PRIMARY KEY (table_id)
);

CREATE TABLE IF NOT EXISTS gen_table_column (
    column_id BIGINT      not null,
    table_id BIGINT,
    column_name VARCHAR(200),
    column_comment VARCHAR(500),
    column_type VARCHAR(100),
    java_type VARCHAR(500),
    java_field VARCHAR(200),
    is_pk CHAR(1),
    is_increment CHAR(1),
    is_required CHAR(1),
    is_insert CHAR(1),
    is_edit CHAR(1),
    is_list CHAR(1),
    is_query CHAR(1),
    query_type VARCHAR(200)    default 'EQ',
    html_type VARCHAR(200),
    dict_type VARCHAR(200)    default '',
    sort INTEGER,
    create_dept BIGINT      default null,
    create_by BIGINT      default null,
    create_time TIMESTAMP,
    update_by BIGINT      default null,
    update_time TIMESTAMP,
    PRIMARY KEY (column_id)
);

CREATE TABLE IF NOT EXISTS sys_oss (
    oss_id BIGINT   not null,
    file_name VARCHAR(255) not null default '',
    original_name VARCHAR(255) not null default '',
    file_suffix VARCHAR(10)  not null default '',
    url VARCHAR(500) not null,
    ext1 text                  default null,
    create_dept BIGINT            default null,
    create_time TIMESTAMP              default null,
    create_by BIGINT            default null,
    update_time TIMESTAMP              default null,
    update_by BIGINT            default null,
    service VARCHAR(20)  not null default 'minio',
    PRIMARY KEY (oss_id)
);

CREATE TABLE IF NOT EXISTS sys_oss_config (
    oss_config_id BIGINT    not null,
    config_key VARCHAR(20)   not null  default '',
    access_key VARCHAR(255)            default '',
    secret_key VARCHAR(255)            default '',
    bucket_name VARCHAR(255)            default '',
    prefix VARCHAR(255)            default '',
    endpoint VARCHAR(255)            default '',
    domain_url VARCHAR(255)            default '',
    is_https CHAR(1)                 default 'N',
    region VARCHAR(255)            default '',
    access_policy CHAR(1)       not null  default '1',
    status CHAR(1)                 default 'N',
    ext1 VARCHAR(255)            default '',
    create_dept BIGINT              default null,
    create_by BIGINT              default null,
    create_time TIMESTAMP                default null,
    update_by BIGINT              default null,
    update_time TIMESTAMP                default null,
    remark VARCHAR(500)            default null,
    PRIMARY KEY (oss_config_id)
);

insert into sys_oss_config values (1761900000000000001, 'minio', 'ruoyi', 'ruoyi123', 'ruoyi', '', '127.0.0.1:9000', '', 'N', '', '1', 'Y', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, null);
insert into sys_oss_config values (1761900000000000002, 'qiniu', 'XXXXXXXXXXXXXXX', 'XXXXXXXXXXXXXXX', 'ruoyi', '', 's3-cn-north-1.qiniucs.com', '', 'N', '', '1', 'N', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, null);
insert into sys_oss_config values (1761900000000000003, 'aliyun', 'XXXXXXXXXXXXXXX', 'XXXXXXXXXXXXXXX', 'ruoyi', '', 'oss-cn-beijing.aliyuncs.com', '', 'N', '', '1', 'N', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, null);
insert into sys_oss_config values (1761900000000000004, 'qcloud', 'XXXXXXXXXXXXXXX', 'XXXXXXXXXXXXXXX', 'ruoyi-1240000000', '', 'cos.ap-beijing.myqcloud.com', '', 'N', 'ap-beijing', '1', 'N', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, null);
insert into sys_oss_config values (1761900000000000005, 'image', 'ruoyi', 'ruoyi123', 'ruoyi', 'image', '127.0.0.1:9000', '', 'N', '', '1', 'N', '', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, null);
CREATE TABLE IF NOT EXISTS sys_client (
    id BIGINT    not null,
    client_id VARCHAR(64)   default null,
    client_key VARCHAR(32)   default null,
    client_secret VARCHAR(255)  default null,
    grant_type VARCHAR(255)  default null,
    device_type VARCHAR(32)   default null,
    access_path VARCHAR(2000) default null,
    ip_whitelist VARCHAR(1000) default null,
    active_timeout INTEGER       default 1800,
    timeout INTEGER       default 604800,
    status CHAR(1)       default '0',
    del_flag CHAR(1)       default '0',
    create_dept BIGINT    default null,
    create_by BIGINT    default null,
    create_time TIMESTAMP      default null,
    update_by BIGINT    default null,
    update_time TIMESTAMP      default null,
    PRIMARY KEY (id)
);

insert into sys_client values (1762000000000000001, 'e5cd7e4891bf95d1d19206ce24a7b32e', 'pc', 'pc123', 'password,social', 'pc', null, null, 1800, 604800, 0, 0, 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP);
insert into sys_client values (1762000000000000002, '428a8310cd442757ae699df5d894f051', 'app', 'app123', 'password,sms,social', 'android', '/app/**', null, 1800, 604800, 0, 0, 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS test_demo (
    id BIGINT    NOT NULL,
    dept_id BIGINT    NULL DEFAULT NULL,
    user_id BIGINT    NULL DEFAULT NULL,
    order_num INTEGER       NULL DEFAULT 0,
    test_key VARCHAR(255) NULL DEFAULT NULL,
    value VARCHAR(255) NULL DEFAULT NULL,
    version INTEGER       NULL DEFAULT 0,
    create_dept BIGINT    NULL DEFAULT NULL,
    create_time TIMESTAMP  NULL DEFAULT NULL,
    create_by BIGINT    NULL DEFAULT NULL,
    update_time TIMESTAMP  NULL DEFAULT NULL,
    update_by BIGINT    NULL DEFAULT NULL,
    del_flag INTEGER       NULL DEFAULT 0,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS test_tree (
    id BIGINT    NOT NULL,
    parent_id BIGINT    NULL DEFAULT 0,
    dept_id BIGINT    NULL DEFAULT NULL,
    user_id BIGINT    NULL DEFAULT NULL,
    tree_name VARCHAR(255) NULL DEFAULT NULL,
    version INTEGER       NULL DEFAULT 0,
    create_dept BIGINT    NULL DEFAULT NULL,
    create_time TIMESTAMP  NULL DEFAULT NULL,
    create_by BIGINT    NULL DEFAULT NULL,
    update_time TIMESTAMP  NULL DEFAULT NULL,
    update_by BIGINT    NULL DEFAULT NULL,
    del_flag INTEGER       NULL DEFAULT 0,
    PRIMARY KEY (id)
);

INSERT INTO test_demo VALUES (1762100000000000001, 1761000000000000102, 1761100000000000004, 1, '测试数据权限', '测试', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000002, 1761000000000000102, 1761100000000000003, 2, '子节点1', '111', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000003, 1761000000000000102, 1761100000000000003, 3, '子节点2', '222', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000004, 1761000000000000108, 1761100000000000004, 4, '测试数据', 'demo', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000005, 1761000000000000108, 1761100000000000003, 13, '子节点11', '1111', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000006, 1761000000000000108, 1761100000000000003, 12, '子节点22', '2222', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000007, 1761000000000000108, 1761100000000000003, 11, '子节点33', '3333', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000008, 1761000000000000108, 1761100000000000003, 10, '子节点44', '4444', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000009, 1761000000000000108, 1761100000000000003, 9, '子节点55', '5555', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000010, 1761000000000000108, 1761100000000000003, 8, '子节点66', '6666', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000011, 1761000000000000108, 1761100000000000003, 7, '子节点77', '7777', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000012, 1761000000000000108, 1761100000000000003, 6, '子节点88', '8888', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_demo VALUES (1762100000000000013, 1761000000000000108, 1761100000000000003, 5, '子节点99', '9999', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000001, 0, 1761000000000000102, 1761100000000000004, '测试数据权限', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000002, 1762200000000000001, 1761000000000000102, 1761100000000000003, '子节点1', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000003, 1762200000000000002, 1761000000000000102, 1761100000000000003, '子节点2', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000004, 0, 1761000000000000108, 1761100000000000004, '测试树1', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000005, 1762200000000000004, 1761000000000000108, 1761100000000000003, '子节点11', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000006, 1762200000000000004, 1761000000000000108, 1761100000000000003, '子节点22', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000007, 1762200000000000004, 1761000000000000108, 1761100000000000003, '子节点33', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000008, 1762200000000000005, 1761000000000000108, 1761100000000000003, '子节点44', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000009, 1762200000000000006, 1761000000000000108, 1761100000000000003, '子节点55', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000010, 1762200000000000007, 1761000000000000108, 1761100000000000003, '子节点66', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000011, 1762200000000000007, 1761000000000000108, 1761100000000000003, '子节点77', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000012, 1762200000000000010, 1761000000000000108, 1761100000000000003, '子节点88', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);
INSERT INTO test_tree VALUES (1762200000000000013, 1762200000000000010, 1761000000000000108, 1761100000000000003, '子节点99', 0, 1761000000000000103, CURRENT_TIMESTAMP, 1761100000000000001, NULL, NULL, 0);

COMMENT ON COLUMN sys_social.id IS '主键';
COMMENT ON COLUMN sys_social.user_id IS '用户ID';
COMMENT ON COLUMN sys_social.auth_id IS '平台+平台唯一id';
COMMENT ON COLUMN sys_social.source IS '用户来源';
COMMENT ON COLUMN sys_social.open_id IS '平台编号唯一id';
COMMENT ON COLUMN sys_social.user_name IS '登录账号';
COMMENT ON COLUMN sys_social.nick_name IS '用户昵称';
COMMENT ON COLUMN sys_social.email IS '用户邮箱';
COMMENT ON COLUMN sys_social.avatar IS '头像地址';
COMMENT ON COLUMN sys_social.access_token IS '用户的授权令牌';
COMMENT ON COLUMN sys_social.expire_in IS '用户的授权令牌的有效期，部分平台可能没有';
COMMENT ON COLUMN sys_social.refresh_token IS '刷新令牌，部分平台可能没有';
COMMENT ON COLUMN sys_social.access_code IS '平台的授权信息，部分平台可能没有';
COMMENT ON COLUMN sys_social.union_id IS '用户的 unionid';
COMMENT ON COLUMN sys_social.scope IS '授予的权限，部分平台可能没有';
COMMENT ON COLUMN sys_social.token_type IS '个别平台的授权信息，部分平台可能没有';
COMMENT ON COLUMN sys_social.id_token IS 'id token，部分平台可能没有';
COMMENT ON COLUMN sys_social.mac_algorithm IS '小米平台用户的附带属性，部分平台可能没有';
COMMENT ON COLUMN sys_social.mac_key IS '小米平台用户的附带属性，部分平台可能没有';
COMMENT ON COLUMN sys_social.code IS '用户的授权code，部分平台可能没有';
COMMENT ON COLUMN sys_social.oauth_token IS 'Twitter平台用户的附带属性，部分平台可能没有';
COMMENT ON COLUMN sys_social.oauth_token_secret IS 'Twitter平台用户的附带属性，部分平台可能没有';
COMMENT ON COLUMN sys_social.create_dept IS '创建部门';
COMMENT ON COLUMN sys_social.create_by IS '创建者';
COMMENT ON COLUMN sys_social.create_time IS '创建时间';
COMMENT ON COLUMN sys_social.update_by IS '更新者';
COMMENT ON COLUMN sys_social.update_time IS '更新时间';
COMMENT ON COLUMN sys_social.del_flag IS '删除标志（0代表存在 1代表删除）';
COMMENT ON TABLE sys_social IS '社会化关系表';
COMMENT ON COLUMN sys_dept.dept_id IS '部门id';
COMMENT ON COLUMN sys_dept.parent_id IS '父部门id';
COMMENT ON COLUMN sys_dept.ancestors IS '祖级列表';
COMMENT ON COLUMN sys_dept.dept_name IS '部门名称';
COMMENT ON COLUMN sys_dept.dept_category IS '部门类别编码';
COMMENT ON COLUMN sys_dept.order_num IS '显示顺序';
COMMENT ON COLUMN sys_dept.leader IS '负责人';
COMMENT ON COLUMN sys_dept.phone IS '联系电话';
COMMENT ON COLUMN sys_dept.email IS '邮箱';
COMMENT ON COLUMN sys_dept.status IS '部门状态（0正常 1停用）';
COMMENT ON COLUMN sys_dept.del_flag IS '删除标志（0代表存在 1代表删除）';
COMMENT ON COLUMN sys_dept.create_dept IS '创建部门';
COMMENT ON COLUMN sys_dept.create_by IS '创建者';
COMMENT ON COLUMN sys_dept.create_time IS '创建时间';
COMMENT ON COLUMN sys_dept.update_by IS '更新者';
COMMENT ON COLUMN sys_dept.update_time IS '更新时间';
COMMENT ON TABLE sys_dept IS '部门表';
COMMENT ON COLUMN sys_user.user_id IS '用户ID';
COMMENT ON COLUMN sys_user.dept_id IS '部门ID';
COMMENT ON COLUMN sys_user.user_name IS '用户账号';
COMMENT ON COLUMN sys_user.nick_name IS '用户昵称';
COMMENT ON COLUMN sys_user.user_type IS '用户类型（sys_user系统用户）';
COMMENT ON COLUMN sys_user.email IS '用户邮箱';
COMMENT ON COLUMN sys_user.phone_number IS '手机号码';
COMMENT ON COLUMN sys_user.gender IS '用户性别（0男 1女 2未知）';
COMMENT ON COLUMN sys_user.avatar IS '头像地址';
COMMENT ON COLUMN sys_user.password IS '密码';
COMMENT ON COLUMN sys_user.status IS '账号状态（0正常 1停用）';
COMMENT ON COLUMN sys_user.del_flag IS '删除标志（0代表存在 1代表删除）';
COMMENT ON COLUMN sys_user.login_ip IS '最后登录IP';
COMMENT ON COLUMN sys_user.login_date IS '最后登录时间';
COMMENT ON COLUMN sys_user.create_dept IS '创建部门';
COMMENT ON COLUMN sys_user.create_by IS '创建者';
COMMENT ON COLUMN sys_user.create_time IS '创建时间';
COMMENT ON COLUMN sys_user.update_by IS '更新者';
COMMENT ON COLUMN sys_user.update_time IS '更新时间';
COMMENT ON COLUMN sys_user.remark IS '备注';
COMMENT ON TABLE sys_user IS '用户信息表';
COMMENT ON COLUMN sys_post.post_id IS '岗位ID';
COMMENT ON COLUMN sys_post.dept_id IS '部门id';
COMMENT ON COLUMN sys_post.post_code IS '岗位编码';
COMMENT ON COLUMN sys_post.post_category IS '岗位类别编码';
COMMENT ON COLUMN sys_post.post_name IS '岗位名称';
COMMENT ON COLUMN sys_post.post_sort IS '显示顺序';
COMMENT ON COLUMN sys_post.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_post.del_flag IS '删除标志（0代表存在 1代表删除）';
COMMENT ON COLUMN sys_post.create_dept IS '创建部门';
COMMENT ON COLUMN sys_post.create_by IS '创建者';
COMMENT ON COLUMN sys_post.create_time IS '创建时间';
COMMENT ON COLUMN sys_post.update_by IS '更新者';
COMMENT ON COLUMN sys_post.update_time IS '更新时间';
COMMENT ON COLUMN sys_post.remark IS '备注';
COMMENT ON TABLE sys_post IS '岗位信息表';
COMMENT ON COLUMN sys_role.role_id IS '角色ID';
COMMENT ON COLUMN sys_role.role_name IS '角色名称';
COMMENT ON COLUMN sys_role.role_key IS '角色权限字符串';
COMMENT ON COLUMN sys_role.role_sort IS '显示顺序';
COMMENT ON COLUMN sys_role.data_scope IS '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限 5：仅本人数据权限 6：部门及以下或本人数据权限）';
COMMENT ON COLUMN sys_role.menu_check_strictly IS '菜单树选择项是否关联显示';
COMMENT ON COLUMN sys_role.dept_check_strictly IS '部门树选择项是否关联显示';
COMMENT ON COLUMN sys_role.status IS '角色状态（0正常 1停用）';
COMMENT ON COLUMN sys_role.del_flag IS '删除标志（0代表存在 1代表删除）';
COMMENT ON COLUMN sys_role.create_dept IS '创建部门';
COMMENT ON COLUMN sys_role.create_by IS '创建者';
COMMENT ON COLUMN sys_role.create_time IS '创建时间';
COMMENT ON COLUMN sys_role.update_by IS '更新者';
COMMENT ON COLUMN sys_role.update_time IS '更新时间';
COMMENT ON COLUMN sys_role.remark IS '备注';
COMMENT ON TABLE sys_role IS '角色信息表';
COMMENT ON COLUMN sys_menu.menu_id IS '菜单ID';
COMMENT ON COLUMN sys_menu.menu_name IS '菜单名称';
COMMENT ON COLUMN sys_menu.parent_id IS '父菜单ID';
COMMENT ON COLUMN sys_menu.order_num IS '显示顺序';
COMMENT ON COLUMN sys_menu.path IS '路由地址';
COMMENT ON COLUMN sys_menu.component IS '组件路径';
COMMENT ON COLUMN sys_menu.query_param IS '路由参数';
COMMENT ON COLUMN sys_menu.is_frame IS '是否为外链（Y是 N否）';
COMMENT ON COLUMN sys_menu.is_cache IS '是否缓存（Y缓存 N不缓存）';
COMMENT ON COLUMN sys_menu.menu_type IS '菜单类型（M目录 C菜单 F按钮）';
COMMENT ON COLUMN sys_menu.visible IS '显示状态（0显示 1隐藏）';
COMMENT ON COLUMN sys_menu.status IS '菜单状态（0正常 1停用）';
COMMENT ON COLUMN sys_menu.perms IS '权限标识';
COMMENT ON COLUMN sys_menu.icon IS '菜单图标';
COMMENT ON COLUMN sys_menu.active_menu IS '激活菜单路径';
COMMENT ON COLUMN sys_menu.ext IS '扩展字段';
COMMENT ON COLUMN sys_menu.create_dept IS '创建部门';
COMMENT ON COLUMN sys_menu.create_by IS '创建者';
COMMENT ON COLUMN sys_menu.create_time IS '创建时间';
COMMENT ON COLUMN sys_menu.update_by IS '更新者';
COMMENT ON COLUMN sys_menu.update_time IS '更新时间';
COMMENT ON COLUMN sys_menu.remark IS '备注';
COMMENT ON TABLE sys_menu IS '菜单权限表';
COMMENT ON COLUMN sys_user_role.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_role.role_id IS '角色ID';
COMMENT ON TABLE sys_user_role IS '用户和角色关联表';
COMMENT ON COLUMN sys_role_menu.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_menu.menu_id IS '菜单ID';
COMMENT ON TABLE sys_role_menu IS '角色和菜单关联表';
COMMENT ON COLUMN sys_role_dept.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_dept.dept_id IS '部门ID';
COMMENT ON TABLE sys_role_dept IS '角色和部门关联表';
COMMENT ON COLUMN sys_user_post.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_post.post_id IS '岗位ID';
COMMENT ON TABLE sys_user_post IS '用户与岗位关联表';
COMMENT ON COLUMN sys_oper_log.oper_id IS '日志主键';
COMMENT ON COLUMN sys_oper_log.title IS '模块标题';
COMMENT ON COLUMN sys_oper_log.business_type IS '业务类型（0其它 1新增 2修改 3删除）';
COMMENT ON COLUMN sys_oper_log.method IS '方法名称';
COMMENT ON COLUMN sys_oper_log.request_method IS '请求方式';
COMMENT ON COLUMN sys_oper_log.operator_type IS '操作类别（0其它 1后台用户 2手机端用户）';
COMMENT ON COLUMN sys_oper_log.oper_name IS '操作人员';
COMMENT ON COLUMN sys_oper_log.user_id IS '操作用户ID';
COMMENT ON COLUMN sys_oper_log.dept_id IS '操作部门ID';
COMMENT ON COLUMN sys_oper_log.dept_name IS '部门名称';
COMMENT ON COLUMN sys_oper_log.client_key IS '客户端';
COMMENT ON COLUMN sys_oper_log.device_type IS '设备类型';
COMMENT ON COLUMN sys_oper_log.browser IS '浏览器类型';
COMMENT ON COLUMN sys_oper_log.os IS '操作系统';
COMMENT ON COLUMN sys_oper_log.oper_url IS '请求URL';
COMMENT ON COLUMN sys_oper_log.oper_ip IS '主机地址';
COMMENT ON COLUMN sys_oper_log.oper_location IS '操作地点';
COMMENT ON COLUMN sys_oper_log.oper_param IS '请求参数';
COMMENT ON COLUMN sys_oper_log.json_result IS '返回参数';
COMMENT ON COLUMN sys_oper_log.status IS '操作状态（0正常 1异常）';
COMMENT ON COLUMN sys_oper_log.error_msg IS '错误消息';
COMMENT ON COLUMN sys_oper_log.oper_time IS '操作时间';
COMMENT ON COLUMN sys_oper_log.cost_time IS '消耗时间';
COMMENT ON TABLE sys_oper_log IS '操作日志记录';
COMMENT ON COLUMN sys_dict_type.dict_id IS '字典主键';
COMMENT ON COLUMN sys_dict_type.dict_name IS '字典名称';
COMMENT ON COLUMN sys_dict_type.dict_type IS '字典类型';
COMMENT ON COLUMN sys_dict_type.create_dept IS '创建部门';
COMMENT ON COLUMN sys_dict_type.create_by IS '创建者';
COMMENT ON COLUMN sys_dict_type.create_time IS '创建时间';
COMMENT ON COLUMN sys_dict_type.update_by IS '更新者';
COMMENT ON COLUMN sys_dict_type.update_time IS '更新时间';
COMMENT ON COLUMN sys_dict_type.remark IS '备注';
COMMENT ON TABLE sys_dict_type IS '字典类型表';
COMMENT ON COLUMN sys_dict_data.dict_code IS '字典编码';
COMMENT ON COLUMN sys_dict_data.dict_sort IS '字典排序';
COMMENT ON COLUMN sys_dict_data.dict_label IS '字典标签';
COMMENT ON COLUMN sys_dict_data.dict_value IS '字典键值';
COMMENT ON COLUMN sys_dict_data.dict_type IS '字典类型';
COMMENT ON COLUMN sys_dict_data.css_class IS '样式属性（其他样式扩展）';
COMMENT ON COLUMN sys_dict_data.list_class IS '表格回显样式';
COMMENT ON COLUMN sys_dict_data.is_default IS '是否默认（Y是 N否）';
COMMENT ON COLUMN sys_dict_data.create_dept IS '创建部门';
COMMENT ON COLUMN sys_dict_data.create_by IS '创建者';
COMMENT ON COLUMN sys_dict_data.create_time IS '创建时间';
COMMENT ON COLUMN sys_dict_data.update_by IS '更新者';
COMMENT ON COLUMN sys_dict_data.update_time IS '更新时间';
COMMENT ON COLUMN sys_dict_data.remark IS '备注';
COMMENT ON TABLE sys_dict_data IS '字典数据表';
COMMENT ON COLUMN sys_config.config_id IS '参数主键';
COMMENT ON COLUMN sys_config.config_name IS '参数名称';
COMMENT ON COLUMN sys_config.config_key IS '参数键名';
COMMENT ON COLUMN sys_config.config_value IS '参数键值';
COMMENT ON COLUMN sys_config.config_type IS '系统内置（Y是 N否）';
COMMENT ON COLUMN sys_config.create_dept IS '创建部门';
COMMENT ON COLUMN sys_config.create_by IS '创建者';
COMMENT ON COLUMN sys_config.create_time IS '创建时间';
COMMENT ON COLUMN sys_config.update_by IS '更新者';
COMMENT ON COLUMN sys_config.update_time IS '更新时间';
COMMENT ON COLUMN sys_config.remark IS '备注';
COMMENT ON TABLE sys_config IS '参数配置表';
COMMENT ON COLUMN sys_login_info.info_id IS '访问ID';
COMMENT ON COLUMN sys_login_info.user_name IS '用户账号';
COMMENT ON COLUMN sys_login_info.client_key IS '客户端';
COMMENT ON COLUMN sys_login_info.device_type IS '设备类型';
COMMENT ON COLUMN sys_login_info.ipaddr IS '登录IP地址';
COMMENT ON COLUMN sys_login_info.login_location IS '登录地点';
COMMENT ON COLUMN sys_login_info.browser IS '浏览器类型';
COMMENT ON COLUMN sys_login_info.os IS '操作系统';
COMMENT ON COLUMN sys_login_info.status IS '登录状态（0正常 1异常）';
COMMENT ON COLUMN sys_login_info.msg IS '提示消息';
COMMENT ON COLUMN sys_login_info.login_time IS '访问时间';
COMMENT ON TABLE sys_login_info IS '系统访问记录';
COMMENT ON COLUMN sys_notice.notice_id IS '公告ID';
COMMENT ON COLUMN sys_notice.notice_title IS '公告标题';
COMMENT ON COLUMN sys_notice.notice_type IS '公告类型（1通知 2公告）';
COMMENT ON COLUMN sys_notice.notice_content IS '公告内容';
COMMENT ON COLUMN sys_notice.status IS '公告状态（0正常 1关闭）';
COMMENT ON COLUMN sys_notice.create_dept IS '创建部门';
COMMENT ON COLUMN sys_notice.create_by IS '创建者';
COMMENT ON COLUMN sys_notice.create_time IS '创建时间';
COMMENT ON COLUMN sys_notice.update_by IS '更新者';
COMMENT ON COLUMN sys_notice.update_time IS '更新时间';
COMMENT ON COLUMN sys_notice.remark IS '备注';
COMMENT ON TABLE sys_notice IS '通知公告表';
COMMENT ON COLUMN sys_message.message_id IS '消息ID';
COMMENT ON COLUMN sys_message.category IS '消息分组(system/notice/workflow)';
COMMENT ON COLUMN sys_message.type IS '消息类型';
COMMENT ON COLUMN sys_message.source IS '消息来源';
COMMENT ON COLUMN sys_message.title IS '标题';
COMMENT ON COLUMN sys_message.message IS '摘要消息';
COMMENT ON COLUMN sys_message.content IS '详细内容';
COMMENT ON COLUMN sys_message.data_json IS '扩展数据JSON';
COMMENT ON COLUMN sys_message.path IS '前端跳转路径';
COMMENT ON COLUMN sys_message.send_user_ids IS '目标用户ID串，0表示全局';
COMMENT ON COLUMN sys_message.create_dept IS '创建部门';
COMMENT ON COLUMN sys_message.create_by IS '创建者';
COMMENT ON COLUMN sys_message.create_time IS '创建时间';
COMMENT ON COLUMN sys_message.update_by IS '更新者';
COMMENT ON COLUMN sys_message.update_time IS '更新时间';
COMMENT ON TABLE sys_message IS '消息记录表';
COMMENT ON COLUMN gen_table.table_id IS '编号';
COMMENT ON COLUMN gen_table.data_name IS '数据源名称';
COMMENT ON COLUMN gen_table.table_name IS '表名称';
COMMENT ON COLUMN gen_table.table_comment IS '表描述';
COMMENT ON COLUMN gen_table.class_name IS '实体类名称';
COMMENT ON COLUMN gen_table.tpl_category IS '使用的模板（crud单表操作 tree树表操作）';
COMMENT ON COLUMN gen_table.frontend_type IS '前端模板类型，对应 vm 下的模板目录';
COMMENT ON COLUMN gen_table.package_name IS '生成包路径';
COMMENT ON COLUMN gen_table.module_name IS '生成模块名';
COMMENT ON COLUMN gen_table.business_name IS '生成业务名';
COMMENT ON COLUMN gen_table.function_name IS '生成功能名';
COMMENT ON COLUMN gen_table.function_author IS '生成功能作者';
COMMENT ON COLUMN gen_table.gen_type IS '生成代码方式（0zip压缩包 1自定义路径）';
COMMENT ON COLUMN gen_table.gen_path IS '生成路径（不填默认项目路径）';
COMMENT ON COLUMN gen_table.options IS '其它生成选项';
COMMENT ON COLUMN gen_table.create_dept IS '创建部门';
COMMENT ON COLUMN gen_table.create_by IS '创建者';
COMMENT ON COLUMN gen_table.create_time IS '创建时间';
COMMENT ON COLUMN gen_table.update_by IS '更新者';
COMMENT ON COLUMN gen_table.update_time IS '更新时间';
COMMENT ON COLUMN gen_table.remark IS '备注';
COMMENT ON TABLE gen_table IS '代码生成业务表';
COMMENT ON COLUMN gen_table_column.column_id IS '编号';
COMMENT ON COLUMN gen_table_column.table_id IS '归属表编号';
COMMENT ON COLUMN gen_table_column.column_name IS '列名称';
COMMENT ON COLUMN gen_table_column.column_comment IS '列描述';
COMMENT ON COLUMN gen_table_column.column_type IS '列类型';
COMMENT ON COLUMN gen_table_column.java_type IS 'JAVA类型';
COMMENT ON COLUMN gen_table_column.java_field IS 'JAVA字段名';
COMMENT ON COLUMN gen_table_column.is_pk IS '是否主键（1是）';
COMMENT ON COLUMN gen_table_column.is_increment IS '是否自增（1是）';
COMMENT ON COLUMN gen_table_column.is_required IS '是否必填（1是）';
COMMENT ON COLUMN gen_table_column.is_insert IS '是否为插入字段（1是）';
COMMENT ON COLUMN gen_table_column.is_edit IS '是否编辑字段（1是）';
COMMENT ON COLUMN gen_table_column.is_list IS '是否列表字段（1是）';
COMMENT ON COLUMN gen_table_column.is_query IS '是否查询字段（1是）';
COMMENT ON COLUMN gen_table_column.query_type IS '查询方式（等于、不等于、大于、小于、范围）';
COMMENT ON COLUMN gen_table_column.html_type IS '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）';
COMMENT ON COLUMN gen_table_column.dict_type IS '字典类型';
COMMENT ON COLUMN gen_table_column.sort IS '排序';
COMMENT ON COLUMN gen_table_column.create_dept IS '创建部门';
COMMENT ON COLUMN gen_table_column.create_by IS '创建者';
COMMENT ON COLUMN gen_table_column.create_time IS '创建时间';
COMMENT ON COLUMN gen_table_column.update_by IS '更新者';
COMMENT ON COLUMN gen_table_column.update_time IS '更新时间';
COMMENT ON TABLE gen_table_column IS '代码生成业务表字段';
COMMENT ON COLUMN sys_oss.oss_id IS '对象存储主键';
COMMENT ON COLUMN sys_oss.file_name IS '文件名';
COMMENT ON COLUMN sys_oss.original_name IS '原名';
COMMENT ON COLUMN sys_oss.file_suffix IS '文件后缀名';
COMMENT ON COLUMN sys_oss.url IS 'URL地址';
COMMENT ON COLUMN sys_oss.ext1 IS '扩展字段';
COMMENT ON COLUMN sys_oss.create_dept IS '创建部门';
COMMENT ON COLUMN sys_oss.create_time IS '创建时间';
COMMENT ON COLUMN sys_oss.create_by IS '上传人';
COMMENT ON COLUMN sys_oss.update_time IS '更新时间';
COMMENT ON COLUMN sys_oss.update_by IS '更新人';
COMMENT ON COLUMN sys_oss.service IS '服务商';
COMMENT ON TABLE sys_oss IS 'OSS对象存储表';
COMMENT ON COLUMN sys_oss_config.oss_config_id IS '主键';
COMMENT ON COLUMN sys_oss_config.config_key IS '配置key';
COMMENT ON COLUMN sys_oss_config.access_key IS 'accessKey';
COMMENT ON COLUMN sys_oss_config.secret_key IS '秘钥';
COMMENT ON COLUMN sys_oss_config.bucket_name IS '桶名称';
COMMENT ON COLUMN sys_oss_config.prefix IS '前缀';
COMMENT ON COLUMN sys_oss_config.endpoint IS '访问站点';
COMMENT ON COLUMN sys_oss_config.domain_url IS '自定义域名';
COMMENT ON COLUMN sys_oss_config.is_https IS '是否https（Y=是,N=否）';
COMMENT ON COLUMN sys_oss_config.region IS '域';
COMMENT ON COLUMN sys_oss_config.access_policy IS '桶权限类型(0=private 1=public 2=custom)';
COMMENT ON COLUMN sys_oss_config.status IS '是否默认（Y=是,N=否）';
COMMENT ON COLUMN sys_oss_config.ext1 IS '扩展字段';
COMMENT ON COLUMN sys_oss_config.create_dept IS '创建部门';
COMMENT ON COLUMN sys_oss_config.create_by IS '创建者';
COMMENT ON COLUMN sys_oss_config.create_time IS '创建时间';
COMMENT ON COLUMN sys_oss_config.update_by IS '更新者';
COMMENT ON COLUMN sys_oss_config.update_time IS '更新时间';
COMMENT ON COLUMN sys_oss_config.remark IS '备注';
COMMENT ON TABLE sys_oss_config IS '对象存储配置表';
COMMENT ON COLUMN sys_client.id IS 'id';
COMMENT ON COLUMN sys_client.client_id IS '客户端id';
COMMENT ON COLUMN sys_client.client_key IS '客户端key';
COMMENT ON COLUMN sys_client.client_secret IS '客户端秘钥';
COMMENT ON COLUMN sys_client.grant_type IS '授权类型';
COMMENT ON COLUMN sys_client.device_type IS '设备类型';
COMMENT ON COLUMN sys_client.access_path IS '允许访问路径';
COMMENT ON COLUMN sys_client.ip_whitelist IS 'IP白名单';
COMMENT ON COLUMN sys_client.active_timeout IS 'token活跃超时时间';
COMMENT ON COLUMN sys_client.timeout IS 'token固定超时';
COMMENT ON COLUMN sys_client.status IS '状态（0正常 1停用）';
COMMENT ON COLUMN sys_client.del_flag IS '删除标志（0代表存在 1代表删除）';
COMMENT ON COLUMN sys_client.create_dept IS '创建部门';
COMMENT ON COLUMN sys_client.create_by IS '创建者';
COMMENT ON COLUMN sys_client.create_time IS '创建时间';
COMMENT ON COLUMN sys_client.update_by IS '更新者';
COMMENT ON COLUMN sys_client.update_time IS '更新时间';
COMMENT ON TABLE sys_client IS '系统授权表';
COMMENT ON COLUMN test_demo.id IS '主键';
COMMENT ON COLUMN test_demo.dept_id IS '部门id';
COMMENT ON COLUMN test_demo.user_id IS '用户id';
COMMENT ON COLUMN test_demo.order_num IS '排序号';
COMMENT ON COLUMN test_demo.test_key IS 'key键';
COMMENT ON COLUMN test_demo.value IS '值';
COMMENT ON COLUMN test_demo.version IS '版本';
COMMENT ON COLUMN test_demo.create_dept IS '创建部门';
COMMENT ON COLUMN test_demo.create_time IS '创建时间';
COMMENT ON COLUMN test_demo.create_by IS '创建人';
COMMENT ON COLUMN test_demo.update_time IS '更新时间';
COMMENT ON COLUMN test_demo.update_by IS '更新人';
COMMENT ON COLUMN test_demo.del_flag IS '删除标志';
COMMENT ON TABLE test_demo IS '测试单表';
COMMENT ON COLUMN test_tree.id IS '主键';
COMMENT ON COLUMN test_tree.parent_id IS '父id';
COMMENT ON COLUMN test_tree.dept_id IS '部门id';
COMMENT ON COLUMN test_tree.user_id IS '用户id';
COMMENT ON COLUMN test_tree.tree_name IS '值';
COMMENT ON COLUMN test_tree.version IS '版本';
COMMENT ON COLUMN test_tree.create_dept IS '创建部门';
COMMENT ON COLUMN test_tree.create_time IS '创建时间';
COMMENT ON COLUMN test_tree.create_by IS '创建人';
COMMENT ON COLUMN test_tree.update_time IS '更新时间';
COMMENT ON COLUMN test_tree.update_by IS '更新人';
COMMENT ON COLUMN test_tree.del_flag IS '删除标志';
COMMENT ON TABLE test_tree IS '测试树表';

CREATE INDEX IF NOT EXISTS idx_sys_dept_parent_id ON sys_dept (parent_id);
CREATE INDEX IF NOT EXISTS idx_sys_user_dept_id ON sys_user (dept_id);
CREATE INDEX IF NOT EXISTS idx_sys_user_create_by ON sys_user (create_by);
CREATE INDEX IF NOT EXISTS idx_sys_user_user_name ON sys_user (user_name);
CREATE INDEX IF NOT EXISTS idx_sys_user_phone ON sys_user (phone_number);
CREATE INDEX IF NOT EXISTS idx_sys_post_dept_id ON sys_post (dept_id);
CREATE INDEX IF NOT EXISTS idx_sys_role_create_dept ON sys_role (create_dept);
CREATE INDEX IF NOT EXISTS idx_sys_role_create_by ON sys_role (create_by);
CREATE INDEX IF NOT EXISTS idx_sys_user_role_rid ON sys_user_role (role_id);
CREATE INDEX IF NOT EXISTS idx_sys_oper_log_bt ON sys_oper_log (business_type);
CREATE INDEX IF NOT EXISTS idx_sys_oper_log_uid ON sys_oper_log (user_id);
CREATE INDEX IF NOT EXISTS idx_sys_oper_log_s ON sys_oper_log (status);
CREATE INDEX IF NOT EXISTS idx_sys_oper_log_ot ON sys_oper_log (oper_time);
CREATE INDEX IF NOT EXISTS idx_sys_dict_data_type ON sys_dict_data (dict_type);
CREATE INDEX IF NOT EXISTS idx_sys_login_info_s ON sys_login_info (status);
CREATE INDEX IF NOT EXISTS idx_sys_login_info_lt ON sys_login_info (login_time);
CREATE INDEX IF NOT EXISTS idx_sys_message_category_time ON sys_message (category, create_time);
