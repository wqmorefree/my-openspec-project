package com.openspec.project.config;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.flywaydb.core.Flyway;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;

/**
 * Flyway 启动迁移（显式装配，不依赖 Spring Boot 自带的 FlywayAutoConfiguration ——
 * Spring Boot 4 已移除该类，参见 docs/rules/database.md 第五章）。
 *
 * 与业务数据源解耦：使用 PostgreSQL 驱动形态连接金仓（jdbc:postgresql://...），
 * 迁移在最高优先级 ApplicationRunner 中执行，确保任何业务数据查询（如 OSS 配置、
 * 系统参数初始化等 ApplicationRunner）之前表已就绪。
 */
@Configuration
public class FlywayConfig {

    private static final Log log = LogFactory.getLog(FlywayConfig.class);

    @Value("${spring.flyway.url}")
    private String flywayUrl;

    @Value("${spring.flyway.user}")
    private String flywayUser;

    @Value("${spring.flyway.password}")
    private String flywayPassword;

    @Value("${spring.flyway.locations:classpath:db/migration}")
    private String flywayLocations;

    /**
     * 由 flyway-core 纯 API 构造；url/user/password 来自应用 spring.flyway.* 配置。
     */
    @Bean(initMethod = "migrate")
    public Flyway flyway() {
        return Flyway.configure()
            .dataSource(flywayUrl, flywayUser, flywayPassword)
            .locations(flywayLocations)
            .baselineOnMigrate(true)
            .cleanDisabled(true)
            .load();
    }

    @Bean
    @Order(Ordered.HIGHEST_PRECEDENCE)
    public ApplicationRunner flywayMigrationRunner() {
        return new ApplicationRunner() {
            @Override
            public void run(ApplicationArguments args) throws Exception {
                // Flyway 12.4 migrate() 在 bean initMethod 已执行；此处仅打日志占位。
                log.info("Flyway 迁移已完成（spring.flyway.url=" + flywayUrl + "）");
            }
        };
    }
}
