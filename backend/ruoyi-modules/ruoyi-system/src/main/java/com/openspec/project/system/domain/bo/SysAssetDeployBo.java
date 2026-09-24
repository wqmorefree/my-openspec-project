package com.openspec.project.system.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import com.openspec.project.system.domain.SysAssetDeploy;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 系统部署节点业务对象 sys_asset_deploy
 *
 * @author my-openspec-project
 */
@Data
@AutoMapper(target = SysAssetDeploy.class, reverseConvertGenerate = false)
public class SysAssetDeployBo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 主键ID（UUID）
     */
    private String id;

    /**
     * 所属系统ID（逻辑外键，指向 sys_asset.id）
     */
    @NotBlank(message = "所属系统ID不能为空")
    private String assetId;

    /**
     * 模块名称
     */
    @NotBlank(message = "模块名称不能为空")
    @Size(min = 0, max = 128, message = "模块名称长度不能超过{max}个字符")
    private String moduleName;

    /**
     * 部署应用
     */
    @NotBlank(message = "部署应用不能为空")
    @Size(min = 0, max = 128, message = "部署应用长度不能超过{max}个字符")
    private String deployApp;

    /**
     * 主机名
     */
    @NotBlank(message = "主机名不能为空")
    @Size(min = 0, max = 128, message = "主机名长度不能超过{max}个字符")
    private String hostName;

    /**
     * IP地址
     */
    @NotBlank(message = "IP地址不能为空")
    @Size(min = 0, max = 64, message = "IP地址长度不能超过{max}个字符")
    private String ipAddress;

    /**
     * 容器IP
     */
    @Size(min = 0, max = 64, message = "容器IP长度不能超过{max}个字符")
    private String containerIp;

    /**
     * 链接模版
     */
    @Size(min = 0, max = 256, message = "链接模版长度不能超过{max}个字符")
    private String linkTemplate;

    /**
     * 机房
     */
    @Size(min = 0, max = 128, message = "机房长度不能超过{max}个字符")
    private String idc;

    /**
     * CPU（核）
     */
    @Min(value = 0, message = "CPU核数不能为负数")
    private Integer cpuCores;

    /**
     * 内存（G）
     */
    @DecimalMin(value = "0", message = "内存不能为负数")
    private BigDecimal memoryGb;

    /**
     * 系统盘（G）
     */
    @DecimalMin(value = "0", message = "系统盘不能为负数")
    private BigDecimal sysDiskGb;

    /**
     * 数据盘（G）
     */
    @DecimalMin(value = "0", message = "数据盘不能为负数")
    private BigDecimal dataDiskGb;

    /**
     * 操作系统
     */
    @Size(min = 0, max = 128, message = "操作系统长度不能超过{max}个字符")
    private String osInfo;

    /**
     * 快照备份需求
     */
    @Size(min = 0, max = 256, message = "快照备份需求长度不能超过{max}个字符")
    private String snapshotNeed;

    /**
     * 服务器类型
     */
    @Size(min = 0, max = 64, message = "服务器类型长度不能超过{max}个字符")
    private String serverType;

    /**
     * 节点数量
     */
    @Min(value = 0, message = "节点数量不能为负数")
    private Integer nodeCount;

    /**
     * 租户
     */
    @Size(min = 0, max = 64, message = "租户长度不能超过{max}个字符")
    private String tenant;

    /**
     * VPC
     */
    @Size(min = 0, max = 128, message = "VPC长度不能超过{max}个字符")
    private String vpc;

    /**
     * 安全组
     */
    @Size(min = 0, max = 256, message = "安全组长度不能超过{max}个字符")
    private String securityGroup;

    /**
     * 应用描述
     */
    private String appDesc;

    /**
     * 系统环境 1-生产 2-测试 3-开发
     */
    @NotNull(message = "系统环境不能为空")
    @Min(value = 1, message = "系统环境取值不合法")
    @Max(value = 3, message = "系统环境取值不合法")
    private Integer sysEnv;

    /**
     * 运行环境
     */
    @Size(min = 0, max = 128, message = "运行环境长度不能超过{max}个字符")
    private String runtimeEnv;

    /**
     * 部署网段
     */
    @Size(min = 0, max = 128, message = "部署网段长度不能超过{max}个字符")
    private String deploySubnet;

    /**
     * 路径信息
     */
    @Size(min = 0, max = 256, message = "路径信息长度不能超过{max}个字符")
    private String pathInfo;

    /**
     * 文件挂载
     */
    @Size(min = 0, max = 256, message = "文件挂载长度不能超过{max}个字符")
    private String fileMount;

    /**
     * 是否涉及批量操作 0-否 1-是
     */
    @Min(value = 0, message = "是否涉及批量操作取值不合法")
    @Max(value = 1, message = "是否涉及批量操作取值不合法")
    private Integer batchOpFlag;

    /**
     * 批量调度平台
     */
    @Size(min = 0, max = 128, message = "批量调度平台长度不能超过{max}个字符")
    private String batchSchedPlatform;

    /**
     * 是否纳入应用监控 0-否 1-是
     */
    @Min(value = 0, message = "是否纳入应用监控取值不合法")
    @Max(value = 1, message = "是否纳入应用监控取值不合法")
    private Integer appMonitorFlag;

    /**
     * 网络QoS策略
     */
    @Size(min = 0, max = 256, message = "网络QoS策略长度不能超过{max}个字符")
    private String networkQos;

    /**
     * 域名
     */
    @Size(min = 0, max = 256, message = "域名长度不能超过{max}个字符")
    private String domainName;

    /**
     * 国产化 0-否 1-是
     */
    @Min(value = 0, message = "国产化取值不合法")
    @Max(value = 1, message = "国产化取值不合法")
    private Integer domesticFlag;

    /**
     * ETL工具
     */
    @Size(min = 0, max = 128, message = "ETL工具长度不能超过{max}个字符")
    private String etlTool;

    /**
     * 备注
     */
    @Size(min = 0, max = 256, message = "备注长度不能超过{max}个字符")
    private String remark;

}
