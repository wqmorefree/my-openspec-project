package com.openspec.project.system.service;

import com.openspec.project.common.core.domain.PageResult;
import com.openspec.project.common.mybatis.core.page.PageQuery;
import com.openspec.project.system.domain.bo.SysAssetBo;
import com.openspec.project.system.domain.vo.SysAssetVo;
import jakarta.servlet.http.HttpServletResponse;

import java.util.Collection;
import java.util.List;

/**
 * 系统技术资产 服务层
 *
 * @author my-openspec-project
 */
public interface ISysAssetService {

    /**
     * 分页查询系统技术资产列表
     *
     * @param bo       查询条件
     * @param pageQuery 分页参数
     * @return 系统技术资产分页结果
     */
    PageResult<SysAssetVo> selectPageAssetList(SysAssetBo bo, PageQuery pageQuery);

    /**
     * 查询系统技术资产集合
     *
     * @param bo 查询条件
     * @return 系统技术资产集合
     */
    List<SysAssetVo> selectAssetList(SysAssetBo bo);

    /**
     * 通过ID查询单个系统技术资产
     *
     * @param id 主键ID
     * @return 系统技术资产
     */
    SysAssetVo selectAssetById(String id);

    /**
     * 新增系统技术资产
     *
     * @param bo 系统技术资产
     * @return 影响行数
     */
    int insertAsset(SysAssetBo bo);

    /**
     * 修改系统技术资产
     *
     * @param bo 系统技术资产
     * @return 影响行数
     */
    int updateAsset(SysAssetBo bo);

    /**
     * 批量删除系统技术资产
     *
     * @param ids 需要删除的主键ID集合
     * @return 影响行数
     */
    int deleteAssetByIds(Collection<String> ids);

    /**
     * 按当前筛选条件导出 CSV。
     *
     * @param bo       查询条件
     * @param response HTTP 响应
     */
    void exportCsv(SysAssetBo bo, HttpServletResponse response);

}