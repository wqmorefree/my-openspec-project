package com.openspec.project.system.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import com.openspec.project.system.domain.SysAssetDeploy;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 系统部署节点视图对象 sys_asset_deploy
 *
 * @author my-openspec-project
 */
@Data
@AutoMapper(target = SysAssetDeploy.class)
public class SysAssetDeployVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 主键ID（UUID）
     */
    private String id;

    /**
     * 所属系统ID（逻辑外键，指向 sys_asset.id）
     */
    private String assetId;

    /**
     * 模块名称
     */
    private String moduleName;

    /**
     * 部署应用
     */
    private String deployApp;

    /**
     * 主机名
     */
    private String hostName;

    /**
     * IP地址
     */
    private String ipAddress;

    /**
     * 容器IP
     */
    private String containerIp;

    /**
     * 链接模版
     */
    private String linkTemplate;

    /**
     * 机房
     */
    private String idc;

    /**
     * CPU（核）
     */
    private Integer cpuCores;

    /**
     * 内存（G）
     */
    private BigDecimal memoryGb;

    /**
     * 系统盘（G）
     */
    private BigDecimal sysDiskGb;

    /**
     * 数据盘（G）
     */
    private BigDecimal dataDiskGb;

    /**
     * 操作系统
     */
    private String osInfo;

    /**
     * 快照备份需求
     */
    private String snapshotNeed;

    /**
     * 服务器类型
     */
    private String serverType;

    /**
     * 节点数量
     */
    private Integer nodeCount;

    /**
     * 租户
     */
    private String tenant;

    /**
     * VPC
     */
    private String vpc;

    /**
     * 安全组
     */
    private String securityGroup;

    /**
     * 应用描述
     */
    private String appDesc;

    /**
     * 系统环境 1-生产 2-测试 3-开发
     */
    private Integer sysEnv;

    /**
     * 运行环境
     */
    private String runtimeEnv;

    /**
     * 部署网段
     */
    private String deploySubnet;

    /**
     * 路径信息
     */
    private String pathInfo;

    /**
     * 文件挂载
     */
    private String fileMount;

    /**
     * 是否涉及批量操作 0-否 1-是
     */
    private Integer batchOpFlag;

    /**
     * 批量调度平台
     */
    private String batchSchedPlatform;

    /**
     * 是否纳入应用监控 0-否 1-是
     */
    private Integer appMonitorFlag;

    /**
     * 网络QoS策略
     */
    private String networkQos;

    /**
     * 域名
     */
    private String domainName;

    /**
     * 国产化 0-否 1-是
     */
    private Integer domesticFlag;

    /**
     * ETL工具
     */
    private String etlTool;

    /**
     * 备注
     */
    private String remark;

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

}
