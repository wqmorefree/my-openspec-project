package com.openspec.project.system.service.impl;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.Wrapper;
import jakarta.servlet.http.HttpServletResponse;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import com.openspec.project.common.core.exception.ServiceException;
import com.openspec.project.common.core.domain.PageResult;
import com.openspec.project.common.core.utils.MapstructUtils;
import com.openspec.project.common.mybatis.core.page.PageQuery;
import com.openspec.project.common.satoken.utils.LoginHelper;
import com.openspec.project.common.typehandler.Sm4KeyProvider;
import com.openspec.project.system.domain.SysAsset;
import com.openspec.project.system.domain.bo.SysAssetBo;
import com.openspec.project.system.domain.vo.SysAssetVo;
import com.openspec.project.system.mapper.SysAssetMapper;
import com.openspec.project.system.service.ISysAssetService;
import com.openspec.project.system.service.ISysDictTypeService;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 系统技术资产 服务层实现
 *
 * @author my-openspec-project
 */
@RequiredArgsConstructor
@Service
public class SysAssetServiceImpl implements ISysAssetService {

    /**
     * 导出/流式读取每批行数
     */
    private static final long EXPORT_BATCH_SIZE = 500L;

    private final SysAssetMapper assetMapper;

    private final ISysDictTypeService dictTypeService;

    /**
     * 分页查询系统技术资产列表
     *
     * @param bo        查询条件
     * @param pageQuery 分页参数
     * @return 系统技术资产分页列表
     */
    @Override
    public PageResult<SysAssetVo> selectPageAssetList(SysAssetBo bo, PageQuery pageQuery) {
        Page<SysAsset> page = pageQuery.build();
        IPage<SysAssetVo> result = assetMapper.selectAssetVoPage(page, buildQueryWrapper(bo), Sm4KeyProvider.getKey());
        return PageResult.build(result.getRecords(), result.getTotal());
    }

    /**
     * 查询系统技术资产信息集合
     *
     * @param bo 查询条件
     * @return 系统技术资产集合
     */
    @Override
    public List<SysAssetVo> selectAssetList(SysAssetBo bo) {
        return assetMapper.selectAssetVoList(buildQueryWrapper(bo), Sm4KeyProvider.getKey());
    }

    /**
     * 根据查询条件构建查询包装器
     *
     * @param bo 查询条件对象
     * @return 构建好的查询包装器
     */
    private Wrapper<SysAsset> buildQueryWrapper(SysAssetBo bo) {
        return assetMapper.lambda()
            .eqIfPresent(SysAsset::getId, bo.getId())
            .eqIfPresent(SysAsset::getCode, bo.getCode())
            .and(StrUtil.isNotBlank(bo.getKeyword()),
                w -> w.like(SysAsset::getName, bo.getKeyword()).or().like(SysAsset::getCode, bo.getKeyword()))
            .likeIfText(SysAsset::getName, bo.getName())
            .likeIfText(SysAsset::getBizDomain, bo.getBizDomain())
            .likeIfText(SysAsset::getOwner, bo.getOwner())
            .eqIfPresent(SysAsset::getStatus, bo.getStatus());
    }

