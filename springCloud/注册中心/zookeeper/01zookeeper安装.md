资料来源：
[zookeeper安装](http://www.cnblogs.com/winner-0715/p/5508500.html)

[Zookeeper数据查看工具ZooInspector](https://blog.csdn.net/q283614346/article/details/84900470)

### zookeeper介绍

Apache ZooKeeper 是一个开放源码的分布式应用程序协调组件，是 Hadoop 和 Hbase 的重要组件。它是一个为分布式应用提供一致性服务的软件，提供的功能包括：配置维护、域名服务、分布式同步、组服务等。

　　在微服务项目开发中 ZooKeeper 主要的角色是当做服务注册中心存在，我们将编写好的服务注册至 ZooKeeper 即可。

![img](https://mrhelloworld.com/resources/articles/spring/spring-cloud/zookeeper/image-20200726172810833.png)

### 安装jdk

Zookeeper使用java语言编写，所以它的运行环境需要java环境的支持

ZooKeeper 在 Java 中运行，版本 1.8 或更高（JDK 8 LTS，JDK 11 LTS，JDK 12 - Java 9 和 10 不支持）

### 安装zookeeper

**下载**

[下载地址](http://mirrors.hust.edu.cn/apache/zookeeper/)访问官网下载

　ZooKeeper 下载地址：

- <https://zookeeper.apache.org/releases.html#download>
- <https://archive.apache.org/dist/zookeeper/>

**解压**

~~~~shell
tar -xvf zookeeper-3.4.8.tar.gz
~~~~

**创建data文件夹**

~~~shell
cd zookeeper/
mkdir data
~~~

**修改配置**

~~~shell
cd conf/
cp zoo_sample.cfg zoo.cfg
~~~

**vim修改zoo.cfg**

修改dataDir的值，路径改成刚才创建的文件路径

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1xn5ey3nqj20r40godie.jpg ':size=60%')

**启动服务**

~~~shell
cd ../bin
~~~

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1xnacyvloj218y0icq8f.jpg ':size=60%')

启动服务器

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1xncm1uldj217y04kab9.jpg ':size=60%')

~~~~shell
./zkServer.sh stop
~~~~

`start`启动

`status`查看状态

`stop` 关闭服务

`restart` 重启服务器

### 客户端连接

进入`bin`目录，执行

~~~shell
./zkCli.sh -server 127.0.0.1:2181
~~~

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1xneg4jzcj22hq0m2h67.jpg ':size=60%')



### ZooInspector

Zookeeper作为常用的集群协调者组件被广泛应用，平常我们可以通过ZkCli.sh客户端查看Zookeeper中的数据，但是并不清晰，因为ZK本身数据是以树型结构存储组织的，今天推荐一个apache实用的界面操作工具ZooInspector。

下载地址：https://issues.apache.org/jira/secure/attachment/12436620/ZooInspector.zip<br/>

解压后进入build文件夹，双击`zookeeper-dev-ZooInspector.jar`

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1xoua9myxj21400u040i.jpg ':size=60%')























