# 前端编码规范（Vue 3 + TypeScript）

> 适用于 `frontend/` 下所有 `.vue` 和 `.ts` 文件。

---

## 📌 概要总结

**必须遵守的核心规则：**

| 类别 | 核心规则 |
|------|----------|
| **组件命名** | 基础组件 `Base` 前缀、公共组件语义化、文件名 PascalCase |
| **组件结构** | `<template>` → `<script setup lang="ts">` → `<style scoped>` |
| **类型** | 必须用 TypeScript，禁止 `any`，API 必须定义响应类型 |
| **状态** | 跨组件用 Pinia，组件内用 `ref`/`reactive` |
| **API** | 统一封装 axios，禁止在组件中直接写 URL |
| **样式** | 必须加 `scoped`，复杂组件用 BEM 命名 |

**禁止事项：**
- ❌ 使用 `any`
- ❌ 在组件中硬编码 API URL
- ❌ 使用 Options API（必须用 `<script setup>`）
- ❌ 使用 `v-html` 渲染用户输入

---

## 一、组件分类与命名

### 1.1 组件分类

| 组件类型 | 目录 | 命名规则 | 示例 |
|----------|------|----------|------|
| **基础组件**（原子） | `components/base/` | `Base` 前缀 + PascalCase | `BaseButton.vue`、`BaseTable.vue` |
| **公共组件**（业务无关） | `components/common/` | PascalCase，语义化 | `UserAvatar.vue`、`PageHeader.vue` |
| **业务组件**（页面级） | `views/` 或 `components/business/` | PascalCase，含业务语义 | `OrderList.vue`、`UserProfileCard.vue` |

**规则**：
- 基础组件必须以 `Base` 开头，方便区分
- 公共组件不加前缀，直接语义化命名
- 业务组件放在 `views/` 下，一个页面一个文件
- 组件文件名使用 PascalCase（如 `UserList.vue`）

### 1.2 组件结构

| 规范项 | 规则 |
|--------|------|
| **结构顺序** | `<template>` → `<script setup>` → `<style scoped>` |
| **语言** | 必须使用 TypeScript，`<script setup lang="ts">` |
| **Props 定义** | 必须使用 `defineProps<T>()` 或 `withDefaults` |
| **Emits 定义** | 使用 `defineEmits<T>()` |

**Vue 组件示例**：

```vue
<template>
  <div class="user-list">
    <el-table :data="users" v-loading="loading">
      <el-table-column prop="name" label="姓名" />
      <el-table-column prop="email" label="邮箱" />
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getUserList } from '@/api/modules/user'
import type { UserVO } from '@/types/user'

const users = ref<UserVO[]>([])
const loading = ref(false)

const fetchUsers = async () => {
  loading.value = true
  try {
    const res = await getUserList()
    users.value = res.data
  } finally {
    loading.value = false
  }
}

onMounted(() => fetchUsers())
</script>

<style scoped>
.user-list {
  padding: 20px;
}
</style>
```

---

## 二、Props / Emits 命名

```typescript
// ✅ 正确：Props 用 camelCase，事件用 kebab-case
const props = defineProps<{
  userName: string       // 模板中用 :user-name="xxx"
  isActive: boolean
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
  (e: 'item-click', item: UserVO): void
}>()
```

| 规范项 | 规则 |
|--------|------|
| **Props 命名** | camelCase（`userName`） |
| **模板中使用** | kebab-case（`:user-name="xxx"`） |
| **事件命名** | kebab-case（`item-click`） |
| **v-model** | 使用 `update:modelValue` |

---

## 三、TypeScript 类型规范

| 规范项 | 规则 |
|--------|------|
| **类型定义** | `src/types/` 目录存放全局类型 |
| **API 响应类型** | 必须为每个 API 定义响应类型 |
| **组件 Props** | 使用 `defineProps<{ ... }>()` 定义类型 |
| **避免 any** | 使用 `unknown` 或具体类型替代 `any` |

