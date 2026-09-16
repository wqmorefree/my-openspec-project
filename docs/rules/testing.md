# 测试规范

> 适用于所有测试文件（后端 + 前端）。
>
> **信创合规说明**：本项目涉及信创合规，测试需覆盖国密算法（SM2/SM3/SM4），CI 生成的测试报告可作为合规证据。

---

## 📌 概要总结

**必须遵守的核心规则：**

| 类别 | 核心规则 |
|------|----------|
| **命名** | 后端 `XxxTest` / `XxxIT`，前端 `Xxx.spec.ts` |
| **方法命名** | `should_预期行为_when_条件` |
| **覆盖率** | 国密工具 100%、核心 Service ≥ 90%、Controller ≥ 70% |
| **独立性** | 测试之间不依赖执行顺序 |
| **国密测试** | SM2/SM3/SM4 必须覆盖加解密、签名、边界情况 |
| **提交要求** | 新增功能必须附带测试，CI 必须通过 |
| **CI 门禁** | 覆盖率不达标时，CI 拒绝合并 |

**禁止事项：**
- ❌ 测试之间共享状态
- ❌ 单元测试依赖真实数据库 / Redis
- ❌ 测试方法名用 `test1`、`test2`
- ❌ 提交未通过测试的代码
- ❌ 使用 `[skip ci]` 绕过 CI

---

## 一、测试命名

### 1.1 测试类命名

| 类型 | 命名规则 | 示例 |
|------|----------|------|
| Java 单元测试 | `XxxTest` | `UserServiceTest.java` |
| Java 集成测试 | `XxxIT` | `UserControllerIT.java` |
| Vue 组件测试 | `Xxx.spec.ts` | `UserList.spec.ts` |

### 1.2 测试方法命名

统一格式：

```
should_预期行为_when_条件
```

> **风格说明**：
> - **Java**：方法名用下划线连接，如 `should_returnUser_when_userExists`
> - **前端 TS**：`it()` 描述用自然语言句子（空格分隔），如 `it('should render user list when data is loaded', ...)`
>
> 两种是各自生态的惯例写法，含义相同，均符合本规范。

**示例**：

```java
@Test
void should_returnUser_when_userExists() { }

@Test
void should_throwException_when_userNotFound() { }

@Test
void should_returnEmptyList_when_noUsers() { }
```

```typescript
it('should render user list when data is loaded', () => { })
it('should show loading when fetching data', () => { })
it('should display empty state when list is empty', () => { })
```

---

## 二、测试覆盖率要求

### 2.1 按模块定义

| 模块 | 覆盖率 | 说明 |
|------|--------|------|
| **国密工具类** | **100%** | 安全相关，必须全覆盖 |
| **资产 Service** | ≥ 90% | 核心业务逻辑 |
| **用户 Service** | ≥ 85% | 涉及认证授权 |
| **通用工具类** | 100% | 复用性高 |
| **Controller** | ≥ 70% | 参数校验 + 响应格式 |
| **简单 CRUD** | ≥ 50% | 可适当放宽 |

### 2.2 优先级

1. **国密工具类**（最高优先级，必须全覆盖）
2. **核心业务逻辑**（Service 层）
3. **通用工具函数**
4. **Controller**
5. **简单 CRUD**（可选）

**不测**：Getter/Setter、纯注解类、常量类。

---

## 三、测试分层

| 层级 | 说明 | 工具 | 是否连数据库 |
|------|------|------|-------------|
| **单元测试** | 测试单个方法，Mock 外部依赖 | JUnit 5 + Mockito（后端）/ Vitest（前端） | ❌ 不连 |
| **集成测试** | 测试多个组件协作 | Spring Boot Test | ✅ H2 内存库 |
| **端到端测试** | 测试完整用户流程 | Playwright / Cypress（可选） | ✅ 真实环境 |

**原则**：
- 单元测试**不连数据库**，用 Mock
- 集成测试用 H2 内存数据库
- 端到端测试只覆盖核心流程

---

## 四、后端测试

