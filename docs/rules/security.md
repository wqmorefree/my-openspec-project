
# 安全规范（信创合规）

> 适用于所有涉及安全边界的代码（后端 + 前端）。
>
> **加密策略**：本项目为内部管理系统，涉及信创合规，**国密算法为默认**。

---

## 📌 概要总结

**必须遵守的核心规则：**

| 类别 | 核心规则 |
|------|----------|
| **密码存储** | SM3 三次加盐哈希（应用层 Hutool），禁止 MD5/SHA1 |
| **密码传输** | 登录密码 SM2 加密（应用层） |
| **敏感数据存储** | 手机号、身份证、资产密钥 **数据库层 kbcrypto SM4 加密** |
| **Token** | JWT + SM2 签名，httpOnly Cookie 存储 |
| **SQL 注入** | MyBatis 使用 `#{}`，禁止 `${}` |
| **越权防护** | 校验资源归属 |
| **日志脱敏** | 手机号、身份证、密码必须脱敏 |
| **密钥管理** | 环境变量注入，禁止硬编码 |

**禁止事项：**
- ❌ 密码用 MD5/SHA1/BCrypt 存储（必须 SM3）
- ❌ 敏感字段明文存数据库（必须 SM4）
- ❌ 字符串拼接 SQL
- ❌ 密钥硬编码在代码或 `application.yml`
- ❌ 日志打印完整手机号、身份证、密码
- ❌ 使用 `v-html` 渲染用户输入
- ❌ Token 存储在 localStorage

---

## 一、加密策略总览

### 1.1 加密层次

本项目的加密分为**两个层次**：

| 层次 | 工具 | 用途 | 详见 |
|------|------|------|------|
| **应用层** | Hutool（Java） | 密码 SM3 哈希、登录密码 SM2 传输 | 本文档第二、三章 |
| **数据库层** | kbcrypto（KingbaseES） | 敏感字段 SM4 存储加密 | `database.md` 第六章 |

### 1.2 何时用哪个？

| 场景 | 加密层次 | 算法 | 是否可逆 |
|------|----------|------|----------|
| **用户密码存储** | 应用层 | SM3 + 三次加盐 | ❌ 不可逆 |
| **登录密码传输** | 应用层 | SM2 | ✅ 可逆 |
| **JWT 签名** | 应用层 | SM2 | ✅ 可验签 |
| **手机号存储** | 数据库层 | kbcrypto SM4 | ✅ 可逆 |
| **身份证存储** | 数据库层 | kbcrypto SM4 | ✅ 可逆 |
| **资产密钥存储** | 数据库层 | kbcrypto SM4 | ✅ 可逆 |
| **资产 IP** | ❌ 不加密 | — | — |

### 1.3 算法选型

| 场景 | 算法 | 说明 |
|------|------|------|
| **非对称加密/签名** | **SM2** | 用于密码传输、JWT 签名 |
| **哈希/摘要** | **SM3** | 用于密码存储、完整性校验 |
| **对称加密** | **SM4** | 用于敏感字段加密存储 |

---

## 二、密码存储（SM3 加盐）

> **应用层**使用 Hutool 实现 SM3 三次加盐哈希。

### 2.1 存储方案

采用 **SM3 三次加盐哈希**：

```java
public class PasswordEncoder {
    
    private static final String SALT_1 = "固定盐1";
    private static final String SALT_2 = "固定盐2";
    private static final String SALT_3 = "固定盐3";
    
    /**
     * 三次加盐 SM3 哈希
     */
    public static String encode(String password) {
        String hash1 = SmUtil.sm3(password + SALT_1);
        String hash2 = SmUtil.sm3(hash1 + SALT_2);
        return SmUtil.sm3(hash2 + SALT_3);
    }
    
    /**
     * 校验密码
     */
    public static boolean matches(String rawPassword, String encodedPassword) {
        return encode(rawPassword).equals(encodedPassword);
    }
}
```

### 2.2 依赖

