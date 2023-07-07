资料来源：

[MyBatisPlus Insert以及自动生成ID策略](https://blog.csdn.net/qq_56403015/article/details/128505164)



## Insert以及自动生成ID策略

在[pojo类](https://so.csdn.net/so/search?q=pojo类&spm=1001.2101.3001.7020)中设置id的字段，并且为其配置类型。（默认为ASSIGN_ID

```java
private String name;
private int age;
@TableId(type = ASSIGN_ID)
private int bid;
private String datasource;
```

- **NONE**: 不设置id生成策略，MP不自动生成，约等于INPUT,所以这两种方式都需要用户手动设置，但是手动设置问题是容易出现相同的ID造成主键冲突。
- **AUTO**:数据库ID自增,这种策略适合在数据库服务器只有1台的情况下使用,不可作为分布式ID使用。
- **ASSIGN_UUID**:可以在分布式的情况下使用，而且能够保证唯一，但是生成的主键是32位的字符串，长度过长占用空间而且还不能排序，并且查询效率较低。
- **ASSIGN_ID**:可以在分布式的情况下使用，生成的是Long类型的数字，但是生成的策略和服务器时间有关，如果修改了系统时间就有可能导致出现重复主键。
- **INPUT**: 这种ID生成策略，需要将表的自增策略删除掉，一定要对ID进行输入，如果不进行输入就会报错。