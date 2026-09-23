package com.openspec.project.system.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import com.openspec.project.system.domain.SysAsset;

import java.io.Serial;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

/**
 * 系统技术资产业务对象 sys_asset
 *
 * @author my-openspec-project
 */
@Data
@AutoMapper(target = SysAsset.class, reverseConvertGenerate = false)
public class SysAssetBo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 主键ID（UUID）
     */
    private String id;

    /**
     * 系统编码（人工维护，不可改）
     */
    @NotBlank(message = "系统编码不能为空")
    @Size(min = 0, max = 64, message = "系统编码长度不能超过{max}个字符")
    private String code;

    /**
     * 系统名称
     */
    @NotBlank(message = "系统名称不能为空")
    @Size(min = 0, max = 128, message = "系统名称长度不能超过{max}个字符")
    private String name;

    /**
     * 所属业务域
     */
    @NotBlank(message = "所属业务域不能为空")
    @Size(min = 0, max = 128, message = "所属业务域长度不能超过{max}个字符")
    private String bizDomain;

    /**
     * 负责人
     */
    @NotBlank(message = "负责人不能为空")
    @Size(min = 0, max = 64, message = "负责人长度不能超过{max}个字符")
    private String owner;

    /**
     * 状态 1-在建 2-已上线 3-已下线 4-维护中
     */
    @NotNull(message = "状态不能为空")
    @Min(value = 1, message = "状态取值不合法")
    @Max(value = 4, message = "状态取值不合法")
    private Integer status;

    /**
     * 关键词（系统编码/系统名称模糊查询，列表筛选用）
     */
    private String keyword;

    /**
     * 项目名称
     */
    @Size(min = 0, max = 128, message = "项目名称长度不能超过{max}个字符")
    private String projectName;

    /**
     * 项目编号
     */
    @Size(min = 0, max = 64, message = "项目编号长度不能超过{max}个字符")
    private String projectNo;

    /**
     * 组长
     */
    @Size(min = 0, max = 64, message = "组长长度不能超过{max}个字符")
    private String leaderName;

    /**
     * 组长手机（SM4加密）
     */
    @Size(min = 0, max = 128, message = "组长手机长度不能超过{max}个字符")
    private String leaderMobile;

    /**
     * 项目经理
     */
    @Size(min = 0, max = 64, message = "项目经理长度不能超过{max}个字符")
    private String pmName;

    /**
     * 项目经理手机（SM4加密）
     */
    @Size(min = 0, max = 128, message = "项目经理手机长度不能超过{max}个字符")
    private String pmMobile;

    /**
     * 系统介绍
     */
    private String intro;

    /**
     * 系统类别
     */
    @Size(min = 0, max = 64, message = "系统类别长度不能超过{max}个字符")
    private String category;

    /**
     * SVN文档地址
     */
    @Size(min = 0, max = 256, message = "SVN文档地址长度不能超过{max}个字符")
    private String svnDocUrl;

    /**
     * Git代码地址
     */
    @Size(min = 0, max = 256, message = "Git代码地址长度不能超过{max}个字符")
    private String gitCodeUrl;

    /**
     * 模块名
     */
    @Size(min = 0, max = 128, message = "模块名长度不能超过{max}个字符")
    private String moduleName;

    /**
     * 分支名
     */
    @Size(min = 0, max = 128, message = "分支名长度不能超过{max}个字符")
    private String branchName;

    /**
     * 分支描述
     */
    @Size(min = 0, max = 256, message = "分支描述长度不能超过{max}个字符")
    private String branchDesc;

    /**
     * 分支地址
     */
    @Size(min = 0, max = 256, message = "分支地址长度不能超过{max}个字符")
    private String branchUrl;

    /**
     * 请求参数
     */
    private Map<String, Object> params = new HashMap<>();

}