```xml
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.8.16</version>
</dependency>
<dependency>
    <groupId>org.bouncycastle</groupId>
    <artifactId>bcprov-jdk18on</artifactId>
    <version>1.78</version>
</dependency>
```

### 2.3 禁止

```java
// ❌ MD5
DigestUtils.md5DigestAsHex(password.getBytes());

// ❌ SHA1
DigestUtils.sha1Hex(password);

// ❌ BCrypt（信创环境不认可国际算法）
new BCryptPasswordEncoder().encode(password);
```

---

## 三、传输加密（SM2）

> **应用层**使用 Hutool 实现 SM2 加解密。

### 3.1 登录密码加密流程

```
前端                          后端
 │                             │
 │── GET /api/v1/auth/public-key ──→  获取 SM2 公钥
 │←────── SM2 公钥 ────────────│
 │                             │
 │  用 SM2 公钥加密密码         │
 │                             │
 │── POST /api/v1/auth/login ──→  用 SM2 私钥解密
 │   { username, encryptedPwd }│
 │←────── Token ───────────────│
```

### 3.2 后端实现

```java
@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {
    
    private static final SM2 SM2_INSTANCE = SmUtil.sm2();
    
    @GetMapping("/public-key")
    public Result<String> getPublicKey() {
        return Result.success(SM2_INSTANCE.getPublicKeyBase64());
    }
    
    @PostMapping("/login")
    public Result<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        // 用私钥解密前端传来的密码
        String rawPassword = SM2_INSTANCE.decryptStr(
            dto.getEncryptedPassword(), 
            KeyType.PrivateKey
        );
        // 校验
        UserEntity user = userService.findByUsername(dto.getUsername());
        if (!PasswordEncoder.matches(rawPassword, user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        // 生成 Token
        String token = jwtService.generateToken(user.getId());
        return Result.success(new LoginVO(token));
    }
}
```

### 3.3 前端实现

**依赖安装**：

```bash
npm install sm-crypto
```

```typescript
// src/api/modules/auth.ts
import { sm2 } from 'sm-crypto'

export const getPublicKey = () => request.get('/auth/public-key')

export const login = async (username: string, password: string) => {
  // 1. 获取公钥
  const { data: publicKey } = await getPublicKey()
  
  // 2. SM2 加密密码
  const encryptedPwd = sm2.doEncrypt(password, publicKey, 1)  // 1 表示 C1C3C2 模式
  
  // 3. 提交登录
  return request.post('/auth/login', {
    username,
    encryptedPassword: encryptedPwd
  })
}
```

### 3.4 注意事项

| 事项 | 说明 |
|------|------|
| **SM2 格式** | 前后端必须统一使用 **C1C3C2** 模式 |
| **公钥获取** | 每次登录前获取，或缓存（有有效期） |
| **HTTPS** | 即使有 SM2 加密，生产环境仍必须 HTTPS |

---

## 四、敏感数据加密（数据库层 SM4）

> **数据库层**使用 KingbaseES 的 kbcrypto 插件实现 SM4 加解密。
>
> **详细说明见 `database.md` 第六章**。

### 4.1 加密范围

| 字段 | 加密方式 | 说明 |
|------|----------|------|
| **密码** | SM3 加盐（应用层） | 不可逆 |
| **手机号** | kbcrypto SM4（数据库层） | 可逆，需解密展示 |
| **身份证** | kbcrypto SM4（数据库层） | 可逆，需解密展示 |
| **资产密钥/许可证** | kbcrypto SM4（数据库层） | 可逆，需解密展示 |
| **资产 IP** | ❌ 不加密 | 按公司要求明文存储 |
| **资产名称/备注** | ❌ 不加密 | 普通文本 |

### 4.2 kbcrypto 插件使用

**加载扩展**：

```sql
CREATE EXTENSION kbcrypto;
```

**SM4 加解密**：

`sm4(data, key, flag)` 函数用于 SM4 加解密：

| 参数 | 说明 |
|------|------|
| `data` | 待加解密的数据 |
| `key` | 密钥（16 字节） |
| `flag` | 加解密标识：**0-加密，1-解密**（官方标准） |

