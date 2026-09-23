-- V4：系统技术资产状态字典（asset_status）
-- 状态编码与 design.md「数据模型」一致：1-在建 2-已上线 3-已下线 4-维护中
INSERT INTO sys_dict_type (dict_id, dict_name, dict_type, create_dept, create_by, create_time, update_by, update_time, remark)
VALUES (1761500000000000013, '资产状态', 'asset_status', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, '系统技术资产状态');

INSERT INTO sys_dict_data (dict_code, dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, create_dept, create_by, create_time, update_by, update_time, remark) VALUES
(1761600000000000039, 1, '在建',   '1', 'asset_status', '', 'primary', 'Y', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, '在建'),
(1761600000000000040, 2, '已上线', '2', 'asset_status', '', 'success', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, '已上线'),
(1761600000000000041, 3, '已下线', '3', 'asset_status', '', 'info',    'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, '已下线'),
(1761600000000000042, 4, '维护中', '4', 'asset_status', '', 'warning', 'N', 1761000000000000103, 1761100000000000001, CURRENT_TIMESTAMP, 1761100000000000001, CURRENT_TIMESTAMP, '维护中');