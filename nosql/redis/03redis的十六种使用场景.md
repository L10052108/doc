资料来源：<br/>
[16个 Redis 常见使用场景](https://mp.weixin.qq.com/s/c-86kFGd3M33sRsKhTUOPA)<br/>
[微服务Spring Boot 整合 Redis 实现 UV 数据统计](https://juejin.cn/post/7221373067229216826)<br/>



### 缓存

String类型

例如：热点数据缓存（例如报表、明星出轨），对象缓存、全页缓存、可以提升热点数据的访问数据。



### 分布式锁

String 类型setnx方法，只有不存在时才能添加成功，返回true

 ```java
public static boolean getLock(String key) {
    Long flag = jedis.setnx(key, "1");
    if (flag == 1) {
        jedis.expire(key, 10);
    }
    return flag == 1;
}

public static void releaseLock(String key) {
    jedis.del(key);
}
 ```

### 全局ID

int类型，incrby，利用原子性

```
incrby userid 1000
```

分库分表的场景，一次性拿一段

### **位统计**

String类型的bitcount（1.6.6的bitmap数据结构介绍）

字符是以8位二进制存储的

```java

set k1 a
setbit k1 6 1
setbit k1 7 0
get k1 
/* 6 7 代表的a的二进制位的修改
a 对应的ASCII码是97，转换为二进制数据是01100001
b 对应的ASCII码是98，转换为二进制数据是01100010

因为bit非常节省空间（1 MB=8388608 bit），可以用来做大数据量的统计。
*/
```

例如：在线用户统计，留存用户统计

```java
setbit onlineusers 01 
setbit onlineusers 11 
setbit onlineusers 20
```

```
BITOPANDdestkeykey[key...] ，对一个或多个 key 求逻辑并，并将结果保存到 destkey 。
BITOPORdestkeykey[key...] ，对一个或多个 key 求逻辑或，并将结果保存到 destkey 。
BITOPXORdestkeykey[key...] ，对一个或多个 key 求逻辑异或，并将结果保存到 destkey 。
BITOPNOTdestkeykey ，对给定 key 求逻辑非，并将结果保存到 destkey 。
```

计算出7天都在线的用户

```java
BITOP "AND" "7_days_both_online_users" "day_1_online_users" "day_2_online_users" ...  "day_7_online_users"
```

### **用户关注、推荐模型**

follow 关注 fans 粉丝

相互关注：

- sadd 1:follow 2
- sadd 2:fans 1
- sadd 1:fans 2
- sadd 2:follow 1

我关注的人也关注了他(取交集)：

- sinter 1:follow 2:fans

可能认识的人：

- 用户1可能认识的人(差集)：sdiff 2:follow 1:follow
- 用户2可能认识的人：sdiff 1:follow 2:follow

### **点赞、签到、打卡**

假如上面的微博ID是t1001，用户ID是u3001

![image-20230720170554814](img/image-20230720170554814.png)

用 like:t1001 来维护 t1001 这条微博的所有点赞用户

- 点赞了这条微博：sadd like:t1001 u3001
- 取消点赞：srem like:t1001 u3001
- 是否点赞：sismember like:t1001 u3001
- 点赞的所有用户：smembers like:t1001
- 点赞数：scard like:t1001

是不是比数据库简单多了。

### **消息队列**

List提供了两个阻塞的弹出操作：blpop/brpop，可以设置超时时间

- blpop：blpop key1 timeout 移除并获取列表的第一个元素，如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止。
- brpop：brpop key1 timeout 移除并获取列表的最后一个元素，如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止。



上面的操作。其实就是java的阻塞队列。学习的东西越多。学习成本越低

- 队列：先进先除：rpush blpop，左头右尾，右边进入队列，左边出队列
- 栈：先进后出：rpush brpop

### **排行榜**

id 为6001 的新闻点击数加1：zincrby hotNews:20190926 1 n6001

获取今天点击最多的15条：zrevrange hotNews:20190926 0 15 withscores

![image-20230720170621716](img/image-20230720170621716.png)

### UV统计



- UV：全称Unique Visitor，也叫独立访客量，是指通过互联网访问、浏览这个网页的自然人。1天内同一个用户多次访问该网站，只记录1次。
- PV：全称Page View，也叫页面访问量或点击量，用户每访问网站的一个页面，记录1次PV，用户多次打开页面，则记录多次PV。往往用来衡量网站的流量。

通常来说 UV 会比 PV 大很多，一个网站的独立访客量 和 页面访问或点击量，肯定是独立访客大的。

UV统计在服务端做会比较麻烦，因为要判断该用户是否已经统计过了，需要将统计过的用户信息保存。但是如果每个访问的用户都保存到Redis中，数据量会非常恐怖，那怎么处理呢？

Hyperloglog(HLL)是从Loglog算法派生的概率算法，用于确定非常大的集合的基数，而不需要存储其所有值。

Redis 中的HLL 是基于string数据结构实现的，单个**HLL的内存永远小于16kb**， 内存极低！作为代价，其测量结果是概率性的，**有小于0.81％的误差**。不过对于UV统计来说，这完全可以忽略。

**使用SpringBoot单元测试进行测试百万数据统计**

```java
@Test
void testHyperLoglog() {
    String[] values = new String[1000];
    int j = 0;
    for (int i = 0; i < 1000000; i++) {
        j = i % 1000;
        values[j] = "user" + i;
        if (j == 999) {
            //发送至redis
            stringRedisTemplate.opsForHyperLogLog().add("hl2", values);
        }
    }
    //统计数量
    Long count = stringRedisTemplate.opsForHyperLogLog().size("hl2");
    System.out.println("count = " + count);
}

```

**执行后，如下图**

![image-20230720171454404](img/image-20230720171454404.png ':size=40%')

**再次查看内存占比**

![image-20230720171513726](img/image-20230720171513726.png ':size=40%')

**可以看出占用大约为14KB，存储上百万数据只占用了14KB数据，可见HyperLogLog的强大！**