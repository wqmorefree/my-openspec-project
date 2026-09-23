package com.openspec.project.system.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Constants;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.github.yulichang.base.MPJBaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import com.openspec.project.common.mybatis.core.mapper.BaseMapperPlus;
import com.openspec.project.system.domain.SysAsset;
import com.openspec.project.system.domain.vo.SysAssetVo;

import java.util.List;

/**
 * 系统技术资产 数据层
 *
 * @author my-openspec-project
 */
public interface SysAssetMapper extends BaseMapperPlus<SysAsset, SysAssetVo>, MPJBaseMapper<SysAsset> {

    /**
     * 手机密文列内联解密片段：在主查询内调用金仓 kbcrypto sm4(?, ?, 1)，
     * 避免应用层逐字段发起独立 SQL（N+1）。NULL/空字节直接返回 NULL。
     */
    String DECRYPT_COLUMNS = """
        id, code, name, biz_domain, owner, status, project_name, project_no, leader_name,
        CASE WHEN octet_length(leader_mobile) > 0
             THEN convert_from(sm4(leader_mobile, #{sm4Key}, 1), 'UTF8') END AS leader_mobile,
        pm_name,
        CASE WHEN octet_length(pm_mobile) > 0
             THEN convert_from(sm4(pm_mobile, #{sm4Key}, 1), 'UTF8') END AS pm_mobile,
        intro, category, svn_doc_url, git_code_url, module_name, branch_name, branch_desc, branch_url,
        created_user, updated_user, created_time, updated_time
        """;

    /**
     * 分页查询系统技术资产（手机列在 SQL 内联解密，整页仅 1 条主查询 + 1 条 count）。
     *
     * @param page      分页对象
     * @param wrapper   查询条件（仅筛选表达式，排序由 SQL 固定给出，避免空条件时拼接异常）
     * @param sm4Key    SM4 密钥
     * @return 系统技术资产分页结果
     */
    @Select("<script>SELECT " + DECRYPT_COLUMNS + " FROM sys_asset WHERE is_deleted = 0 "
        + "<if test=\"ew != null and ew.sqlSegment != null and ew.sqlSegment != ''\">AND ${ew.sqlSegment}</if>"
        + " ORDER BY created_time DESC, id ASC</script>")
    IPage<SysAssetVo> selectAssetVoPage(Page<SysAsset> page,
                                        @Param(Constants.WRAPPER) com.baomidou.mybatisplus.core.conditions.Wrapper<SysAsset> wrapper,
                                        @Param("sm4Key") String sm4Key);

    /**
     * 集合查询系统技术资产（手机列在 SQL 内联解密）。
     *
     * @param wrapper 查询条件
     * @param sm4Key  SM4 密钥
     * @return 系统技术资产列表
     */
    @Select("<script>SELECT " + DECRYPT_COLUMNS + " FROM sys_asset WHERE is_deleted = 0 "
        + "<if test=\"ew != null and ew.sqlSegment != null and ew.sqlSegment != ''\">AND ${ew.sqlSegment}</if>"
        + " ORDER BY created_time DESC, id ASC</script>")
    List<SysAssetVo> selectAssetVoList(@Param(Constants.WRAPPER) com.baomidou.mybatisplus.core.conditions.Wrapper<SysAsset> wrapper,
                                       @Param("sm4Key") String sm4Key);

    /**
     * 按主键查询系统技术资产详情（手机列在 SQL 内联解密）。
     *
     * @param id     主键ID
     * @param sm4Key SM4 密钥
     * @return 系统技术资产详情
     */
    @Select("SELECT " + DECRYPT_COLUMNS + " FROM sys_asset WHERE id = #{id} AND is_deleted = 0")
    SysAssetVo selectAssetVoById(@Param("id") String id, @Param("sm4Key") String sm4Key);
}