```sql
-- 加密（flag = 0）
SELECT sm4('13812341234', '0123456789ABCDEF', 0);

-- 解密（flag = 1）
SELECT sm4(encrypted_data, '0123456789ABCDEF', 1);
```

**SM3 哈希**：

```sql
SELECT sm3('password');
```

### 4.3 与 `database.md` 的关系

| 内容 | 位置 |
|------|------|
| **加密范围** | 本文档 4.1 |
| **kbcrypto 安装与配置** | `database.md` 第六章 |
| **建表时的加密字段定义** | `database.md` 第四章 |
| **MyBatis-Plus 自动加解密** | `database.md` 第七章 |

---

## 五、Token 认证（JWT + SM2 签名）

### 5.1 JWT 生成（Hutool JWT）

> 使用 Hutool JWT（`hutool-all` 已包含），直接传入 SM2 对象签名，无需额外依赖和 Key 转换。

```java
import cn.hutool.jwt.JWT;
import cn.hutool.jwt.JWTUtil;
import cn.hutool.crypto.SmUtil;
import cn.hutool.crypto.asymmetric.SM2;

@Service
public class JwtService {
    
    private final SM2 sm2;
    private static final long EXPIRE_MS = 2 * 60 * 60 * 1000;  // 2 小时
    
    public JwtService(@Value("${jwt.sm2.private-key}") String privateKey,
                      @Value("${jwt.sm2.public-key}") String publicKey) {
        this.sm2 = SmUtil.sm2(privateKey, publicKey);
    }
    
    public String generateToken(String userId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("exp", System.currentTimeMillis() + EXPIRE_MS);
        
        return JWTUtil.createToken(claims, sm2.getPrivateKey());
    }
    
    public String parseUserId(String token) {
        JWT jwt = JWTUtil.parseToken(token);
        if (!jwt.setKey(sm2.getPublicKey()).verify()) {
            throw new BusinessException("Token 无效或已过期");
        }
        return jwt.getPayload("userId").toString();
    }
}
```

### 5.2 Token 存储

| 规范项 | 要求 |
|--------|------|
| **存储位置** | httpOnly Cookie（推荐） |
| **过期时间** | 2 小时 |
| **刷新机制** | Refresh Token（7 天） |
| **禁止** | localStorage 存储 |

```
Set-Cookie: token=xxx; HttpOnly; Secure; SameSite=Strict; Path=/
```

---

## 六、SQL 注入防护

### 6.1 必须使用 `#{}`

**✅ 正确**：

```java
@Select("SELECT id, username, phone FROM user WHERE username = #{username}")
UserEntity findByUsername(@Param("username") String username);
```

**❌ 错误**：

```java
// 字符串拼接
@Select("SELECT * FROM user WHERE username = '" + username + "'")

// MyBatis ${} 拼接
@Select("SELECT * FROM user WHERE username = '${username}'")
```

### 6.2 动态表名/排序字段

使用 `${}` 时**必须白名单校验**：

```java
private static final Set<String> ALLOWED_SORT_FIELDS = 
    Set.of("created_time", "updated_time", "username");

public List<UserEntity> list(String sortField) {
    if (!ALLOWED_SORT_FIELDS.contains(sortField)) {
        throw new BusinessException("非法的排序字段");
    }
    return userMapper.selectListWithSort(sortField);
}
```

---

## 七、XSS / CSRF 防护

### 7.1 XSS 防护

| 规范项 | 要求 |
|--------|------|
| **优先用 `{{ }}`** | Vue 默认转义 HTML |
| **避免 `v-html`** | 除非内容可信 |
| **必须用 `v-html` 时** | 用 DOMPurify 净化 |

```typescript
import DOMPurify from 'dompurify'
const safeHtml = DOMPurify.sanitize(userInput)
```

### 7.2 CSRF 防护

| 方案 | 说明 |
|------|------|
| **SameSite Cookie** | `SameSite=Strict` |
| **CSRF Token** | 请求头携带 Token |
| **检查 Referer** | 校验请求来源 |

