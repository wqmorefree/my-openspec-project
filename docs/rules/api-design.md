# API 接口设计规范

> 适用于所有 Controller 和前后端接口约定。

---

## 📌 概要总结

**必须遵守的核心规则：**

| 类别 | 核心规则 |
|------|----------|
| **响应格式** | 统一 `{ code, message, data }`，禁止返回裸数据 |
| **RESTful** | 用 HTTP 方法表达操作，URL 用复数名词 |
| **分页** | 统一 `pageNum` / `pageSize`，响应含 `list` / `total` |
| **版本** | 通过 URL 前缀 `/api/v1/` 区分 |
| **参数校验** | 使用 `@Valid` + JSR-303 注解 |
| **空数据** | 列表返回 `[]`，对象不存在返回 404 |
| **删除接口** | 统一返回 `200 + Result`，不用 204 |

**禁止事项：**
- ❌ 在 URL 中使用动词（`/getUsers`）
- ❌ 直接返回 Entity 给前端
- ❌ 返回 `null` 作为空数据
- ❌ 在 URL 中暴露自增 ID 规律（用 UUID）

---

## 一、统一响应格式

### 1.1 标准响应结构

```json
{
  "code": 200,
  "message": "操作成功",
  "data": { ... }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `code` | Integer | 业务状态码 |
| `message` | String | 提示信息 |
| `data` | T | 业务数据，可为 `null` |

### 1.2 Java 响应类

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Result<T> {
    private Integer code;
    private String message;
    private T data;
    
    public static <T> Result<T> success(T data) {
        return new Result<>(200, "操作成功", data);
    }
    
    public static <T> Result<T> success() {
        return new Result<>(200, "操作成功", null);
    }
    
    public static <T> Result<T> error(String message) {
        return new Result<>(500, message, null);
    }
    
    public static <T> Result<T> error(Integer code, String message) {
        return new Result<>(code, message, null);
    }
}
```

### 1.3 空数据返回规范

| 场景 | ✅ 正确 | ❌ 错误 |
|------|--------|--------|
| 列表为空 | `data: []` | `data: null` |
| 对象不存在 | `code: 404` | `code: 200, data: null` |
| 删除成功 | `code: 200, data: null` | HTTP 204 |

---

## 二、RESTful API 设计

### 2.1 URL 命名规则

| 规则 | ✅ 正确 | ❌ 错误 |
|------|--------|--------|
| 使用复数名词 | `/users` | `/user`、`/getUser` |
| 使用 kebab-case | `/user-profiles` | `/userProfiles` |
| 不在 URL 中用动词 | `POST /users` | `POST /createUser` |
| 资源 ID 放路径 | `/users/{id}` | `/users?id=123` |

### 2.2 标准操作映射

| 操作 | HTTP 方法 | URL 示例 |
|------|-----------|----------|
| 查询列表 | GET | `/api/v1/users?pageNum=1&pageSize=10` |
| 查询详情 | GET | `/api/v1/users/{id}` |
| 新增 | POST | `/api/v1/users` |
| 全量更新 | PUT | `/api/v1/users/{id}` |
| 部分更新 | PATCH | `/api/v1/users/{id}` |
| 删除 | DELETE | `/api/v1/users/{id}` |

### 2.3 嵌套资源

| 场景 | URL 示例 |
|------|----------|
| 查询某用户的订单 | `/api/v1/users/{userId}/orders` |
| 查询某订单的商品 | `/api/v1/orders/{orderId}/items` |

**嵌套层级不超过 2 层**，超过时用独立资源 + 查询参数。

### 2.4 批量操作

| 操作 | 方法 | URL | 说明 |
|------|------|-----|------|
| 批量创建 | POST | `/api/v1/users/batch` | Body 传数组 |
| 批量删除 | DELETE | `/api/v1/users/batch` | Body 传 ID 数组 |
| 批量更新 | PUT | `/api/v1/users/batch` | Body 传对象数组 |

> **注意**：DELETE 带 Body 在部分 HTTP 客户端中不被支持，如遇到问题可改用 `POST /api/v1/users/batch-delete`。

### 2.5 版本管理

- 通过 URL 前缀区分：`/api/v1/`、`/api/v2/`
- 新版本**不兼容**旧版本时，才升级版本号
- 旧版本接口保留至少 **6 个月**
- 废弃接口加 `@Deprecated` 注解 + 响应头 `Deprecation: true`

---

## 三、分页规范

### 3.1 请求参数

| 参数 | 名称 | 类型 | 说明 |
|------|------|------|------|
| 页码 | `pageNum` | Integer | 从 1 开始 |
| 每页大小 | `pageSize` | Integer | 默认 10，最大 100 |
| 排序字段 | `sortField` | String | 可选，如 `createdTime` |
| 排序方向 | `sortOrder` | String | 可选，`asc` / `desc` |

