package com.openspec.project.system.service.impl;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import com.openspec.project.common.core.exception.ServiceException;
import com.openspec.project.common.core.utils.MapstructUtils;
import com.openspec.project.common.excel.core.ExcelResult;
import com.openspec.project.common.excel.utils.ExcelBuilder;
import com.openspec.project.common.satoken.utils.LoginHelper;
import com.openspec.project.system.domain.SysAssetDeploy;
import com.openspec.project.system.domain.bo.SysAssetDeployBo;
import com.openspec.project.system.domain.vo.SysAssetDeployImportVo;
import com.openspec.project.system.domain.vo.SysAssetDeployVo;
import com.openspec.project.system.listener.SysAssetDeployImportListener;
import com.openspec.project.system.mapper.SysAssetDeployMapper;
import com.openspec.project.system.service.ISysAssetDeployService;
import com.openspec.project.system.service.ISysDictTypeService;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 系统部署节点 服务层实现
 *
 * @author my-openspec-project
 */
@RequiredArgsConstructor
@Service
public class SysAssetDeployServiceImpl implements ISysAssetDeployService {

    private final SysAssetDeployMapper deployMapper;

    private final ISysDictTypeService dictTypeService;

    /**
     * 查询系统部署节点列表
     *
     * @param bo 查询条件（assetId 必传，sysEnv 可选）
     * @return 部署节点列表
     */
    @Override
    public List<SysAssetDeployVo> selectDeployList(SysAssetDeployBo bo) {
        return deployMapper.selectVoList(buildQueryWrapper(bo));
    }

    /**
     * 构建部署节点查询包装器：强制按系统归属，可选系统环境过滤。
     *
     * @param bo 查询条件
     * @return 查询包装器
     */
    private LambdaQueryWrapper<SysAssetDeploy> buildQueryWrapper(SysAssetDeployBo bo) {
        if (StrUtil.isBlank(bo.getAssetId())) {
            throw new ServiceException("assetId 不能为空");
        }
        return Wrappers.<SysAssetDeploy>lambdaQuery()
            .eq(SysAssetDeploy::getAssetId, bo.getAssetId())
            .eq(bo.getSysEnv() != null, SysAssetDeploy::getSysEnv, bo.getSysEnv())
            .orderByAsc(SysAssetDeploy::getSysEnv)
            .orderByDesc(SysAssetDeploy::getCreatedTime);
    }

    /**
     * 新增系统部署节点
     *
     * @param bo 部署节点
     * @return 影响行数
     */
    @Override
    public int insertDeploy(SysAssetDeployBo bo) {
        validateDeployAppUnique(bo.getAssetId(), bo.getDeployApp(), null);
        SysAssetDeploy deploy = MapstructUtils.convert(bo, SysAssetDeploy.class);
        applyDefaultFlags(deploy);
        String username = LoginHelper.getUsername();
        deploy.setCreatedUser(username);
        deploy.setUpdatedUser(username);
        return deployMapper.insert(deploy);
    }

    /**
     * 导入部署节点（存在则更新，不存在则新增）。
     *
     * @param bo 部署节点
     * @return 影响行数
     */
    @Override
    public int upsertDeploy(SysAssetDeployBo bo) {
        SysAssetDeploy existing = deployMapper.selectOne(
            Wrappers.<SysAssetDeploy>lambdaQuery()
                .eq(SysAssetDeploy::getAssetId, bo.getAssetId())
                .eq(SysAssetDeploy::getDeployApp, bo.getDeployApp()));
        if (existing != null) {
            bo.setId(existing.getId());
            SysAssetDeploy deploy = MapstructUtils.convert(bo, SysAssetDeploy.class);
            applyDefaultFlags(deploy);
            deploy.setUpdatedTime(LocalDateTime.now());
            deploy.setUpdatedUser(LoginHelper.getUsername());
            return deployMapper.updateById(deploy);
        }
        SysAssetDeploy deploy = MapstructUtils.convert(bo, SysAssetDeploy.class);
        applyDefaultFlags(deploy);
        String username = LoginHelper.getUsername();
        deploy.setCreatedUser(username);
        deploy.setUpdatedUser(username);
        return deployMapper.insert(deploy);
    }