### 4.1 依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.assertj</groupId>
    <artifactId>assertj-core</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>
```

### 4.2 单元测试示例（Service）

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserMapper userMapper;
    
    @InjectMocks
    private UserServiceImpl userService;
    
    @Test
    void should_returnUser_when_userExists() {
        // given
        String userId = "uuid-123";
        UserEntity entity = new UserEntity();
        entity.setId(userId);
        entity.setUsername("test");
        when(userMapper.selectById(userId)).thenReturn(entity);
        
        // when
        UserVO result = userService.getUserById(userId);
        
        // then
        assertThat(result).isNotNull();
        assertThat(result.getUsername()).isEqualTo("test");
        verify(userMapper, times(1)).selectById(userId);
    }
    
    @Test
    void should_throwException_when_userNotFound() {
        // given
        String userId = "not-exist";
        when(userMapper.selectById(userId)).thenReturn(null);
        
        // when & then
        assertThatThrownBy(() -> userService.getUserById(userId))
            .isInstanceOf(BusinessException.class)
            .hasMessage("用户不存在");
    }
}
```

### 4.3 集成测试示例（Controller）

```java
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerIT {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void should_returnUser_when_getById() throws Exception {
        // given
        UserVO userVO = new UserVO();
        userVO.setId("uuid-123");
        userVO.setUsername("test");
        when(userService.getUserById("uuid-123")).thenReturn(userVO);
        
        // when & then
        mockMvc.perform(get("/api/v1/users/uuid-123"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value(200))
            .andExpect(jsonPath("$.data.username").value("test"));
    }
}
```

### 4.4 测试结构（Given-When-Then）

```java
@Test
void should_xxx_when_yyy() {
    // given：准备数据和 Mock
    // when：执行被测方法
    // then：断言结果
}
```

---

## 五、前端测试

### 5.1 依赖

```bash
npm install -D vitest @vue/test-utils happy-dom @vitest/coverage-v8
```

### 5.2 配置

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'happy-dom',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      thresholds: {
        lines: 70,
        functions: 70,
        branches: 70,
        statements: 70
      }
    }
  }
})
```

### 5.3 组件测试示例

```typescript
// src/components/__tests__/UserList.spec.ts
import { describe, it, expect, vi } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import UserList from '@/components/common/UserList.vue'

// Mock API
vi.mock('@/api/modules/user', () => ({
  getUserList: vi.fn().mockResolvedValue({
    data: {
      list: [{ id: '1', name: 'Alice', email: 'alice@example.com' }],
      total: 1
    }
  })
}))

describe('UserList', () => {
  it('should render user list when data is loaded', async () => {
    const wrapper = mount(UserList)
    await flushPromises()
    
    expect(wrapper.text()).toContain('Alice')
    expect(wrapper.text()).toContain('alice@example.com')
  })
  
  it('should show loading when fetching data', async () => {
    const wrapper = mount(UserList)
    expect(wrapper.find('.loading').exists()).toBe(true)
    await flushPromises()
    expect(wrapper.find('.loading').exists()).toBe(false)
  })
})
```

### 5.4 工具函数测试示例

```typescript
// src/utils/__tests__/format.spec.ts
import { describe, it, expect } from 'vitest'
import { formatDate, maskPhone } from '@/utils/format'

describe('formatDate', () => {
  it('should format ISO datetime to date', () => {
    expect(formatDate('2025-01-01T10:30:00Z')).toBe('2025-01-01')
  })

  it('should return empty string when date is null', () => {
    expect(formatDate(null)).toBe('')
  })
})

describe('maskPhone', () => {
  it('should mask middle digits', () => {
    expect(maskPhone('13812341234')).toBe('138****1234')
  })
})
```

---

## 六、国密算法测试

> 信创合规核心：国密算法必须 100% 覆盖。

### 6.1 SM3 密码哈希测试

```java
class PasswordEncoderTest {
    
    @Test
    void should_hashPasswordConsistently_when_sameInput() {
        String raw = "123456";
        String hash1 = PasswordEncoder.encode(raw);
        String hash2 = PasswordEncoder.encode(raw);
        assertThat(hash1).isEqualTo(hash2);
    }
    
