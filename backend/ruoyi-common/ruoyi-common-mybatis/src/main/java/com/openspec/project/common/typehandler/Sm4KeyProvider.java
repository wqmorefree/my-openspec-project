package com.openspec.project.common.typehandler;

import cn.hutool.core.util.StrUtil;
import com.openspec.project.common.core.exception.ServiceException;

/**
 * SM4 密钥统一提供者。
 *
 * <p>密钥从环境变量 {@code SM4_KEY} 注入（见 security.md 第十章），全应用只允许此处读取一次，
 * 缺失时快速失败并返回明确的业务错误，避免以数据库 SQL 异常形式在首次读写敏感字段时才暴露。</p>
 *
 * @author my-openspec-project
 */
public final class Sm4KeyProvider {

    private static volatile String cachedKey;

    private Sm4KeyProvider() {
    }

    /**
     * 获取 SM4 密钥（首次调用时读取并缓存）。
     *
     * @return SM4 密钥
     */
    public static String getKey() {
        String key = cachedKey;
        if (key == null) {
            synchronized (Sm4KeyProvider.class) {
                key = cachedKey;
                if (key == null) {
                    key = System.getenv("SM4_KEY");
                    if (StrUtil.isBlank(key)) {
                        throw new ServiceException("SM4_KEY 环境变量未配置，敏感字段加解密无法初始化");
                    }
                    cachedKey = key;
                }
            }
        }
        return key;
    }
}