    /**
     * 修改系统部署节点
     *
     * @param bo 部署节点
     * @return 影响行数
     */
    @Override
    public int updateDeploy(SysAssetDeployBo bo) {
        SysAssetDeploy origin = deployMapper.selectById(bo.getId());
        if (origin == null) {
            throw new ServiceException("部署节点不存在");
        }
        validateDeployAppUnique(bo.getAssetId(), bo.getDeployApp(), bo.getId());
        SysAssetDeploy deploy = MapstructUtils.convert(bo, SysAssetDeploy.class);
        applyDefaultFlags(deploy);
        deploy.setUpdatedTime(LocalDateTime.now());
        deploy.setUpdatedUser(LoginHelper.getUsername());
        return deployMapper.updateById(deploy);
    }

    /**
     * 标记字段空值兜底为 0，与 DDL 默认值语义保持一致。
     *
     * @param deploy 部署节点实体
     */
    private void applyDefaultFlags(SysAssetDeploy deploy) {
        if (deploy.getBatchOpFlag() == null) {
            deploy.setBatchOpFlag(0);
        }
        if (deploy.getAppMonitorFlag() == null) {
            deploy.setAppMonitorFlag(0);
        }
        if (deploy.getDomesticFlag() == null) {
            deploy.setDomesticFlag(0);
        }
    }

    /**
     * 校验同系统下部署应用名称唯一（软删除记录不占名额）。
     *
     * @param assetId   系统ID
     * @param deployApp 部署应用名称
     * @param excludeId 排除的主键ID（编辑时传自身 id）
     */
    private void validateDeployAppUnique(String assetId, String deployApp, String excludeId) {
        LambdaQueryWrapper<SysAssetDeploy> wrapper = Wrappers.<SysAssetDeploy>lambdaQuery()
            .eq(SysAssetDeploy::getAssetId, assetId)
            .eq(SysAssetDeploy::getDeployApp, deployApp)
            .ne(excludeId != null, SysAssetDeploy::getId, excludeId);
        Long count = deployMapper.selectCount(wrapper);
        if (count != null && count > 0) {
            throw new ServiceException("当前系统部署应用已存在：" + deployApp);
        }
    }

    /**
     * 批量逻辑删除部署节点（写删除时间）
     *
     * @param ids 主键ID集合
     * @return 影响行数
     */
    @Override
    public int deleteDeployByIds(Collection<String> ids) {
        if (CollUtil.isEmpty(ids)) {
            return 0;
        }
        return logicDelete(Wrappers.<SysAssetDeploy>lambdaUpdate()
            .in(SysAssetDeploy::getId, ids));
    }

    /**
     * 按所属系统批量逻辑删除全部部署节点（写删除时间）
     *
     * @param assetIds 系统ID集合
     * @return 影响行数
     */
    @Override
    public int deleteByAssetIds(Collection<String> assetIds) {
        if (CollUtil.isEmpty(assetIds)) {
            return 0;
        }
        return logicDelete(Wrappers.<SysAssetDeploy>lambdaUpdate()
            .in(SysAssetDeploy::getAssetId, assetIds));
    }

    /**
     * 执行逻辑删除更新：置删除标记、删除时间与更新人。
     *
     * @param update 条件更新包装器
     * @return 影响行数
     */
    private int logicDelete(com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<SysAssetDeploy> update) {
        return deployMapper.update(null, update
            .set(SysAssetDeploy::getIsDeleted, 1)
            .set(SysAssetDeploy::getDeletedTime, LocalDateTime.now())
            .set(SysAssetDeploy::getUpdatedTime, LocalDateTime.now())
            .set(SysAssetDeploy::getUpdatedUser, LoginHelper.getUsername()));
    }

    /**
     * Excel 批量导入部署节点。
     *
     * @param file    导入文件
     * @param assetId 所属系统ID
     * @return 导入分析明细
     */
    @Override
    public String importExcel(MultipartFile file, String assetId) throws Exception {
        ExcelResult<SysAssetDeployImportVo> result = ExcelBuilder
            .read(file.getInputStream(), SysAssetDeployImportVo.class)
            .listener(new SysAssetDeployImportListener(assetId))
            .doRead();
        return result.getAnalysis();
    }

    /**
     * 按当前系统（含环境过滤）导出 CSV（UTF-8 BOM）。
     *
     * <p>列表语义与 {@link #selectDeployList} 相同，保证导出内容与表格一致；
     * 无数据时抛出业务异常，不生成空文件。共 32 个字段。</p>
     *
     * @param bo       查询条件
     * @param response HTTP 响应
     */
    @Override
    public void exportCsv(SysAssetDeployBo bo, HttpServletResponse response) {
        List<SysAssetDeployVo> list = selectDeployList(bo);
        if (CollUtil.isEmpty(list)) {
            throw new ServiceException("暂无符合条件的部署节点数据，请调整筛选条件后再导出");
        }
        Map<String, String> envLabelMap = dictTypeService.selectDictDataByType("deploy_sys_env").stream()
            .collect(Collectors.toMap(d -> d.getDictValue(), d -> d.getDictLabel()));

        String suffix = DateTimeFormatter.ofPattern("yyyyMMddHHmmss").format(LocalDateTime.now());
        String encodeFileName = java.net.URLEncoder.encode("部署节点_" + suffix + ".csv", StandardCharsets.UTF_8)
            .replace("+", "%20");
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + encodeFileName);

