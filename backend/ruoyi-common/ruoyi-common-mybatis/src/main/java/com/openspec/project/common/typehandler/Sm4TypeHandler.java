package com.openspec.project.common.typehandler;

import cn.hutool.core.util.StrUtil;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HexFormat;

/**
 * 敏感字段 SM4 加解密 TypeHandler（数据库层 kbcrypto 插件实现）
 *
 * <p>加解密均在 KingbaseES 数据库内完成，应用层仅做编排：
 * <ul>
 *   <li>写入：先执行 {@code SELECT sm4(?, ?, 0)} 得到 bytea 密文，再绑定为写参数（flag=0 加密）</li>
 *   <li>读取：实体字段取到的是密文（{@code \x} 前缀 hex 文本），执行
 *       {@code SELECT convert_from(sm4(?, ?, 1), 'UTF8')} 还原明文（flag=1 解密）</li>
 * </ul>
 *
 * <p>密钥从环境变量 {@code SM4_KEY} 注入，禁止硬编码（见 security.md 第十章）。
 *
 * <p><b>金仓驱动兼容</b>：Kingbase8 驱动默认 prepareThreshold=5，同一 SQL 第 6 次执行起
 * 切换服务端预编译（二进制协议），此时 bytea 列的 {@code ResultSet.getString()} 会错误返回
 * {@code byte[].toString()}（形如 {@code [B@1a2b3c}），因此加密结果必须通过
 * {@code getBytes()} 取回并自行做 hex 编码，禁止使用 getString()。
 *
 * @author my-openspec-project
 */
@MappedJdbcTypes(JdbcType.VARCHAR)
public class Sm4TypeHandler extends BaseTypeHandler<String> {

    /** 密文 hex 文本前缀，与金仓 bytea 的 hex 输出格式一致 */
    private static final String HEX_PREFIX = "\\x";

    /**
     * 加密：调用数据库 sm4() 函数（flag=0），bytea 结果经 getBytes() 取回后编码为 \x hex 文本
     */
    private String encrypt(String plain, Connection conn) throws SQLException {
        if (StrUtil.isBlank(plain)) {
            return plain;
        }
        try (PreparedStatement ps = conn.prepareStatement("SELECT sm4(?, ?, 0)")) {
            ps.setString(1, plain);
            ps.setString(2, Sm4KeyProvider.getKey());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    byte[] cipher = rs.getBytes(1);
                    return cipher == null ? plain : HEX_PREFIX + HexFormat.of().formatHex(cipher);
                }
                return plain;
            }
        }
    }

    /**
     * 解密：调用数据库 sm4() 函数（flag=1）并转回 UTF-8 文本
     */
    private String decrypt(String cipher, Connection conn) throws SQLException {
        if (StrUtil.isBlank(cipher)) {
            return cipher;
        }
        try (PreparedStatement ps = conn.prepareStatement("SELECT convert_from(sm4(?, ?, 1), 'UTF8')")) {
            ps.setString(1, cipher);
            ps.setString(2, Sm4KeyProvider.getKey());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : cipher;
            }
        }
    }

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i,
                                    String parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, encrypt(parameter, ps.getConnection()));
    }

    @Override
    public String getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return decrypt(rs.getString(columnName), rs.getStatement().getConnection());
    }

    @Override
    public String getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return decrypt(rs.getString(columnIndex), rs.getStatement().getConnection());
    }

    @Override
    public String getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return decrypt(cs.getString(columnIndex), cs.getConnection());
    }

}
