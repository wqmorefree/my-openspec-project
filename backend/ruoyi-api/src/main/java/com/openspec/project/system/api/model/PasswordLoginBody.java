package com.openspec.project.system.api.model;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.openspec.project.common.core.domain.model.LoginBody;
import org.hibernate.validator.constraints.Length;

/**
 * 密码登录对象
 *
 * @author Lion Li
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class PasswordLoginBody extends LoginBody {

    /**
     * 用户名
     */
    @NotBlank(message = "{user.username.not.blank}")
    @Length(min = 2, max = 30, message = "{user.username.length.valid}")
    private String username;

    /**
     * 用户密码（前端经 SM2 加密后的密文，见 docs/rules/security.md 登录加密章节）
     * 明文长度校验在 PasswordAuthStrategy 解密后进行
     */
    @NotBlank(message = "{user.password.not.blank}")
    private String password;

}
