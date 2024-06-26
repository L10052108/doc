资料来源：<br/>
[面渣逆袭：MySQL六十六问，两万字+五十图详解！](https://www.toutiao.com/article/7227085009981784637/)



## 基础

作为SQL Boy，基础部分不会有人不会吧？面试也不怎么问，基础掌握不错的小伙伴可以**跳过**这一部分。当然，可能会现场写一些SQL语句，SQ语句可以通过牛客、LeetCode、LintCode之类的网站来练习。

### 1. 什么是内连接、外连接、交叉连接、笛卡尔积呢？

- 内连接（inner join）：取得两张表中满足存在连接匹配关系的记录。
- 外连接（outer join）：不只取得两张表中满足存在连接匹配关系的记录，还包括某张表（或两张表）中不满足匹配关系的记录。
- 交叉连接（cross join）：显示两张表所有记录一一对应，没有匹配关系进行筛选，它是笛卡尔积在SQL中的实现，如果A表有m行，B表有n行，那么A和B交叉连接的结果就有m*n行。
- 笛卡尔积：是数学中的一个概念，例如集合A={a,b}，集合B={1,2,3}，那么A✖️B={<a,o>,<a,1>,<a,2>,<b,0>,<b,1>,<b,2>,}。

### 2. 那MySQL 的内连接、左连接、右连接有有什么区别？

MySQL的连接主要分为内连接和外连接，外连接常用的有左连接、右连接。

![img](img/fec929efc0f94e50b23f36b2ae89a693~noop.image ':size=50%')



- inner join 内连接，在两张表进行连接查询时，只保留两张表中完全匹配的结果集
- left join 在两张表进行连接查询时，会返回左表所有的行，即使在右表中没有匹配的记录。
- right join 在两张表进行连接查询时，会返回右表所有的行，即使在左表中没有匹配的记录。

### 3.说一下数据库的三大范式？

![img](img/226ce58d170b486daa03e1fed1348780~noop.image  ':size=50%')



- 第一范式：数据表中的每一列（每个字段）都不可以再拆分。 例如用户表，用户地址还可以拆分成国家、省份、市，这样才是符合第一范式的。
- 第二范式：在第一范式的基础上，非主键列完全依赖于主键，而不能是依赖于主键的一部分。 例如订单表里，存储了商品信息（商品价格、商品类型），那就需要把商品ID和订单ID作为联合主键，才满足第二范式。
- 第三范式：在满足第二范式的基础上，表中的非主键只依赖于主键，而不依赖于其他非主键。 例如订单表，就不能存储用户信息（姓名、地址）。



三大范式的作用是为了控制数据库的冗余，是对空间的节省，实际上，一般互联网公司的设计都是反范式的，通过冗余一些数据，避免跨表跨库，利用空间换时间，提高性能。

### 4.varchar与char的区别？

![img](img/38ef9e48d5cc483bbae0e55edfd4afbb~noop.image  ':size=60%')



**char**：

- char表示定长字符串，长度是固定的；
- 如果插入数据的长度小于char的固定长度时，则用空格填充；
- 因为长度固定，所以存取速度要比varchar快很多，甚至能快50%，但正因为其长度固定，所以会占据多余的空间，是空间换时间的做法；
- 对于char来说，最多能存放的字符个数为255，和编码无关

**varchar**：

- varchar表示可变长字符串，长度是可变的；
- 插入的数据是多长，就按照多长来存储；
- varchar在存取方面与char相反，它存取慢，因为长度不固定，但正因如此，不占据多余的空间，是时间换空间的做法；
- 对于varchar来说，最多能存放的字符个数为65532

日常的设计，对于长度相对固定的字符串，可以使用char，对于长度不确定的，使用varchar更合适一些。

### 5.blob和text有什么区别？

- blob用于存储二进制数据，而text用于存储大字符串。
- blob没有字符集，text有一个字符集，并且根据字符集的校对规则对值进行排序和比较

### 6.DATETIME和TIMESTAMP的异同？

**相同点**：

1. 两个数据类型存储时间的表现格式一致。均为 YYYY-MM-DD HH:MM:SS
2. 两个数据类型都包含「日期」和「时间」部分。
3. 两个数据类型都可以存储微秒的小数秒（秒后6位小数秒）

**区别**：

![img](img/98a7b69f5b0b42f4903374aaff131d3e~noop.image  ':size=50%')



1. **日期范围**：DATETIME 的日期范围是 1000-01-01 00:00:00.000000 到 9999-12-31 23:59:59.999999；TIMESTAMP 的时间范围是1970-01-01 00:00:01.000000 UTC到 ``2038-01-09 03:14:07.999999 UTC
2. **存储空间**：DATETIME 的存储空间为 8 字节；TIMESTAMP 的存储空间为 4 字节
3. **时区相关**：DATETIME 存储时间与时区无关；TIMESTAMP 存储时间与时区有关，显示的值也依赖于时区
4. **默认值**：DATETIME 的默认值为 null；TIMESTAMP 的字段默认不为空(not null)，默认值为当前时间(CURRENT_TIMESTAMP)

### 7.MySQL中 in 和 exists 的区别？

MySQL中的in语句是把外表和内表作hash 连接，而exists语句是对外表作loop循环，每次loop循环再对内表进行查询。我们可能认为exists比in语句的效率要高，这种说法其实是不准确的，要区分情景：

1. 如果查询的两个表大小相当，那么用in和exists差别不大。
2. 如果两个表中一个较小，一个是大表，则子查询表大的用exists，子查询表小的用in。
3. not in 和not exists：如果查询语句使用了not in，那么内外表都进行全表扫描，没有用到索引；而not extsts的子查询依然能用到表上的索引。所以无论那个表大，用not exists都比not in要快。

### 8.MySQL里记录货币用什么字段类型比较好？

货币在数据库中MySQL常用Decimal和Numric类型表示，这两种类型被MySQL实现为同样的类型。他们被用于保存与货币有关的数据。

例如salary DECIMAL(9,2)，9(precision)代表将被用于存储值的总的小数位数，而2(scale)代表将被用于存储小数点后的位数。存储在salary列中的值的范围是从-9999999.99到9999999.99。

DECIMAL和NUMERIC值作为字符串存储，而不是作为二进制浮点数，以便保存那些值的小数精度。

之所以不使用float或者double的原因：因为float和double是以二进制存储的，所以有一定的误差。

### 9.MySQL怎么存储emoji?

MySQL可以直接使用字符串存储emoji。

但是需要注意的，utf8 编码是不行的，MySQL中的utf8是阉割版的 utf8，它最多只用 3 个字节存储字符，所以存储不了表情。那该怎么办？

需要使用utf8mb4编码。

```
alter table blogs modify content text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci not null;
```

### 10.drop、delete与truncate的区别？

三者都表示删除，但是三者有一些差别：

|          | delete                                   | truncate                       | drop                                               |
| -------- | ---------------------------------------- | ------------------------------ | -------------------------------------------------- |
| 类型     | 属于DML                                  | 属于DDL                        | 属于DDL                                            |
| 回滚     | 可回滚                                   | 不可回滚                       | 不可回滚                                           |
| 删除内容 | 表结构还在，删除表的全部或者一部分数据行 | 表结构还在，删除表中的所有数据 | 从数据库中删除表，所有数据行，索引和权限也会被删除 |
| 删除速度 | 删除速度慢，需要逐行删除                 | 删除速度快                     | 删除速度最快                                       |

因此，在不再需要一张表的时候，用drop；在想删除部分数据行时候，用delete；在保留表而删除所有数据的时候用truncate。

### 11.UNION与UNION ALL的区别？

- 如果使用UNION ALL，不会合并重复的记录行
- 效率 UNION 高于 UNION ALL

### 12.count(1)、count(*) 与 count(列名) 的区别？

![img](img/b981fbf8ffc64447887aec01109fb712~noop.image  ':size=50%')



**执行效果**：

- count(*)包括了所有的列，相当于行数，在统计结果的时候，不会忽略列值为NULL
- count(1)包括了忽略所有列，用1代表代码行，在统计结果的时候，不会忽略列值为NULL
- count(列名)只包括列名那一列，在统计结果的时候，会忽略列值为空（这里的空不是只空字符串或者0，而是表示null）的计数，即某个字段值为NULL时，不统计。

**执行速度**：

- 列名为主键，count(列名)会比count(1)快
- 列名不为主键，count(1)会比count(列名)快
- 如果表多个列并且没有主键，则 count（1） 的执行效率优于 count（*）
- 如果有主键，则 select count（主键）的执行效率是最优的
- 如果表只有一个字段，则 select count（*）最优。

### 13.一条SQL查询语句的执行顺序？

![img](img/4e670a8a45c54527b922f532e35e03cc~noop.image ':size=70%')


1. **FROM**：对FROM子句中的左表<left_table>和右表<right_table>执行笛卡儿积（Cartesianproduct），产生虚拟表VT1
2. **ON**：对虚拟表VT1应用ON筛选，只有那些符合<join_condition>的行才被插入虚拟表VT2中
3. **JOIN**：如果指定了OUTER JOIN（如LEFT OUTER JOIN、RIGHT OUTER JOIN），那么保留表中未匹配的行作为外部行添加到虚拟表VT2中，产生虚拟表VT3。如果FROM子句包含两个以上表，则对上一个连接生成的结果表VT3和下一个表重复执行步骤1）～步骤3），直到处理完所有的表为止
4. **WHERE**：对虚拟表VT3应用WHERE过滤条件，只有符合<where_condition>的记录才被插入虚拟表VT4中
5. **GROUP BY**：根据GROUP BY子句中的列，对VT4中的记录进行分组操作，产生VT5
6. **CUBE|ROLLUP**：对表VT5进行CUBE或ROLLUP操作，产生表VT6
7. **HAVING**：对虚拟表VT6应用HAVING过滤器，只有符合<having_condition>的记录才被插入虚拟表VT7中。
8. **SELECT**：第二次执行SELECT操作，选择指定的列，插入到虚拟表VT8中
9. **DISTINCT**：去除重复数据，产生虚拟表VT9
10. **ORDER BY**：将虚拟表VT9中的记录按照<order_by_list>进行排序操作，产生虚拟表VT10。11）
11. **LIMIT**：取出指定行的记录，产生虚拟表VT11，并返回给查询用户

- 