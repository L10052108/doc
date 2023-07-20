资料来源：

[美团面试：为什么MySQL不建议使用NULL作为列默认值？](https://mp.weixin.qq.com/s/XAO048ZQljPXrTsmSr01LA)



## 为什么 MySQL 不建议使用 NULL 作为列默认值？

### 介绍

`NULL`值是一种对列的特殊约束,我们创建一个新列时,如果没有明确的使用关键字`not null`声明该数据列,`Mysql`会默认的为我们添加上`NULL`约束. 有些开发人员在创建数据表时,由于懒惰直接使用 Mysql 的默认推荐设置.(即允许字段使用`NULL`值).而这一陋习很容易在使用`NULL`的场景中得出不确定的查询结果以及引起数据库性能的下降.



`NULL`并不意味着什么都没有,我们要注意 `NULL` 跟 `''`(空值)是两个完全不一样的值.MySQL 中可以操作`NULL`值操作符主要有三个.

- `IS NULL`
- `IS NOT NULL`
- `<=>` 太空船操作符,这个操作符很像`=`,`select NULL<=>NULL`可以返回`true`,但是`select NULL=NULL`返回`false`.
- `IFNULL` 一个函数.怎么使用自己查吧…反正我会了

Example

Null never returns true when comparing with any other values except null with “<=>”.

`NULL`通过任一操作符与其它值比较都会得到`NULL`,除了`<=>`.