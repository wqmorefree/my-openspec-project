declare module 'sm-crypto' {
  export interface Sm2Api {
    doEncrypt(msg: string, publicKey: string, cipherMode?: number): string;
    doDecrypt(encryptData: string, privateKey: string, cipherMode?: number): string;
    doSignature(msg: string, privateKey: string, options?: unknown): string;
    doVerifySignature(msg: string, signHex: string, publicKey: string, options?: unknown): boolean;
  }
  export interface Sm3Api {
    digest(msg: string | ArrayBuffer, options?: unknown): string;
  }
  export interface Sm4Api {
    encrypt(inArray: unknown, key: unknown, options?: unknown): unknown;
    decrypt(inArray: unknown, key: unknown, options?: unknown): unknown;
  }
  export const sm2: Sm2Api;
  export const sm3: Sm3Api;
  export const sm4: Sm4Api;
}