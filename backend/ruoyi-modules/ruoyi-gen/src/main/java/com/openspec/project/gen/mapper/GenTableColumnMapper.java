package com.openspec.project.gen.mapper;

import com.baomidou.mybatisplus.annotation.InterceptorIgnore;
import com.openspec.project.common.mybatis.core.mapper.BaseMapperPlus;
import com.openspec.project.gen.domain.GenTableColumn;

/**
 * 业务字段 数据层
 *
 * @author Lion Li
 */
@InterceptorIgnore(dataPermission = "true", tenantLine = "true")
public interface GenTableColumnMapper extends BaseMapperPlus<GenTableColumn, GenTableColumn> {

}
