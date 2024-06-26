## corn表达式

### 规则介绍

corn 从左到右（用空格隔开）：秒 分 小时 月份中的日期 月份 星期中的日期 年份

| 字段             | 允许值                       | 允许的特殊字符         |
| -------------- | ------------------------- | --------------- |
| 秒（Seconds）     | 0~59 的整数                  | , - * /         |
| 分（Minutes）     | 0~59 的整数                  | , - * /         |
| 小时（Hours）      | 0~23 的整数                  | , - * /         |
| 日期（DayofMonth） | 1~31 的整数                  | ,- * ? / L W C  |
| 月份（Month）      | 1~12 的整数或者 JAN-DEC        | , - * /         |
| 星期（DayofWeek）  | 1~7 的整数或者 SUN-SAT （1=SUN） | , - * ? / L C # |
| 年(可选，留空)（Year） | 1970~2099                 | , - * /         |

- `*`：表示匹配该域的任意值。假如在 Minutes 域使用*, 即表示每分钟都会触发事件。
- `?`：只能用在 DayofMonth 和 DayofWeek 两个域。
- `-`：表示范围。例如在 Minutes 域使用 5-20，表示从 5 分到 20 分钟每分钟触发一次
- `/`：表示起始时间开始触发，然后每隔固定时间触发一次。
- `,`：表示列出枚举值。例如：在 Minutes 域使用 5,20，则意味着在 5 和 20 分每分钟触发一次。
- `L`：表示最后，只能出现在 DayofWeek 和 DayofMonth 域。
- `W`:表示有效工作日(周一到周五),只能出现在 DayofMonth 域，系统将在离指定日期的最近的有效工作日触发事件。
- `LW`:这两个字符可以连用，表示在某个月最后一个工作日，即最后一个星期五。
- `#`:用于确定每个月第几个星期几，只能出现在 DayofMonth 域。例如在 4#2，表示某月的第二个星期三。

### 常用表达式例子

- `0 0 2 1 * ? *` 表示在每月的 1 日的凌晨 2 点调整任务
- `0 15 10 ? * MON-FRI` 表示周一到周五每天上午 10:15 执行作业
- `0 15 10 ? 6L 2002-2006` 表示 2002-2006 年的每个月的最后一个星期五上午 10:15 执行作
- `0 0 10,14,16 * * ?` 每天上午 10 点，下午 2 点，4 点
- `0 0/30 9-17 * * ?` 朝九晚五工作时间内每半小时
- `0 0 12 ? * WED` 表示每个星期三中午 12 点
- `0 0 12 * * ?` 每天中午 12 点触发
- `0 15 10 ? * *` 每天上午 10:15 触发
- `0 15 10 * * ?`  每天上午 10:15 触发
- `0 15 10 * * ? *` 每天上午 10:15 触发
- `0 15 10 * * ? 2005` 2005 年的每天上午 10:15 触发
- `0 * 14 * * ?` 在每天下午 2 点到下午 2:59 期间的每 1 分钟触发
- `0 0/5 14 * * ?` 在每天下午 2 点到下午 2:55 期间的每 5 分钟触发
- `0 0/5 14,18 * * ?` 在每天下午 2 点到 2:55 期间和下午 6 点到 6:55 期间的每 5 分钟触发
- `0 0-5 14 * * ?` 在每天下午 2 点到下午 2:05 期间的每 1 分钟触发
- `0 10,44 14 ? 3 WED` 每年三月的星期三的下午 2:10 和 2:44 触发
- `0 15 10 ? * MON-FRI` 周一至周五的上午 10:15 触发
- `0 15 10 15 * ?` 每月 15 日上午 10:15 触发
- `0 15 10 L * ?` 每月最后一日的上午 10:15 触发
- `0 15 10 ? * 6L` 每月的最后一个星期五上午 10:15 触发
- `0 15 10 ? * 6L 2002-2005` 2002 年至 2005 年的每月的最后一个星期五上午 10:15 触发
- `0 15 10 ? * 6#3` 每月的第三个星期五上午 10:1 触发