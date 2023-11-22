资料来源：<br/>
[这是我见过最强的Java版内网穿透神器！](https://www.toutiao.com/article/7296387980644745764/?app=news_article&timestamp=1700618142&use_new_style=1&req_id=20231122095542B804686EF0B7C742BA21&group_id=7296387980644745764&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=b466b2b7-4d80-4d94-9967-ff9ebdb57ba7&source=m_redirect)



## jasypt-spring-boot：Spring Boot 的 Jasypt 集成

**项目介绍**：

- Jasypt(Java Simplified Encryption)是一个简单易用的开源的 Java 加密库，支持多种加密算法，用于简化应用程序中的数据加密和解密操作。
- Jasypt 可以很方便地与 SpringBoot 应用结合，jasypt-spring-boot 就是 Spring Boot 2.x 和 3.0.0 的集成。

**使用效果（这里以加密数据库参数为例展示）**：

引入依赖：

```xml
<dependency>
  <groupId>com.github.ulisesbocchio</groupId>
  <artifactId>jasypt-spring-boot-starter</artifactId>
  <version>3.0.5</version>
</dependency>
```

application.yml中指定加密算法、秘钥、前缀以及后缀等：

```yaml
jasypt:
  encryptor:
    algorithm: PBEWithMD5AndDES  # 配置加密算法
    password: 123456  # 推荐使用JVM参数
    iv-generator-classname: org.jasypt.iv.NoIvGenerator
    property:
      prefix: SUNS(
      suffix: )
```

测试：

```java
@SpringBootTest
class JasyptDemoApplicationTests {

    @Resource
    private StringEncryptor stringEncryptor;

    @Test
    void testGenerate() {
        String url = "jdbc:mysql://localhost:3306/suns";
        String username = "root";
        String password = "123456";

        String urlSecret = this.stringEncryptor.encrypt(url);
        String usernameSecret = this.stringEncryptor.encrypt(username);
        String passwordSecret = this.stringEncryptor.encrypt(password);

        System.out.println("url为：" + url + ",加密后为" + urlSecret);
        System.out.println("username为：" + username + ",加密后为" + usernameSecret);
        System.out.println("password为：" + password + ",加密后为" + passwordSecret);
    }
}
```

获取加密后的结果并填充到application.yml中：

```yaml
spring:
  application:
    name: JASYPT-DEMO
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: SUNS(dBQZmnmLCIlF7jXaKnlJlvxRiRxYUGQp+yx989jFIM7apyLTXMNxQYoNZdowCC6P)  # 使用密文,注意使用IT()包裹起来
    username: SUNS(NLQETcOTnMhO32Ay6/J0wQ==)
    password: SUNS(6KTh0+ejC43aZzVwc8xfxw==)
```

详细使用请参考这篇文章：SpringBoot 使用 Jasypt 对敏感信息进行脱敏处理。

**相关地址**：

- 项目地址：**https://github.com/ulisesbocchio/jasypt-spring-boot**
- Demo 地址：**https://github.com/ulisesbocchio/jasypt-spring-boot-samples/tree/master/jasypt-spring-boot-demo**