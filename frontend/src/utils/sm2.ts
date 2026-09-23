import { sm2 } from 'sm-crypto';

/**
 * SM2 公钥加密字符串（C1C3C2，无 04 前缀）。
 *
 * 后端 PasswordAuthStrategy 通过 Hutool SM2 私钥解密，且 EncryptUtils.decryptBySm2
 * 会对首字节非 0x04 的密文自动补前缀，因此使用 cipherMode=1 即可互通。
 *
 * @param data 明文
 * @param publicKey HEX 公钥（04||x||y，来自 /auth/public-key）
 */
export function sm2Encrypt(data: string, publicKey: string): string {
  return sm2.doEncrypt(data, publicKey, 1);
}