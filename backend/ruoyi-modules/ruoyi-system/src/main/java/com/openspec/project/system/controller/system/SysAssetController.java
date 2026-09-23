package com.openspec.project.system.controller.system;

import cn.dev33.satoken.annotation.SaCheckPermission;
import cn.dev33.satoken.annotation.SaCheckRole;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import com.openspec.project.common.core.constant.SystemConstants;
import com.openspec.project.common.core.domain.PageResult;
import com.openspec.project.common.core.domain.R;
import com.openspec.project.common.excel.core.ExcelResult;
import com.openspec.project.common.excel.utils.ExcelBuilder;
import com.openspec.project.common.log.annotation.Log;
import com.openspec.project.common.log.enums.BusinessType;
import com.openspec.project.common.mybatis.core.page.PageQuery;
import com.openspec.project.common.web.core.BaseController;
import com.openspec.project.system.domain.bo.SysAssetBo;
import com.openspec.project.system.domain.vo.SysAssetImportVo;
import com.openspec.project.system.domain.vo.SysAssetVo;
import com.openspec.project.system.listener.SysAssetImportListener;
import com.openspec.project.system.service.ISysAssetService;
import org.springframework.http.MediaType;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Arrays;
import java.util.List;

/**
 * 系统技术资产信息操作处理
 *
 * @author my-openspec-project
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/system/asset")
public class SysAssetController extends BaseController {

    private final ISysAssetService assetService;

    /**
     * 分页查询系统技术资产列表。
     *
     * @param asset     查询条件
     * @param pageQuery 分页参数
     * @return 系统技术资产分页结果
     */
    @SaCheckPermission("system:asset:list")
    @GetMapping("/list")
    public R<PageResult<SysAssetVo>> list(SysAssetBo asset, PageQuery pageQuery) {
        return R.ok(assetService.selectPageAssetList(asset, pageQuery));
    }

    /**
     * 获取系统技术资产详细信息。
     *
     * @param id 主键ID
     * @return 系统技术资产详情
     */
    @SaCheckPermission("system:asset:query")
    @GetMapping(value = "/{id}")
    public R<SysAssetVo> getInfo(@PathVariable String id) {
        return R.ok(assetService.selectAssetById(id));
    }

    /**
     * 新增系统技术资产。
     *
     * @param asset 系统技术资产参数
     * @return 操作结果
     */
    @SaCheckPermission("system:asset:add")
    @Log(title = "系统技术资产管理", businessType = BusinessType.INSERT)
    @PostMapping
    public R<Void> add(@Validated @RequestBody SysAssetBo asset) {
        return toAjax(assetService.insertAsset(asset));
    }

    /**
     * 修改系统技术资产。
     *
     * @param asset 系统技术资产参数
     * @return 操作结果
     */
    @SaCheckPermission("system:asset:edit")
    @Log(title = "系统技术资产管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public R<Void> edit(@Validated @RequestBody SysAssetBo asset) {
        return toAjax(assetService.updateAsset(asset));
    }

    /**
     * 按当前筛选条件导出 CSV。
     *
     * @param asset   查询条件
     * @param response HTTP 响应
     */
    @SaCheckPermission("system:asset:export")
    @Log(title = "系统技术资产管理", businessType = BusinessType.EXPORT)
    @GetMapping("/export")
    public void export(SysAssetBo asset, HttpServletResponse response) {
        assetService.exportCsv(asset, response);
    }

    /**
     * 导入系统技术资产（Excel）。
     *
     * @param file 导入文件
     * @return 导入分析明细消息
     */
    @SaCheckPermission("system:asset:import")
    @Log(title = "系统技术资产管理", businessType = BusinessType.IMPORT)
    @PostMapping(value = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public R<String> importData(@RequestPart("file") MultipartFile file) throws Exception {
        ExcelResult<SysAssetImportVo> result = ExcelBuilder.read(file.getInputStream(), SysAssetImportVo.class)
            .listener(new SysAssetImportListener())
            .doRead();
        return R.ok("导入成功", result.getAnalysis());
    }

    /**
     * 删除系统技术资产（逻辑删除，仅管理员）。
     *
     * @param ids 主键ID串
     * @return 操作结果
     */
    @SaCheckRole(SystemConstants.SUPER_ADMIN_ROLE_KEY)
    @SaCheckPermission("system:asset:remove")
    @Log(title = "系统技术资产管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public R<Void> remove(@PathVariable String[] ids) {
        return toAjax(assetService.deleteAssetByIds(Arrays.asList(ids)));
    }

}
