资料来源：<br/>
[IDEA创建新的模块SPRINGBOOT](https://www.cnblogs.com/jthr/p/15504032.html)<br/>
[Spring Cloud 系列之 Netflix Ribbon 负载均衡](https://mrhelloworld.com/ribbon/)<br/>

[为什么我推荐你使用 Redis 实现用户签到系统](https://mrhelloworld.com/redis-sign)

## 创建maven模块

### 选择架构


![1578836785223.png](file/1578836785223.png ':size=70%')

![image-20200213131503574.png](file/image-20200213131503574.png ':size=70%')

![image-20200213131548627.png](file/image-20200213131548627.png ':size=70%')

![image-20200213131647813.png](file/image-20200213131647813.png ':size=70%')

![1578826063614.png](file/1578826063614.png ':size=70%')



### Spring Initializr初始化项目

使用 `Spring Initializr` 初始化 Spring Boot 项目，添加 `Spring Web`，`Spring Data Redis`，`Lombok`。

![img](file/image-20210306151255231.png)

![img](https://mrhelloworld.com/resources/articles/why/redis/image-20210306151255231.png)

![/resources/articles/why/redis/image-20210310172507723.png](https://mrhelloworld.com/resources/articles/why/redis/image-20210310172507723.png)

　顺便再添加 `hutool` 工具集，方便使用日期时间工具类。

~~~~xml
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.5.9</version>
</dependency>
~~~~

### 创建简单项目

- 也可以不选择架构，直接使用简单方法

file— new moduel — maven — 选择jdk

![](file/Apr-28-2022%2018-02-44.gif ':size=80%')

