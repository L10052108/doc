

资料来源：https://www.cnblogs.com/mrhelloworld/p/nacos1.html 

## 介绍

![img](https://mrhelloworld.com/resources/articles/spring/spring-cloud/nacos/nacos.png)

　Nacos 是 Alibaba 公司推出的开源工具，用于实现分布式系统的服务发现与配置管理。英文全称 Dynamic Naming and Configuration Service，Na 为 Naming/NameServer 即注册中心，co 为 Configuration 即配置中心，Service 是指该注册/配置中心都是以服务为核心。服务（Service）是 Nacos 世界的一等公民。

> 官网是这样说的：一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。

　　Nacos 致力于发现、配置和管理微服务。Nacos 提供了一组简单易用的特性集，可以快速实现动态服务发现、服务配置、服务元数据及流量管理。

　　Nacos 可以更敏捷和容易地构建、交付和管理微服务平台。 Nacos 是构建以“服务”为中心的现代应用架构的服务基础设施。

　　使用 Nacos 简化服务发现、配置管理、服务治理及管理的解决方案，让微服务的发现、管理、共享、组合更加容易。

　　Nacos 官网：<https://nacos.io/zh-cn/>

　　Github：<https://github.com/alibaba/nacos>

##  nacos 安装

- 源码方式
- 安装包方式

### 源码

Nacos 依赖 Java 环境来运行。如果您是从代码开始构建并运行 Nacos，还需要为此配置 Maven 环境，请确保是在以下版本环境中安装使用:

- JDK 1.8+；
- Maven 3.2.x+。

- 执行的命令

```Shell
git clone https://github.com/alibaba/nacos.git
cd nacos/
mvn -Prelease-nacos -Dmaven.test.skip=true clean install -U  
ls -al distribution/target/

// change the $version to your actual path
cd distribution/target/nacos-server-$version/nacos/bin
```

### 安装包

您可以从 <https://github.com/alibaba/nacos/releases> 下载最新稳定版本的 `nacos-server` 包。

## 启动服务

### Linux/Unix/Mac

在 Nacos 的解压目录 `nacos/bin` 目录下启动。

　　启动命令（standalone 代表着单机模式运行，非集群模式）:

`sh startup.sh -m standalone`

　　如果您使用的是 ubuntu 系统，或者运行脚本报错提示符号找不到，可尝试如下运行：

`bash startup.sh -m standalone`

### Windows

启动命令：

`cmd startup.cmd`

或者双击 `startup.cmd` 运行文件。

### 访问

访问：<http://localhost:8848/nacos/> ，默认用户名/密码是 nacos/nacos。

![img](https://mrhelloworld.com/resources/articles/spring/spring-cloud/nacos/image-20200429142118555.png ':size=60%')

## 关闭服务

### Linux/Unix/Mac

```
sh shutdown.sh
```

### Windows

`cmd shutdown.cmd`

或者双击 `shutdown.cmd` 运行文件。

## 配置数据库

　Nacos 在 `0.7` 版本之前，默认使用的是嵌入式数据库 `Apache Derby` 来存储数据（内嵌的数据库会随着 Nacos 一起启动，无需额外安装）；`0.7` 版本及以后，增加了对 `MySQL` 数据源的支持。

### MySQL数据库

　环境要求：MySQL 5.6.5+（生产使用建议至少主备模式，或者采用高可用数据库）；

### 初始化MySQL

创建数据库 `nacos_config`。

　　SQL源文件地址：<https://github.com/alibaba/nacos/blob/master/distribution/conf/nacos-mysql.sql> ，或者在 `nacos-server` 解压目录 `conf` 下，找到 `nacos-mysql.sql` 文件，运行该文件，结果如下：

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0jl31n47cj206r08djrm.jpg)



### application.properties　

修改 `nacos/conf/application.properties` 文件的以下内容。

![img](https://mrhelloworld.com/resources/articles/spring/spring-cloud/nacos/image-20200429181636359.png)

修改后的结果

~~~~Java
#*************** Config Module Related Configurations ***************#
### If user MySQL as datasource:
# 指定数据源为 MySQL
spring.datasource.platform=mysql

### Count of DB:
# 数据库实例数量
db.num=1

# 数据库连接信息，如果是 MySQL 8.0+ 版本需要添加 serverTimezone=Asia/Shanghai
### Connect URL of DB:
db.url.0=jdbc:mysql://127.0.0.1:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&serverTimezone=Asia/Shanghai
db.user=root
db.password=1234
~~~~

- mysql8注意
> 如果你和我一样使用的是 MySQL 8.0+ 版本，那么启动 Nacos 时肯定会报错。莫慌，在 Nacos 安装目录下新建 `plugins/mysql` 文件夹，并放入 8.0+ 版本的 mysql-connector-java-8.0.xx.jar，重启 Nacos 即可，启动时会提示更换了 MySQL 的 driver-class 类。

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0jl4wn4pfj20rb01p0t3.jpg)