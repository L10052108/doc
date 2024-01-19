资料来源：<br/>
[Spring Boot + Disruptor = 王炸！](https://mp.weixin.qq.com/s/0iG5brK3bYF0BgSjX4jRiA)

## Disruptor 

`Disruptor` 是一个开源的高性能内存队列，由英国外汇交易公司 LMAX 开发的，获得了 2011 年的 Oracle 官方的 Duke's Choice Awards(Duke 选择大奖)。

![图片](img\640.png)

> “Duke 选择大奖”旨在表彰过去一年里全球个人或公司开发的、最具影响力的 Java 技术应用，由甲骨文公司主办。含金量非常高！

我专门找到了 Oracle 官方当年颁布获得 Duke's Choice Awards 项目的那篇文章（文章地址：**https://blogs.oracle.com/java/post/and-the-winners-arethe-dukes-choice-award**） 。从文中可以看出，同年获得此大奖荣誉的还有大名鼎鼎的 Netty 、JRebel 等项目。

![图片](img\641.png)2011 年的 Oracle 官方的 Duke's Choice Awards

并且，有一些知名的开源项目到了 `Disruptor` ，就比如性能强大的 Java 日志框架 **Log4j 2**[1] 和蚂蚁金服分布式链路跟踪组件 **SOFATracer**[2] 就是基于 Disruptor 来做的异步日志，相关阅读：**蚂蚁金服分布式链路跟踪组件 SOFATracer 中 Disruptor 实践（含源码）**[3]。

![图片](img\642.png)

`Disruptor` 提供的功能类似于 `Kafka`、`RocketMQ` 这类分布式队列，不过，其作为范围是 JVM(内存)。

- Github 地址：**https://github.com/LMAX-Exchange/disruptor**
- 官方教程：**https://lmax-exchange.github.io/disruptor/user-guide/index.html**

`Disruptor` 解决了 JDK 内置线程安全队列的性能和内存安全问题。

JDK 中常见的线程安全的队列如下：

| 队列名字                | 锁                      | 是否有界 |
| :---------------------- | :---------------------- | :------- |
| `ArrayBlockingQueue`    | 加锁（`ReentrantLock`） | 有界     |
| `LinkedBlockingQueue`   | 加锁（`ReentrantLock`） | 有界     |
| `LinkedTransferQueue`   | 无锁（`CAS`）           | 无界     |
| `ConcurrentLinkedQueue` | 无锁（`CAS`）           | 无界     |

从上表中可以看出：这些队列要不就是加锁有界，要不就是无锁无界。而加锁的的队列势必会影响性能，无界的队列又存在内存溢出的风险。

因此，一般情况下，我们都是不建议使用 JDK 内置线程安全队列。

`Disruptor` 就不一样了！它在无锁的情况下还能保证队列有界，并且还是线程安全的。

不过， **`Disruptor` 的基本使用非常简单，我们最重要的还是要搞懂其原理，明白它是如何被设计成这么厉害的并发框架。**

## Disruptor 核心概念

- **Event** ：你可以把 Event 理解为存放在队列中等待消费的消息对象。
- **EventFactory** ：事件工厂用于生产事件，我们在初始化 `Disruptor` 类的时候需要用到。
- **EventHandler** ：Event 在对应的 Handler 中被处理，你可以将其理解为生产消费者模型中的消费者。
- **EventProcessor** ：EventProcessor 持有特定消费者(Consumer)的 Sequence，并提供用于调用事件处理实现的事件循环(Event Loop)。
- **Disruptor** ：事件的生产和消费需要用到`Disruptor` 对象。
- **RingBuffer** ：RingBuffer（环形数组）用于保存事件。
- **WaitStrategy** ：等待策略。决定了没有事件可以消费的时候，事件消费者如何等待新事件的到来。
- **Producer** ：生产者，只是泛指调用 Disruptor 发布事件的用户代码，Disruptor 没有定义特定接口或类型。
- **ProducerType** ：指定是单个事件发布者模式还是多个事件发布者模式（发布者和生产者的意思类似，我个人比较喜欢用发布者）。
- **Sequencer** ：Sequencer 是 Disruptor 的真正核心。此接口有两个实现类 SingleProducerSequencer、MultiProducerSequencer ，它们定义在生产者和消费者之间快速、正确地传递数据的并发算法。

![图片](img\643.png)LMAX Disruptor User Guide

## Disruptor 实战

引入jar

```xml
<dependency>
    <groupId>com.lmax</groupId>
    <artifactId>disruptor</artifactId>
    <version>3.4.4</version>
</dependency>
```

我们要使用 `Disruptor` 实现一个最基本的生产消费模型的整个步骤是下面这样的（标准的生产消费者模型）：

1. **定义事件（Event）** : 你可以把 Event 理解为存放在队列中等待消费的消息对象。
2. **创建事件工厂** ：事件工厂用于生产事件，我们在初始化 `Disruptor` 类的时候需要用到。
3. **创建处理事件的 `Handler`** ：Event 在对应的 Handler 中被处理，你可以将其理解为生产消费者模型中的消费者。
4. **创建并启动 `Disruptor`** : 事件的生产和消费需要用到`Disruptor` 对象。
5. **发布事件** ：发布的事件保存在 `Disruptor` 的环形数组中。
6. **关闭 `Disruptor`** ：类似于线程池的关闭。

整个步骤看似比较复杂，其实，逻辑还是比较简单的。我们需要围绕事件（Event）和`Disruptor`来做文章。



方式一

```java
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.dsl.Disruptor;
import com.lmax.disruptor.util.DaemonThreadFactory;

import java.nio.ByteBuffer;

public class LongEventMain2 {

    public static void handleEvent(LongEvent event, long sequence, boolean endOfBatch)
    {
        System.out.println(event);
    }

    public static void translate(LongEvent event, long sequence, ByteBuffer buffer)
    {
        event.set(buffer.getLong(0));
    }

    public static void main(String[] args) throws Exception
    {
        int bufferSize = 1024;

        Disruptor<LongEvent> disruptor =
                new Disruptor<>(LongEvent::new, bufferSize, DaemonThreadFactory.INSTANCE);
        disruptor.handleEventsWith(LongEventMain2::handleEvent);
        disruptor.start();

        RingBuffer<LongEvent> ringBuffer = disruptor.getRingBuffer();
        ByteBuffer bb = ByteBuffer.allocate(8);
        for (long l = 0; true; l++)
        {
            bb.putLong(0, l);
            ringBuffer.publishEvent(LongEventMain2::translate, bb);
            Thread.sleep(1000);
        }
    }
}
```

方式二

*Example* `LongEvent`

```java

public class LongEvent
{
    private long value;

    public void set(long value)
    {
        this.value = value;
    }

    @Override
    public String toString()
    {
        return "LongEvent{" + "value=" + value + '}';
    }
}
```

*Example* `LongEventFactory`

```java
import com.lmax.disruptor.EventFactory;

public class LongEventFactory implements EventFactory<LongEvent>
{
    @Override
    public LongEvent newInstance()
    {
        return new LongEvent();
    }
}
```

*Example* `LongEventHandler`

```java
import com.lmax.disruptor.EventHandler;

public class LongEventHandler implements EventHandler<LongEvent>
{
    @Override
    public void onEvent(LongEvent event, long sequence, boolean endOfBatch)
    {
        System.out.println("Event: " + event);
    }
}
```

*Publishing events using lambdas*

```java
import com.lmax.disruptor.dsl.Disruptor;
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.util.DaemonThreadFactory;
import java.nio.ByteBuffer;

public class LongEventMain
{
    public static void main(String[] args) throws Exception
    {
        int bufferSize = 1024;

        Disruptor<LongEvent> disruptor =
                new Disruptor<>(LongEvent::new, bufferSize, DaemonThreadFactory.INSTANCE);

        disruptor.handleEventsWith((event, sequence, endOfBatch) ->
                System.out.println("Event: " + event));
        disruptor.start();


        RingBuffer<LongEvent> ringBuffer = disruptor.getRingBuffer();
        ByteBuffer bb = ByteBuffer.allocate(8);
        for (long l = 0; true; l++)
        {
            bb.putLong(0, l);
            ringBuffer.publishEvent((event, sequence, buffer) -> event.set(buffer.getLong(0)), bb);
            Thread.sleep(1000);
        }
    }


}
```

