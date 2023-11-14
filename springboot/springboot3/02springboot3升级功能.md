资料来源：

[新项目为什么决定用 Spring Boot 3.1 + JDK 17了](https://www.toutiao.com/article/7281057786770145847/?app=news_article&timestamp=1700090165&use_new_style=1&req_id=202311160716059A397971CA044D4CF940&group_id=7281057786770145847&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=79b773ca-aeb9-416d-8199-17774cd742c8&source=m_redirect)

## 一、新特性概述

经过半年的沉淀 Spring Boot 3.1于2023年5月18日正式发布了，带来了许多令人兴奋的新特性和改进。

本篇博客将详细介绍**Spring Boot 3.1的新特性、升级说明以及核心功能的改进**。

![img](img/8ef90fab76bf4fc58f06dd492a173591~noop.image)



同时，2.6.x 版本线已经停止维护了，最新支持版本如下图所示：

![img](img/323d2116a211486185308184d2a5bc29~noop.image)



下图时间轴展示了2.7.x 这也是目前唯一正在维护的 2.x 版本线了，商业支持的版本也只有 2.5.x 了。

![img](img/e7f6698ab8f441fb843e27f7a6047c07~noop.image)



## 二、最低环境要求

**Spring Boot 3.1.0 需要Java 17**，并且兼容 Java 20（包括 Java 20）。 还需要Spring Framework 6.0.9或更高版本。

### 1、为以下构建工具提供显式构建支持：

![img](img/3590bc919ab14efdbc7e0c5baac61343~noop.image)



### 2、Spring Boot 支持以下嵌入式 servlet 容器：

![img](img/181fa0203a1142a8a44457aa7c3861a8~noop.image)



### 3、GraalVM本地镜像：

可以使用 GraalVM 22.3 或更高版本将 Spring Boot 应用程序转换为本机映像。

可以使用原生构建工具Gradle/Maven 插件或native-imageGraalVM 提供的工具来创建图像。您还可以使用原生图像 Paketo buildpack创建原生图像。

### 4、支持以下版本：

![img](img/566832f0ce074dbcabf20eba1ab9c2c7~noop.image)



## 三、核心特性

### 1、Apache HttpClient 4 的依赖管理

> Spring Framework 6 中删除了RestTemplate对Apache HttpClient 4 的支持，取而代之的是 Apache HttpClient 5。Spring Boot 3.0 包括 HttpClient 4 和 5 的依赖管理。继续使用 HttpClient 4 的应用程序在使用时可能会遇到难以诊断的错误。Spring Boot 3.1 移除了 HttpClient 4 的依赖管理，以鼓励用户转而使用 HttpClient 5。

HttpClient 5 是Apache HttpComponents中的一个 HTTP 客户端库，可以用来发送 HTTP 请求和接收 HTTP 响应。下面是 HttpClient 5 的简单使用示例：

### （1）添加 HttpClient 5 的依赖

在 Maven 项目中，可以通过在 pom.xml 文件中添加以下依赖将 HttpClient 5 添加到项目中：

```xml
<dependencies>
    <dependency>
        <groupId>org.apache.httpcomponents</groupId>
        <artifactId>httpclient5</artifactId>
        <version>5.1</version>
    </dependency>
</dependencies>
```

### （2）创建 HttpClient 实例：

```java
HttpClient httpClient = HttpClientBuilder.create().build();
```

### （3）创建 HttpGet 请求：

```java
HttpGet httpGet = new HttpGet("https://www.example.com/");
```

### （4）发送请求并获取响应：

```java
HttpResponse response = httpClient.execute(httpGet);
```

### （5）处理响应:

```java
int statusCode = response.getStatusLine().getStatusCode();
String responseBody = EntityUtils.toString(response.getEntity());
```

其中，response.getStatusLine().getStatusCode() 可以获取响应状态码，EntityUtils.toString(response.getEntity()) 可以获取响应正文。

### （6）完整的代码如下：

```java
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;

public class HttpClientExample {
    public static void main(String[] args) throws Exception {
        HttpClient httpClient = HttpClientBuilder.create().build();
        HttpGet httpGet = new HttpGet("https://www.example.com/");
        HttpResponse response = httpClient.execute(httpGet);
        int statusCode = response.getStatusLine().getStatusCode();
        String responseBody = EntityUtils.toString(response.getEntity());
        System.out.println("Status code: " + statusCode);
        System.out.println("Response body: " + responseBody);
    }
}
```

### 2、Servlet 和过滤器注册

ServletRegistrationBean如果注册失败，和类FilterRegistrationBean现在将失败，IllegalStateException而不是记录警告。如果您需要旧的行为，您应该调用
setIgnoreRegistrationFailure(true)您的注册 bean。

### 3、Git 提交 ID Maven 插件版本属性

用于覆盖 的版本的属性
io.github.git-commit-id:git-commit-id-maven-plugin已更新以与其工件名称保持一致。为了适应这种变化，请
git-commit-id-plugin.version在
git-commit-id-maven-plugin.version您的pom.xml。

### 4、Hibernate 6.2

Spring Boot 3.1 升级到 Hibernate 6.2。请参阅Hibernate 6.2 迁移指南以了解这对您的应用程序有何影响。

![img](img/b7b8cd53b18a4e94befeaf434ff1f57a~noop.image)



### 5、Jackson 2.15

Spring Boot 3.1 升级到 Jackson 2.15。请参阅Jackson wiki以了解这对您的应用程序有何影响。

![img](img/95e128a4b7ac4ad8877c7e7c960754c8~noop.image)



2.15 中的一个显着变化是引入了处理限制。要调整这些约束，请定义
Jackson2ObjectMapperBuilderCustomizer类似于以下内容：

```java
@Bean 
Jackson2ObjectMapperBuilderCustomizer customStreamReadConstraints() { 
    return (builder) -> builder.postConfigurer((objectMapper) -> objectMapper.getFactory() 
        .setStreamReadConstraints(StreamReadConstraints.builder().maxNestingDepth(2000).build())); 
}
```

### 6、Mockito 5

Spring Boot 3.1 升级到 Mockito 5，特别是 5.3。请参阅 Mockito 发行说明以了解 Mockito 5.x 系列中的显着变化。

![img](img/383d02cb3ac243c38f3f994452298f36~noop.image)



### 7、Health Group Membership Validation

现在在启动时验证配置的健康组成员身份。如果包含或排除了不存在的健康指标，启动将失败。可以禁用此验证，恢复早期版本的行为，方法是设置
management.endpoint.health.validate-group-membership为false。

## 四、增强功能

### 1、服务连接

> 引入了新的服务连接概念。此类连接在应用程序中由 bean 表示ConnectionDetails。这些 bean 提供了必要的细节来建立与删除服务的连接，并且 Spring Boot 的自动配置已更新为使用ConnectionDetailsbean。当此类 beans 可用时，它们将优先于任何与连接相关的配置属性。与连接本身无关的配置属性，例如控制连接池大小和行为的属性，仍将被使用。

此低级功能旨在作为其他高级功能的构建块，这些功能通过定义ConnectionDetailsbean 自动配置服务连接。

在没有在其他地方定义适当的 bean 的情况下…ConnectionDetails，Spring Boot 的自动配置已更新为定义自己的基础，由相关配置属性支持。这允许…ConnectionDetails注入而不必处理没有这样的 bean 可用并且需要回退到基于属性的配置的情况。

###  2、在开发时使用测试容器

> 引入了对在开发时使用测试容器管理外部服务的支持。

在开发时使用 Testcontainer 时，可以使用新的 Maven goal( spring-boot:test-run) 和 Gradle task( bootTestRun) 通过测试 main 方法启动应用程序。

Container可以使用新注释导入将 Testcontainers 实例声明为静态字段的类@ImportTestcontainers。

测试容器生命周期的管理得到改进，确保容器先初始化，最后销毁。对可重复使用容器的支持也得到了改进。

从方法贡献属性Container @Bean，DynamicPropertyRegistry现在可以注入。@DynamicPropertySource这与您在测试中使用的方式类似。

**有关详细信息，请参阅下图：**

![img](img/54de1509bc5246c8a3718ddf20dda33c~noop.image)



**测试容器服务连接**

使用 Testcontainers 时，@DynamicPropertySource通常用于根据容器的设置配置应用程序属性：

```java
@Container
static GenericContainer redis = new GenericContainer(DockerImageName.parse("redis").withTag("4.0.14"));

// …

@DynamicPropertySource
static void redisProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.data.redis.host", redis::getHost);
    registry.add("spring.data.redis.port", redis::getFirstMappedPort);
}
```

**现在可以简化为以下内容:**

```java
@Container
@ServiceConnection
static GenericContainer redis = new GenericContainer(DockerImageName.parse("redis").withTag("4.0.14"));
```

此处，@ServiceConnection指示容器应使用 Redis 连接详细信息的来源。
spring-boot-testcontainers提供注释的模块将从@ServiceConnection容器中提取这些细节，同时仍然允许使用 Testcontainers API 来定义和配置它。

下图查看注释当前支持的服务的完整列表@ServiceConnection。

![img](img/701892b88dcc43e8bdabb6899419b4ff~noop.image)



###  3、Docker Compose

> 一个新模块，
> spring-boot-docker-compose提供与 Docker Compose 的集成。当您的应用程序启动时，Docker Compose 集成将在当前工作目录中查找配置文件。支持以下文件：

- compose.yaml
- compose.yml
- docker-compose.yaml
- docker-compose.yml

要使用非标准文件，请设置该
spring.docker.compose.file属性。

默认情况下，配置文件中声明的服务将被启动docker compose up，这些服务的连接详细信息 bean 将被添加到应用程序上下文中，以便可以在没有任何进一步配置的情况下使用这些服务。当应用程序停止时，服务将使用 关闭docker compose down。
spring.docker.compose.lifecycle-management可以使用、
spring.docker.compose.startup.command和配置属性自定义此生命周期管理和用于启动和关闭服务的命令
spring.docker.compose.shutdown.command。

下图展示更多详细信息，包括当前支持的服务列表：

![img](img/8e5fbdc26b79406faca1d8dd3c6c0a67~noop.image)



###  4、SSL 配置

> RestTemplateJava KeyStore 和 PEM 编码证书等 SSL 信任材料现在可以使用属性进行配置，并WebClient以更一致的方式应用于各种类型的连接，例如嵌入式 Web 服务器、数据服务。

**使用 PEM 编码证书配置 SSL示例：**

带有前缀的配置属性spring.ssl.bundle.pem可用于以 PEM 编码文本的形式配置信任材料包。每个包都有一个用户提供的名称，可用于引用该包。

当用于保护嵌入式 Web 服务器时，akeystore通常配置有证书和私钥，如本例所示：

```yaml
spring:
  ssl:
    bundle:
      pem:
        mybundle:
          keystore:
            certificate: "classpath:application.crt"
            private-key: "classpath:application.key"
```

当用于保护嵌入式 Web 服务器时，truststore通常使用服务器证书配置 a，如本例所示：

```yaml
spring:
  ssl:
    bundle:
      pem:
        mybundle:
          truststore:
            certificate: "classpath:server.crt"
```

###  5、Spring授权服务器的自动配置

此版本提供了对Spring Authorization Server项目的支持以及一个新的
spring-boot-starter-oauth2-authorization-server启动器。

**示例：**

如果您
spring-security-oauth2-authorization-server的类路径上有，您可以利用一些自动配置来设置基于 Servlet 的 OAuth2 授权服务器。

您可以在
spring.security.oauth2.authorizationserver.client前缀下注册多个 OAuth2 客户端，如以下示例所示：

```yaml
spring:
  security:
    oauth2:
      authorizationserver:
        client:
          my-client-1:
            registration:
              client-id: "abcd"
              client-secret: "{noop}secret1"
              client-authentication-methods:
                - "client_secret_basic"
              authorization-grant-types:
                - "authorization_code"
                - "refresh_token"
              redirect-uris:
                - "https://my-client-1.com/login/oauth2/code/abcd"
                - "https://my-client-1.com/authorized"
              scopes:
                - "openid"
                - "profile"
                - "email"
                - "phone"
                - "address"
            require-authorization-consent: true
          my-client-2:
            registration:
              client-id: "efgh"
              client-secret: "{noop}secret2"
              client-authentication-methods:
                - "client_secret_jwt"
              authorization-grant-types:
                - "client_credentials"
              scopes:
                - "user.read"
                - "user.write"
            jwk-set-uri: "https://my-client-2.com/jwks"
            token-endpoint-authentication-signing-algorithm: "RS256"
```

> Spring Boot 为 Spring Authorization Server 提供的自动配置，就是为了快速上手而设计的。大多数应用程序都需要定制，并希望定义几个 bean 来覆盖自动配置。

以下组件可以定义为 beans 以覆盖特定于 Spring Authorization Server 的自动配置：

- RegisteredClientRepository
- AuthorizationServerSettings
- SecurityFilterChain
- com.nimbusds.jose.jwk.source.JWKSource<com.nimbusds.jose.proc.SecurityContext>
- JwtDecoder

### 6、Docker镜像构建

#### （1）图像创建日期和时间

Mavenspring-boot:build-image目标和bootBuildImageGradle 任务现在有一个createdDate配置选项，可用于将Created生成的图像元数据中的字段值设置为用户指定的日期或使用now当前日期和时间。

#### （2）图像应用目录

Mavenspring-boot:build-image目标和bootBuildImageGradle 任务现在有一个applicationDirectory配置选项，可用于设置构建器映像中的位置，应用程序内容将上传到该位置以供构建包使用。这也将是应用程序内容在生成的图像中的位置。

## 五、用于 GraphQL 的 Spring

### 1、异常处理

@GraphQlExceptionHandler在控制器中声明的方法，或者@ControllerAdvice现在由 Spring for GraphQL 开箱即用地支持控制器方法调用。此外，Spring Boot通过@ControllerAdvice配置DataFetcher、QueryDslDataFetcher、QueryByExampleDataFetcher、GraphQlSource。

### 2、分页和排序

当 Spring Data 在类路径上时，GraphQL 的 Spring 现在自动配置为支持分页和排序。

### 3、改进的模式类型生成

GraphQlSource现在自动配置了一个
ConnectionTypeDefinitionConfigurer. 它通过查找类型定义名称以“Connection”结尾的字段来生成“Connection”类型Connection Type，如果它们尚不存在，则添加所需的类型定义。

### 4、支持使用 OTLP 导出跟踪

当
io.opentelemetry:opentelemetry-exporter-otlp在类路径上时，OtlpHttpSpanExporter将自动配置。可以使用management.otlp.tracing.*配置属性自定义导出器的配置。

### 5、Wavefront Span 标签定制

如果您正在使用 Wavefront 并且想要为 RED 指标自定义 span 标签，现在有一个名为的新属性
management.wavefront.trace-derived-custom-tag-keys允许您执行此操作。

### 6、文件和控制台的不同日志级别

如果您使用的是 Logback 或 Log4j2，现在可以选择为控制台日志和文件日志设置不同的日志级别。这可以使用配置属性logging.threshold.console和来设置logging.threshold.file。

### 7、最大 HTTP 响应标头大小

如果您使用的是 Tomcat 或 Jetty，您现在可以限制最大 HTTP 响应标头大小。对于 Tomcat，您可以使用该
server.tomcat.max-http-response-header-size属性，而对于 Jetty，您可以使用
server.jetty.max-http-response-header-size. 默认情况下，响应标头仅限于8kb。

### 六、spring Boot 3.1 中的弃用

| **已弃用**                                                   | **取而代之**                                                 |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| spring.kafka.streams.cache-max-size-buffering                | spring.kafka.streams.state-store-cache-max-size              |
| MongoPropertiesClientSettingsBuilderCustomizer               | StandardMongoClientSettingsBuilderCustomizer                 |
| org.springframework.boot.autoconfigure.security.oauth2.client.OAuth2ClientPropertiesRegistrationAdapter | org.springframework.boot.autoconfigure.security.oauth2.client.OAuth2ClientPropertiesMapper |
| org.springframework.boot.web.server.SslStoreProvider         | SSL bundle                                                   |

### 七、依赖升级

Spring Boot 3.1.0 迁移到几个 Spring 项目的新版本：

| **Spring项目**              | **Versions** |
| --------------------------- | ------------ |
| Spring Authorization Server | 1.1.0        |
| Spring Batch                | 5.0.2        |
| Spring Data                 | 2023.0.0     |
| Spring Framework            | 6.0.9        |
| Spring GraphQL              | 1.2.0        |
| Spring HATEOAS              | 2.1.0        |
| Spring Integration          | 6.1.0        |
| Spring Kafka                | 3.0.7        |
| Spring LDAP                 | 3.1.0        |
| Spring Security             | 6.1.0        |
| Spring Session              | 3.1.0        |
| Spring Web Services         | 4.0.4        |

许多第三方依赖项也已更新，其中一些更值得注意的是：

| **第三方依赖**        | **Versions** |
| --------------------- | ------------ |
| Couchbase Java Client | 3.4.6        |
| Elasticsearch Client  | 8.7          |
| Hibernate             | 6.2          |
| GraphQL Java          | 20.1         |
| Jackson               | 2.15.0       |
| Kafka                 | 3.4.0        |
| Kotlin                | 1.8.21       |
| Liquibase             | 4.20         |
| Micrometer            | 1.11.0       |
| Micrometer Tracing    | 1.1.1        |
| Mockito               | 5.3          |
| Native Build Tools    | 0.9.22       |
| Neo4j Java Driver     | 5.8.0        |
| OpenTelemetry         | 1.24.0       |
| Rabbit AMQP Client    | 5.17.0       |
| Reactor BOM           | 2022.0.7     |
| Testcontainers        | 1.18         |
| Undertow              | 2.3.6.Final  |

## 八、其他

1. Spring Kafka ContainerCustomizer bean现在被应用于自动配置的KafkaListenerContainerFactory。
2. 添加了management.otlp.metrics.export.headers属性，以支持向OTLP注册表发送头。
3. JoranConfigurators bean现在可以在AOT处理中使用。
4. spring.kafka.admin添加了额外的close-timeout、operation-timeout、auto-startup和auto-create属性。
5. BatchInterceptor bean现在被应用于自动配置的ConcurrentKafkaListenerContainerFactory。
6. Nomad已添加到已识别的CloudPlaform值列表中。
7. 现在可以为spring.jmx指定registration-policy属性。
8. 添加了withSanitizedValue实用方法到SanitizableData中。
9. 引入了RabbitTemplateCustomizer。这种类型的bean将自定义自动配置的RabbitTemplate。
10. 支持CNB Platform API 0.11。
11. spring-boot-starter-parent将Maven编译器版本设置为配置的Java版本。
12. 通过设置-Dspring-boot.build-info.skip，现在可以跳过build-info目标。
13. Micrometer的OtlpMeterRegistry支持聚合时间配置。
14. Log4j2和Logback支持更多颜色。
15. 添加了对R2DBC MySQL驱动程序（io.asyncer:r2dbc-mysql）的依赖管理。
16. 添加了对R2DBC MariaDB驱动程序（org.mariadb:r2dbc-mariadb）的依赖管理。
17. 使用OpenTelemetry时，用于创建自动配置的SdkTracerProvider的SdkTracerProviderBuilder可以通过定义SdkTracerProviderBuilderCustomizer bean进行自定义。
18. MockServerRestTemplateCustomizer现在通过新的setBufferContent方法支持启用内容缓冲
19. 当自动配置Spring Batch时，可以通过定义BatchConversionServiceCustomizer bean来自定义转换服务。
20. 用于创建JWK Set URI的JTW解码器的构建器可以通过定义JwkSetUriReactiveJwtDecoderBuilderCustomizer或JwkSetUriJwtDecoderBuilderCustomizer bean进行自定义。
21. 恢复了对io.r2dbc:r2dbc-mssql的依赖管理。
22. Logback的根日志级别现在尽早默认为INFO。
23. 默认情况下，Docker Compose现在使用stop而不是down停止。