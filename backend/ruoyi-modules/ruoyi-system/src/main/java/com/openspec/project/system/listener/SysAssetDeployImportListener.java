package com.openspec.project.system.listener;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HtmlUtil;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.apache.fesod.sheet.context.AnalysisContext;
import org.apache.fesod.sheet.event.AnalysisEventListener;
import com.openspec.project.common.core.exception.ServiceException;
import com.openspec.project.common.core.utils.SpringUtils;
import com.openspec.project.common.core.utils.StreamUtils;
import com.openspec.project.common.core.utils.ValidatorUtils;
import com.openspec.project.common.excel.core.ExcelListener;
import com.openspec.project.common.excel.core.ExcelResult;
import com.openspec.project.system.domain.bo.SysAssetDeployBo;
import com.openspec.project.system.domain.vo.SysAssetDeployImportVo;
import com.openspec.project.system.service.ISysAssetDeployService;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 系统部署节点导入监听器。
 *
 * <p>逐行校验：必填与取值由 {@code SysAssetDeployBo} 校验注解兜底；部署应用名称存在时更新、
 * 不存在时新增（文件内重复和库内冲突均为更新语义），不整体回滚。
 * 所有节点强制归属指定系统（assetId）。</p>
 *
 * @author my-openspec-project
 */
@Slf4j
public class SysAssetDeployImportListener
    extends AnalysisEventListener<SysAssetDeployImportVo> implements ExcelListener<SysAssetDeployImportVo> {

    private static final String NL = "\n";

    private final ISysAssetDeployService deployService;

    /**
     * 所属系统ID
     */
    private final String assetId;

    /**
     * 文件内已处理的「部署应用」集合（用于区分新增/更新提示）
     */
    private final Set<String> importedKeys = new HashSet<>();

    private int successNum = 0;
    private int failureNum = 0;
    private final StringBuilder successMsg = new StringBuilder();
    private final StringBuilder failureMsg = new StringBuilder();

    /**
     * 构造系统部署节点导入监听器。
     *
     * @param assetId 所属系统ID
     */
    public SysAssetDeployImportListener(String assetId) {
        this.assetId = assetId;
        this.deployService = SpringUtils.getBean(ISysAssetDeployService.class);
    }

    /**
     * 逐行处理导入数据。
     *
     * @param importVo 导入数据
     * @param context  Excel 解析上下文
     */
    @Override
    public void invoke(SysAssetDeployImportVo importVo, AnalysisContext context) {
        String deployApp = StrUtil.trim(importVo.getDeployApp());
        try {
            if (StrUtil.isBlank(deployApp)) {
                throw new ServiceException("部署应用不能为空");
            }
            SysAssetDeployBo bo = BeanUtil.toBean(importVo, SysAssetDeployBo.class);
            bo.setAssetId(assetId);
            ValidatorUtils.validate(bo);
            // 存在则更新、不存在则新增
            deployService.upsertDeploy(bo);
            boolean isUpdate = importedKeys.contains(deployApp);
            importedKeys.add(deployApp);
            successNum++;
            String action = isUpdate ? "更新成功" : "导入成功";
            successMsg.append(NL).append(successNum).append("、部署应用 ").append(deployApp).append(" ").append(action);
        } catch (Exception e) {
            failureNum++;
            String message = e.getMessage();
            if (e instanceof ConstraintViolationException cvException) {
                message = StreamUtils.join(cvException.getConstraintViolations(), ConstraintViolation::getMessage, ", ");
            }
            String safeApp = StrUtil.nullToEmpty(HtmlUtil.cleanHtmlTag(StrUtil.nullToEmpty(deployApp)));
            String msg = NL + failureNum + "、部署应用 " + safeApp + " 导入失败：" + message;
            failureMsg.append(msg);
            log.error(msg, e);
        }
    }

    /**
     * 所有数据解析完成后的回调。
     *
     * @param context Excel 解析上下文
     */
    @Override
    public void doAfterAllAnalysed(AnalysisContext context) {

    }

    /**
     * 获取系统部署节点导入结果。
     *
     * @return Excel 导入结果
     */
    @Override
    public ExcelResult<SysAssetDeployImportVo> getExcelResult() {
        return new ExcelResult<>() {

            @Override
            public String getAnalysis() {
                if (failureNum > 0) {
                    failureMsg.insert(0,
                        "很抱歉，导入失败！共 " + failureNum + " 条数据不正确，其中成功 " + successNum + " 条，错误如下：");
                    throw new ServiceException(failureMsg.toString());
                }
                successMsg.insert(0, "恭喜您，共 " + successNum + " 条数据全部导入成功，明细如下：");
                return successMsg.toString();
            }

            @Override
            public List<SysAssetDeployImportVo> getList() {
                return null;
            }

            @Override
            public List<String> getErrorList() {
                return null;
            }
        };
    }

}
