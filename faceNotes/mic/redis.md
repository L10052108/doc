

### 谈谈你对Redis的理解


文字教程 [「金九银十必问面试题」谈谈你对Redis的理解](https://www.toutiao.com/article/7141202477369688610/)<br/>
视频教程 [「金九银十必问面试题」谈谈你对Redis的理解](https://www.toutiao.com/video/7131992009057370655/)<br/>
准确来说，Redis是一个基于内存实现的Key-Value数据结构的Nosql数据库。

注意，这里有三个关键点。

- 内存存储
- key-value结构
- Nosql

所谓内存存储，是指所有数据是存储在内存里面，数据的IO性能比较高。

回答：

Redis是一个基于Key-Value存储结构的Nosql开源内存数据库。

它提供了5种常用的数据类型，String、Map、Set、ZSet、List。

针对不同的结构，可以解决不同场景的问题。

因此它可以覆盖应用开发中大部分的业务场景，比如top10问题、好友关注列表、热点话题等。

其次，由于Redis是基于内存存储，并且在数据结构上做了大量的优化

所以IO性能比较好，在实际开发中，会把它作为应用与数据库之间的一个分布式缓存组件。

并且它又是一个非关系型数据的存储，不存在表之间的关联查询问题，所以它可以很好的提升应用程序的数据IO效率。

最后，作为企业级开发来说，它又提供了主从复制+哨兵、以及集群方式实现高可用在Redis集群里面，通过hash槽的方式实现了数据分片，进一步提升了性能。
<hr/>

### Redis里面的持久化机制怎么回答

资料来源：[Redis里面的持久化机制怎么回答](https://www.toutiao.com/video/7100835616237191694/?from_scene=all)

#### 回答：

首先， Redis 本身是一个基于 Key-Value 结构的内存数据库， 为了避免 Redis 故障导致数据丢失的问题， 所以提供了 RDB 和 AOF 两种持久化机制。<br/>
RDB 是通过快照的方式来实现持久化的， 也就是说会根据快照的触发条件， 把内存里面的数据快照写入到磁盘，以二进制的压缩文件进行存储。

![image-20221005211401765](img/image-20221005211401765.png ':size=30%')

<br/>
RDB 快照的触发方式有很多， 比如执行 bgsave 命令触发异步快照， 执行 save命令触发同步快照， 同步快照会阻塞客户端的执行指令。<br/>
根据 redis.conf 文件里面的配置， 自动触发 bgsave 主从复制的时候触发 AOF持久化， 它是一种近乎实时的方式， 把 Redis Server 执行的事务命令进行追加存储。<br/>
简单来说， 就是客户端执行一个数据变更的操作， Redis Server 就会把这个命令追加到 aof 缓冲区的末尾， 然后再把缓冲区的数据写入到磁盘的 AOF 文件里面，至于最终什么时候真正持久化到磁盘， 是根据刷盘的策略来决定的。<br/>

![image-20221005211528152](img/image-20221005211528152.png ':size=30%')

另外， 因为 AOF 这种指令追加的方式， 会造成 AOF 文件过大， 带来明显的 IO性能问题， 所以 Redis 针对这种情况提供了 AOF 重写机制， 也就是说当 AOF
文件的大小达到某个阈值的时候， 就会把这个文件里面相同的指令进行压缩。<br/>

![image-20221005211634950](img/image-20221005211634950.png ':size=30%')

因此， 基于对 RDB 和 AOF 的工作原理的理解， 我认为 RDB 和 AOF 的优缺点有两个。<br/>
RDB 是每隔一段时间触发持久化， 因此数据安全性低， AOF 可以做到实时持久化， 数据安全性较高 RDB 文件默认采用压缩的方式持久化， AOF 存储的是执行
指令， 所以 RDB 在数据恢复的时候性能比 AOF 要好<br/>
在我看来， 所谓优缺点， 本质上其实是哪种方案更适合当前的应用场景而已。  <br/>


### Redis存在线程安全问题吗

资料来源：[Redis存在线程安全问题吗](https://www.toutiao.com/video/7090436681647522311/?from_scene=all)

好的， 关于这个问题， 我从两个方面来回答。
**第一个， 从 Redis 服务端层面。** <br/>
Redis Server 本身是一个线程安全的 K-V 数据库， 也就是说在 Redis Server 上执行的指令， 不需要任何同步机制， 不会存在线程安全问题。<br/>
虽然 Redis 6.0 里面， 增加了多线程的模型， 但是增加的多线程只是用来处理<br/>
网络 IO 事件， 对于指令的执行过程， 仍然是由主线程来处理， 所以不会存在多个线程通知执行操作指令的情况。<br/>

![image-20221005213307721](img/image-20221005213307721.png ':size=50%')

为什么 Redis 没有采用多线程来执行指令， 我认为有几个方面的原因。<br/>
Redis Server 本身可能出现的性能瓶颈点无非就是网络 IO、 CPU、 内存。 但是CPU 不是 Redis 的瓶颈点， 所以没必要使用多线程来执行指令。<br/>
如果采用多线程， 意味着对于 redis 的所有指令操作， 都必须要考虑到线程安全问题， 也就是说需要加锁来解决， 这种方式带来的性能影响反而更大。<br/>
**第二个， 从 Redis 客户端层面。**
虽然 Redis Server 中的指令执行是原子的， 但是如果有多个 Redis 客户端同时执行多个指令的时候， 就无法保证原子性。<br/>
假设两个 redis client 同时获取 Redis Server 上的 key1， 同时进行修改和写入，因为多线程环境下的原子性无法被保障， 以及多进程情况下的共享资源访问的竞争问题， 使得数据的安全性无法得到保障。<br/>

![image-20221005213333745](img/image-20221005213333745.png  ':size=50%')<br/>

当然， 对于客户端层面的线程安全性问题， 解决方法有很多， 比如尽可能的使用Redis 里面的原子指令， 或者对多个客户端的资源访问加锁， 或者通过 Lua 脚本来实现多个指令的操作等等。<br/>

### 缓存雪崩和缓存穿透的理解以及如何避免？

资料来源：[缓存雪崩和缓存穿透的理解以及如何避免？](https://www.toutiao.com/video/7081953754299400734/?from_scene=all)

缓存雪崩， 就是存储在缓存里面的大量数据， 在同一个时刻全部过期，原本缓存组件抗住的大部分流量全部请求到了数据库。导致数据库压力增加造成数据库服务器崩溃的现象<br/>

![image-20221005213713715](img/image-20221005213713715.png ':size=40%')

导致缓存雪崩的主要原因， 我认为有两个：<br/>
缓存中间件宕机， 当然可以对缓存中间件做高可用集群来避免。<br/>
缓存中大部分 key 都设置了相同的过期时间， 导致同一时刻这些 key 都过期了。<br/>
对于这样的情况， 可以在失效时间上增加一个 1 到 5 分钟的随机值。<br/>
缓存穿透问题， 表示是短时间内有大量的不存在的 key 请求到应用里面， 而这些不存在的 key 在缓存里面又找不到， 从而全部穿透到了数据库， 造成数据库压力。<br/>
我认为这个场景的核心问题是针对缓存的一种攻击行为， 因为在正常的业务里面，<br/>
即便是出现了这样的情况， 由于缓存的不断预热， 影响不会很大。<br/>
而攻击行为就需要具备时间是的持续性， 而只有 key 确实在数据库里面也不存在的情况下， 才能达到这个目的， 所以， 我认为有两个方法可以解决：<br/>
把无效的 key 也保存到 Redis 里面， 并且设置一个特殊的值， 比如“null”， 这样的话下次再来访问， 就不会去查数据库了。<br/>
但是如果攻击者不断用随机的不存在的 key 来访问， 也还是会存在问题， 所以可以用布隆过滤器来实现， 在系统启动的时候把目标数据全部缓存到布隆过滤器里
面， 当攻击者用不存在的 key 来请求的时候， 先到布隆过滤器里面查询， 如果不存在， 那意味着这个 key 在数据库里面也不存在。布隆过滤器还有一个好处， 就是它采用了 bitmap 来进行数据存储， 占用的内存空间很少<br/>

![image-20221005213912677](img/image-20221005213912677.png  ':size=40%')

不过， 在我看来， 您提出来的这个问题， 有点过于放大了它带来的影响。<br/>
首先， 在一个成熟的系统里面， 对于比较重要的热点数据， 必然会有一个专门缓存系统来维护， 同时它的过期时间的维护必然和其他业务的 key 会有一定的差别。<br/>
而且非常重要的场景， 我们还会设计多级缓存系统。<br/>
其次， 即便是触发了缓存雪崩， 数据库本身的容灾能力也并没有那么脆弱， 数据库的主从、 双主、 读写分离这些策略都能够很好的缓解并发流量。<br/>
最后， 数据库本身也有最大连接数的限制， 超过限制的请求会被拒绝， 再结合熔断机制， 也能够很好的保护数据库系统， 最多就是造成部分用户体验不好。<br/>
另外， 在程序设计上， 为了避免缓存未命中导致大量请求穿透到数据库的问题，还可以在访问数据库这个环节加锁。 虽然影响了性能， 但是对系统是安全的<br/>

![image-20221005214155934](img/image-20221005214155934.png   ':size=40%')

总而言之， 我认为解决的办法很多， 具体选择哪种方式， 还是看具体的业务场景。


### Redis的内存淘汰算法和原理是什么？

资料来源：[Redis的内存淘汰算法和原理是什么？](https://www.toutiao.com/video/7081226773366571550/?from_scene=all)

<hr/>


### Redis和Mysql如何保证数据一致性，如何高分回答？

资料来源：[Redis和Mysql如何保证数据一致性，如何高分回答？](https://www.toutiao.com/video/7078611818205151751/?from_scene=all)

<hr/>