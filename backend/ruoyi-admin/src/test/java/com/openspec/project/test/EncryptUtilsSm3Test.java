package com.openspec.project.test;

import com.openspec.project.common.encrypt.utils.EncryptUtils;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * SM3 密码哈希单元测试（docs/rules/testing.md 6.1；三次迭代 + 固定常量）
 */
@DisplayName("EncryptUtils SM3 单元测试")
@Tag("local")
@Tag("dev")
@Tag("prod")
public class EncryptUtilsSm3Test {

    @DisplayName("相同输入 -> 哈希结果确定一致")
    @Test
    void should_produceSameHash_when_sameInputEncodedTwice() {
        // given
        String raw = "123456";

        // when
        String hash1 = EncryptUtils.sm3Password(raw);
        String hash2 = EncryptUtils.sm3Password(raw);

        // then
        assertEquals(hash1, hash2);
    }

    @DisplayName("不同输入 -> 哈希结果不同")
    @Test
    void should_produceDifferentHash_when_inputDiffers() {
        // given
        String hash1 = EncryptUtils.sm3Password("123456");
        String hash2 = EncryptUtils.sm3Password("654321");

        // then
        assertNotEquals(hash1, hash2);
    }

    @DisplayName("密码哈希 -> 单项 SM3 三次迭代链")
    @Test
    void should_chainThreeIterations_when_sm3PasswordApplied() {
        // given
        String raw = "123456";

        // when：单项 SM3 迭代三次 vs sm3Password
        String once = EncryptUtils.encryptBySm3(raw);
        String twice = EncryptUtils.encryptBySm3(once);
        String thrice = EncryptUtils.encryptBySm3(twice);

        // then
        assertEquals(thrice, EncryptUtils.sm3Password(raw));
    }

    @DisplayName("密码哈希 -> 64 位十六进制摘要")
    @Test
    void should_return64CharHex_when_sm3PasswordApplied() {
        // when
        String hash = EncryptUtils.sm3Password("123456");

        // then：SM3 摘要 256 位 = 64 个十六进制字符
        assertEquals(64, hash.length());
        assertTrue(hash.matches("[0-9a-f]{64}"));
    }

}
