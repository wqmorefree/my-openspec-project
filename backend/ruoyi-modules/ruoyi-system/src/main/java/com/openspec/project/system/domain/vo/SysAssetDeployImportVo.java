package com.openspec.project.system.domain.vo;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.fesod.sheet.annotation.ExcelProperty;
import com.openspec.project.common.excel.annotation.ExcelDictFormat;
import com.openspec.project.common.excel.convert.ExcelDictConvert;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 系统部署节点导入 VO
 *
 * @author my-openspec-project
 */
@Data
@NoArgsConstructor
public class SysAssetDeployImportVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 模块名称
     */
    @ExcelProperty(value = "模块名称")
    private String moduleName;

    /**
     * 部署应用
     */
    @ExcelProperty(value = "部署应用")
    private String deployApp;

    /**
     * 主机名
     */
    @ExcelProperty(value = "主机名")
    private String hostName;

    /**
     * IP地址
     */
    @ExcelProperty(value = "IP地址")
    private String ipAddress;

    /**
     * 容器IP
     */
    @ExcelProperty(value = "容器IP")
    private String containerIp;

    /**
     * 链接模版
     */
    @ExcelProperty(value = "链接模版")
    private String linkTemplate;

    /**
     * 机房
     */
    @ExcelProperty(value = "机房")
    private String idc;

    /**
     * CPU（核）
     */
    @ExcelProperty(value = "CPU（核）")
    private Integer cpuCores;

    /**
     * 内存（G）
     */
    @ExcelProperty(value = "内存（G）")
    private BigDecimal memoryGb;

    /**
     * 系统盘（G）
     */
    @ExcelProperty(value = "系统盘（G）")
    private BigDecimal sysDiskGb;

    /**
     * 数据盘（G）
     */
    @ExcelProperty(value = "数据盘（G）")
    private BigDecimal dataDiskGb;

    /**
     * 操作系统
     */
    @ExcelProperty(value = "操作系统")
    private String osInfo;

    /**
     * 快照备份需求
     */
    @ExcelProperty(value = "快照备份需求")
    private String snapshotNeed;

    /**
     * 服务器类型
     */
    @ExcelProperty(value = "服务器类型")
    private String serverType;

    /**
     * 节点数量
     */
    @ExcelProperty(value = "节点数量")
    private Integer nodeCount;

    /**
     * 租户
     */
    @ExcelProperty(value = "租户")
    private String tenant;

    /**
     * VPC
     */
    @ExcelProperty(value = "VPC")
    private String vpc;

    /**
     * 安全组
     */
    @ExcelProperty(value = "安全组")
    private String securityGroup;

    /**
     * 应用描述
     */
    @ExcelProperty(value = "应用描述")
    private String appDesc;

    /**
     * 系统环境 1-生产 2-测试 3-开发
     */
    @ExcelProperty(value = "系统环境", converter = ExcelDictConvert.class)
    @ExcelDictFormat(dictType = "deploy_sys_env")
    private Integer sysEnv;

    /**
     * 运行环境
     */
    @ExcelProperty(value = "运行环境")
    private String runtimeEnv;

    /**
     * 部署网段
     */
    @ExcelProperty(value = "部署网段")
    private String deploySubnet;

    /**
     * 路径信息
     */
    @ExcelProperty(value = "路径信息")
    private String pathInfo;

    /**
     * 文件挂载
     */
    @ExcelProperty(value = "文件挂载")
    private String fileMount;

    /**
     * 是否涉及批量操作 0-否 1-是（导入模板填「是/否」，经表达式转换为 0/1）
     */
    @ExcelProperty(value = "是否涉及批量操作", converter = ExcelDictConvert.class)
    @ExcelDictFormat(readConverterExp = "0=否,1=是")
    private Integer batchOpFlag;

    /**
     * 批量调度平台
     */
    @ExcelProperty(value = "批量调度平台")
    private String batchSchedPlatform;

    /**
     * 是否纳入应用监控 0-否 1-是（导入模板填「是/否」，经表达式转换为 0/1）
     */
    @ExcelProperty(value = "是否纳入应用监控", converter = ExcelDictConvert.class)
    @ExcelDictFormat(readConverterExp = "0=否,1=是")
    private Integer appMonitorFlag;

    /**
     * 网络QoS策略
     */
    @ExcelProperty(value = "网络QoS策略")
    private String networkQos;

    /**
     * 域名
     */
    @ExcelProperty(value = "域名")
    private String domainName;

    /**
     * 国产化 0-否 1-是（导入模板填「是/否」，经表达式转换为 0/1）
     */
    @ExcelProperty(value = "国产化", converter = ExcelDictConvert.class)
    @ExcelDictFormat(readConverterExp = "0=否,1=是")
    private Integer domesticFlag;

    /**
     * ETL工具
     */
    @ExcelProperty(value = "ETL工具")
    private String etlTool;

    /**
     * 备注
     */
    @ExcelProperty(value = "备注")
    private String remark;

}