**示例**：

```
GET /api/v1/users?pageNum=1&pageSize=10&sortField=createdTime&sortOrder=desc
```

### 3.2 分页响应

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "list": [...],
    "total": 100,
    "pageNum": 1,
    "pageSize": 10
  }
}
```

### 3.3 Java 分页类

```java
@Data
public class PageResult<T> {
    private List<T> list;
    private Long total;
    private Integer pageNum;
    private Integer pageSize;
    
    public static <T> PageResult<T> of(List<T> list, Long total, 
                                        Integer pageNum, Integer pageSize) {
        PageResult<T> result = new PageResult<>();
        result.setList(list);
        result.setTotal(total);
        result.setPageNum(pageNum);
        result.setPageSize(pageSize);
        return result;
    }
}
```

---

## 四、HTTP 状态码

> **说明**：HTTP 状态码表达**协议层**结果，业务状态码表达**业务层**结果。本项目统一在响应体里用 `code` 表达业务结果。

| 状态码 | 使用场景 |
|--------|----------|
| 200 | 请求成功（含删除操作） |
| 400 | 请求参数错误 |
| 401 | 未登录 / Token 失效 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

**不使用的状态码**：

| 状态码 | 不使用原因 |
|--------|-----------|
| 201 | 本项目不通过 `Location` 头返回新资源地址 |
| 204 | 与统一响应格式冲突，删除也返回 200 |
| 409 | 冲突信息通过 `code` 表达（如 `code: 40901`） |

---

## 五、请求参数校验

### 5.1 使用 JSR-303 注解

```java
@PostMapping
public Result<UserVO> create(@Valid @RequestBody UserDTO userDTO) {
    // ...
}

@Data
public class UserDTO {
    @NotBlank(message = "用户名不能为空")
    @Size(max = 64, message = "用户名长度不能超过 64")
    private String username;
    
    @NotNull(message = "年龄不能为空")
    @Min(value = 0, message = "年龄不能小于 0")
    @Max(value = 150, message = "年龄不能大于 150")
    private Integer age;
    
    @Email(message = "邮箱格式不正确")
    private String email;
    
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;
}
```

### 5.2 `@Valid` vs `@Validated`

| 注解 | 来源 | 适用场景 |
|------|------|----------|
| `@Valid` | JSR-303 | 简单参数校验（推荐） |
| `@Validated` | Spring | 需要**分组校验**时使用 |

### 5.3 常用校验注解

| 注解 | 用途 |
|------|------|
| `@NotNull` | 不能为 null |
| `@NotBlank` | 字符串不能为 null 或空 |
| `@NotEmpty` | 集合/数组不能为空 |
| `@Size` | 长度范围 |
| `@Min` / `@Max` | 数值范围 |
| `@Email` | 邮箱格式 |
| `@Pattern` | 正则表达式 |

### 5.4 校验失败处理

由全局异常处理器统一捕获 `MethodArgumentNotValidException`，返回 400 + 具体错误信息。

---

## 六、接口文档

| 规范项 | 要求 |
|--------|------|
| **工具** | Swagger / Knife4j |
| **访问地址** | `http://localhost:8080/doc.html` |
| **注解** | Controller 加 `@Api`，方法加 `@ApiOperation`，DTO 加 `@ApiModel` |
| **更新** | 接口变更必须同步更新文档 |

**Maven 依赖**：

```xml
<dependency>
    <groupId>com.github.xiaoymin</groupId>
    <artifactId>knife4j-openapi3-jakarta-spring-boot-starter</artifactId>
    <version>4.4.0</version>
</dependency>
```

详情见 [Knife4j 官方文档](https://doc.xiaominfo.com/)。

```java
@Api(tags = "用户管理")
@RestController
@RequestMapping("/api/v1/users")
public class UserController {
    
    @ApiOperation("根据 ID 查询用户")
    @GetMapping("/{id}")
    public Result<UserVO> getById(
            @ApiParam(value = "用户 ID", required = true) 
            @PathVariable Long id) {
        // ...
    }
}
```

---

## 七、幂等性设计

### 7.1 需要幂等的场景

- 创建表单、保存表单、提交表单
- 任何"提交"类操作

### 7.2 实现方案

| 方案 | 适用场景 |
|------|----------|
| **Token 机制** | 前端先获取 Token，提交时携带，服务端校验后删除 |
| **唯一键约束** | 数据库层面去重 |
| **乐观锁** | 版本号 + CAS |
| **分布式锁** | Redis / Redisson |

### 7.3 禁止依赖前端防重复

前端按钮禁用、防抖只是体验优化，**不能作为幂等性保障**。
```
