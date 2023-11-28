资料来源：<br/>
[TLog：轻量级的分布式日志标记追踪神器](https://www.toutiao.com/article/7306155306894033418/?app=news_article&timestamp=1701137034&use_new_style=1&req_id=20231128100353EC464C8689F27DB00993&group_id=7306155306894033418&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=4815c3f4-0d3b-4130-bd15-6b10a2061b09&source=m_redirect)<br/>

# TLog：轻量级的分布式日志标记追踪神器

2023-11-28 07:05·[墨林码农](https://www.toutiao.com/c/user/token/MS4wLjABAAAA66wte15xa4_F02Wbi22T2IN5bWcWG7w_RLszp-slGj0/?source=tuwen_detail)

> 墨林码农专注分享开源项目， 精选开源社区技术干货，分享Github、Gitee上有趣、有价值的项目，一起学习，一起成长。

#  简介

TLog是一个轻量级的分布式日志标记追踪神器，10分钟即可接入，自动对日志打标签完成微服务的链路追踪。支持**log4j**，**log4j2**，**logback**三大日志框架，支持自动检测适配，支持**dubbo**，**dubbox**，**springcloud**三大RPC框架

#  TLog 特性

- 通过对日志打标签完成轻量级微服务日志追踪
- 提供三种接入方式：javaagent完全无侵入接入，字节码一行代码接入，基于配置文件的接入
- 对业务代码无侵入式设计，使用简单，10分钟即可接入
- 支持常见的log4j，log4j2，logback三大日志框架，并提供自动检测，完成适配
- 支持dubbo，dubbox，springcloud三大RPC框架
- 支持Spring Cloud Gateway和Soul网关
- 适配HttpClient和Okhttp的http调用标签传递
- 支持三种任务框架，JDK的TimerTask，Quartz，XXL-JOB
- 支持日志标签的自定义模板的配置，提供多个系统级埋点标签的选择
- 支持异步线程的追踪，包括线程池，多级异步线程等场景
- 几乎无性能损耗，快速稳定，经过压测，损耗在0.01%

# TLog架构图

![img](img/e168541db8e3431ca0c291603acbae4f~noop.image)



# ✨TLog 最新版本

```xml
<dependency>
    <groupId>com.yomahub</groupId>
    <artifactId>tlog-all-spring-boot-starter</artifactId>
    <version>1.5.1</version>
</dependency>
```

# ⚒️TLog 接入方式

TLog提供三大接入方式，兼容各种各样的项目环境，请对照以下表，选择适合你项目的接入方式

|                              | springboot项目自启动 | 非springboot项目自启动 | springboot项目外置容器 | 非springboot项目外置容器 |
| ---------------------------- | -------------------- | ---------------------- | ---------------------- | ------------------------ |
| javaagent方式                | 适合                 | 不适合                 | 不适合                 | 不适合                   |
| 字节码注入方式               | 适合                 | 适合                   | 不适合                 | 不适合                   |
| 日志框架适配器方式（最稳定） | 适合                 | 适合                   | 适合                   | 适合                     |

# Javaagent接入方式

这种方式完全不侵入项目，利用Javaagent在启动时加入jar包，整个过程1分钟就能搞定。 **这种方式要求你的项目必须是springboot项目。**

1、在你的java启动参数中加入：

```shell
-javaagent:/your_path/tlog-agent.jar
```

只需要这一步，就可以把springboot项目快速接入了

2、这里以dubbo+log4j为例，展示下最终日志效果

Consumer代码

![img](img/100b5a914dab4151bbdad8e128ebfcdb~noop.image)



Consumer日志打印：

```
2020-09-16 18:12:56,748 [WARN] [TLOG]重新生成traceId[7161457983341056]  >> com.yomahub.tlog.web.TLogWebInterceptor:39
2020-09-16 18:12:56,763 [INFO] <0><7161457983341056> logback-dubbox-consumer:invoke method sayHello,name=jack  >> com.yomahub.tlog.example.dubbox.controller.DemoController:22
2020-09-16 18:12:56,763 [INFO] <0><7161457983341056> 测试日志aaaa  >> com.yomahub.tlog.example.dubbox.controller.DemoController:23
2020-09-16 18:12:56,763 [INFO] <0><7161457983341056> 测试日志bbbb  >> com.yomahub.tlog.example.dubbox.controller.DemoController:24
```

Provider代码：

![img](img/32440cbe5b664d39b5a922e9cce1d9fb~noop.image)



Provider日志打印：

```
2020-09-16 18:12:56,854 [INFO] <0.1><7161457983341056> logback-dubbox-provider:invoke method sayHello,name=jack  >> com.yomahub.tlog.example.dubbo.service.impl.DemoServiceImpl:15
2020-09-16 18:12:56,854 [INFO] <0.1><7161457983341056> 测试日志cccc  >> com.yomahub.tlog.example.dubbo.service.impl.DemoServiceImpl:16
2020-09-16 18:12:56,854 [INFO] <0.1><7161457983341056> 测试日志dddd  >> com.yomahub.tlog.example.dubbo.service.impl.DemoServiceImpl:17
```

可以看到，经过简单接入后，各个微服务之间每个请求有一个全局唯一的traceId贯穿其中，对所有的日志输出都能生效，这下定位某个请求的日志链就变得轻松了。

提示

其中traceId前面的0，0.1是spanId。

# 字节码注入方式

这种方式适合springboot项目，需要项目依赖
tlog-all-spring-boot-starter包， tlog提供springboot的自动装配功能。只需要在你的启动类中加入一行代码，即可以自动进行探测你项目所使用的Log框架，并进行增强。

```xml
<dependency>
  <groupId>com.yomahub</groupId>
  <artifactId>tlog-all-spring-boot-starter</artifactId>
  <version>1.5.1</version>
</dependency>
```

![img](img/82d41f642bb740ada9adc058f1a4745c~noop.image)



方法对3大日志框架的**异步日志**形式也支持，请放心使用！

注意：

因为这里是用javassist实现，需要在jvm加载对应日志框架的类之前，进行字节码增强。所以这里用static块。但是此方法要注意以下几点：

- 对于Springboot应用而言，启动类中不能加入log定义，否则会不生效。
- 如果你的项目是非springboot，或者你是用tomcat/jboss/jetty等外置容器启动的(springboot的spring-boot-starter-web属于内置容器)，则此方法无法使用
- 对于使用log4j2日志框架的应用来说，此方法如果出现不生效的情况：

请把log4j2配置文件的pattern中的m/msg/message改成tm/tmsg/tmessage

# 日志框架适配器方式

TLog提供了每一种日志框架适配的方式，需要你去修改日志的配置文件，替换相应的类 ，配置方式也很简单，这种方式支持了全特性，为官方推荐方式！

> **Log4j框架适配器参考：**
>
> https://tlog.yomahub.com/pages/a48c8e/
>
> **Log4j2框架适配器参考：**
>
> https://tlog.yomahub.com/pages/8d5538/

下面以接入Logback框架适配器为例介绍下具体操作：

1、同步日志

换掉encoder的实现类或者换掉layout的实现类就可以了

![img](img/348a825eb5bf4e9cb99418fc1873cf4c~noop.image)



2、异步日志

替换掉appender的实现类就可以了

![img](img/14d5804786d14e87a7d2078b619099ef~noop.image)



# 总结

随着微服务盛行，很多公司都把系统按照业务边界拆成了很多微服务，在排错查日志的时候。因为业务链路贯穿着很多微服务节点，导致定位某个请求的日志以及上下游业务的日志会变得有些困难。

**TLog**提供了一种最简单的方式来**解决日志追踪问题**，它不收集日志，也不需要另外的存储空间，它只是自动的对你的日志进行打标签，自动生成**TraceId**贯穿你微服务的一整条链路。并且提供上下游节点信息。非常适合**中小型企业**以及想快速解决日志追踪问题的公司项目使用。

# 结束语

几个简单的字符，就能创造出欢乐，

几个简单的号码，便能写出奇迹。

一个键盘，就能畅游世界，

一根网线，便能知晓天下。

创作不易，感谢大家的支持。后续也会分享更多的干货和技术资讯，您的阅读就是对小编的支持，再次感谢各位老铁！