资料来源：<br/>
[windows系统安装sqlite和创建db文件](https://blog.csdn.net/ffyyhh995511/article/details/126270426)<br/>
[SQLite数据库介绍与使用](https://blog.csdn.net/cnds123/article/details/129052163)<br/>
[gitee代码](https://gitee.com/L10052108/store)<br/>
[微信为什么使用SQLite保存聊天记录？](https://mp.weixin.qq.com/s/Ak764O1c-UqkIBJWIHAADg)<br/>

## sqlite使用

### sqlite 的介绍

#### 介绍

SQLite 是一个被大家低估的数据库，但有些人认为它是一个不适合生产环境使用的玩具数据库。事实上，SQLite 是一个非常可靠的数据库，它可以处理 TB 级的数据，但它没有网络层。接下来，本文将与大家共同探讨 SQLite 在过去一年中最新的 SQL 功能。

SQLite是一个轻量级、跨平台的关系型数据库。SQLite的很小，它的数据库就是一个文件，但是它并不缺乏功能。不需要复杂的安装或管理。SQLite事务是完全兼容ACID的，允许从多个进程或线程安全访问。SQLite特别适合为单个应用程序和设备提供本地数据存储，使用很简单，将sqlite3.exe可执行文件复制到目标计算机上就可以运行它，新版本对SQL支持比较完善了，因此可以很方便的用来学习SQL。

#### 特点

◇轻量级

先说它的第一个特色：轻量级。SQLite和C/S模式的数据库软件不同，它是进程内的数据库引擎，因此不存在数据库的客户端和服务器。使用SQLite一般只需要带上它的一个动态库，就可以享受它的全部功能。而且那个动态库的尺寸也挺小，以版本3.6.11为例，Windows下487KB、Linux下347KB。

◇绿色软件

SQLite的另外一个特点是绿色：它的核心引擎本身不依赖第三方的软件，使用它也不需要“安装”。所以在部署的时候能够省去不少麻烦。

◇单一文件

所谓的“单一文件”，就是数据库中所有的信息（比如表、视图、触发器、等）都包含在一个文件内。这个文件可以copy到其它目录或其它机器上，也照用不误。

◇跨平台/可移植性

可在 UNIX、Linux, Mac OS-X, Android, iOS和 Windows中运行。

#### 安装

进入SQLite下载页面[SQLite Download Page](https://www.sqlite.org/download.html)，从Windows区下载预编译的二进制文件。
下载sqlite-tools-win32-.zip和sqlite-dll-win32-.zip压缩文件。

![img](img\45de42619ab546149e01285ac1c56a85.png)

创建文件夹 D:\sqlite，并在此文件夹下解压上面两个压缩文件，将得到 sqlite3.def、sqlite3.dll 和 sqlite3.exe 文件。

![img](img\5985e215a4c748ef9d8f10353da81d49.png)

添加 D:\sqlite到PATH 环境变量

![img](img\9da95b92144045c299c92f8b4f65f6b0.png)



使用cmd命令进入你要创建db文件的文件夹目录

```bash
PS D:\sqlite-bible-3> sqlite3
SQLite version 3.39.2 2022-07-21 15:24:47
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
```

使用提示的命令".open FILENAME"创建DB文件

```bash
sqlite> .open my-sqlite.db
sqlite>
```

生成DB文件

![img](img\c811439a91294658a97d910be1089184.png)



#### Navicat连接

![image-20230629155515449](img\image-20230629155515449.png ':size=30%')



执行`sql`建表语句

```sql
CREATE TABLE user
(
    id BIGINT(20) NOT NULL ,
    name VARCHAR(30) NULL DEFAULT NULL ,
    age INT(11) NULL DEFAULT NULL ,
    email VARCHAR(50) NULL DEFAULT NULL ,
    PRIMARY KEY (id)
);

INSERT INTO user (id, name, age, email) VALUES
                                            (1, 'Jone', 18, 'test1@baomidou.com'),
                                            (2, 'Jack', 20, 'test2@baomidou.com'),
                                            (3, 'Tom', 28, 'test3@baomidou.com'),
                                            (4, 'Sandy', 21, 'test4@baomidou.com'),
                                            (5, 'Billie', 24, 'test5@baomidou.com');
```



?> 从建表语句上看，和`h2`不一样，少了`COMMENT  xxx`备注的内容

## springboot 集成sqlite

在H2基础上进行修改

文件结构

![image-20230629155014043](img\image-20230629155014043.png ':size=20%')



`sqlite`配置文件

```yml
# local环境jdbc配置
spring:
  datasource:
    driver-class-name: org.sqlite.JDBC
  #  url: jdbc:sqlite:D:/file/ideaProject/store/db/sqlLite/db/mydb.db
    #    url: jdbc:sqlite:db\mydb.db
    url: jdbc:sqlite::resource:sqlite\mydb2.db
    data-username:
    data-password:
```

使用绝对路径

```
  #  url: jdbc:sqlite:D:/file/ideaProject/store/db/sqlLite/db/mydb.db
```

放在项目`db`文件夹下面

```
  #  url: jdbc:sqlite:D:/file/ideaProject/store/db/sqlLite/db/mydb.db
```

放在`resource`文件夹下

```
    url: jdbc:sqlite::resource:sqlite\mydb2.db
```

其他的代码和`h2`相同，运行测试

![image-20230629160210487](img\image-20230629160210487.png)