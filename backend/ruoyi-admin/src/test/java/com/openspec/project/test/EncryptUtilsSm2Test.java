package com.openspec.project.test;

import cn.hutool.core.util.HexUtil;
import cn.hutool.crypto.SmUtil;
import cn.hutool.crypto.asymmetric.SM2;
import com.openspec.project.common.encrypt.utils.EncryptUtils;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * SM2 加解密与签名验签单元测试（docs/rules/testing.md 6.3）
 */
@DisplayName("EncryptUtils SM2 单元测试")
@Tag("local")
@Tag("dev")
@Tag("prod")
public class EncryptUtilsSm2Test {

    private static final String RAW = "123456";

    @DisplayName("公钥加密 -> 私钥解密还原明文")
    @Test
    void should_recoverOriginal_when_sm2HexRoundTrip() {
        // given：SM2 密钥对
        Map<String, String> keyMap = EncryptUtils.generateSm2Key();
        String publicKey = keyMap.get(EncryptUtils.PUBLIC_KEY);
        String privateKey = keyMap.get(EncryptUtils.PRIVATE_KEY);

        // when：公钥加密（Hex）后私钥解密
        String cipher = EncryptUtils.encryptBySm2Hex(RAW, publicKey);
        String plain = EncryptUtils.decryptBySm2(cipher, privateKey);

        // then
        assertEquals(RAW, plain);
    }

    @DisplayName("sm-crypto 风格密文（省略 04 前缀）-> 解密自动补全还原")
    @Test
    void should_restoreMissingPointPrefix_when_decryptSmCryptoStyleCipher() {
        // given：密钥对 + 剥离 04 前缀模拟 sm-crypto doEncrypt 输出
        Map<String, String> keyMap = EncryptUtils.generateSm2Key();
        String publicKey = keyMap.get(EncryptUtils.PUBLIC_KEY);
        String privateKey = keyMap.get(EncryptUtils.PRIVATE_KEY);
        String cipher = EncryptUtils.encryptBySm2Hex(RAW, publicKey);
        assertTrue(cipher.startsWith("04"));
        String smCryptoStyle = cipher.substring(2);

        // when：私钥解密
        String plain = EncryptUtils.decryptBySm2(smCryptoStyle, privateKey);

        // then
        assertEquals(RAW, plain);
    }

    @DisplayName("Base64 公钥 -> 转换为 04 开头 130 位 HEX 点")
    @Test
    void should_convertBase64KeyToHexPoint_when_getSm2PublicKeyHex() {
        // given：SM2 密钥对
        String publicKey = EncryptUtils.generateSm2Key().get(EncryptUtils.PUBLIC_KEY);

        // when
        String hex = EncryptUtils.getSm2PublicKeyHex(publicKey);

        // then：非压缩点 04||x||y 共 65 字节 = 130 个十六进制字符
        assertEquals(130, hex.length());
        assertTrue(hex.startsWith("04"));
    }

    @DisplayName("私钥签名 -> 公钥验签通过")
    @Test
    void should_verifySuccessfully_when_signAndVerify() {
        // given：SM2 密钥对与原文
        Map<String, String> keyMap = EncryptUtils.generateSm2Key();
        String publicKey = keyMap.get(EncryptUtils.PUBLIC_KEY);
        String privateKey = keyMap.get(EncryptUtils.PRIVATE_KEY);
        String data = "asset-123";
        String dataHex = HexUtil.encodeHexStr(data.getBytes(StandardCharsets.UTF_8));

        // when：私钥签名后公钥验签
        SM2 sm2 = SmUtil.sm2(privateKey, null);
        String sign = sm2.signHex(dataHex);
        boolean verified = EncryptUtils.verifySm2SignHex(dataHex, sign, publicKey);

        // then
        assertTrue(verified);
    }

    @DisplayName("数据被篡改 -> 验签失败")
    @Test
    void should_failVerify_when_dataTampered() {
        // given：对 asset-123 签名
        Map<String, String> keyMap = EncryptUtils.generateSm2Key();
        String publicKey = keyMap.get(EncryptUtils.PUBLIC_KEY);
        String privateKey = keyMap.get(EncryptUtils.PRIVATE_KEY);
        SM2 sm2 = SmUtil.sm2(privateKey, null);
        String sign = sm2.signHex(HexUtil.encodeHexStr("asset-123".getBytes(StandardCharsets.UTF_8)));

        // when：篡改后原文验签
        boolean verified = EncryptUtils.verifySm2SignHex(
            HexUtil.encodeHexStr("asset-456".getBytes(StandardCharsets.UTF_8)), sign, publicKey);

        // then
        assertFalse(verified);
    }

    @DisplayName("私钥为空 -> 抛出参数异常")
    @Test
    void should_throwIllegalArgument_when_privateKeyBlank() {
        // when & then
        assertThrows(IllegalArgumentException.class,
            () -> EncryptUtils.decryptBySm2("aabbcc", ""));
    }

}
