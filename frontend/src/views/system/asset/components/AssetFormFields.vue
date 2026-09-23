<template>
  <el-row :gutter="16">
    <!-- 系统技术资产 19 字段表单（列表新增/编辑弹窗、详情基础信息 Tab 共用） -->
    <el-col :span="12">
    <el-form-item label="系统编码" prop="code">
      <el-input v-model="form.code" placeholder="请输入系统编码" :disabled="isEdit" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="系统名称" prop="name">
      <el-input v-model="form.name" placeholder="请输入系统名称" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="所属业务域" prop="bizDomain">
      <el-input v-model="form.bizDomain" placeholder="请输入所属业务域" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="负责人" prop="owner">
      <el-input v-model="form.owner" placeholder="请输入负责人" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="状态" prop="status">
      <el-radio-group v-model="form.status">
        <el-radio v-for="dict in asset_status" :key="dict.value" :value="Number(dict.value)">
          {{ dict.label }}
        </el-radio>
      </el-radio-group>
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="系统类别" prop="category">
      <el-input v-model="form.category" placeholder="请输入系统类别" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="项目名称" prop="projectName">
      <el-input v-model="form.projectName" placeholder="请输入项目名称" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="项目编号" prop="projectNo">
      <el-input v-model="form.projectNo" placeholder="请输入项目编号" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="组长" prop="leaderName">
      <el-input v-model="form.leaderName" placeholder="请输入组长" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="组长手机" prop="leaderMobile">
      <el-input v-model="form.leaderMobile" placeholder="请输入组长手机" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="项目经理" prop="pmName">
      <el-input v-model="form.pmName" placeholder="请输入项目经理" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="项目经理手机" prop="pmMobile">
      <el-input v-model="form.pmMobile" placeholder="请输入项目经理手机" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="SVN文档地址" prop="svnDocUrl">
      <el-input v-model="form.svnDocUrl" placeholder="请输入SVN文档地址" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="Git代码地址" prop="gitCodeUrl">
      <el-input v-model="form.gitCodeUrl" placeholder="请输入Git代码地址" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="模块名" prop="moduleName">
      <el-input v-model="form.moduleName" placeholder="请输入模块名" />
    </el-form-item>
  </el-col>
  <el-col :span="12">
    <el-form-item label="分支名" prop="branchName">
      <el-input v-model="form.branchName" placeholder="请输入分支名" />
    </el-form-item>
  </el-col>
  <el-col :span="24">
    <el-form-item label="分支描述" prop="branchDesc">
      <el-input v-model="form.branchDesc" placeholder="请输入分支描述" />
    </el-form-item>
  </el-col>
  <el-col :span="24">
    <el-form-item label="分支地址" prop="branchUrl">
      <el-input v-model="form.branchUrl" placeholder="请输入分支地址" />
    </el-form-item>
  </el-col>
  <el-col :span="24">
    <el-form-item label="系统介绍" prop="intro">
      <el-input v-model="form.intro" type="textarea" :rows="3" placeholder="请输入系统介绍" />
    </el-form-item>
  </el-col>
  </el-row>
</template>

<script setup lang="ts">
import type { AssetForm } from '@/api/system/asset/types';
import { useDict } from '@/utils/dict';

defineOptions({ inheritAttrs: false });

defineProps<{
  /** 表单数据（父级 reactive 对象，字段直接双向绑定） */
  form: AssetForm;
  /** 编辑态：系统编码禁用；列表新增时为 false，详情 Tab 编辑固定为 true */
  isEdit?: boolean;
}>();

const { asset_status } = toRefs<any>(useDict('asset_status'));
</script>
