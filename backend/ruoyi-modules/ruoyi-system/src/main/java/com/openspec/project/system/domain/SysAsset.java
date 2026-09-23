package com.openspec.project.system.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.openspec.project.common.typehandler.Sm4TypeHandler;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 系统技术资产对象 sys_asset
 *
 * @author my-openspec-project
 */
@Data
@TableName("sys_asset")
public class SysAsset implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 主键ID（UUID）
     */
    @TableId(type = IdType.ASSIGN_UUID)
    private String id;

    /**
     * 系统编码（人工维护，不可改）
     */
    private String code;

    /**
     * 系统名称
     */
    private String name;

    /**
     * 所属业务域
     */
    private String bizDomain;

    /**
     * 负责人
     */
    private String owner;

    /**
     * 状态 1-在建 2-已上线 3-已下线 4-维护中
     */
    private Integer status;

    /**
     * 项目名称
     */
    private String projectName;

    /**
     * 项目编号
     */
    private String projectNo;

    /**
     * 组长
     */
    private String leaderName;

    /**
     * 组长手机（SM4加密）
     */
    @TableField(typeHandler = Sm4TypeHandler.class)
    private String leaderMobile;

    /**
     * 项目经理
     */
    private String pmName;

    /**
     * 项目经理手机（SM4加密）
     */
    @TableField(typeHandler = Sm4TypeHandler.class)
    private String pmMobile;

    /**
     * 系统介绍
     */
    private String intro;

    /**
     * 系统类别
     */
    private String category;

    /**
     * SVN文档地址
     */
    private String svnDocUrl;

    /**
     * Git代码地址
     */
    private String gitCodeUrl;

    /**
     * 模块名
     */
    private String moduleName;

    /**
     * 分支名
     */
    private String branchName;

    /**
     * 分支描述
     */
    private String branchDesc;

    /**
     * 分支地址
     */
    private String branchUrl;

    /**
     * 创建人
     */
    private String createdUser;

    /**
     * 更新人
     */
    private String updatedUser;

    /**
     * 创建时间
     */
    private LocalDateTime createdTime;

    /**
     * 更新时间
     */
    private LocalDateTime updatedTime;

    /**
     * 是否删除 0-否 1-是
     */
    @TableLogic
    private Integer isDeleted;

    /**
     * 删除时间（软删除）
     */
    private LocalDateTime deletedTime;

}