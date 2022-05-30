资料来源：

[上传jar包到内网Nexus私服仓库](https://blog.csdn.net/m0_38001814/article/details/89494078)

[使用 Nexus 搭建私服并上传下载 Jar 包——Maven](http://zyxwmj.top/articles/2019/11/04/1572866911213.html)



## nexus

### 私服的介绍

私服是架设在局域网的一种特殊的远程仓库，用于代理远程仓库及部署第三方构建。有了私服之后，maven会先请求私服库，若私服库存在，则直接下载到本地仓库；反之，maven会先从远程仓库下载至私服，再从私服下载至本地仓库，下面是一个简单的架构图：

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h2qexl02lpj21pq0hemyo.jpg)

Maven私有库，顾名思义是给私人提供依赖仓库。在很多时候，Maven私有库对我们的作用很大。比如在局域网开发时访问不了远程仓库，私人开发的工具包自我版本管理，一些第三方禁止访问的工具包（如Oracle等），购买了一些第三方商用工具包等等。当然，Maven私有库还能在自动化部署起到加速作用，想想看，你在服务器上构建jar包或者war包时要走外网，而Maven私有库是内网的，这速度体验能一样么？

一般比较常用的私服库为Sonatype Nexus

### Nexus3的使用

目前 Nexus 分为 Nexus 2.x 和 Nexus 3.x 两个大版本，它们是并行的关系，目前使用最多，运行最稳定的是 Nexus 2.x，下面我们以 Nexus 2.x 为例，演示 Nexus 的安装过程。

1.  进入 [Nexus 2.x 下载页面](http://help.sonatype.com/repomanager2/download#Download-NexusRepositoryManager2OSS)，根据本机操作系统，选择对应的版本进行下载，如下图所示。

[nexus3](https://help.sonatype.com/repomanager3/product-information/download)<br/>
[nexus2](https://help.sonatype.com/repomanager2/download#Download-NexusRepositoryManager2OSS)



### 命令行上传jar

需要上传的jar

~~~~xml
        <!-- 友盟  -->
        <dependency>
            <groupId>com.alibaba.platform.shared</groupId>
            <artifactId>ocean.client.java.basic</artifactId>
            <version>1.0.1</version>
        </dependency>
~~~~

命令行上传

~~~Shell
mvn deploy:deploy-file -DgroupId=com.alibaba.platform.shared -DartifactId=ocean.client.java.basic -Dversion=1.0.1 -Dpackaging=jar -Dfile=/Users/liuwei/Downloads/umeng.api.client.java.biz.jar -Durl=https://nexus.liuwei.store/repository/maven-releases/ -DrepositoryId=nexus
~~~

**mvn deploy:deploy-file 命令的参数说明**

- -DgroupId=xxxxxx 就相当于 pom 中的 groupId
- -DartifactId=xxxxxx 就相当于 pom 中的 artifactId
- -Dversion=xxxxxx 就相当于 pom 中的版本号 version
- -Dpackaging=xxxxxx 就相当于 pom 中打包方式
- -Dfile=xxxxxx 本地环境
- -Durl=xxxxxx 上传的 url，指定本地仓库
- -DrepositoryId=xxxxxx 对应的是 setting.xml 里边的 id
- -DpomFile=xxxxxx 对应的是 pom 文件路径

查询上传的结果
![](https://tva1.sinaimg.cn/large/e6c9d24ely1h2qf70bu8qj219w0apjsi.jpg)





pom中修改

~~~~java
    <distributionManagement>
        <repository>
            <id>nexus</id>
            <name>Releases</name>
            <url>https://nexus.liuwei.store/nexus/content/repositories/releases/</url>
        </repository>
        <snapshotRepository>
            <id>nexus</id>
            <name>Snapshot</name>
            <url>https://nexus.liuwei.store/nexus/content/repositories/snapshots/</url>
        </snapshotRepository>
    </distributionManagement>
~~~~

