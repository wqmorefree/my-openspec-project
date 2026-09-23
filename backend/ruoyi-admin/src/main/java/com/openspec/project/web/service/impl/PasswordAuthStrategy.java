package com.openspec.project.web.service.impl;

import cn.dev33.satoken.stp.StpUtil;
import cn.dev33.satoken.stp.parameter.SaLoginParameter;
import cn.hutool.core.util.ObjectUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.openspec.project.common.core.constant.Constants;
import com.openspec.project.common.core.constant.GlobalConstants;
import com.openspec.project.common.core.constant.SystemConstants;
import com.openspec.project.common.core.enums.LoginType;
import com.openspec.project.common.core.exception.ServiceException;
import com.openspec.project.common.core.exception.user.CaptchaException;
import com.openspec.project.common.core.exception.user.CaptchaExpireException;
import com.openspec.project.common.core.exception.user.UserException;
import com.openspec.project.common.core.utils.MessageUtils;
import com.openspec.project.common.core.utils.StringUtils;
import com.openspec.project.common.core.utils.ValidatorUtils;
import com.openspec.project.common.json.utils.JsonUtils;
import com.openspec.project.common.redis.utils.RedisUtils;
import com.openspec.project.common.satoken.utils.LoginHelper;
import com.openspec.project.common.web.config.properties.CaptchaProperties;
import com.openspec.project.system.api.model.LoginUser;
import com.openspec.project.system.api.model.PasswordLoginBody;
import com.openspec.project.system.domain.SysUser;
import com.openspec.project.system.domain.vo.SysClientVo;
import com.openspec.project.system.domain.vo.SysUserVo;
import com.openspec.project.system.mapper.SysUserMapper;
import com.openspec.project.web.domain.vo.LoginVo;
import com.openspec.project.web.service.IAuthStrategy;
import com.openspec.project.web.service.SysLoginService;
import com.openspec.project.common.encrypt.utils.EncryptUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * 密码认证策略
 *
 * @author Michelle.Chung
 */
@Slf4j
@Service("password" + IAuthStrategy.BASE_NAME)
@RequiredArgsConstructor
public class PasswordAuthStrategy implements IAuthStrategy {

    /**
     * 认证失败统一提示（user-auth spec：用户名不存在与密码错误不可区分，不泄露具体原因）
     */
    private static final String LOGIN_FAIL_MESSAGE = "用户名或密码错误";

    private final CaptchaProperties captchaProperties;
    private final SysLoginService loginService;
    private final SysUserMapper userMapper;

    /**
     * 登录密码 SM2 传输加密私钥（Base64）。
     */
    @Value("${security.crypto.sm2.privateKey}")
    private String sm2PrivateKey;

    /**
     * 执行账号密码登录，并按客户端配置生成访问令牌。
     *
     * @param body   登录请求体
     * @param client 当前客户端配置
     * @return 登录结果
     */
    @Override
    public LoginVo login(String body, SysClientVo client) {
        PasswordLoginBody loginBody = JsonUtils.parseObject(body, PasswordLoginBody.class);
        ValidatorUtils.validate(loginBody);
        String username = loginBody.getUsername();
        String password = loginBody.getPassword();
        String code = loginBody.getCode();
        String uuid = loginBody.getUuid();

        boolean captchaEnabled = captchaProperties.getEnable();
        // 验证码开关
        if (captchaEnabled) {
            validateCaptcha(username, code, uuid);
        }
        SysUserVo user = loadUserByUsername(username);
        // 前端密码经 SM2 加密传输，此处先解密还原明文，再按 SM3³ 迭代哈希比对
        String rawPassword = EncryptUtils.decryptBySm2(password, sm2PrivateKey);
        // 明文密码长度校验（密文在 DTO 阶段无法校验）
        if (rawPassword.length() < 5 || rawPassword.length() > 30) {
            throw new ServiceException("用户密码长度必须在5到30个字符之间");
        }
        // 失败计数/锁定仍在服务端执行（checkLogin），但对外统一提示「用户名或密码错误」，
        // 不泄露重试次数/锁定细节，与 user-auth spec「密码错误」场景一致
        try {
            loginService.checkLogin(LoginType.PASSWORD, username, () -> !EncryptUtils.sm3Password(rawPassword).equals(user.getPassword()));
        } catch (UserException e) {
            throw new ServiceException(LOGIN_FAIL_MESSAGE);
        }
        // 此处可根据登录用户的数据不同 自行创建 loginUser
        LoginUser loginUser = loginService.buildLoginUser(user);
        loginUser.setClientKey(client.getClientKey());
        loginUser.setDeviceType(client.getDeviceType());
        SaLoginParameter model = IAuthStrategy.buildLoginParameter(client);
        // 生成token
        LoginHelper.login(loginUser, model);

        LoginVo loginVo = new LoginVo();
        loginVo.setAccessToken(StpUtil.getTokenValue());
        loginVo.setExpireIn(StpUtil.getTokenTimeout());
        loginVo.setClientId(client.getClientId());
        return loginVo;
    }

    /**
     * 校验图形验证码是否有效且匹配。
     *
     * @param username 用户名
     * @param code     用户输入的验证码
     * @param uuid     验证码缓存标识
     */
    private void validateCaptcha(String username, String code, String uuid) {
        String verifyKey = GlobalConstants.CAPTCHA_CODE_KEY + StringUtils.blankToDefault(uuid, "");
        String captcha = RedisUtils.getCacheObject(verifyKey);
        RedisUtils.deleteObject(verifyKey);
        if (captcha == null) {
            loginService.recordLoginInfo(username, Constants.LOGIN_FAIL, MessageUtils.message("user.jcaptcha.expire"));
            throw new CaptchaExpireException();
        }
        if (!StringUtils.equalsIgnoreCase(code, captcha)) {
            loginService.recordLoginInfo(username, Constants.LOGIN_FAIL, MessageUtils.message("user.jcaptcha.error"));
            throw new CaptchaException();
        }
    }

    /**
     * 按用户名加载可登录用户，并校验是否存在或被停用。
     *
     * @param username 用户名
     * @return 用户信息
     */
    private SysUserVo loadUserByUsername(String username) {
        SysUserVo user = userMapper.lambda()
            .eq(SysUser::getUserName, username)
            .voOne();
        if (ObjectUtil.isNull(user)) {
            // 服务端日志保留真实原因；对外与密码错误完全一致，避免账号枚举
            log.info("登录用户：{} 不存在.", username);
            throw new ServiceException(LOGIN_FAIL_MESSAGE);
        } else if (SystemConstants.DISABLE.equals(user.getStatus())) {
            log.info("登录用户：{} 已被停用.", username);
            throw new UserException("user.blocked", username);
        }
        return user;
    }

}
