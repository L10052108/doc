资料来源：
[Spring Cloud 系列之 Alibaba Sentinel 服务哨兵](https://mrhelloworld.com/sentinel/)


上一篇：<br/>
[03_openFeign添加token认证](springCloud/feign&ribbon/03openFeign添加token认证.md)<br/>



## sentinel介绍

![42d.png](large/43697219-3cb4ef3a-9975-11e8-9a9c-73f4f537442d.png ':size=40%')

　　前文中我们提到 Netflix 中多项开源产品已进入维护阶段，不再开发新的版本，就目前来看是没有什么问题的。但是从长远角度出发，我们还是需要考虑是否有可替代产品使用。比如本文中要介绍的 Alibaba Sentinel 就是一款高性能且轻量级的流量控制、熔断降级可替换方案。是一款面向云原生微服务的高可用流控防护组件。

　　Sentinel 官网：https://sentinelguard.io/zh-cn/

　　Github：https://github.com/alibaba/Sentinel

### Sentinel 是什么

随着微服务的流行，服务和服务之间的稳定性变得越来越重要。Sentinel 是面向分布式服务架构的流量控制组件，主要以流量为切入点，从流量控制、熔断降级、系统自适应保护等多个维度来保障微服务的稳定性。

Sentinel 具有以下特征：
> **丰富的应用场景：**Sentinel 承接了阿里巴巴近 10 年的双十一大促流量的核心场景，例如秒杀（即突发流量控制在系统容量可以承受的范围）、消息削峰填谷、集群流量控制、实时熔断下游不可用应用等。<br/>
> **完备的实时监控：**Sentinel 同时提供实时的监控功能。您可以在控制台中看到接入应用的单台机器秒级数据，甚至 500 台以下规模的集群的汇总运行情况。<br/>
> **广泛的开源生态：**Sentinel 提供开箱即用的与其它开源框架/库的整合模块，例如与 Spring Cloud、Dubbo、gRPC 的整合。您只需要引入相应的依赖并进行简单的配置即可快速地接入 Sentinel。<br/>
> **完善的 SPI 扩展点：**Sentinel 提供简单易用、完善的 SPI 扩展接口。您可以通过实现扩展接口来快速地定制逻辑。例如定制规则管理、适配动态数据源等。

Sentinel 主要特征

![/sentinel-features-overview-en.png](large/sentinel-features-overview-en.png ':size=50%')

　　 Sentinel 的关注点在于：

- 多样化的流量控制
- 熔断降级
- 系统负载保护
- 实时监控和控制台

### Sentinel 开源生态

　Sentinel 目前已经针对 Servlet、Dubbo、Spring Boot/Spring Cloud、gRPC 等进行了适配，用户只需引入相应依赖并进行简单配置即可非常方便地享受 Sentinel 的高可用流量防护能力。Sentinel 还为 Service Mesh 提供了集群流量防护的能力。未来 Sentinel 还会对更多常用框架进行适配。

**Sentinel 分为两个部分:**

- 核心库（Java 客户端）不依赖任何框架/库，能够运行于所有 Java 运行时环境，同时对 Dubbo / Spring Cloud 等框架也有较好的支持。
- 控制台（Dashboard）基于 Spring Boot 开发，打包后可以直接运行，不需要额外的 Tomcat 等应用容器。

### Sentinel 的历史

- 2012 年，Sentinel 诞生，主要功能为入口流量控制。
- 2013-2017 年，Sentinel 在阿里巴巴集团内部迅速发展，成为基础技术模块，覆盖了所有的核心场景。Sentinel 也因此积累了大量的流量归整场景以及生产实践。
- 2018 年，Sentinel 开源，并持续演进。
- 2019 年，Sentinel 朝着多语言扩展的方向不断探索，推出 [C++ 原生版本](https://github.com/alibaba/sentinel-cpp)，同时针对 Service Mesh 场景也推出了 [Envoy 集群流量控制支持](https://github.com/alibaba/Sentinel/tree/master/sentinel-cluster/sentinel-cluster-server-envoy-rls)，以解决 Service Mesh 架构下多语言限流的问题。
- 2020 年，推出 [Sentinel Go 版本](https://github.com/alibaba/sentinel-golang)，继续朝着云原生方向演进。

## Sentinel 的使用

### 控制台

　　Sentinel 提供一个轻量级的开源控制台，它提供机器发现以及健康情况管理、监控（单机和集群），规则管理和推送的功能。

　　官网文档：[https://github.com/alibaba/Sentinel/wiki/控制台](https://github.com/alibaba/Sentinel/wiki/%e6%8e%a7%e5%88%b6%e5%8f%b0)

**下载控制台**

您可以从 [release 页面](https://github.com/alibaba/Sentinel/releases) 下载最新版本的控制台 jar 包。

　　您也可以从最新版本的源码自行构建 Sentinel 控制台：

- 下载 [控制台](https://github.com/alibaba/Sentinel/tree/master/sentinel-dashboard) 工程
- 使用以下命令将代码打包成一个 fat jar: `mvn clean package`

　**启动控制台**　
　启动命令如下，本文使用的是目前最新 1.8.4 版本：

!> 注意：启动 Sentinel 控制台需要 JDK 版本为 1.8 及以上版本。

其中 `-Dserver.port=8080` 用于指定 Sentinel 控制台端口为 `8080`。

　　从 Sentinel 1.6.0 起，Sentinel 控制台引入基本的**登录**功能，默认用户名和密码都是 `sentinel`。可以参考 [鉴权模块文档](https://github.com/alibaba/Sentinel/wiki/%e6%8e%a7%e5%88%b6%e5%8f%b0#%e9%89%b4%e6%9d%83) 配置用户名和密码。

**访问控制台**

![image-20200131171829583.png](large/image-20200131171829583.png ':size=40%')

输入默认用户名和密码 `sentinel` 点击登录。至此控制台就安装完成了。

### 客户端接入

父工程添加依赖

~~~~xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-alibaba-dependencies</artifactId>
            <version>2.1.0.RELEASE</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
~~~~

　　子工程需要添加如下依赖：

~~~~xml
<!-- spring cloud alibaba sentinel 依赖 -->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
</dependency>
~~~~

配置文件

　客户端需要启动 Transport 模块来与 Sentinel 控制台进行通信。

　　`order-service-rest` 的 application.yml

~~~~yaml
spring:
  cloud:
    # 配置 Sentinel
    sentinel:
      transport:
        port: 8719
        dashboard: localhost:8080
~~~~

这里的 `spring.cloud.sentinel.transport.port` 端口配置会在应用对应的机器上启动一个 Http Server，该 Server 会与 Sentinel 控制台做交互。比如 Sentinel 控制台添加了一个限流规则，会把规则数据 push 给这个 Http Server 接收，Http Server 再将规则注册到 Sentinel 中。

**初始化客户端**

**确保客户端有访问量**，Sentinel 会在**客户端首次调用的时候**进行初始化，开始向控制台发送心跳包。

简单的理解就是：访问一次客户端，Sentinel 即可完成客户端初始化操作，并持续向控制台发送心跳包。

!> 我们的Sentinel控制台监控的数据**只能看最近5分钟的**

![](large/e6c9d24ely1h2488guuqpj22940u0449.jpg ':size=70%')

![](large/e6c9d24ely1h248g51k3fj21gn0grdht.jpg ':size=70%')




**QPS**

QPS即每秒查询率，是对一个特定的查询服务器在规定时间内所处理流量多少的衡量标准。

**每秒查询率**

因特网上，经常用每秒查询率来衡量域名系统服务器的机器的性能，即为QPS。

对应fetches/sec，即每秒的响应请求数，也即是最大吞吐能力。

**计算关系：**

QPS = 并发量 / 平均响应时间

并发量 = QPS * 平均响应时间


》》》》》》》》》》》》》后面代码出现问题，有时间再继续完善