package com.openspec.project.system.controller.system;

import cn.dev33.satoken.annotation.SaCheckPermission;
import cn.dev33.satoken.annotation.SaCheckRole;
import lombok.RequiredArgsConstructor;
import com.openspec.project.common.core.constant.SystemConstants;
import com.openspec.project.common.core.domain.R;
import com.openspec.project.common.log.annotation.Log;
import com.openspec.project.common.log.enums.BusinessType;
import com.openspec.project.common.web.core.BaseController;
import com.openspec.project.system.domain.bo.SysAssetDeployBo;
import com.openspec.project.system.domain.vo.SysAssetDeployVo;
import com.openspec.project.system.service.ISysAssetDeployService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Arrays;
import java.util.List;

/**
 * 系统部署节点信息操作处理
 *
 * @author my-openspec-project
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/system/asset/deploy")
public class SysAssetDeployController extends BaseController {

    private final ISysAssetDeployService deployService;

    /**
     * 查询系统部署节点列表（不分页）。
     *
     * @param bo 查询条件（assetId 必传，sysEnv 可选）
     * @return 部署节点列表
     */
    @SaCheckPermission("system:asset:query")
    @GetMapping("/list")
    public R<List<SysAssetDeployVo>> list(SysAssetDeployBo bo) {
        return R.ok(deployService.selectDeployList(bo));
    }

    /**
     * 新增系统部署节点。
     *
     * @param bo 部署节点参数
     * @return 操作结果
     */
    @SaCheckPermission("system:asset:add")
    @Log(title = "系统部署节点管理", businessType = BusinessType.INSERT)
    @PostMapping
    public R<Void> add(@Validated @RequestBody SysAssetDeployBo bo) {
        return toAjax(deployService.insertDeploy(bo));
    }

    /**
     * 修改系统部署节点。
     *
     * @param bo 部署节点参数
     * @return 操作结果
     */
    @SaCheckPermission("system:asset:edit")
    @Log(title = "系统部署节点管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public R<Void> edit(@Validated @RequestBody SysAssetDeployBo bo) {
        return toAjax(deployService.updateDeploy(bo));
    }

    /**
     * 删除系统部署节点（逻辑删除，仅管理员）。
     *
     * @param ids 主键ID串
     * @return 操作结果
     */
    @SaCheckRole(SystemConstants.SUPER_ADMIN_ROLE_KEY)
    @SaCheckPermission("system:asset:remove")
    @Log(title = "系统部署节点管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@PathVariable String[] ids) {
        return toAjax(deployService.deleteDeployByIds(Arrays.asList(ids)));
    }

    /**
     * 按系统导出部署节点 CSV。
     *
     * @param bo       查询条件（assetId 必传，sysEnv 可选）
     * @param response HTTP 响应
     */
    @SaCheckPermission("system:asset:export")
    @Log(title = "系统部署节点管理", businessType = BusinessType.EXPORT)
    @GetMapping("/export")
    public void export(SysAssetDeployBo bo, HttpServletResponse response) {
        deployService.exportCsv(bo, response);
    }

    /**
     * 导入系统部署节点（Excel）。
     *
     * @param file 导入文件
     * @return 导入分析明细消息
     */
    @SaCheckPermission("system:asset:import")
    @Log(title = "系统部署节点管理", businessType = BusinessType.IMPORT)
    @PostMapping(value = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public R<String> importData(@RequestPart("file") MultipartFile file,
                                @RequestParam("assetId") String assetId) throws Exception {
        return R.ok("导入成功", deployService.importExcel(file, assetId));
    }

}