    @Test
    void should_returnTrue_when_passwordMatches() {
        String raw = "123456";
        String encoded = PasswordEncoder.encode(raw);
        assertThat(PasswordEncoder.matches(raw, encoded)).isTrue();
    }
    
    @Test
    void should_returnFalse_when_passwordNotMatches() {
        String encoded = PasswordEncoder.encode("123456");
        assertThat(PasswordEncoder.matches("wrong", encoded)).isFalse();
    }
    
    @Test
    void should_returnDifferentHash_when_differentInput() {
        String hash1 = PasswordEncoder.encode("123456");
        String hash2 = PasswordEncoder.encode("654321");
        assertThat(hash1).isNotEqualTo(hash2);
    }
}
```

### 6.2 SM4 加解密测试（数据库层 kbcrypto）

> SM4 由数据库层 kbcrypto 插件实现（见 `database.md` 第六章），应用层通过 `Sm4TypeHandler` 自动加解密，**不存在独立的 `Sm4Util` 类**。测试即验证「写入加密、读取解密」的完整链路。

```java
@SpringBootTest
class Sm4TypeHandlerTest {

    @Autowired
    private AssetMapper assetMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void should_decryptToOriginal_when_encryptAndDecrypt() {
        // given：明文写入（TypeHandler 自动加密落库）
        AssetEntity entity = buildAsset("abcd-1234-efgh");
        assetMapper.insert(entity);

        // when：读取（TypeHandler 自动解密还原）
        AssetEntity loaded = assetMapper.selectById(entity.getId());

        // then
        assertThat(loaded.getSecretKey()).isEqualTo("abcd-1234-efgh");
    }

    @Test
    void should_storeCipherText_inDatabase() {
        // given
        AssetEntity entity = buildAsset("abcd-1234-efgh");
        assetMapper.insert(entity);

        // when：绕过 ORM 直查数据库密文
        String cipher = jdbcTemplate.queryForObject(
            "SELECT secret_key FROM asset WHERE id = ?",
            String.class, entity.getId());

        // then：数据库中存储的是密文，且非明文
        assertThat(cipher).isNotEqualTo("abcd-1234-efgh");
        assertThat(cipher).isNotBlank();
    }

    @Test
    void should_handleChineseCharacters() {
        // given：中文敏感内容
        AssetEntity entity = buildAsset("资产密钥-测试");
        assetMapper.insert(entity);

        // when & then
        AssetEntity loaded = assetMapper.selectById(entity.getId());
        assertThat(loaded.getSecretKey()).isEqualTo("资产密钥-测试");
    }

    @Test
    void should_handleNull_when_secretKeyIsNull() {
        // given
        AssetEntity entity = buildAsset(null);
        assetMapper.insert(entity);

        // when & then
        AssetEntity loaded = assetMapper.selectById(entity.getId());
        assertThat(loaded.getSecretKey()).isNull();
    }

    private AssetEntity buildAsset(String secretKey) {
        AssetEntity entity = new AssetEntity();
        entity.setAssetName("测试资产-" + UUID.randomUUID());
        entity.setSecretKey(secretKey);
        return entity;
    }
}
```

> 注意：kbcrypto 的 `sm4()` 函数需要测试环境密钥（见 `application-test.yml`）。此测试属于集成测试，测试库需支持 `sm4()` 函数（详见 `database.md` 第七章的 `Sm4TypeHandler` 定义）。

### 6.3 SM2 加解密与签名测试

```java
class Sm2UtilTest {
    
    @Test
    void should_decryptSuccessfully_when_sm2Encrypted() {
        // 模拟前端用公钥加密
        SM2 sm2 = SmUtil.sm2();
        String publicKey = sm2.getPublicKeyBase64();
        String rawPassword = "123456";
        String encrypted = SmUtil.sm2(null, publicKey)
            .encryptBcd(rawPassword, KeyType.PublicKey);
        
        // 后端用私钥解密
        String decrypted = sm2.decryptStr(encrypted, KeyType.PrivateKey);
        assertThat(decrypted).isEqualTo(rawPassword);
    }
    
