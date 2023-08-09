资料来源：

[警告！别再使用 TIMESTAMP 作为日期字段～](https://mp.weixin.qq.com/s/XqLMTBanoToA6AHU4GMUww)



## 别再使用 TIMESTAMP 作为日期字段

### 日期类型

MySQL 数据库中常见的日期类型有 YEAR、DATE、TIME、DATETIME、TIMESTAMEP。因为业务绝大部分场景都需要将日期精确到秒，所以在表结构设计中，常见使用的日期类型为DATETIME 和 TIMESTAMP



### dateTime

类型 DATETIME 最终展现的形式为：`YYYY-MM-DD HH：MM：SS`，固定占用 8 个字节。

从 MySQL 5.6 版本开始，`DATETIME` 类型支持毫秒，`DATETIME(N)` 中的 N 表示毫秒的精度。

例如，`DATETIME(6)` 表示可以存储 6 位的毫秒值。同时，一些日期函数也支持精确到毫秒，例如常见的函数 `NOW`、`SYSDATE`：

用户可以将 DATETIME 初始化值设置为当前时间，并设置自动更新当前时间的属性。例如用户表 User有register_date、last_modify_date两个字段的定义：

```sql
CREATE TABLE User (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    sex CHAR(1) NOT NULL,
    password VARCHAR(1024) NOT NULL,
    money INT NOT NULL DEFAULT 0,
    register_date DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    last_modify_date DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    CHECK (sex = 'M' OR sex = 'F'),
    PRIMARY KEY(id)
);
```

在上面的表 User 中，列 `register_date` 表示注册时间，`DEFAULT CURRENT_TIMESTAMP` 表示记录插入时，若没有指定时间，默认就是当前时间。

列 `last_modify_date` 表示当前记录最后的修改时间，`DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) `表示每次修改都会修改为当前时间。

### timestamp

除了 DATETIME，日期类型中还有一种` TIMESTAMP` 的时间戳类型，其实际存储的内容为`1970-01-01 00:00:00`到现在的毫秒数。在 MySQL 中，由于类型 `TIMESTAMP` 占用 4 个字节，因此其存储的时间上限只能到`2038-01-19 03:14:07`。

同类型 DATETIME 一样，从 `MySQL 5.6 `版本开始，类型` TIMESTAMP` 也能支持毫秒。与` DATETIME `不同的是，若带有毫秒时，类型 `TIMESTAMP` 占用 7 个字节，而 `DATETIME` 无论是否存储毫秒信息，都占用 8 个字节。

如果想使用 `TIMESTAMP` 的时区功能，你可以通过下面的语句将之前的用户表 `User` 的注册时间字段类型从 `DATETIME(6)` 修改为 `TIMESTAMP(6)`：

```sql
ALTER TABLE User CHANGE register_date register_date TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6);
```

这时通过设定不同的 time_zone，可以观察到不同时区下的注册时间：

```sql

mysql> SELECT name,regist er_date FROM User WHERE name = 'David';
+-------+----------------------------+
| name  | register_date              |
+-------+----------------------------+
| David | 2018-09-14 18:28:33.898593 |
+-------+----------------------------+
1 row in set (0.00 sec)

mysql> SET time_zone = '-08:00';
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT name,register_date FROM User WHERE name = 'David';
+-------+----------------------------+
| name  | register_date              |
+-------+----------------------------+
| David | 2018-09-14 02:28:33.898593 |
+-------+----------------------------+
1 row in set (0.00 sec)
```

为了优化 TIMESTAMP 的使用，强烈建议你使用显式的时区，而不是操作系统时区。比如在配置文件中显示地设置时区，而不要使用系统时区：

```
[mysqld]time_zone = "+08:00"
```

IMESTAMP 的上限值 2038 年很快就会到来，那时业务又将面临一次类似千年虫的问题。另外，TIMESTAMP 还存在潜在的性能问题。

### 总结

日期类型通常就是使用 DATETIME 和 TIMESTAMP 两种类型，然而由于类型 TIMESTAMP 存在性能问题，建议你还是尽可能使用类型 DATETIME。我总结一下今天的重点内容：

- MySQL 5.6 版本开始 DATETIME 和 TIMESTAMP 精度支持到毫秒；
- DATETIME 占用 8 个字节，TIMESTAMP 占用 4 个字节，DATETIME(6) 依然占用 8 个字节，TIMESTAMP(6) 占用 7 个字节；
- TIMESTAMP 日期存储的上限为 2038-01-19 03:14:07，业务用 TIMESTAMP 存在风险；
- 使用 TIMESTAMP 必须显式地设置时区，不要使用默认系统时区，否则存在性能问题，推荐在配置文件中设置参数 time_zone = '+08:00'；
- 推荐日期类型使用 DATETIME，而不是 TIMESTAMP 和 INT 类型；
- 表结构设计时，每个核心业务表，推荐设计一个 last_modify_date 的字段，用以记录每条记录的最后修改时间。