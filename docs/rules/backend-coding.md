# 后端编码规范（Java）

> 适用于 `backend/` 下所有 `.java` 文件。

---

## 📌 概要总结

**必须遵守的核心规则：**

| 类别 | 核心规则 |
|------|----------|
| **命名** | 类 PascalCase、方法/变量 camelCase、常量 UPPER_SNAKE_CASE |
| **分层** | Controller → Service → Mapper，禁止跨层调用 |
| **注入** | 使用 `@RequiredArgsConstructor` 构造器注入 |
| **日志** | `@Slf4j`，用 `{}` 占位符，禁止 `System.out.println()` |
| **异常** | 统一 `@RestControllerAdvice`，业务异常用 `BusinessException` |
| **工具类** | 优先用 Apache Commons / Hutool，不重复造轮子 |
| **事务** | `@Transactional` 加在 Service 层，Controller 层禁止 |
| **脱敏** | 手机号、身份证、密码必须脱敏后才能打日志 |

**禁止事项：**
- ❌ Controller 直接调 Mapper
- ❌ 字符串拼接 SQL
- ❌ 返回 Entity 给前端
- ❌ 使用魔法值（用枚举替代）
- ❌ 直接抛 `RuntimeException`

---

## 一、命名规范

| 规范项 | 规则 | 示例 |
|--------|------|------|
| **包命名** | 全小写，用点分隔 | `com.openspec.project.module` |
| **类命名** | PascalCase | `UserService`、`OrderController` |
| **方法/变量** | camelCase | `getUserById`、`userName` |
| **常量** | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| **DTO/VO/Entity** | 以类型后缀结尾 | `UserDTO`、`UserVO`、`UserEntity` |
| **工具类** | `XxxUtil` | `StringUtil`、`DateUtil` |
| **枚举** | `XxxEnum` | `UserStatusEnum` |
| **常量类** | `XxxConstants` | `UserConstants` |

---

## 二、分层架构

```
Controller → Service → Mapper → Database
```

| 层 | 职责 | 规范 |
|----|------|------|
| **Controller** | 接收请求、参数校验、返回响应 | `@RestController` + `@RequestMapping("/api/v1/xxx")` |
| **Service** | 业务逻辑、事务控制 | 接口 + 实现类（`XxxService` + `XxxServiceImpl`） |
| **Mapper** | 数据访问 | MyBatis-Plus BaseMapper |
| **Entity** | 数据库实体 | 对应数据库表，**不直接返回前端** |
| **DTO** | 请求对象 | 接收前端参数 |
| **VO** | 响应对象 | 返回给前端 |

**禁止跨层调用**（如 Controller 直接调 Mapper）。

---

## 三、依赖注入

使用**构造器注入**：

```java
@Slf4j
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @GetMapping("/{id}")
    public Result<UserVO> getById(@PathVariable Long id) {
        log.info("查询用户信息, userId={}", id);
        UserVO user = userService.getUserById(id);
        return Result.success(user);
    }
}
```

---

## 四、异常处理

- 使用**全局异常处理器** `@ControllerAdvice`
- 业务异常使用自定义 `BusinessException`
- 禁止直接抛出 `RuntimeException`

### 4.1 业务异常类定义

```java
@Getter
@AllArgsConstructor
public class BusinessException extends RuntimeException {

    private final Integer code;

    public BusinessException(String message) {
        super(message);
        this.code = ResultCode.SYSTEM_ERROR.getCode();
    }

    public BusinessException(Integer code, String message) {
        super(message);
        this.code = code;
    }

    public BusinessException(ResultCode resultCode) {
        super(resultCode.getMessage());
        this.code = resultCode.getCode();
    }
}
```

> 说明：
> - 无参 `code` 的构造器默认取 `SYSTEM_ERROR(500)`，业务语义错误时显式传入业务码（如 `40901`）
> - 与第十一章 `ResultCode` 枚举配合使用，避免魔法值
> - 抛出方式：`throw new BusinessException("用户不存在");` 或 `throw new BusinessException(ResultCode.NOT_FOUND);`

### 4.2 全局异常处理器

```java
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BusinessException.class)
    public Result<Void> handleBusinessException(BusinessException e) {
        log.warn("业务异常: {}, code={}", e.getMessage(), e.getCode());
        return Result.error(e.getCode(), e.getMessage());
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<Void> handleParamException(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldErrors().stream()
                .map(f -> f.getField() + " " + f.getDefaultMessage())
                .collect(Collectors.joining("; "));
        log.warn("参数校验失败: {}", msg);
        return Result.error(400, msg);
    }
    
    @ExceptionHandler(Exception.class)
    public Result<Void> handleException(Exception e) {
        log.error("系统异常", e);
        return Result.error("系统繁忙，请稍后重试");
    }
}
```

> 注意：参数校验失败统一用 `Result.error(400, msg)` 返回业务码 400，与 `api-design.md` 5.4 的约定一致。

---

## 五、日志规范

### 5.1 日志级别使用

| 级别 | 使用场景 |
|------|----------|
| **ERROR** | 系统错误、异常堆栈，需要人工介入 |
| **WARN** | 非预期但可恢复的情况 |
| **INFO** | 关键业务节点：登录、订单创建、定时任务 |
| **DEBUG** | 开发调试信息，生产环境关闭 |

### 5.2 日志写法

- 使用 Lombok `@Slf4j`
- **禁止** `System.out.println()`
- 使用占位符 `{}`，**禁止**字符串拼接

```java
@Slf4j
@Service
public class UserService {
    public UserVO getUserById(Long id) {
        log.info("查询用户信息, userId={}", id);
        UserEntity entity = userMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("用户不存在");
        }
        return userConverter.toVO(entity);
    }
}
```

