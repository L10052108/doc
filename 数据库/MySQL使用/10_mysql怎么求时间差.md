资料来源：<br/>
[mysql怎么求时间差](https://www.utheme.cn/code/mysql/26085.html)


## 计算时间差

在日常开发或数据分析工作中，我们经常需要计算时间差，例如计算两个时间戳之间的时长，或者计算某个事件距离当前时间的时间差等。MySQL提供了几个函数来方便地计算时间差。

### 天数(DATEDIFF)

DATEDIFF函数可以计算两个日期之间的天数差。其语法如下：

```sql
DATEDIFF(end_date, start_date)
```

其中end_date和start_date是表示时间的日期格式，可以是日期字符串、时间戳或Date类型的列。

例如，计算2020年10月1日到2020年10月5日这五天之间的天数差：

```sql
SELECT DATEDIFF('2020-10-05', '2020-10-01');
```

说明这五天之间相差了4天。c

### 时间差（DATEDIFF）

TIMESTAMPDIFF函数可以计算两个时间戳之间的时间差，其语法如下：

```sql
TIMESTAMPDIFF(interval, start_date, end_date)
```

其中interval表示计算的时间单位，可以是second（秒）、minute（分钟）、hour（小时）、day（天）、week（周）、month（月）或year（年）；start_date和end_date是表示时间的时间戳或Datetime类型的列。

例如，计算2020年10月1日13点30分到2020年10月1日14点30分之间的时间差：

```sql
SELECT TIMESTAMPDIFF(minute, '2020-10-01 13:30:00', '2020-10-01 14:30:00');c
```

结果是60

说明这两个时间戳之间相差了60分钟。

### UNIX_TIMESTAMP

UNIX_TIMESTAMP函数可以将日期字符串或Datetime类型的列转换为Unix时间戳。Unix时间戳是指自1970年1月1日零时零分零秒起至当前时间的秒数。

```sql
UNIX_TIMESTAMP([date])
```

其中date表示要转换的日期，可以是日期字符串、Datetime类型的列或者NOW()函数。

例如，将2020年10月1日转换为Unix时间戳：

```sql
SELECT UNIX_TIMESTAMP('2020-10-01');
```

输出结果为：`1601491200`

说明2020年10月1日的Unix时间戳是1601491200。c

### FROM_UNIXTIME

FROM_UNIXTIME函数可以将Unix时间戳转换为日期字符串或Datetime类型的列。其语法如下：

```sql
FROM_UNIXTIME(unix_timestamp, [format])
```

其中unix_timestamp为Unix时间戳，可以是整数或者Datetime类型的列。format表示输出的日期格式，可以省略，默认为`%Y-%m-%d %H:%i:%s`格式。

```sql
SELECT FROM_UNIXTIME(1601491200);
```

结果
`2020-10-01 00:00:00`

说明1601491200对应的日期是2020年10月1日。