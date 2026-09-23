package com.openspec.project.system.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import org.apache.fesod.sheet.annotation.ExcelIgnoreUnannotated;
import org.apache.fesod.sheet.annotation.ExcelProperty;
import com.openspec.project.common.excel.annotation.ExcelDictFormat;
import com.openspec.project.common.excel.convert.ExcelDictConvert;
import com.openspec.project.system.domain.SysAsset;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 系统技术资产视图对象 sys_asset
 *
 * @author my-openspec-project
 */
@Data
@ExcelIgnoreUnannotated
@AutoMapper(target = SysAsset.class)
public class SysAssetVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 主键ID（UUID）
     */
    @ExcelProperty(value = "主键ID")
    private String id;

    /**
     * 系统编码（人工维护，不可改）
     */
    @ExcelProperty(value = "系统编码")
    private String code;

    /**
     * 系统名称
     */
    @ExcelProperty(value = "系统名称")
    private String name;

    /**
     * 所属业务域
     */
    @ExcelProperty(value = "所属业务域")
    private String bizDomain;

    /**
     * 负责人
     */
    @ExcelProperty(value = "负责人")
    private String owner;

    /**
     * 状态 1-在建 2-已上线 3-已下线 4-维护中
     */
    @ExcelProperty(value = "状态", converter = ExcelDictConvert.class)
    @ExcelDictFormat(dictType = "asset_status")
    private Integer status;

    /**
     * 项目名称
     */
    @ExcelProperty(value = "项目名称")
    private String projectName;

    /**
     * 项目编号
     */
    @ExcelProperty(value = "项目编号")
    private String projectNo;

    /**
     * 组长
     */
    @ExcelProperty(value = "组长")
    private String leaderName;

    /**
     * 组长手机（SM4加密）
     */
    @ExcelProperty(value = "组长手机")
    private String leaderMobile;

    /**
     * 项目经理
     */
    @ExcelProperty(value = "项目经理")
    private String pmName;

    /**
     * 项目经理手机（SM4加密）
     */
    @ExcelProperty(value = "项目经理手机")
    private String pmMobile;

    /**
     * 系统介绍
     */
    @ExcelProperty(value = "系统介绍")
    private String intro;

    /**
     * 系统类别
     */
    @ExcelProperty(value = "系统类别")
    private String category;

    /**
     * SVN文档地址
     */
    @ExcelProperty(value = "SVN文档地址")
    private String svnDocUrl;

    /**
     * Git代码地址
     */
    @ExcelProperty(value = "Git代码地址")
    private String gitCodeUrl;

    /**
     * 模块名
     */
    @ExcelProperty(value = "模块名")
    private String moduleName;

    /**
     * 分支名
     */
    @ExcelProperty(value = "分支名")
    private String branchName;

    /**
     * 分支描述
     */
    @ExcelProperty(value = "分支描述")
    private String branchDesc;

    /**
     * 分支地址
     */
    @ExcelProperty(value = "分支地址")
    private String branchUrl;

    /**
     * 创建时间
     */
    @ExcelProperty(value = "创建时间")
    private LocalDateTime createdTime;

    /**
     * 更新时间
     */
    @ExcelProperty(value = "更新时间")
    private LocalDateTime updatedTime;

}