    @Test
    void should_verifySuccessfully_when_signAndVerify() {
        SM2 sm2 = SmUtil.sm2();
        String data = "asset-123";
        
        // 签名
        String sign = sm2.signHex(HexUtil.encodeHexStr(data.getBytes()));
        
        // 验签
        boolean verified = sm2.verifyHex(
            HexUtil.encodeHexStr(data.getBytes()), 
            sign
        );
        assertThat(verified).isTrue();
    }
    
    @Test
    void should_failVerify_when_dataTampered() {
        SM2 sm2 = SmUtil.sm2();
        String data = "asset-123";
        String sign = sm2.signHex(HexUtil.encodeHexStr(data.getBytes()));
        
        // 篡改数据
        String tampered = "asset-456";
        boolean verified = sm2.verifyHex(
            HexUtil.encodeHexStr(tampered.getBytes()), 
            sign
        );
        assertThat(verified).isFalse();
    }
}
```

### 6.4 前后端加解密兼容测试

```java
@Test
void should_beCompatible_when_frontendEncryptAndBackendDecrypt() {
    // 模拟前端 sm-crypto 的加密结果（C1C3C2 模式）
    String frontendEncrypted = "04a1b2c3..."; // 实际测试时从前端生成
    
    SM2 sm2 = SmUtil.sm2(privateKey, publicKey);
    String decrypted = sm2.decryptStr(frontendEncrypted, KeyType.PrivateKey);
    
    assertThat(decrypted).isEqualTo("123456");
}
```

---

## 七、Mock 规范

### 7.1 后端 Mock

```java
// Mock 返回值
when(userMapper.selectById(anyString())).thenReturn(entity);

// Mock 抛异常
when(userMapper.selectById(anyString()))
    .thenThrow(new BusinessException("用户不存在"));

// 验证调用
verify(userMapper, times(1)).selectById("uuid-123");
verify(userMapper, never()).deleteById(anyString());
```

### 7.2 敏感字段 SM4 测试（数据库层 kbcrypto）

> 按 `database.md` 7.4，敏感字段加解密由 `Sm4TypeHandler` 编排、调用数据库层 kbcrypto 的 `sm4()` 函数，**不存在独立的 `Sm4Util` 类**。单元测试时 Mock，集成测试验证真实链路。

**单元测试时 Mock**：

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private Sm4TypeHandler sm4TypeHandler;
    
    @Test
    void should_encryptPhone_when_createUser() {
        UserEntity user = new UserEntity();
        user.setPhone("13812341234");
        
        // 测试逻辑：持久化后断言落库为密文
        
        verify(userMapper, never()).deleteById(anyString());
    }
}
```

**集成测试时验证完整加解密链路**：

```java
@SpringBootTest
class UserServiceIT {
    
    @Autowired
    private UserMapper userMapper;
    
    @Test
    void should_storeCipherAndReadPlain() {
        UserEntity user = new UserEntity();
        user.setPhone("13812341234");
        userMapper.insert(user);
        
        // 数据库实际存的是 SM4 密文
        UserEntity fromDb = userMapper.selectByPhoneRaw(user.getId());
        assertThat(fromDb.getPhone()).isNotEqualTo("13812341234");
        
        // 经 Sm4TypeHandler 解密后应用层读到明文
        UserEntity decrypted = userMapper.selectById(user.getId());
        assertThat(decrypted.getPhone()).isEqualTo("13812341234");
    }
}
```

> `selectByPhoneRaw` 为绕过 TypeHandler 的查询（例如 XML 中直接映射字段），用于断言落库为密文。

### 7.3 前端 Mock

```typescript
// Mock 模块
vi.mock('@/api/modules/user', () => ({
  getUserList: vi.fn().mockResolvedValue({ data: { list: [] } })
}))

// Mock 函数
const mockFn = vi.fn()
mockFn.mockReturnValue(42)
mockFn.mockResolvedValue({ data: {} })

// 验证调用
expect(mockFn).toHaveBeenCalledTimes(1)
expect(mockFn).toHaveBeenCalledWith('arg')
```

