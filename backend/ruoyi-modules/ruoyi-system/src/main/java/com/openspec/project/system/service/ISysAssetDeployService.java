package com.openspec.project.system.service;

import com.openspec.project.system.domain.bo.SysAssetDeployBo;
import com.openspec.project.system.domain.vo.SysAssetDeployVo;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.Collection;
import java.util.List;

/**
 * 系统部署节点 服务层
 *
 * @author my-openspec-project
 */
public interface ISysAssetDeployService {

    /**
     * 查询系统部署节点列表。
     *
     * @param bo 查询条件（assetId 必传，sysEnv 可选）
     * @return 部署节点列表
     */
    List<SysAssetDeployVo> selectDeployList(SysAssetDeployBo bo);

    /**
     * 新增系统部署节点。
     *
     * @param bo 部署节点
     * @return 影响行数
     */
    int insertDeploy(SysAssetDeployBo bo);

    /**
     * 导入部署节点（存在则更新，不存在则新增）。
     *
     * @param bo 部署节点
     * @return 影响行数
     */
    int upsertDeploy(SysAssetDeployBo bo);

    /**
     * 修改系统部署节点。
     *
     * @param bo 部署节点
     * @return 影响行数
     */
    int updateDeploy(SysAssetDeployBo bo);

    /**
     * 批量逻辑删除部署节点。
     *
     * @param ids 主键ID集合
     * @return 影响行数
     */
    int deleteDeployByIds(Collection<String> ids);

    /**
     * 按所属系统批量逻辑删除全部部署节点（系统删除级联用）。
     *
     * @param assetIds 系统ID集合
     * @return 影响行数
     */
    int deleteByAssetIds(Collection<String> assetIds);

    /**
     * Excel 批量导入部署节点。
     *
     * @param file    导入文件
     * @param assetId 所属系统ID
     * @return 导入分析明细
     */
    String importExcel(MultipartFile file, String assetId) throws Exception;

    /**
     * 按系统导出部署节点 CSV（32 字段全量）。
     *
     * @param bo       查询条件
     * @param response HTTP 响应
     */
    void exportCsv(SysAssetDeployBo bo, HttpServletResponse response);

}
