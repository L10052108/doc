资料来源：<br/>
[mysql怎么求时间差](https://www.utheme.cn/code/mysql/26085.html)<br/>
[MySQL 获得当前日期时间函数](https://www.cnblogs.com/ggjucheng/p/3352280.html)

## 时间函数

### now

获得当前日期+时间（date + time）函数：now()

```sql
mysql> select now();
+---------------------+
| now()               |
+---------------------+
| 2023-08-09 16:46:04 |
+---------------------+
1 row in set (0.00 sec)

mysql> select current_timestamp, current_timestamp();
+---------------------+---------------------+
| current_timestamp   | current_timestamp() |
+---------------------+---------------------+
| 2023-08-09 16:46:14 | 2023-08-09 16:46:14 |
+---------------------+---------------------+
1 row in set (0.00 sec)
```

### MySQL 日期转换函数、时间转换函数

MySQL Date/Time to Str（日期/时间转换为字符串）函数：date_format(date,format), time_format(time,format)

```sql
mysql> select date_format('2008-08-08 22:23:01', '%Y%m%d%H%i%s');

+----------------------------------------------------+
| date_format('2008-08-08 22:23:01', '%Y%m%d%H%i%s') |
+----------------------------------------------------+
| 20080808222301 |
+----------------------------------------------------+
```

MySQL 日期、时间转换函数：date_format(date,format), time_format(time,format) 能够把一个日期/时间转换成各种各样的字符串格式。它是 str_to_date(str,format) 函数的 一个逆转换。

MySQL Str to Date （字符串转换为日期）函数：str_to_date(str, format)

~~~~sql
select str_to_date('08/09/2008', '%m/%d/%Y'); -- 2008-08-09
select str_to_date('08/09/08' , '%m/%d/%y'); -- 2008-08-09
select str_to_date('08.09.2008', '%m.%d.%Y'); -- 2008-08-09
select str_to_date('08:09:30', '%h:%i:%s'); -- 08:09:30
select str_to_date('08.09.2008 08:09:30', '%m.%d.%Y %h:%i:%s'); -- 2008-08-09 08:09:30
~~~~

可以看到，str_to_date(str,format) 转换函数，可以把一些杂乱无章的字符串转换为日期格式。另外，它也可以转换为时间。“format” 可以参看 MySQL 手册。

MySQL （日期、天数）转换函数：to_days(date), from_days(days)

```sql
select to_days('0000-00-00'); -- 0
select to_days('2008-08-08'); -- 733627
```

MySQL （时间、秒）转换函数：time_to_sec(time), sec_to_time(seconds)

```sql
select time_to_sec('01:00:05'); -- 3605
select sec_to_time(3605); -- '01:00:05'
```

MySQL 拼凑日期、时间函数：makdedate(year,dayofyear), maketime(hour,minute,second)

~~~~sql
select makedate(2001,31); -- '2001-01-31'
select makedate(2001,32); -- '2001-02-01'
select maketime(12,15,30); -- '12:15:30'
~~~~

MySQL （Unix 时间戳、日期）转换函数

```sql
unix_timestamp(),
unix_timestamp(date),
from_unixtime(unix_timestamp),
from_unixtime(unix_timestamp,format)
```

下面是示例：

~~~~sql
select unix_timestamp(); -- 1218290027
select unix_timestamp('2008-08-08'); -- 1218124800
select unix_timestamp('2008-08-08 12:30:00'); -- 1218169800

select from_unixtime(1218290027); -- '2008-08-09 21:53:47'
select from_unixtime(1218124800); -- '2008-08-08 00:00:00'
select from_unixtime(1218169800); -- '2008-08-08 12:30:00'

select from_unixtime(1218169800, '%Y %D %M %h:%i:%s %x'); -- '2008 8th August 12:30:00 2008'
~~~~

### 时间计算函数

MySQL 为日期增加一个时间间隔：date_add()

```sql
set @dt = now();

select date_add(@dt, interval 1 day); -- add 1 day
select date_add(@dt, interval 1 hour); -- add 1 hour
select date_add(@dt, interval 1 minute); -- ...
select date_add(@dt, interval 1 second);
select date_add(@dt, interval 1 microsecond);
select date_add(@dt, interval 1 week);
select date_add(@dt, interval 1 month);
select date_add(@dt, interval 1 quarter);
select date_add(@dt, interval 1 year);

select date_add(@dt, interval -1 day); -- sub 1 day
```

MySQL adddate(), addtime()函数，可以用 date_add() 来替代。下面是 date_add() 实现 addtime() 功能示例：

~~~~sql
mysql> set @dt = '2008-08-09 12:12:33';

mysql>
mysql> select date_add(@dt, interval '01:15:30' hour_second);

+------------------------------------------------+
| date_add(@dt, interval '01:15:30' hour_second) |
+------------------------------------------------+
| 2008-08-09 13:28:03 |
+------------------------------------------------+

mysql> select date_add(@dt, interval '1 01:15:30' day_second);

+-------------------------------------------------+
| date_add(@dt, interval '1 01:15:30' day_second) |
+-------------------------------------------------+
| 2008-08-10 13:28:03 |
+-------------------------------------------------+
~~~~

MySQL 为日期减去一个时间间隔：date_sub()

```sql
mysql> select date_sub('1998-01-01 00:00:00', interval '1 1:1:1' day_second);

+----------------------------------------------------------------+
| date_sub('1998-01-01 00:00:00', interval '1 1:1:1' day_second) |
+----------------------------------------------------------------+
| 1997-12-30 22:58:59 |
+----------------------------------------------------------------+
```

MySQL date_sub() 日期时间函数 和 date_add() 用法一致，不再赘述。

MySQL 日期、时间相减函数：datediff(date1,date2), timediff(time1,time2)

```
MySQL datediff(date1,date2)：两个日期相减 date1 - date2，返回天数。
select datediff('2008-08-08', '2008-08-01'); -- 7
select datediff('2008-08-01', '2008-08-08'); -- -7
```

MySQL timediff(time1,time2)：两个日期相减 time1 - time2，返回 time 差值。

```
select timediff('2008-08-08 08:08:08', '2008-08-08 00:00:00'); -- 08:08:08
select timediff('08:08:08', '00:00:00'); -- 08:08:08
```

注意：timediff(time1,time2) 函数的两个参数类型必须相同。

MySQL 时间戳（timestamp）转换、增、减函数：

```
timestamp(date) -- date to timestamp
timestamp(dt,time) -- dt + time
timestampadd(unit,interval,datetime_expr) --
timestampdiff(unit,datetime_expr1,datetime_expr2) --
```

请看示例部分：

```
select timestamp('2008-08-08'); -- 2008-08-08 00:00:00
select timestamp('2008-08-08 08:00:00', '01:01:01'); -- 2008-08-08 09:01:01
select timestamp('2008-08-08 08:00:00', '10 01:01:01'); -- 2008-08-18 09:01:01

select timestampadd(day, 1, '2008-08-08 08:00:00'); -- 2008-08-09 08:00:00
select date_add('2008-08-08 08:00:00', interval 1 day); -- 2008-08-09 08:00:00

MySQL timestampadd() 函数类似于 date_add()。
select timestampdiff(year,'2002-05-01','2001-01-01'); -- -1
select timestampdiff(day ,'2002-05-01','2001-01-01'); -- -485
select timestampdiff(hour,'2008-08-08 12:00:00','2008-08-08 00:00:00'); -- -12

select datediff('2008-08-08 12:00:00', '2008-08-01 00:00:00'); -- 7
```

MySQL timestampdiff() 函数就比 datediff() 功能强多了，datediff() 只能计算两个日期（date）之间相差的天数。


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

说明这五天之间相差了4天。

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