---

## 八、测试数据管理

| 规范项 | 要求 |
|--------|------|
| **独立性** | 每个测试自己准备数据，不依赖其他测试 |
| **可读性** | 用 `given/when/then` 结构 |
| **工厂方法** | 复杂对象用工厂方法创建 |
| **禁止** | 使用生产数据做测试 |

**测试数据工厂**：

```java
public class UserTestDataFactory {
    
    public static UserEntity createUser() {
        UserEntity user = new UserEntity();
        user.setId("uuid-" + UUID.randomUUID());
        user.setUsername("test-user");
        user.setPassword(PasswordEncoder.encode("123456"));
        user.setCreatedTime(LocalDateTime.now());
        return user;
    }
    
    public static UserEntity createUser(String username) {
        UserEntity user = createUser();
        user.setUsername(username);
        return user;
    }
}
```

---

## 九、测试环境规范

### 9.1 测试环境配置

| 测试类型 | 数据库 | 国密密钥 |
|----------|--------|----------|
| **单元测试** | Mock，不连库 | 固定测试密钥 |
| **集成测试** | H2 内存库 | 固定测试密钥 |
| **本地调试** | KingbaseES | 环境变量 |

### 9.2 测试密钥配置

```yaml
# src/test/resources/application-test.yml
crypto:
  sm4:
    key: 0123456789abcdef  # 仅测试用，生产用环境变量
jwt:
  sm2:
    private-key: 测试私钥
    public-key: 测试公钥

spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  flyway:
    enabled: false  # 测试环境用 H2，不使用 Flyway
```

> **重要**：测试密钥**仅用于测试环境**，生产环境必须使用环境变量注入。

---

## 十、测试执行

### 10.1 后端

```bash
mvn test                    # 运行所有测试
mvn test -Dtest=UserServiceTest   # 运行指定测试类
mvn test -Dtest=UserServiceTest#should_returnUser_when_userExists  # 运行指定方法
mvn verify                  # 运行集成测试
mvn clean test jacoco:report  # 运行测试并生成覆盖率报告
```

### 10.2 前端

```bash
npm run test                # 运行所有测试
npm run test -- UserList    # 运行匹配的测试
npm run test:coverage       # 生成覆盖率报告
```

---

## 十一、CI 集成

### 11.1 CI 的作用

CI（持续集成）在每次代码提交后自动执行：

| 步骤 | 说明 |
|------|------|
| **拉取代码** | 从 Git 仓库拉取最新代码 |
| **安装依赖** | `mvn install` / `npm install` |
| **运行测试** | `mvn test` / `npm run test` |
| **代码检查** | Checkstyle / ESLint |
| **生成覆盖率报告** | JaCoCo（后端）/ Istanbul（前端） |
| **构建项目** | `mvn package` / `npm run build` |
| **通知结果** | 失败时通知，阻止合并 |

### 11.2 工具选型

| 工具 | 适用场景 | 本项目选择 |
|------|----------|-----------|
| **GitHub Actions** | GitHub 项目，免费 | ✅ 推荐 |
| **GitLab CI** | GitLab 项目 | — |
| **Jenkins** | 企业内网 | — |
| **Gitee Go** | Gitee 项目 | — |

### 11.3 完整配置示例（GitHub Actions）

