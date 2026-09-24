<template>
  <el-row :gutter="16">
    <!-- 分组一：基础信息（7 字段） -->
    <el-col :span="24">
      <el-divider content-position="left">基础信息</el-divider>
    </el-col>
    <el-col :span="8">
      <el-form-item label="模块名称" prop="moduleName">
        <el-input v-model="form.moduleName" placeholder="请输入模块名称" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="部署应用" prop="deployApp">
        <el-input v-model="form.deployApp" placeholder="请输入部署应用" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="主机名" prop="hostName">
        <el-input v-model="form.hostName" placeholder="请输入主机名" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="IP地址" prop="ipAddress">
        <el-input v-model="form.ipAddress" placeholder="请输入IP地址" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="系统环境" prop="sysEnv">
        <el-select v-model="form.sysEnv" placeholder="请选择系统环境" style="width: 100%">
          <el-option
            v-for="dict in deploy_sys_env"
            :key="dict.value"
            :label="dict.label"
            :value="Number(dict.value)"
          />
        </el-select>
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="运行环境" prop="runtimeEnv">
        <el-input v-model="form.runtimeEnv" placeholder="请输入运行环境" />
      </el-form-item>
    </el-col>
    <el-col :span="24">
      <el-form-item label="应用描述" prop="appDesc">
        <el-input v-model="form.appDesc" type="textarea" :rows="2" placeholder="请输入应用描述" />
      </el-form-item>
    </el-col>

    <!-- 分组二：资源配置（9 字段） -->
    <el-col :span="24">
      <el-divider content-position="left">资源配置</el-divider>
    </el-col>
    <el-col :span="8">
      <el-form-item label="容器IP" prop="containerIp">
        <el-input v-model="form.containerIp" placeholder="请输入容器IP" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="机房" prop="idc">
        <el-input v-model="form.idc" placeholder="请输入机房" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="服务器类型" prop="serverType">
        <el-input v-model="form.serverType" placeholder="请输入服务器类型" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="CPU（核）" prop="cpuCores">
        <el-input-number v-model="form.cpuCores" :min="0" :precision="0" :step="1" controls-position="right" style="width: 100%" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="内存（G）" prop="memoryGb">
        <el-input-number v-model="form.memoryGb" :min="0" :step="1" controls-position="right" style="width: 100%" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="节点数量" prop="nodeCount">
        <el-input-number v-model="form.nodeCount" :min="0" :precision="0" :step="1" controls-position="right" style="width: 100%" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="系统盘（G）" prop="sysDiskGb">
        <el-input-number v-model="form.sysDiskGb" :min="0" :step="1" controls-position="right" style="width: 100%" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="数据盘（G）" prop="dataDiskGb">
        <el-input-number v-model="form.dataDiskGb" :min="0" :step="1" controls-position="right" style="width: 100%" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="操作系统" prop="osInfo">
        <el-input v-model="form.osInfo" placeholder="请输入操作系统" />
      </el-form-item>
    </el-col>

    <!-- 分组三：网络配置（7 字段） -->
    <el-col :span="24">
      <el-divider content-position="left">网络配置</el-divider>
    </el-col>
    <el-col :span="8">
      <el-form-item label="链接模版" prop="linkTemplate">
        <el-input v-model="form.linkTemplate" placeholder="请输入链接模版" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="租户" prop="tenant">
        <el-input v-model="form.tenant" placeholder="请输入租户" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="VPC" prop="vpc">
        <el-input v-model="form.vpc" placeholder="请输入VPC" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="安全组" prop="securityGroup">
        <el-input v-model="form.securityGroup" placeholder="请输入安全组" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="部署网段" prop="deploySubnet">
        <el-input v-model="form.deploySubnet" placeholder="请输入部署网段" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="域名" prop="domainName">
        <el-input v-model="form.domainName" placeholder="请输入域名" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="网络QoS策略" prop="networkQos">
        <el-input v-model="form.networkQos" placeholder="请输入网络QoS策略" />
      </el-form-item>
    </el-col>

    <!-- 分组四：运维配置（9 字段） -->
    <el-col :span="24">
      <el-divider content-position="left">运维配置</el-divider>
    </el-col>
    <el-col :span="8">
      <el-form-item label="快照备份需求" prop="snapshotNeed">
        <el-input v-model="form.snapshotNeed" placeholder="请输入快照备份需求" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="路径信息" prop="pathInfo">
        <el-input v-model="form.pathInfo" placeholder="请输入路径信息" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="文件挂载" prop="fileMount">
        <el-input v-model="form.fileMount" placeholder="请输入文件挂载" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="批量操作" prop="batchOpFlag">
        <el-radio-group v-model="form.batchOpFlag">
          <el-radio v-for="dict in sys_yes_no" :key="dict.value" :value="Number(dict.value)">
            {{ dict.label }}
          </el-radio>
        </el-radio-group>
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="批量调度平台" prop="batchSchedPlatform">
        <el-input v-model="form.batchSchedPlatform" placeholder="请输入批量调度平台" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="应用监控" prop="appMonitorFlag">
        <el-radio-group v-model="form.appMonitorFlag">
          <el-radio v-for="dict in sys_yes_no" :key="dict.value" :value="Number(dict.value)">
            {{ dict.label }}
          </el-radio>
        </el-radio-group>
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="国产化" prop="domesticFlag">
        <el-radio-group v-model="form.domesticFlag">
          <el-radio v-for="dict in sys_yes_no" :key="dict.value" :value="Number(dict.value)">
            {{ dict.label }}
          </el-radio>
        </el-radio-group>
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="ETL工具" prop="etlTool">
        <el-input v-model="form.etlTool" placeholder="请输入ETL工具" />
      </el-form-item>
    </el-col>
    <el-col :span="8">
      <el-form-item label="备注" prop="remark">
        <el-input v-model="form.remark" placeholder="请输入备注" />
      </el-form-item>
    </el-col>
  </el-row>
</template>

<script setup lang="ts">
import type { DeployForm } from '@/api/system/asset/deploy/types';
import { useDict } from '@/utils/dict';

defineProps<{ form: DeployForm }>();

const { deploy_sys_env, sys_yes_no } = toRefs<any>(useDict('deploy_sys_env', 'sys_yes_no'));
</script>