---

## 八、越权访问防护

| 类型 | 说明 | 防护 |
|------|------|------|
| **水平越权** | 用户 A 能访问用户 B 的资产 | 校验资源归属 |
| **垂直越权** | 普通用户能访问管理员接口 | `@PreAuthorize("hasRole('ADMIN')")` |

```java
public AssetVO getAsset(String assetId, String currentUserId) {
    AssetEntity asset = assetMapper.selectById(assetId);
    if (asset == null || !asset.getOwnerId().equals(currentUserId)) {
        throw new BusinessException("资产不存在");
    }
    return converter.toVO(asset);
}
```

---

## 九、日志脱敏

| 字段 | 脱敏规则 | 示例 |
|------|----------|------|
| **手机号** | 保留前 3 后 4 | `138****1234` |
| **身份证** | 保留前 3 后 4 | `110***********1234` |
| **密码** | 完全隐藏 | `******` |
| **资产密钥** | 保留前 4 后 4 | `abcd****wxyz` |

```java
// 手机号脱敏
log.info("用户登录, phone={}", phone.replaceAll("(\\d{3})\\d{4}(\\d{4})", "$1****$2"));

// 身份证脱敏
log.info("用户实名, idCard={}", idCard.replaceAll("(\\d{3})\\d{11}(\\d{4})", "$1***********$2"));
```

---

## 十、密钥管理

### 10.1 密钥清单

| 密钥 | 用途 | 长度要求 |
|------|------|----------|
| **SM4_KEY** | 数据库层敏感字段加解密 | 16 字节 |
| **SM2 私钥** | 应用层 JWT 签名、密码解密 | 64 字符（Hex） |
| **SM2 公钥** | 应用层 JWT 验签、密码加密 | 128 字符（Hex） |
| **数据库密码** | 连接数据库 | 按公司策略 |

### 10.2 配置方式

**❌ 禁止**：

```yaml
crypto:
  sm4:
    key: 0123456789abcdef  # 硬编码
```

**✅ 正确**：

```yaml
crypto:
  sm4:
    key: ${SM4_KEY}  # 环境变量注入

jwt:
  sm2:
    private-key: ${SM2_PRIVATE_KEY}
    public-key: ${SM2_PUBLIC_KEY}
```

```bash
# 环境变量（Linux / Mac）
export SM4_KEY=0123456789abcdef
export SM2_PRIVATE_KEY=xxx
export SM2_PUBLIC_KEY=xxx
```

### 10.3 `.gitignore`

```
.env
.env.local
.env.*.local
application-local.yml
*.pem
*.key
```

---

## 十一、HTTPS 与安全响应头

### 11.1 HTTPS

| 环境 | 要求 |
|------|------|
| **生产环境** | 必须 HTTPS |
| **开发环境** | HTTP 可接受 |

### 11.2 安全响应头

| 响应头 | 值 | 作用 |
|--------|-----|------|
| `Strict-Transport-Security` | `max-age=31536000` | 强制 HTTPS |
| `X-Content-Type-Options` | `nosniff` | 禁止 MIME 嗅探 |
| `X-Frame-Options` | `DENY` | 防点击劫持 |
| `Content-Security-Policy` | `default-src 'self'` | 防 XSS |

---

## 十二、安全自查清单

提交代码前自检：

- [ ] 密码使用 SM3 三次加盐
- [ ] 登录密码前端用 SM2 加密传输
- [ ] 手机号、身份证、资产密钥使用数据库层 kbcrypto SM4 加密
- [ ] JWT 使用 SM2 签名
- [ ] SQL 使用 `#{}` 参数绑定
- [ ] 资源访问校验了归属
- [ ] 日志中敏感信息已脱敏
- [ ] 密钥使用环境变量注入
- [ ] `.env` 已加入 `.gitignore`
- [ ] 前端未使用 `v-html` 渲染用户输入
- [ ] Token 存储在 httpOnly Cookie
- [ ] 生产环境启用 HTTPS