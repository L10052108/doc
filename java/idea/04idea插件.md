资料来源：<br/>
[这款 IDEA 插件太好用了，堪称日志管理神器！](https://mp.weixin.qq.com/s/pfa5mJmAETJoxwdxIqBpXA)<br/>
[Idea热加载插件JRebel激活及使用教程](https://blog.csdn.net/qq_42263280/article/details/128888312)<br/>
[IntelliJ IDEA好用插件推荐之（一）：Grep Console](https://blog.csdn.net/xutong_123/article/details/128311026)<br/>
[IDEA 插件推荐](https://blog.csdn.net/objectness/article/details/129246104)

## idea插件

### mybatis 接口和xml 关联

![image-20230815164621406](img/image-20230815164621406.png)

使用效果

![2023-08-15-16-55-59](img/2023-08-15-16-55-59.gif)

### mybatis 日志

![image-20230606095857494](img\image-20230606095857494.png)

Installed安装之后重启，点击上方的Tools就能看到

![20200710155628413](img\20200710155628413.png)

![20200710155818265](img\20200710155818265.png)

### JRebel

在 Java 开发领域，热部署一直是一个难以解决的问题，目前的 Java 虚拟机只能实现方法体的修改热部署，例如使用devtool来实现热部署，但是在功能上它也有所限制，如果新增方法或者修改方法参数后，热部署是不生效的。因此对于整个类的结构修改，仍然需要重启虚拟机，对类重新加载才能完成更新操作。对于某些大型的应用来说，每次的重启都需要花费大量的时间成本。

因此，在这里为大家带来一款Idea集成的热加载插件-JRbel。但是这个插件是需要收费的，故在这里为大家带来激活使用的详细教程，手把手教学一波。亲测可用！

#### Jrbel插件下载
首先在Idea中找到setting->plugins，在MarketPlace中搜索该插件。

![dc783a4dde02e3c0096b1ab4924483c6](img\dc783a4dde02e3c0096b1ab4924483c6.png)

点击“应用”后，按要求重启一下Idea，使下载的Jrebel插件生效。

这个时候在Idea主界面侧边栏上就有Jrebel的安装指南出现了。

![107140336774d568ae41252ee4d7b31c](img\107140336774d568ae41252ee4d7b31c.png)

然后我们根据Jrebel的安装指南进行安装即可。

#### 激活Jrebel

安装第一步就需要对Jrebel进行激活，这里笔者推荐第一种激活方式。

![a7551031abb723f3099c4fed5ae4e2b1](img\a7551031abb723f3099c4fed5ae4e2b1.png)

然后我们需要配置license server地址，这里我们通过一个JrebelBrainsLicenseServerforJava的激活jar包来实现，通过将jar包放在服务器上运行，然后就可以通过我们自己的服务器来作为license server地址了

下载地址：

```
下载:https://jinlilu.lanzoum.com/iHMG110q1p8h 密码:6g3h
```



![image-20230629095618933](img\image-20230629095618933.png)

打开后是这样的，等着就行不要关掉

![image-20230629095633917](img\image-20230629095633917.png)

如果放在服务器上，特别是腾讯云，阿里云之类的，记得开放服务器防火墙，安全组策略以及Linux系统防火墙上的1008端口。没有服务器也不要紧，用自己电脑也可。只不过不能一直把jar包运行着。

在线生成一个GUID

https://www.guidgen.com/

http://www.ofmonkey.com/transfer/guid

复制出来 填到地址后面

![img](img\719bfe70ea2a6ef2ebe56984188742fa.png)

比如

```
http://localhost:8888/0f1e21ef-c04a-4091-95d9-a27d46537744
```

![image-20230629095952949](img\image-20230629095952949.png)

![image-20230629095714757](img\image-20230629095714757.png)

![image-20230629095723789](img\image-20230629095723789.png)

但是到这还没完，虽然现在 Jrebel就能正常使用了，但很多人往往用不到几天就提示激活失败, 无法使用了，甚至jar包结束运行后激活就失败了。原因在于Jrebel激活之后默认是联网使用的 , 在该模式下 , Jrebel会一直联网监测激活信息。所以要调为离线使用的，操作方法就是进入Jrebel设置中点击Work offile 按钮即可。使其变为离线模式即可。


**激活成功！**

![img](\img\89c9b5645ac2678f818b688d897384a9.png)

这样激活就算彻底完成了。

但是这时候仅仅这点配置，功能还是不能正常使用的。还需要我们在Idea中设置自动编译。

配置自动编译
找到setting->build,Excution->Compiler,并勾选Build project automatically。

![img](img\9975f35bb8e70ec0f9a879c4d13cc730.png)


然后找到setting->Advanced Setting，勾选Compiler中的

Allow auto-make to start even if developed application is currently running

这里笔者是基于idea2022版本配置的，基本上配置完成就可以了。

![img](img\198200dedc2e966b809aa7b2242e599b.png)

#### 本地热部署使用

配置完Jrebel后，如果在本地使用，可以通过Idea界面左下角的Jrenel面板对自己的项目进行设置即可。

![img](img\c08f49499acae3fb23d8429307a2f53b.png)

左侧的图标对应的本地热部署，右侧的对应远程热部署。

> 勾选成功后项目或者模块中的src/resource目录下回生成一个rebel.xml文件

主启动类，和运行栏也会出现Jrebel运行的图标。

![img](img\9c66fc4c73d7efbb49209328762e4baf.png)

如果发现启动后部分更新效果并没有，也可尝试在启动类上配置一下更新资源的配置。

![img](img\5a4cf794acd3c265cbdd33560f85423c.png)

都配置好了以后，可以先试一下，第一次运行要重新编译，打包，执行。如果不生效可以重启一次idea, 一般来讲重启后都可以生效。

#### 使用效果

修改代码中的内容，自动加载

![2023-06-29-09-51-07](img\2023-06-29-09-51-07.gif)



#### JRebel启动慢

更新新版JRebel后，启动卡住无法正常启动项目
Disconnected from the target VM, address: ‘127.0.0.1:58166’, transport: ‘socket’

解决方式
降低版本： 降到什么版本自行测试；
修改idea配置： 根据插件官网回复，问题是由IntelliJ的默认配置的变化引起的，暂时可通过以下配置进行处理：
1/ Open Settings 2/ Open “Languages and Frameworks” 3/ Select “Reactive Streams” 4/ Within the “Debugger” section, chose “None”

![img](img/dc2362fe157845fb82fe029cf3228180.png)



![image-20240808100932849](img/image-20240808100932849.png)



###  在线激活 （推荐）

资料来源：[Jrebel 最新的 2024.3.0 激活方法](https://blog.csdn.net/qq251708339/article/details/134105044)

#### 问题:

- 用新不用旧，老版的插件连最新的springboot3 都不支持
- 激活服务器提示： Ls client not configured

#### 解决方法:

- 1. 访问： https://www.jpy.wang/page/jrebel.html

![在这里插入图片描述](img/c95b56c174799046b8b953542f70a302.png)



2.在jrebel激活的时候填写相应的地址

![在这里插入图片描述](img/9304f5655b00ac48c1353adab50879e5.png)



![在这里插入图片描述](img/14adefa2972c3c21b88d1148ecc46eae.png)

### maven help

1、File→Settings→Plugins，输入maven helper，本地没搜到，就可以点击Search in repositories（或直接点击Browse repositories进入搜索），搜到Maven Helper后选择Install进行安装即可，安装后需重启IDEA。

![image-20230809143150372](img/image-20230809143150372.png)

**使用方法：**

1、安装完后，pom文件下方就会出现Dependency Analyzer面板。可以查看依赖冲突，也可以搜索相关依赖，进入后效果如下：

![img](img/711223-20220106094828214-1347609022.png)

### mybatis

![image-20230809143345599](img/image-20230809143345599.png)

`Mybatis Log Free` 可以把日志中的打印的sql日志，合并输出

### MybatisLogFormat

在使用idea开发的过程中，查询语句会遇到以下sql

![img](img/e80c01a88eb14c3bb789f52cac34f1f8~noop.png)

```tex
Creating a new SqlSession
SqlSession [org.apache.ibatis.session.defaults.DefaultSqlSession@648639f1] was not registered for synchronization because synchronization is not active
JDBC Connection [com.alibaba.druid.proxy.jdbc.ConnectionProxyImpl@fbc1de9] will not be managed by Spring
==>  Preparing: SELECT id,name,province_code FROM t_province WHERE (province_code = ? AND name = ?) limit 1
==> Parameters: 110000(String), 北京市(String)
<==    Columns: id, name, province_code
<==        Row: 1, 北京市, 110000
<==      Total: 1
Closing non transactional SqlSession [org.apache.ibatis.session.defaults.DefaultSqlSession@648639f1]
```

此时如果想得到完成的sql,就需要将上面的带占位符的sql拷贝出来，

```sql
SELECT id,name,province_code FROM t_province WHERE (province_code = ? AND name = ?) limit 1

```

然后再去找到Parameters那一段。

Parameters: 110000(String), 北京市(String)

将sql中的？依次替换Parameters中的实参，就能得到完整的sql了，看似这个很简单，但是如果sql中参数很多，这个时候再用这种方法就很容易出错了。

下面介绍下idea的插件，在
Settings/Plugins/Marketplace中输入 MybatisLogFormat，然后选择安装，下图是我安装过的。

![img](img/274762560fbb43a1bbc92f9c31a56c49~noop.png)

下载安装好重启后，选择sql语句和Parameters参数对应的行，然后右键点击
MybatisLogFormat2Clipboard。

![img](img/fe1ed2b069b1438eb56d11d303247de2~noop.png)

此时一条美化后的sql就可以直接执行了，格式如下

![img](img/4cec53600d7a4d86a25b53dd7fda0e66~noop.png)

用了这个插件后，如果需要把sql拿出来到客户端执行分析，效率就大大提升了。

### 日志插件

![image-20231107165904606](img/image-20231107165904606.png)

**方法一：settings->Other Settings->Grep Console，在右边窗口中自定义你想要的效果**

![img](img/f33f9c922bc74bc3bc9d25ae9eb2661d.png)

**方法二：启动项目后在日志输出控制台右击，再点击Open Grep Console Settings进入** 

![img](img/e85fda7701e34e678cdb021a2f507532.png)

 **方法三：点击IDEA Tools -> Grep Console，点击 Grep Console进入**

![img](img/1cca0fecb2f4441abfdbb538d8dfb4ab.png)

设置完成后，你可以通过代码日志输出测试一下效果

**下面例子我通过设置warn/error的背景色，使得输出更直观：**

![img](img/a49337960d6047a783cfedf564ceb801.png)

```java
public class GrepConsole {
 
    public static void main(String[] args) {
        Logger logger = LoggerFactory.getLogger(GrepConsole.class);
        logger.info("*****info*****");
        logger.warn("*****warn*****");
        logger.error("*****error*****");
    }
}
```

![img](img/bc77b18ebdce48cd952de65cda2f79fe.png)

通过增加Grep条件，过滤你想要的日志：

![img](img/c51f8b24fa744b35bc0810771f6084d7.png)

###  CodeGlance

再也不用疯狂拖拽到底去找一遍啦，多不方便呀，使用此插件可以查看缩略图一样，快速切换到自己需要去的地方~

![image-20240403104820340](img/image-20240403104820340.png)



![img](img/658ab1530dcb0d6b4cd8b28204ded779.gif)

### GenerateAllSetter（快速生成对象所有set方法）

![img](img/b76d209514d799b4031c081d121cf579.gif)

### GsonFormatPlus：json转实体

Alt + ins(*Ins*ert)或者Alt + S打开窗口粘贴需要转换成实体的json字符串

![img](img/3779567348c5529fc907e53d81f31fb3.gif)

### Json Prase（JSON数据格式化工具）

安装之后在IDEA右侧工具栏会生成"Json Parser"快捷方式，点击即可调出工具窗口，将JSON数据输入上方框内点击"Parse"即可进行格式化，比用在线工具网站方便。

![img](img/e3d522b1a25efcada09dafb484856e2c.gif)

### GitToolBox（跟踪每行代码的提交修改记录）

![img](img/19c9968048c1e9ade1ed967f679ee75e.gif)

### RestfulToolkitX（找到controller+快捷请求接口）

新版本的idea可能用不了，作者因该不维护了，网上有人基于这个插件开发了新的插件可以搜索RestfulTool 快捷键 Ctrl + Alt + /

根据url找对应action方法，根据url跳转，Ctrl + \或者Ctrl+Alt+N即可快速定位接口位置，比用IDEA的全局搜索效率高。


![img](img/911245951da88c110de024be1c82fd71.gif)

### HighlightBracketPair(括号匹配高亮显示)

括号匹配高亮显示，你鼠标所在代码所处的括号会标亮，可以方便我们再复杂、繁多的代码结构中清晰的查看到当前所在的代码层级，十分有用。

![img](img/ebd6af6394492d06cfe59fe43e2e6677.png)

## 提交自动生成

![image-20241125090000842](img/image-20241125090000842.png)