    /**
     * 按当前筛选条件导出 CSV（UTF-8 BOM）并流式写入响应。
     *
     * <p>列表语义与 {@link #selectAssetList} 相同：使用同一 {@code buildQueryWrapper}
     * 保证导出内容与筛选列表一致；分页分批读取（{@link #EXPORT_BATCH_SIZE}）并逐批写出，
     * 避免全量加载导致内存压力；无数据时抛出业务异常，由全局处理器返回提示而非空文件。</p>
     *
     * @param bo       查询条件
     * @param response HTTP 响应
     */
    @Override
    public void exportCsv(SysAssetBo bo, HttpServletResponse response) {
        Long total = assetMapper.selectCount(buildQueryWrapper(bo));
        if (total == null || total == 0L) {
            throw new ServiceException("暂无符合条件的系统资产数据，请调整筛选条件后再导出");
        }
        Map<String, String> statusLabelMap = dictTypeService.selectDictDataByType("asset_status").stream()
            .collect(Collectors.toMap(d -> d.getDictValue(), d -> d.getDictLabel()));
        String suffix = DateTimeFormatter.ofPattern("yyyyMMddHHmmss").format(LocalDateTime.now());
        String encodeFileName = java.net.URLEncoder.encode("系统资产_" + suffix + ".csv", StandardCharsets.UTF_8)
            .replace("+", "%20");
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + encodeFileName);

        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        try (OutputStream outputStream = response.getOutputStream()) {
            outputStream.write(("\uFEFF" + joinCsvRow(Arrays.asList(
                "系统编码", "系统名称", "所属业务域", "负责人", "状态",
                "项目名称", "项目编号", "组长", "组长手机", "项目经理", "项目经理手机",
                "系统介绍", "系统类别", "SVN文档地址", "Git代码地址", "模块名", "分支名",
                "分支描述", "分支地址", "创建时间")) + "\r\n").getBytes(StandardCharsets.UTF_8));

            long pages = (total + EXPORT_BATCH_SIZE - 1) / EXPORT_BATCH_SIZE;
            for (long current = 1L; current <= pages; current++) {
                Page<SysAsset> page = new Page<>(current, EXPORT_BATCH_SIZE, false);
                List<SysAssetVo> batch = assetMapper
                    .selectAssetVoPage(page, buildQueryWrapper(bo), Sm4KeyProvider.getKey())
                    .getRecords();
                StringBuilder csv = new StringBuilder();
                for (SysAssetVo vo : batch) {
                    csv.append(joinCsvRow(Arrays.asList(
                        vo.getCode(), vo.getName(), vo.getBizDomain(), vo.getOwner(),
                        statusLabelMap.getOrDefault(String.valueOf(vo.getStatus()), String.valueOf(vo.getStatus())),
                        vo.getProjectName(), vo.getProjectNo(), vo.getLeaderName(), vo.getLeaderMobile(),
                        vo.getPmName(), vo.getPmMobile(), vo.getIntro(), vo.getCategory(),
                        vo.getSvnDocUrl(), vo.getGitCodeUrl(), vo.getModuleName(), vo.getBranchName(),
                        vo.getBranchDesc(), vo.getBranchUrl(),
                        vo.getCreatedTime() == null ? "" : vo.getCreatedTime().format(timeFormatter))))
                        .append("\r\n");
                }
                outputStream.write(csv.toString().getBytes(StandardCharsets.UTF_8));
                outputStream.flush();
            }
        } catch (IOException e) {
            throw new ServiceException("导出 CSV 失败：" + e.getMessage());
        }
    }

    /**
     * 拼接 RFC4180 风格 CSV 行（逗号分隔，含逗号/引号/换行的字段加引号转义）。
     *
     * @param values 单元格值集合
     * @return CSV 行字符串
     */
    private String joinCsvRow(List<String> values) {
        return values.stream().map(SysAssetServiceImpl::escapeCsvCell).collect(Collectors.joining(","));
    }

    /**
     * CSV 单元格转义：先做公式注入中和（= + - @ Tab CR 开头前置单引号），
     * 再按 RFC4180 对逗号/引号/换行加引号转义。
     *
     * @param value 单元格原值
     * @return 转义后的单元格文本
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
     * 通过ID查询单个系统技术资产
     *
     * @param id 主键ID
     * @return 系统技术资产
     */
    @Override
    public SysAssetVo selectAssetById(String id) {
        return assetMapper.selectAssetVoById(id, Sm4KeyProvider.getKey());
    }

    /**
     * 校验系统编码是否已存在（软删除记录不占用唯一名额）。
     *
     * <p>数据库层由 {@code uk_sys_asset_code} 部分唯一索引兜底（WHERE is_deleted=0）；
     * 此处先做业务预校验，返回友好提示并避免触库冲突。</p>
     *
     * @param code      系统编码
     * @param excludeId 排除的主键ID（编辑时传自身 id）
     */
    private void validateCodeUnique(String code, String excludeId) {
        if (StrUtil.isBlank(code)) {
            return;
        }
        LambdaQueryWrapper<SysAsset> wrapper = Wrappers.<SysAsset>lambdaQuery()
            .eq(SysAsset::getCode, code)
            .ne(StrUtil.isNotBlank(excludeId), SysAsset::getId, excludeId);
        Long count = assetMapper.selectCount(wrapper);
        if (count != null && count > 0) {
            throw new ServiceException("系统编码已存在：" + code);
        }
    }

    /**
     * 新增系统技术资产
     *
     * @param bo 系统技术资产
     * @return 影响行数
     */
    @Override
    public int insertAsset(SysAssetBo bo) {
        validateCodeUnique(bo.getCode(), null);
        SysAsset asset = MapstructUtils.convert(bo, SysAsset.class);
        String username = LoginHelper.getUsername();
        asset.setCreatedUser(username);
        asset.setUpdatedUser(username);
        return assetMapper.insert(asset);
    }

    /**
     * 修改系统技术资产。
     *
     * <p>系统编码不可修改：编辑请求中的 code 一律忽略，以库内原值为准。</p>
     *
     * @param bo 系统技术资产
     * @return 影响行数
     */
    @Override
    public int updateAsset(SysAssetBo bo) {
        SysAsset origin = assetMapper.selectById(bo.getId());
        if (origin == null) {
            throw new ServiceException("系统技术资产不存在");
        }
        SysAsset asset = MapstructUtils.convert(bo, SysAsset.class);
        asset.setCode(origin.getCode());
        asset.setUpdatedTime(LocalDateTime.now());
        asset.setUpdatedUser(LoginHelper.getUsername());
        return assetMapper.updateById(asset);
    }

    /**
     * 批量删除系统技术资产（逻辑删除）
     *
     * @param ids 需要删除的主键ID集合
     * @return 影响行数
     */
    @Override
    public int deleteAssetByIds(Collection<String> ids) {
        if (CollUtil.isEmpty(ids)) {
            return 0;
        }
        return assetMapper.deleteByIds(ids);
    }

}
