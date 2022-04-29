资料来源：<br/>
[Spring Cloud 系列之 Alibaba Nacos 配置中心](https://mrhelloworld.com/nacos-config/)



### 环境准备

- 配置命名空间

![](large/e6c9d24ely1h1qfb7a51rj22qy0nc0ve.jpg ':size=75%')

- 打开配置列表

![](large/e6c9d24ely1h1qfcbdwg7j22rk0tutdp.jpg ':size=75%')

- 配置

![](large/e6c9d24ely1h1qfcbdwg7j22rk0tutdp.jpg ':size=75%')

主文件配置

```java
server:
  port: 8003
  servlet:
    # 项目contextPath
    context-path: /
  tomcat:
    # tomcat的URI编码
    uri-encoding: UTF-8
    threads:
      # Tomcat启动初始化的线程数，默认值25
      min-spare: 30
      # tomcat最大线程数，默认为200
      max: 200
```

mybatis配置

```java
server:
  port: 8003
  servlet:
    # 项目contextPath
    context-path: /
  tomcat:
    # tomcat的URI编码
    uri-encoding: UTF-8
    threads:
      # Tomcat启动初始化的线程数，默认值25
      min-spare: 30
      # tomcat最大线程数，默认为200
      max: 200
```

### 配置服务

　在系统开发过程中，开发者通常会将一些需要变更的参数、变量等从代码中分离出来独立管理，以独立的配置文件的形式存在。目的是让静态的系统工件或者交付物（如 WAR，JAR 包等）更好地和实际的物理运行环境进行适配。配置管理一般包含在系统部署的过程中，由系统管理员或者运维人员完成。配置变更是调整系统运行时的行为的有效手段。

系统配置的编辑、存储、分发、变更管理、历史版本管理、变更审计等所有与配置相关的活动。

### 配置中心开发

做好了环境配置，可以继承到开发环境中

### 依赖的jar

pom中增加依赖的jar

```java
<!-- spring cloud alibaba nacos config 依赖 -->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
</dependency>
```

### 配置

修改*bootstrap.yml*文件

```java
spring:
  cloud:
    nacos:
      config:
        enabled: true # 如果不想使用 Nacos 进行配置管理，设置为 false 即可
        server-addr: 124.221.127.60:8848 # Nacos Server 地址
        group: DEFAULT_GROUP # 组，默认为 DEFAULT_GROUP
        file-extension: yaml # 配置内容的数据格式，默认为 properties
        namespace: dev # 对应 dev 环境
        # 扩展配置集
        ext-config[0]:
          data-id: application.yml     # 配置集 id
          group: DEFAULT_GROUP # 组，默认为 DEFAULT_GROUP
          refresh: true # 是否支持动态刷新
        ext-config[1]:
          data-id: mybatis.yml # 配置集 id
          group: DEFAULT_GROUP # 组，默认为 DEFAULT_GROUP
          refresh: true # 是否支持动态刷新
```





多文件配置

> - 通过配置 `spring.cloud.nacos.config.ext-config[n].data-id` 来支持多个配置集。
> - 通过配置 `spring.cloud.nacos.config.ext-config[n].group` 来定制配置组。如果未指定，则使用默认组。
> - 通过配置 `spring.cloud.nacos.config.ext-config[n].refresh` 来控制该配置集是否支持配置的动态刷新。默认情况下不支持。

?> 此时可以启动服务器。和本地的配置的效果相同



### 获取配置

演示代码

```java
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RefreshScope
@RestController
public class ConfigController {

    @Value("${my.date}")
    private Integer date;

    @GetMapping("/config")
    public Map<String, Object> getConfig() {
        Map<String, Object> configMap = new HashMap();
        configMap.put("date", date);
        return configMap;
    }
}
```

使用 *Spring* 的 `@Value` 注解来获取配置信息，`${}` 中对应 *Nacos* 配置中心配置内容的 *key*，:后跟默认值。

　　并且通过 Spring Cloud 原生注解 @RefreshScope 实现配置自动更新。

*展示效果*

![](large/Apr-29-2022_13-26-42.gif ':size=50%')



