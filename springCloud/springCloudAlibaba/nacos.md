

资料来源：nacos



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