        try (OutputStream outputStream = response.getOutputStream()) {
            outputStream.write(("\uFEFF" + joinCsvRow(Arrays.asList(
                "模块名称", "部署应用", "主机名", "IP地址", "容器IP", "链接模版", "机房",
                "CPU（核）", "内存（G）", "系统盘（G）", "数据盘（G）", "操作系统", "快照备份需求",
                "服务器类型", "节点数量", "租户", "VPC", "安全组", "应用描述", "系统环境",
                "运行环境", "部署网段", "路径信息", "文件挂载", "是否涉及批量操作", "批量调度平台",
                "是否纳入应用监控", "网络QoS策略", "域名", "国产化", "ETL工具", "备注")) + "\r\n")
                .getBytes(StandardCharsets.UTF_8));

            byte[] crlf = "\r\n".getBytes(StandardCharsets.UTF_8);
            for (SysAssetDeployVo vo : list) {
                outputStream.write(joinCsvRow(Arrays.asList(
                    vo.getModuleName(), vo.getDeployApp(), vo.getHostName(), vo.getIpAddress(),
                    vo.getContainerIp(), vo.getLinkTemplate(), vo.getIdc(),
                    num(vo.getCpuCores() == null ? null : BigDecimal.valueOf(vo.getCpuCores())),
                    num(vo.getMemoryGb()), num(vo.getSysDiskGb()), num(vo.getDataDiskGb()),
                    vo.getOsInfo(), vo.getSnapshotNeed(), vo.getServerType(),
                    num(vo.getNodeCount() == null ? null : BigDecimal.valueOf(vo.getNodeCount())),
                    vo.getTenant(), vo.getVpc(), vo.getSecurityGroup(), vo.getAppDesc(),
                    envLabelMap.getOrDefault(String.valueOf(vo.getSysEnv()), str(vo.getSysEnv())),
                    vo.getRuntimeEnv(), vo.getDeploySubnet(), vo.getPathInfo(), vo.getFileMount(),
                    yesNo(vo.getBatchOpFlag()), vo.getBatchSchedPlatform(),
                    yesNo(vo.getAppMonitorFlag()), vo.getNetworkQos(), vo.getDomainName(),
                    yesNo(vo.getDomesticFlag()), vo.getEtlTool(), vo.getRemark()))
                    .getBytes(StandardCharsets.UTF_8));
                outputStream.write(crlf);
            }
            outputStream.flush();
        } catch (IOException e) {
            throw new ServiceException("导出 CSV 失败：" + e.getMessage());
        }
    }

    /**
     * 拼接 RFC4180 风格 CSV 行。
     *
     * @param values 单元格值集合
     * @return CSV 行字符串
     */
    private String joinCsvRow(List<String> values) {
        return values.stream().map(SysAssetDeployServiceImpl::escapeCsvCell).collect(Collectors.joining(","));
    }

    /**
     * CSV 单元格转义：先中和公式注入，再按 RFC4180 转义。
     *
     * @param value 单元格原值
     * @return 转义后的文本
     */
    private static String escapeCsvCell(String value) {
        String text = value == null ? "" : value;
        if (!text.isEmpty() && "=+-@\t\r".indexOf(text.charAt(0)) >= 0) {
            text = "'" + text;
        }
        if (text.contains(",") || text.contains("\"") || text.contains("\n") || text.contains("\r")) {
            return "\"" + text.replace("\"", "\"\"") + "\"";
        }
        return text;
    }

    /**
     * BigDecimal 转纯文本（避免科学计数法），空值返回空串。
     *
     * @param value 数值
     * @return 文本
     */
    private static String num(BigDecimal value) {
        return value == null ? "" : value.stripTrailingZeros().toPlainString();
    }

    /**
     * 通用对象转字符串，空值返回空串。
     *
     * @param value 值
     * @return 文本
     */
    private static String str(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    /**
     * 0/1 标记转「否/是」。
     *
     * @param flag 标记
     * @return 是/否
     */
    private static String yesNo(Integer flag) {
        if (flag == null) {
            return "";
        }
        return flag == 1 ? "是" : "否";
    }

}
