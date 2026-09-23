import type { UserInfo } from '@/api/system/user/types';
import type { AxiosPromise } from '@/utils/api-types';
import { closePush } from '@/utils/push';
import request from '@/utils/request';
import { sm2Encrypt } from '@/utils/sm2';
import type { LoginData, LoginResult, VerifyCodeResult } from './types';

// pc端固定客户端授权id
const clientId = import.meta.env.VITE_APP_CLIENT_ID;

/**
 * 获取登录密码 SM2 传输加密公钥（HEX 格式，04||x||y）。
 *
 * @returns {string} SM2 公钥
 */
export function getPublicKey(): AxiosPromise<string> {
  return request({
    url: '/auth/public-key',
    headers: {
      isToken: false
    },
    method: 'get',
    timeout: 20000
  });
}

/**
 * @param data {LoginData}
 * @returns
 */
export async function login(data: LoginData): Promise<AxiosPromise<LoginResult>> {
  // 密码经 SM2 公钥加密传输（C1C3C2），与后端 PasswordAuthStrategy 解密逻辑对应
  if (data.password) {
    const publicKeyRes = await getPublicKey();
    const publicKey = publicKeyRes.data;
    if (!publicKey) {
      throw new Error('SM2 公钥获取失败，登录被拦截，请检查后端服务');
    }
    data.password = sm2Encrypt(data.password, publicKey);
  }
  const params = {
    ...data,
    clientId: data.clientId || clientId,
    grantType: data.grantType || 'password'
  };
  return request({
    url: '/auth/login',
    headers: {
      isToken: false,
      isEncrypt: true,
      repeatSubmit: false
    },
    method: 'post',
    data: params
  });
}

// 注册方法
export function register(data: any) {
  const params = {
    ...data,
    clientId: clientId,
    grantType: 'password'
  };
  return request({
    url: '/auth/register',
    headers: {
      isToken: false,
      isEncrypt: true,
      repeatSubmit: false
    },
    method: 'post',
    data: params
  });
}

/**
 * 注销
 */
export function logout() {
  closePush();
  if (
    import.meta.env.VITE_APP_MESSAGE_ENABLED === 'true' &&
    import.meta.env.VITE_APP_MESSAGE_TRANSPORT.toLowerCase() === 'sse'
  ) {
    request({
      url: import.meta.env.VITE_APP_MESSAGE_PATH + '/close',
      method: 'get'
    });
  }
  return request({
    url: '/auth/logout',
    method: 'post'
  });
}

/**
 * 获取验证码
 */
export function getCodeImg(): AxiosPromise<VerifyCodeResult> {
  return request({
    url: '/auth/code',
    headers: {
      isToken: false
    },
    method: 'get',
    timeout: 20000
  });
}

/**
 * 第三方登录
 */
export function callback(data: LoginData): AxiosPromise<any> {
  const LoginData = {
    ...data,
    clientId: clientId,
    grantType: 'social'
  };
  return request({
    url: '/auth/social/callback',
    method: 'post',
    data: LoginData
  });
}

// 获取用户详细信息
export function getInfo(): AxiosPromise<UserInfo> {
  return request({
    url: '/system/user/getInfo',
    method: 'get'
  });
}
