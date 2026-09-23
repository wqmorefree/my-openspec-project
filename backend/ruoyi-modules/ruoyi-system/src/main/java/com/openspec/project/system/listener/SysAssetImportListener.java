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
import com.openspec.project.system.domain.bo.SysAssetBo;
import com.openspec.project.system.domain.vo.SysAssetImportVo;
import com.openspec.project.system.service.ISysAssetService;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 系统技术资产公用导入监听器
 *
 * <p>逐行校验：必填与状态取值由 {@code SysAssetBo} 校验注解兜底；系统编码做「文件内去重」
 * 与「库内冲突」双重检查，任一冲突均记为失败行并返回逐条明细，不整体回滚。</p>
 *
 * @author my-openspec-project
 */
@Slf4j
public class SysAssetImportListener extends AnalysisEventListener<SysAssetImportVo> implements ExcelListener<SysAssetImportVo> {

    private static final String NL = "\n";

    private final ISysAssetService assetService;

    /**
     * 文件内已成功导入的系统编码集合，用于文件内去重
     */
    private final Set<String> importedCodes = new HashSet<>();

    private int successNum = 0;
    private int failureNum = 0;
    private final StringBuilder successMsg = new StringBuilder();
    private final StringBuilder failureMsg = new StringBuilder();

    /**
     * 构造系统技术资产导入监听器。
     */
    public SysAssetImportListener() {
        this.assetService = SpringUtils.getBean(ISysAssetService.class);
    }

    /**
     * 逐行处理导入数据。
     *
     * @param importVo 导入数据
     * @param context  Excel 解析上下文
     */
    @Override
    public void invoke(SysAssetImportVo importVo, AnalysisContext context) {
        String code = StrUtil.trim(importVo.getCode());
        try {
            if (StrUtil.isBlank(code)) {
                throw new ServiceException("系统编码不能为空");
            }
            if (importedCodes.contains(code)) {
                throw new ServiceException("文件内多次出现系统编码：" + code);
            }
            SysAssetBo bo = BeanUtil.toBean(importVo, SysAssetBo.class);
            ValidatorUtils.validate(bo);
            // 库内冲突（未删除编码占用唯一名额）
            assetService.insertAsset(bo);
            importedCodes.add(code);
            successNum++;
            successMsg.append(NL).append(successNum).append("、系统编码 ").append(code).append(" 导入成功");
        } catch (Exception e) {
            failureNum++;
            String message = e.getMessage();
            if (e instanceof ConstraintViolationException cvException) {
                message = StreamUtils.join(cvException.getConstraintViolations(), ConstraintViolation::getMessage, ", ");
            }
            // code 可能为空（缺必需列的模板/空编码行），清洗前需 null 安全，避免向用户抛出未知异常
            String safeCode = StrUtil.nullToEmpty(HtmlUtil.cleanHtmlTag(StrUtil.nullToEmpty(code)));
            String msg = NL + failureNum + "、系统编码 " + safeCode + " 导入失败：" + message;
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
     * 获取系统技术资产导入结果。
     *
     * @return Excel 导入结果
     */
    @Override
    public ExcelResult<SysAssetImportVo> getExcelResult() {
        return new ExcelResult<>() {

            /**
             * 获取导入结果分析消息。
             *
             * @return 导入结果消息
             */
            @Override
            public String getAnalysis() {
                if (failureNum > 0) {
                    failureMsg.insert(0, "很抱歉，导入失败！共 " + failureNum + " 条数据不正确，其中成功 " + successNum + " 条，错误如下：");
                    throw new ServiceException(failureMsg.toString());
                } else {
                    successMsg.insert(0, "恭喜您，共 " + successNum + " 条数据全部导入成功，明细如下：");
                }
                return successMsg.toString();
            }

            /**
             * 获取导入成功数据列表。
             *
             * @return 导入成功数据列表
             */
            @Override
            public List<SysAssetImportVo> getList() {
                return null;
            }

            /**
             * 获取导入错误信息列表。
             *
             * @return 导入错误信息列表
             */
            @Override
            public List<String> getErrorList() {
                return null;
            }
        };
    }
}