**类型定义示例**：

```typescript
// src/types/user.ts
export interface UserVO {
  id: string
  name: string
  email: string
  createdAt: string
}

export interface UserListResponse {
  list: UserVO[]
  total: number
  pageNum: number
  pageSize: number
}
```

---

## 四、状态管理（Pinia）

| 规范项 | 规则 |
|--------|------|
| **Store 定义** | `src/stores/` 目录，一个模块一个 store |
| **命名** | `useXxxStore`（如 `useTimerStore`） |
| **跨组件状态** | 使用 Pinia |
| **组件内状态** | 使用 `ref` / `reactive` |

```typescript
// src/stores/timer.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useTimerStore = defineStore('timer', () => {
  const remainingSeconds = ref(25 * 60)
  const isRunning = ref(false)

  const displayTime = computed(() => {
    const mins = Math.floor(remainingSeconds.value / 60)
    const secs = remainingSeconds.value % 60
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
  })

  function start() {
    isRunning.value = true
  }

  return { remainingSeconds, isRunning, displayTime, start }
})
```

---

## 五、组合式函数（Composables）

| 规范项 | 规则 |
|--------|------|
| **命名** | `use` 前缀 + camelCase（如 `useTimer`、`useUserList`） |
| **目录** | `src/composables/` |
| **文件名** | camelCase（如 `useTimer.ts`） |

```typescript
// src/composables/useTimer.ts
export function useTimer(initialSeconds: number) {
  const remaining = ref(initialSeconds)
  const isRunning = ref(false)
  
  function start() { isRunning.value = true }
  
  return { remaining, isRunning, start }
}
```

---

## 六、API 请求规范

- 统一封装 axios，放在 `src/api/` 目录
- 按模块拆分，放在 `src/api/modules/` 下
- **禁止**在组件中直接写 URL

```typescript
// src/api/index.ts
import axios from 'axios'

const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 10000
})

export default request
```

```typescript
// src/api/modules/user.ts
import request from '@/api'
import type { UserVO, UserListResponse } from '@/types/user'

export const getUserList = (): Promise<{ data: UserListResponse }> => {
  return request.get('/users')
}
```

---

## 七、路由命名规范

| 规范项 | 规则 | 示例 |
|--------|------|------|
| **path** | kebab-case | `/user-profile` |
| **name** | PascalCase（与组件名对应） | `UserProfile` |
| **组件** | 懒加载 | `component: () => import('@/views/UserProfile.vue')` |

```typescript
// src/router/index.ts
const routes = [
  {
    path: '/user-profile',
    name: 'UserProfile',
    component: () => import('@/views/UserProfile.vue')
  }
]
```

---

## 八、样式规范

| 规范项 | 规则 |
|--------|------|
| **作用域** | 组件样式必须加 `scoped` |
| **预处理器** | 使用 LESS / SCSS（按团队约定） |
| **类名** | kebab-case（如 `user-list`） |

### BEM 命名（复杂组件推荐）

```vue
<template>
  <div class="user-card">
    <div class="user-card__header">...</div>
    <div class="user-card__body">
      <div class="user-card__body--active">...</div>
    </div>
  </div>
</template>
```

| 部分 | 说明 |
|------|------|
| `block` | 块（组件根类名） |
| `block__element` | 元素（双下划线） |
| `block--modifier` | 修饰符（双连字符） |

---

## 九、注释规范

```typescript
/**
 * 用户列表组件
 * @description 展示用户列表，支持分页和搜索
 */
```

```vue
<script setup lang="ts">
// TODO: 支持多选
// FIXME: 大量数据时性能问题
</script>
```

---

## 十、代码格式

| 规范项 | 规则 |
|--------|------|
| 缩进 | 2 空格 |
| 行宽 | 100 字符 |
| 分号 | 不使用（按 Prettier 配置） |
| 引号 | 单引号 |
```
