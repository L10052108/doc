


### Kafka如何保证消息不丢失？

资料来源：[Kafka如何保证消息不丢失？](https://www.toutiao.com/video/7083432523916640799/?from_scene=all)



### Kafka怎么避免重复消费？

资料来源：[Kafka怎么避免重复消费？](https://www.toutiao.com/video/7099638175949128222/?from_scene=all)

#### 回答：

好的， 关于这问题， 我从几个方面来回答。<br/>
首先， Kafka Broker 上存储的消息， 都有一个 Offset 标记。<br/>
然后 kafka 的消费者是通过 offSet 标记来维护当前已经消费的数据，<br/>
每消费一批数据， Kafka Broker 就会更新 OffSet 的值， 避免重复消费<br/>

![image-20221005212051132](img/image-20221005212051132.png ':size=50%')

默认情况下， 消息消费完以后， 会自动提交 Offset 的值， 避免重复消费。<br/>
Kafka 消费端的自动提交逻辑有一个默认的 5 秒间隔， 也就是说在 5 秒之后的下一次向 Broker 拉取消息的时候提交。<br/>
所以在 Consumer 消费的过程中， 应用程序被强制 kill 掉或者宕机， 可能会导致Offset 没提交， 从而产生重复提交的问题。<br/>
除此之外， 还有另外一种情况也会出现重复消费。在 Kafka 里面有一个 Partition Balance 机制， 就是把多个 Partition 均衡的分配给多个消费者。<br/>
Consumer 端会从分配的 Partition 里面去消费消息， 如果 Consumer 在默认的 5分钟内没办法处理完这一批消息。<br/>
就会触发 Kafka 的 Rebalance 机制， 从而导致 Offset 自动提交失败。<br/>
而在重新 Rebalance 之后， Consumer 还是会从之前没提交的 Offset 位置开始消费， 也会导致消息重复消费的问题。<br/>

![image-20221005212250193](img/image-20221005212250193.png ':size=50%')

基于这样的背景下， 我认为解决重复消费消息问题的方法有几个。<br/>
提高消费端的处理性能避免触发 Balance， 比如可以用异步的方式来处理消息，<br/>
缩短单个消息消费的市场。 或者还可以调整消息处理的超时时间。 还可以减少一次性从 Broker 上拉取数据的条数  <br/>

可以针对消息生成 md5 然后保存到 mysql 或者 redis 里面， 在处理消息之前先去 mysql 或者 redis 里面判断是否已经消费过。 这个方案其实就是利用幂等性的思想。<br/>


###  什么叫阻塞队列的有界和无界?

资料来源：[ 什么叫阻塞队列的有界和无界?](https://www.toutiao.com/video/7075638697248424461/?from_scene=all)