### 5.3 日志脱敏

敏感信息（手机号、身份证、密码）在日志中必须脱敏：

```java
// 手机号脱敏：138****1234
log.info("用户登录, phone={}", phone.replaceAll("(\\d{3})\\d{4}(\\d{4})", "$1****$2"));
```

---

## 六、工具类规范

### 6.1 工具类约定

| 规范项 | 规则 |
|--------|------|
| **命名** | `XxxUtil`（如 `StringUtil`、`DateUtil`） |
| **目录** | `common/util/` |
| **方法** | 全部 `static`，无状态 |
| **构造器** | 私有化 `private XxxUtil() {}` |
| **禁止** | 不抛受检异常，不依赖 Spring Bean |

```java
public final class StringUtil {
    
    private StringUtil() {}
    
    public static boolean isBlank(String str) {
        return str == null || str.trim().isEmpty();
    }
}
```

### 6.2 优先使用成熟工具库

**不要重复造轮子**，优先使用以下库：

| 场景 | 推荐工具 |
|------|----------|
| 字符串 | Apache Commons Lang3 `StringUtils` |
| 集合 | Apache Commons Collections / Guava |
| 日期时间 | Java 8 `java.time` / Hutool |
| JSON | Jackson / Fastjson2 |
| Bean 拷贝 | MapStruct / Spring `BeanUtils` |
| 加解密 | Hutool `SecureUtil` |

---

## 七、常量与枚举规范

### 7.1 常量类

```java
public final class UserConstants {
    
    private UserConstants() {}
    
    public static final int MAX_LOGIN_ATTEMPTS = 5;
    public static final String DEFAULT_AVATAR = "/img/default.png";
}
```

### 7.2 枚举类

```java
@Getter
@AllArgsConstructor
public enum UserStatusEnum {
    ACTIVE(1, "正常"),
    DISABLED(0, "禁用");
    
    private final Integer code;
    private final String desc;
    
    public static UserStatusEnum of(Integer code) {
        for (UserStatusEnum e : values()) {
            if (e.code.equals(code)) return e;
        }
        return null;
    }
}
```

**禁止使用魔法值**（如 `if (status == 1)`），必须用枚举或常量替代。

---

## 八、DTO/VO/Entity 转换规范

| 规范项 | 规则 |
|--------|------|
| **推荐工具** | MapStruct（编译期生成，性能好） |
| **禁止** | 手动逐字段 `set`（除非字段很少） |
| **禁止** | 直接返回 Entity 给前端 |

```java
@Mapper(componentModel = "spring")
public interface UserConverter {
    UserVO toVO(UserEntity entity);
    UserEntity toEntity(UserDTO dto);
    List<UserVO> toVOList(List<UserEntity> entities);
}
```

---

## 九、事务规范

| 规范项 | 规则 |
|--------|------|
| **位置** | 加在 Service 层，**不加**在 Controller |
| **粒度** | 尽量小，只包住必要的 DB 操作 |
| **回滚** | 默认只回滚 `RuntimeException`，需要时显式 `rollbackFor` |
| **禁止** | 在事务方法里做远程调用 / 发消息 |

```java
@Transactional(rollbackFor = Exception.class)
public void createOrder(OrderDTO dto) {
    // 业务逻辑
}
```

---

## 十、参数校验规范

```java
@PostMapping
public Result<UserVO> create(@Valid @RequestBody UserDTO dto) {
    // ...
}

@Data
public class UserDTO {
    @NotBlank(message = "用户名不能为空")
    @Size(max = 64, message = "用户名长度不能超过 64")
    private String username;
    
    @Email(message = "邮箱格式不正确")
    private String email;
}
```

---

## 十一、通用返回码规范

```java
@Getter
@AllArgsConstructor
public enum ResultCode {
    SUCCESS(200, "操作成功"),
    PARAM_ERROR(400, "参数错误"),
    UNAUTHORIZED(401, "未登录"),
    FORBIDDEN(403, "无权限"),
    NOT_FOUND(404, "资源不存在"),
    SYSTEM_ERROR(500, "系统错误");
    
    private final Integer code;
    private final String message;
}
```

---

## 十二、编码习惯

| 规范项 | 规则 |
|--------|------|
| **Optional** | 用于返回值，**不用于**参数和字段 |
| **Stream** | 简单场景用，复杂逻辑用 for 循环更清晰 |
| **Lambda** | 保持简短，超过 3 行抽成方法 |
| **空集合** | 返回 `Collections.emptyList()` 而非 `null` |
| **字符串比较** | 常量在前：`"OK".equals(status)` |
| **equals** | 使用 `Objects.equals(a, b)` |

---

## 十三、SQL 编写规范

| 规范项 | 规则 |
|--------|------|
| **禁止** | `SELECT *`，必须列出字段 |
| **分页** | 使用 MyBatis-Plus `Page` 对象 |
| **批量** | 使用 `saveBatch` / `updateBatchById` |
| **索引** | WHERE / ORDER BY 字段必须有索引 |
| **禁止** | 在 WHERE 中对字段做函数运算 |

---

## 十四、代码注释

```java
/**
 * 根据用户 ID 查询用户信息
 *
 * @param id 用户 ID
 * @return 用户信息
 * @throws BusinessException 用户不存在时抛出
 */
public UserVO getUserById(Long id) {
    // ...
}
```

---

## 十五、代码格式

| 规范项 | 规则 |
|--------|------|
| 缩进 | 4 空格 |
| 行宽 | 120 字符 |
| 编码 | UTF-8 |
| 换行符 | LF（Unix） |
```
