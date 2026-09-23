package com.openspec.project.test;

import com.openspec.project.common.typehandler.Sm4TypeHandler;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 敏感字段 SM4 TypeHandler 单元测试（明文/密文/Null 三种输入）
 */
@DisplayName("Sm4TypeHandler 单元测试")
@Tag("local")
@Tag("dev")
@Tag("prod")
public class Sm4TypeHandlerTest {

    private static final String C_CRYPT = "\\x1b4246f4b69bbdeeea7c9c1b3967e0e6";
    private static final String C_PLAIN = "13812341234";
    private static final String C_DEC = "\\x3133383132333431323334";

    /**
     * 明文输入：写入时先经 sm4() 加密为密文再绑参。
     * 加密查询返回 bytea，须通过 getBytes() 取回后自行 hex 编码（金仓驱动二进制协议下
     * 对 bytea 调用 getString() 会错误返回 byte[].toString()）。
     */
    @DisplayName("明文输入 -> 写参绑定为 sm4 密文")
    @Test
    void shouldEncryptPlain_whenSetNonNullParameter() throws Exception {
        PreparedStatement ps = mock(PreparedStatement.class);
        Connection conn = mock(Connection.class);
        when(ps.getConnection()).thenReturn(conn);
        ResultSet rs = mock(ResultSet.class);
        when(rs.next()).thenReturn(true);
        when(rs.getBytes(1)).thenReturn(java.util.HexFormat.of().parseHex(
            C_CRYPT.substring(2)));
        PreparedStatement sm4 = mock(PreparedStatement.class);
        when(sm4.executeQuery()).thenReturn(rs);
        when(conn.prepareStatement("SELECT sm4(?, ?, 0)")).thenReturn(sm4);

        new Sm4TypeHandler().setNonNullParameter(ps, 1, C_PLAIN, null);

        verify(ps, times(1)).setString(1, C_CRYPT);
        verify(rs, times(0)).getString(1);
    }

    /**
     * 密文输入：读取时经 convert_from(sm4(?,?,1)) 还原为明文
     */
    @DisplayName("密文输入 -> 读取还原为明文")
    @Test
    void shouldDecryptCipher_whenGetNullableResult() throws Exception {
        ResultSet rs = mock(ResultSet.class);
        when(rs.getString(1)).thenReturn(C_DEC);
        Statement stmt = mock(Statement.class);
        when(rs.getStatement()).thenReturn(stmt);
        Connection conn = mock(Connection.class);
        when(stmt.getConnection()).thenReturn(conn);
        ResultSet inner = mock(ResultSet.class);
        when(inner.next()).thenReturn(true);
        when(inner.getString(1)).thenReturn("13999999999");
        PreparedStatement sm4 = mock(PreparedStatement.class);
        when(sm4.executeQuery()).thenReturn(inner);
        when(conn.prepareStatement("SELECT convert_from(sm4(?, ?, 1), 'UTF8')")).thenReturn(sm4);

        String plain = new Sm4TypeHandler().getNullableResult(rs, 1);

        assertEquals("13999999999", plain);
        verify(sm4, times(1)).executeQuery();
    }

    /**
     * Null/空输入：不调用数据库 sm4()，直接透传
     */
    @DisplayName("Null 输入 -> 不产生数据库调用")
    @Test
    void shouldPassThroughWithoutDb_whenNullInput() throws Exception {
        PreparedStatement ps = mock(PreparedStatement.class);
        Connection conn = mock(Connection.class);
        when(ps.getConnection()).thenReturn(conn);

        new Sm4TypeHandler().setNonNullParameter(ps, 1, "", null);
        new Sm4TypeHandler().setNonNullParameter(ps, 1, null, null);

        verify(conn, times(0)).prepareStatement("SELECT sm4(?, ?, 0)");
        verify(ps, times(1)).setString(1, "");
        verify(ps, times(1)).setString(1, null);
    }

    /**
     * Null 读取：直接返回 null，不抛异常
     */
    @DisplayName("读取 Null -> 返回 null 不抛异常")
    @Test
    void shouldReturnNull_whenColumnIsNull() throws Exception {
        ResultSet rs = mock(ResultSet.class);
        when(rs.getString(1)).thenReturn(null);
        Statement stmt = mock(Statement.class);
        when(rs.getStatement()).thenReturn(stmt);
        Connection conn = mock(Connection.class);
        when(stmt.getConnection()).thenReturn(conn);

        String value = new Sm4TypeHandler().getNullableResult(rs, 1);

        assertNull(value);
    }

    /**
     * CallableStatement 解密分支同样可用
     */
    @DisplayName("CallableStatement 读取 -> 还原明文")
    @Test
    void shouldDecrypt_whenCallableStatement() throws Exception {
        CallableStatement cs = mock(CallableStatement.class);
        when(cs.getString(1)).thenReturn(C_DEC);
        Connection conn = mock(Connection.class);
        when(cs.getConnection()).thenReturn(conn);
        ResultSet inner = mock(ResultSet.class);
        when(inner.next()).thenReturn(true);
        when(inner.getString(1)).thenReturn("13999999999");
        PreparedStatement sm4 = mock(PreparedStatement.class);
        when(sm4.executeQuery()).thenReturn(inner);
        when(conn.prepareStatement("SELECT convert_from(sm4(?, ?, 1), 'UTF8')")).thenReturn(sm4);

        String plain = new Sm4TypeHandler().getNullableResult(cs, 1);

        assertEquals("13999999999", plain);
    }

    /**
     * 数据库异常应向上传播（不吞掉连接/驱动错误）
     */
    @DisplayName("数据库异常 -> 透传 SQLException")
    @Test
    void shouldPropagateSqlException_whenDbFails() throws Exception {
        ResultSet rs = mock(ResultSet.class);
        when(rs.getString(1)).thenReturn(C_PLAIN);
        Statement stmt = mock(Statement.class);
        when(rs.getStatement()).thenReturn(stmt);
        Connection conn = mock(Connection.class);
        when(stmt.getConnection()).thenReturn(conn);
        when(conn.prepareStatement("SELECT convert_from(sm4(?, ?, 1), 'UTF8')"))
            .thenThrow(new java.sql.SQLException("sm4 function missing"));

        Sm4TypeHandler handler = new Sm4TypeHandler();
        assertThrows(java.sql.SQLException.class, () -> handler.getNullableResult(rs, 1));
    }

}