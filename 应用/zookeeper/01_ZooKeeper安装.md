资料来源：<br/>
[Spring Cloud 系列之 ZooKeeper 注册中心](https://mrhelloworld.com/zookeeper/#zookeeper-%E4%BB%8B%E7%BB%8D)



## ZooKeeper  安装

### 介绍

![image-20200726172810833.png](img/image-20200726172810833.png)

　Apache ZooKeeper 是一个开放源码的分布式应用程序协调组件，是 Hadoop 和 Hbase 的重要组件。它是一个为分布式应用提供一致性服务的软件，提供的功能包括：配置维护、域名服务、分布式同步、组服务等。

　　在微服务项目开发中 ZooKeeper 主要的角色是当做服务注册中心存在，我们将编写好的服务注册至 ZooKeeper 即可。

**环境准备**

　　ZooKeeper 在 Java 中运行，版本 1.8 或更高（JDK 8 LTS，JDK 11 LTS，JDK 12 - Java 9 和 10 不支持）

**下载**

ZooKeeper 下载地址：

- https://zookeeper.apache.org/releases.html#download
- https://archive.apache.org/dist/zookeeper/

**安装**

　将文件上传至 Linux 服务器。

### 单机版

**创建 zookeeper 目录**

　　创建 zookeeper 目录。

```bash
mkdir -p /usr/local/zookeeper
```

　　将文件解压至该目录。

```bash
tar -zxvf apache-zookeeper-3.6.1-bin.tar.gz -C /usr/local/zookeeper/
```

　　创建数据目录、日志目录。

```bash
mkdir -p /usr/local/zookeeper/apache-zookeeper-3.6.1-bin/data
mkdir -p /usr/local/zookeeper/apache-zookeeper-3.6.1-bin/logs
```

**修改配置文件**

```bash
# 进入配置文件目录
cd /usr/local/zookeeper/apache-zookeeper-3.6.1-bin/conf/
# ZooKeeper 启动默认加载名为 zoo.cfg 的配置文件，复制一份命名为 zoo.cfg
cp zoo_sample.cfg zoo.cfg
# 修改配置文件
vi zoo.cfg
```

　　主要修改数据目录`dataDir`、日志目录`dataLogDir`两处即可，修改结果如下：

```bash
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial 
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between 
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just 
# example sakes.
dataDir=/usr/local/zookeeper/apache-zookeeper-3.6.1-bin/data
dataLogDir=/usr/local/zookeeper/apache-zookeeper-3.6.1-bin/logs
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the 
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

## Metrics Providers
#
# https://prometheus.io Metrics Exporter
#metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
#metricsProvider.httpPort=7000
#metricsProvider.exportJvmInfo=true
```

**启动/关闭**

　　启动。

```bash
cd /usr/local/zookeeper/apache-zookeeper-3.6.1-bin/
bin/zkServer.sh start
---------------------------------------------------------------------------------
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/apache-zookeeper-3.6.1-bin/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
```

　　关闭。

```bash
cd /usr/local/zookeeper/apache-zookeeper-3.6.1-bin/
bin/zkServer.sh stop
---------------------------------------------------------------------------------
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/apache-zookeeper-3.6.1-bin/bin/../conf/zoo.cfg
Stopping zookeeper ... STOPPED
```