在项目根目录创建 `.github/workflows/ci.yml`：

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  # ==================== 后端 ====================
  backend:
    name: Backend Test
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'maven'
      
      - name: Run backend tests
        run: |
          cd backend
          mvn clean test
      
      - name: Generate JaCoCo report
        run: |
          cd backend
          mvn jacoco:report
      
      - name: Check coverage threshold
        run: |
          cd backend
          mvn jacoco:check
      
      - name: Upload coverage report
        uses: actions/upload-artifact@v4
        with:
          name: backend-coverage
          path: backend/target/site/jacoco/
      
      - name: Build backend
        run: |
          cd backend
          mvn package -DskipTests

  # ==================== 前端 ====================
  frontend:
    name: Frontend Test
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js 18
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        run: |
          cd frontend
          npm ci
      
      - name: Run linter
        run: |
          cd frontend
          npm run lint
      
      - name: Run frontend tests
        run: |
          cd frontend
          npm run test
      
      - name: Generate coverage report
        run: |
          cd frontend
          npm run test:coverage
      
      - name: Upload coverage report
        uses: actions/upload-artifact@v4
        with:
          name: frontend-coverage
          path: frontend/coverage/
      
      - name: Build frontend
        run: |
          cd frontend
          npm run build

  # ==================== 汇总 ====================
  ci-status:
    name: CI Status
    runs-on: ubuntu-latest
    needs: [ backend, frontend ]
    
    steps:
      - name: All checks passed
        run: echo "✅ 后端和前端测试全部通过"
```

### 11.4 覆盖率门禁

在 CI 中配置**覆盖率门禁**，不达标则拒绝合并：

**后端（JaCoCo）**：

```xml
<!-- backend/pom.xml -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <executions>
        <execution>
            <id>check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>BUNDLE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**前端（Vitest）**：

```typescript
// vite.config.ts
test: {
  coverage: {
    provider: 'v8',
    thresholds: {
      lines: 70,
      functions: 70,
      branches: 70,
      statements: 70
    }
  }
}
```

### 11.5 信创合规测试报告

CI 生成的报告可作为**信创合规的测试证据**：

| 报告类型 | 生成方式 | 用途 |
|----------|----------|------|
| **测试覆盖率报告** | `mvn jacoco:report` | 证明测试充分性 |
| **测试结果报告** | `mvn surefire-report:report` | 证明测试通过 |
| **国密算法测试记录** | 单独测试类 + 报告 | 证明国密合规 |
| **依赖漏洞扫描** | `mvn dependency-check:check` | 证明依赖安全 |

**报告归档位置**：

```
backend/target/site/jacoco/          # 覆盖率报告
backend/target/surefire-reports/     # 测试结果
frontend/coverage/                   # 前端覆盖率
```

### 11.6 分支保护规则

在 GitHub / GitLab 中配置**分支保护**：

| 规则 | 说明 |
|------|------|
| **必须通过 CI** | 所有 CI 检查通过才允许合并 |
| **必须通过代码审查** | 至少 1 人 Review |
| **禁止直接推送 main** | 只允许通过 PR 合并 |
| **禁止强制推送** | 防止历史被覆盖 |

### 11.7 本地预检（提交前）

在提交代码前，本地先跑一遍：

```bash
# 后端
cd backend
mvn clean test jacoco:report

# 前端
cd frontend
npm run lint
npm run test
npm run build
```

**建议**：在 `.git/hooks/pre-push` 中添加本地检查：

```bash
# .git/hooks/pre-push
#!/bin/bash
echo "🔍 运行本地预检..."
cd backend && mvn test || exit 1
cd ../frontend && npm run test || exit 1
echo "✅ 本地预检通过"
```

### 11.8 CI 最佳实践

| 实践 | 说明 |
|------|------|
| **缓存依赖** | Maven / npm 依赖缓存，加速 CI |
| **并行执行** | 前后端测试并行，节省时间 |
| **失败快速反馈** | 测试失败立即通知 |
| **保留历史报告** | 每次构建的报告都归档 |
| **禁止跳过 CI** | 不允许 `[skip ci]` 提交到主分支 |

---

## 十二、提交前要求

- [ ] 所有新增功能必须附带测试
- [ ] 提交前运行 `mvn test` 和 `npm run test` 全部通过
- [ ] 国密工具类覆盖率 100%
- [ ] 核心 Service 覆盖率 ≥ 90%
- [ ] 工具函数覆盖率 100%
- [ ] 无被 `@Disabled` 或 `it.skip` 跳过的测试（除非有明确原因）
- [ ] 测试方法命名符合 `should_xxx_when_yyy` 规范
- [ ] CI 检查通过


