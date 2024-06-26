# 什么是MySQL

MySQL（官方发音为英语发音：`/maɪ ˌɛskjuːˈɛl/` `My S-Q-L`，但也经常读作英语发音：`/maɪ ˈsiːkwəl/` `My Sequel`）原本是一个开放源代码的关系数据库管理系统（DBMS），原开发者为瑞典的`MySQL AB`公司，该公司于2008年被昇阳微系统（Sun Microsystems）收购。2009年，甲骨文公司（Oracle）收购昇阳微系统公司，MySQL成为Oracle旗下产品。在本教程中，会让大家快速掌握MySQL的基本知识，并轻松使用MySQL数据库。

### MySQL 介绍

MySQL在过去由于性能高、成本低、可靠性好，已经成为最流行的开源数据库，因此被广泛地应用在Internet上的中小型网站中，是最流行的关系型数据库管理系统，在WEB应用方面MySQL是最好的RDBMS(Relational Database Management System：关系数据库管理系统)应用软件之一。随着MySQL的不断成熟，它也逐渐用于更多大规模网站和应用，比如维基百科、Google和Facebook等网站。

但被甲骨文公司收购后，Oracle大幅调涨MySQL商业版的售价，且甲骨文公司不再支持另一个自由软件项目OpenSolaris的发展，因此导致自由软件社区们对于Oracle是否还会持续支持MySQL社区版（MySQL之中唯一的免费版本）有所隐忧，因此原先一些使用MySQL的开源软件逐渐转向其它的数据库。例如维基百科已于2013年正式宣布将从MySQL迁移到`MariaDB`数据库。MySQL的创始人麦克尔·维德纽斯以MySQL为基础，成立分支计划[MariaDB](https://github.com/MariaDB/server)。

### MySQL 发展历史

很多人以为MySQL是最近15年内才出现的数据库，其实MySQL数据库的历史可以追溯到1979年，那时 Bill Gates 退学没多久，微软公司也才刚刚起步，而Larry的Oracle公司也才成立不久。那时有一个天才程序员 Monty Widenius 用 BASIC 设计了一个报表工具，过了不久，又将此工具使用 C 语言重写，移植到 UNIX 平台，当时只是一个底层的面向报表存储引擎名叫Unireg。

- 1985年，瑞典的几位志同道合小伙子(David Axmark、Allan Larsson 和Monty Widenius) 成立了一家公司，这就是MySQL AB 的前身。
- 1990年，TcX公司的客户中开始有人要求为他的API提供SQL支持。当时有人提议直接使用商用数据库，但是Monty觉得商用数据库的速度难以令人满意。于是，他直接借助于mSQL的代码，将它集成到自己的存储引擎中。令人失望的是，效果并不太令人满意，于是，Monty雄心大起，决心自己重写一个SQL支持。
- 1996年，MySQL 1.0发布，它只面向一小拨人，相当于内部发布。
- 1996年10月，MySQL 3.11.1发布(MySQL没有2.x版本)，最开始只提供Solaris下的二进制版本。一个月后，Linux版本出现了。
- 1999～2000年，MySQL AB公司在瑞典成立。Monty雇了几个人与Sleepycat合作，开发出了Berkeley DB引擎，因为BDB支持事务处理，所以MySQL从此开始支持事务处理了。
- 2003年12月，MySQL 5.0版本发布，提供了视图、存储过程等功能。
- 2008年1月16日，Sun（太阳微系统）正式收购MySQL。
- 2009年4月20日，甲骨文公司宣布以每股9.50美元，74亿美元的总额收购Sun电脑公司。
- 2010年12月，MySQL 5.5发布，其主要新特性包括半同步的复制及对SIGNAL/RESIGNAL的异常处理功能的支持，最重要的是InnoDB存储引擎终于变为当前MySQL的默认存储引擎。
- 2013年6月18日，甲骨文公司修改MySQL授权协议，移除了GPL。但随后有消息称这是一个bug。

### MySQL 版本

`MySQL`针对不同的用户，分了`社区版`和`企业服务器版`，还提供一些其它版本，是属于`MySQL`相关工具。

1. MySQL Community Server 社区版本，开源免费，但不提供官方技术支持。
2. MySQL Enterprise Edition 企业版本，需付费，可以试用30天。
3. MySQL Cluster 集群版，开源免费。可将几个MySQL Server封装成一个Server。
4. MySQL Cluster CGE 高级集群版，需付费。
5. MySQL Workbench（GUI TOOL）一款专为MySQL设计的ER/数据库建模工具。

> MySQL Workbench是著名的数据库设计工具DBDesigner4的继任者。MySQL Workbench又分为两个版本，分别是社区版（MySQL Workbench OSS）、商用版（MySQL Workbench SE）。

MySQL 版本命命机制由三个数字组成，例如`mysql-5.6.33-osx10.11-x86_64.tar.gz`

- 第一个数字（5）主版本号：当你做了不兼容的 API 修改，
- 第二个数字（7）次版本号：当你做了向下兼容的功能性新增，合计，主要和次要的数字构成发布系列号。该系列号描述了稳定的特征集。
- 第三个数字（1）修订号：当你做了向下兼容的问题修正。这是一个新的bugfix释放增加。在大多数情况下，在一系列最新版本是最好的选择。

> Github 上面有[语义化版本标准](http://semver.org/lang/zh-CN/), 开源仓库[mojombo/semver](https://github.com/mojombo/semver)，上面的版本命名大致是跟语义化版本标准差不多，你可以看语义化版本标准来学习版本名机制。通过语义化版本标准来理解MySQL版本命命机制。

### MySQL 的优势

- 使用C和C++编写，并使用了多种编译器进行测试，保证源代码的可移植性。
- 支持AIX、BSDi、FreeBSD、HP-UX、Linux、Mac OS、Novell NetWare、NetBSD、OpenBSD、OS/2 Wrap、Solaris、Windows等多种操作系统。
- 为多种编程语言提供了API。这些编程语言包括C、C++、C#、VB.NET、Delphi、Eiffel、Java、Perl、PHP、Python、Ruby和Tcl等。
- 支持多线程，充分利用CPU资源，支持多用户。
- 优化的SQL查询算法，有效地提高查询速度。
- 既能够作为一个单独的应用程序在客户端服务器网络环境中运行，也能够作为一个程序库而嵌入到其他的软件中。
- 提供多语言支持，常见的编码如中文的GB 2312、BIG5、日文的Shift JIS等都可以用作数据表名和数据列名。
- 提供TCP/IP、ODBC和JDBC等多种数据库连接途径。
- 提供用于管理、检查、优化数据库操作的管理工具。
- 可以处理拥有上千万条记录的大型数据库。

## 数据库存储引擎

对于初学者来说我们通常不关注存储引擎，但是 MySQL 提供了多个存储引擎，包括处理事务安全表的引擎和处理非事务安全表的引擎。在 MySQL 中，不需要在整个服务器中使用同一种存储引擎，针对具体的要求，可以对每一个表使用不同的存储引擎。

### 存储引擎简介

MySQL中的数据用各种不同的技术存储在文件(或者内存)中。这些技术中的每一种技术都使用不同的存储机制、索引技巧、锁定水平并且最终提供广泛的不同的功能和能力。通过选择不同的技术，你能够获得额外的速度或者功能，从而改善你的应用的整体功能。 存储引擎说白了就是如何存储数据、如何为存储的数据建立索引和如何更新、查询数据等技术的实现方法。

例如，如果你在研究大量的临时数据，你也许需要使用内存存储引擎。内存存储引擎能够在内存中存储所有的表格数据。又或者，你也许需要一个支持事务处理的数据库(以确保事务处理不成功时数据的回退能力)。

#### InnoDB

InnoDB是一个健壮的事务型存储引擎，这种存储引擎已经被很多互联网公司使用，为用户操作非常大的数据存储提供了一个强大的解决方案。我的电脑上安装的 MySQL 5.6.13 版，InnoDB就是作为默认的存储引擎。InnoDB还引入了行级锁定和外键约束，在以下场合下，使用InnoDB是最理想的选择：

- 更新密集的表。InnoDB存储引擎特别适合处理多重并发的更新请求。
- 事务。InnoDB存储引擎是支持事务的标准MySQL存储引擎。
- 自动灾难恢复。与其它存储引擎不同，InnoDB表能够自动从灾难中恢复。
- 外键约束。MySQL支持外键的存储引擎只有InnoDB。
- 支持自动增加列AUTO_INCREMENT属性。
- 从5.7开始innodb存储引擎成为默认的存储引擎。

一般来说，如果需要事务支持，并且有较高的并发读取频率，InnoDB是不错的选择。

#### MyISAM

MyISAM表是独立于操作系统的，这说明可以轻松地将其从Windows服务器移植到Linux服务器；每当我们建立一个MyISAM引擎的表时，就会在本地磁盘上建立三个文件，文件名就是表名。例如，我建立了一个MyISAM引擎的tb_Demo表，那么就会生成以下三个文件：

- tb_demo.frm，存储表定义。
- tb_demo.MYD，存储数据。
- tb_demo.MYI，存储索引。

MyISAM表无法处理事务，这就意味着有事务处理需求的表，不能使用MyISAM存储引擎。MyISAM存储引擎特别适合在以下几种情况下使用：

1. 选择密集型的表。MyISAM存储引擎在筛选大量数据时非常迅速，这是它最突出的优点。
2. 插入密集型的表。MyISAM的并发插入特性允许同时选择和插入数据。例如：MyISAM存储引擎很适合管理邮件或Web服务器日志数据。

#### MRG_MYISAM

MRG_MyISAM存储引擎是一组MyISAM表的组合，老版本叫 MERGE 其实是一回事儿，这些MyISAM表结构必须完全相同，尽管其使用不如其它引擎突出，但是在某些情况下非常有用。说白了，Merge表就是几个相同MyISAM表的聚合器；Merge表中并没有数据，对Merge类型的表可以进行查询、更新、删除操作，这些操作实际上是对内部的MyISAM表进行操作。

Merge存储引擎的使用场景。对于服务器日志这种信息，一般常用的存储策略是将数据分成很多表，每个名称与特定的时间端相关。例如：可以用12个相同的表来存储服务器日志数据，每个表用对应各个月份的名字来命名。当有必要基于所有12个日志表的数据来生成报表，这意味着需要编写并更新多表查询，以反映这些表中的信息。与其编写这些可能出现错误的查询，不如将这些表合并起来使用一条查询，之后再删除Merge表，而不影响原来的数据，删除Merge表只是删除Merge表的定义，对内部的表没有任何影响。

- ENGINE=MERGE，指明使用MERGE引擎，其实是跟MRG_MyISAM一回事儿，也是对的，在MySQL 5.7已经看不到MERGE了。
- UNION=(t1, t2)，指明了MERGE表中挂接了些哪表，可以通过alter table的方式修改UNION的值，以实现增删MERGE表子表的功能。比如：

```sql
alter table tb_merge engine=merge union(tb_log1) insert_method=last;
```

- INSERT_METHOD=LAST，INSERT_METHOD指明插入方式，取值可以是：0 不允许插入；FIRST 插入到UNION中的第一个表； LAST 插入到UNION中的最后一个表。
- MERGE表及构成MERGE数据表结构的各成员数据表必须具有完全一样的结构。每一个成员数据表的数据列必须按照同样的顺序定义同样的名字和类型，索引也必须按照同样的顺序和同样的方式定义。

#### MEMORY

使用MySQL Memory存储引擎的出发点是速度。为得到最快的响应时间，采用的逻辑存储介质是系统内存。虽然在内存中存储表数据确实会提供很高的性能，但当mysqld守护进程崩溃时，所有的Memory数据都会丢失。获得速度的同时也带来了一些缺陷。它要求存储在Memory数据表里的数据使用的是长度不变的格式，这意味着不能使用BLOB和TEXT这样的长度可变的数据类型，VARCHAR是一种长度可变的类型，但因为它在MySQL内部当做长度固定不变的CHAR类型，所以可以使用。

一般在以下几种情况下使用Memory存储引擎：

- 目标数据较小，而且被非常频繁地访问。在内存中存放数据，所以会造成内存的使用，可以通过参数max_heap_table_size控制Memory表的大小，设置此参数，就可以限制Memory表的最大大小。
- 如果数据是临时的，而且要求必须立即可用，那么就可以存放在内存表中。
- 存储在Memory表中的数据如果突然丢失，不会对应用服务产生实质的负面影响。
- Memory同时支持散列索引和B树索引。B树索引的优于散列索引的是，可以使用部分查询和通配查询，也可以使用<、>和>=等操作符方便数据挖掘。散列索引进行“相等比较”非常快，但是对“范围比较”的速度就慢多了，因此散列索引值适合使用在=和<>的操作符中，不适合在<或>操作符中，也同样不适合用在order by子句中。

#### CSV

CSV 存储引擎是基于 CSV 格式文件存储数据。

- CSV 存储引擎因为自身文件格式的原因，所有列必须强制指定 NOT NULL 。
- CSV 引擎也不支持索引，不支持分区。
- CSV 存储引擎也会包含一个存储表结构的 .frm 文件，还会创建一个 .csv 存储数据的文件，还会创建一个同名的元信息文件，该文件的扩展名为 .CSM ，用来保存表的状态及表中保存的数据量。
- 每个数据行占用一个文本行。

因为 csv 文件本身就可以被Office等软件直接编辑，保不齐就有不按规则出牌的情况，如果出现csv 文件中的内容损坏了的情况，也可以使用 CHECK TABLE 或者 REPAIR TABLE 命令检查和修复

#### ARCHIVE

Archive是归档的意思，在归档之后很多的高级功能就不再支持了，仅仅支持最基本的插入和查询两种功能。在MySQL 5.5版以前，Archive是不支持索引，但是在MySQL 5.5以后的版本中就开始支持索引了。Archive拥有很好的压缩机制，它使用zlib压缩库，在记录被请求时会实时压缩，所以它经常被用来当做仓库使用。

#### BLACKHOLE

黑洞存储引擎，所有插入的数据并不会保存，BLACKHOLE 引擎表永远保持为空，写入的任何数据都会消失，

#### PERFORMANCE_SCHEMA

主要用于收集数据库服务器性能参数。MySQL用户是不能创建存储引擎为PERFORMANCE_SCHEMA的表，一般用于记录binlog做复制的中继。在这里有官方的一些介绍[MySQL Performance Schema](https://dev.mysql.com/doc/refman/5.6/en/performance-schema.html)

#### FEDERATED

主要用于访问其它远程MySQL服务器一个代理，它通过创建一个到远程MySQL服务器的客户端连接，并将查询传输到远程服务器执行，而后完成数据存取；在MariaDB的上实现是FederatedX

#### 其他

这里列举一些其它数据库提供的存储引擎，OQGraph、SphinxSE、TokuDB、Cassandra、CONNECT、SQUENCE。提供的名字仅供参考。

### 常用引擎对比

不同存储引起都有各自的特点，为适应不同的需求，需要选择不同的存储引擎，所以首先考虑这些存储引擎各自的功能和兼容。

| 特性                                       | InnoDB | MyISAM | MEMORY | ARCHIVE |
| ---------------------------------------- | ------ | ------ | ------ | ------- |
| 存储限制(Storage limits)                     | 64TB   | No     | YES    | No      |
| 支持事物(Transactions)                       | Yes    | No     | No     | No      |
| 锁机制(Locking granularity)                 | 行锁     | 表锁     | 表锁     | 行锁      |
| B树索引(B-tree indexes)                     | Yes    | Yes    | Yes    | No      |
| T树索引(T-tree indexes)                     | No     | No     | No     | No      |
| 哈希索引(Hash indexes)                       | Yes    | No     | Yes    | No      |
| 全文索引(Full-text indexes)                  | Yes    | Yes    | No     | No      |
| 集群索引(Clustered indexes)                  | Yes    | No     | No     | No      |
| 数据缓存(Data caches)                        | Yes    | No     | N/A    | No      |
| 索引缓存(Index caches)                       | Yes    | Yes    | N/A    | No      |
| 数据可压缩(Compressed data)                   | Yes    | Yes    | No     | Yes     |
| 加密传输(Encrypted data<sup>[1]</sup>)       | Yes    | Yes    | Yes    | Yes     |
| 集群数据库支持(Cluster databases support)       | No     | No     | No     | No      |
| 复制支持(Replication support<sup>[2]</sup>)  | Yes    | No     | No     | Yes     |
| 外键支持(Foreign key support)                | Yes    | No     | No     | No      |
| 存储空间消耗(Storage Cost)                     | 高      | 低      | N/A    | 非常低     |
| 内存消耗(Memory Cost)                        | 高      | 低      | N/A    | 低       |
| 数据字典更新(Update statistics for data dictionary) | Yes    | Yes    | Yes    | Yes     |
| 备份/时间点恢复(backup/point-in-time recovery<sup>[3]</sup>) | Yes    | Yes    | Yes    | Yes     |
| 多版本并发控制(Multi-Version Concurrency Control/MVCC) | Yes    | No     | No     | No      |
| 批量数据写入效率(Bulk insert speed)              | 慢      | 快      | 快      | 非常快     |
| 地理信息数据类型(Geospatial datatype support)    | Yes    | Yes    | No     | Yes     |
| 地理信息索引(Geospatial indexing support<sup>[4]</sup>) | Yes    | Yes    | No     | Yes     |

1. 在服务器中实现（通过加密功能）。在其他表空间加密数据在MySQL 5.7或更高版本兼容。
2. 在服务中实现的，而不是在存储引擎中实现的。
3. 在服务中实现的，而不是在存储引擎中实现的。
4. 地理位置索引，InnoDB支持可mysql5.7.5或更高版本兼容

### 查看存储引擎

使用“SHOW VARIABLES LIKE '%storage_engine%';” 命令在mysql系统变量搜索磨人设置的存储引擎，输入语句如下：

```sql
mysql> SHOW VARIABLES LIKE '%storage_engine%';
+----------------------------------+---------+
| Variable_name                    | Value   |
|----------------------------------+---------|
| default_storage_engine           | InnoDB  |
| default_tmp_storage_engine       | InnoDB  |
| disabled_storage_engines         |         |
| internal_tmp_disk_storage_engine | InnoDB  |
+----------------------------------+---------+
4 rows in set
Time: 0.005s
```

使用“SHOW ENGINES;”命令显示安装以后可用的所有的支持的存储引擎和默认引擎，后面带上 \G 可以列表输出结果，你可以尝试一下如“SHOW ENGINES\G;”。

```sql
mysql> SHOW ENGINES;
+--------------------+---------+--------------------------------------+-------------+--------+-----------+
| Engine             | Support | Comment                              | Transactions| XA     | Savepoints|
|--------------------+---------+--------------------------------------+-------------+--------+-----------|
| InnoDB             | DEFAULT | Supports transactions,               | YES         | YES    | YES       |
|                    |         | row-level locking, and foreign keys  |             |        |           |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables| NO          | NO     | NO        |
| MEMORY             | YES     | Hash based, stored in memory, useful | NO          | NO     | NO        |
|                    |         | for temporary tables                 |             |        |           |
| BLACKHOLE          | YES     | /dev/null storage engine (anything   | NO          | NO     | NO        |
|                    |         | you write to it disappears)          |             |        |           |
| MyISAM             | YES     | MyISAM storage engine                | NO          | NO     | NO        |
| CSV                | YES     | CSV storage engine                   | NO          | NO     | NO        |
| ARCHIVE            | YES     | Archive storage engine               | NO          | NO     | NO        |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                   | NO          | NO     | NO        |
| FEDERATED          | NO      | Federated MySQL storage engine       | <null>      | <null> | <null>    |
+--------------------+---------+--------------------------------------+-------------+--------+-----------+
```

由上面命令输出，可见当前系统的默认数据表类型是InnoDB。当然，我们可以通过修改数据库配置文件中的选项，设定默认表类型。

### 设置存储引擎

对上面数据库存储引擎有所了解之后，你可以在`my.cnf` 配置文件中设置你需要的存储引擎，这个参数放在 [mysqld] 这个字段下面的 default_storage_engine 参数值，例如下面配置的片段

```bash
[mysqld]
default_storage_engine=CSV
```

在创建表的时候，对表设置存储引擎，例如：

```sql
CREATE TABLE `user` (
  `id`     int(100) unsigned NOT NULL AUTO_INCREMENT,
  `name`   varchar(32) NOT NULL DEFAULT '' COMMENT '姓名',
  `mobile` varchar(20) NOT NULL DEFAULT '' COMMENT '手机',
  PRIMARY KEY (`id`)
)ENGINE=InnoDB;
```

在创建用户表 user 的时候，SQL语句最后 ENGINE=InnoDB 就是设置这张表存储引擎为 InnoDB。

### 如何选择合适的存储引擎

提供几个选择标准，然后按照标准，选择对应的存储引擎即可，也可以根据[常用引擎对比](#常用引擎对比)来选择你使用的存储引擎。使用哪种引擎需要根据需求灵活选择，一个数据库中多个表可以使用不同的引擎以满足各种性能和实际需求。使用合适的存储引擎，将会提高整个数据库的性能。

1. 是否需要支持事务；
2. 是否需要使用热备；
3. 崩溃恢复，能否接受崩溃；
4. 是否需要外键支持；
5. 存储的限制；
6. 对索引和缓存的支持；