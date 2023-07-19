资料来源：<br/>
[Java计时新姿势StopWatch](https://juejin.cn/post/6935807854188167175)



## Java计时

 有时我们在做开发的时候需要记录每个任务执行时间，或者记录一段代码执行时间，最简单的方法就是打印当前时间与执行完时间的差值，一般我们检测某段代码执行的时间，都是以如下方式来进行的

```java
public static void main(String[] args) {
  Long startTime = System.currentTimeMillis();
  // 你的业务代码
  Long endTime = System.currentTimeMillis();
  Long elapsedTime = (endTime - startTime) / 1000;
  System.out.println("该段总共耗时：" + elapsedTime + "s");
}

```

 事实上该方法通过获取执行完成时间与执行开始时间的差值得到程序的执行时间，简单直接有效，但想必写多了也是比较烦人的，尤其是碰到不可描述的代码时，会更加的让人忍不住多写几个bug聊表敬意，而且如果想对执行的时间做进一步控制，则需要在程序中很多地方修改。

- **org.springframework.util.StopWatch**

- **org.apache.commons.lang.time.StopWatch**

- 谷歌提供的`guava`中的秒表

## spring下的StopWatch

**StopWatch** 是位于 **org.springframework.util** 包下的一个工具类，通过它可方便的对程序部分代码进行计时(ms级别)，适用于同步单线程代码块。简单总结一句，Spring提供的计时器StopWatch对于秒、毫秒为单位方便计时的程序，尤其是单线程、顺序执行程序的时间特性的统计输出支持比较好。也就是说假如我们手里面有几个在顺序上前后执行的几个任务，而且我们比较关心几个任务分别执行的时间占用状况，希望能够形成一个不太复杂的日志输出，StopWatch提供了这样的功能。而且Spring的StopWatch基本上也就是仅仅为了这样的功能而实现。
 想要使用它，首先你需要在你的 Maven 中引入 Spring 核心包，当然 Spring MVC 和 Spring Boot 都已经自动引入了该包：

```xml
<!-- https://mvnrepository.com/artifact/org.springframework/spring-core -->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-core</artifactId>
    <version>${spring.version}</version>
</dependency>

```

都是从使用开始，那就先来看看它的用法，会如下所示

### 代码案例

```java

import org.springframework.util.StopWatch;

public class SpringStopWatch {

    public static void main(String[] args) throws InterruptedException {
        StopWatch stopWatch = new StopWatch();

        // 任务一模拟休眠3秒钟
        stopWatch.start("TaskOneName");
        Thread.sleep(1000 * 3);
        System.out.println("当前任务名称：" + stopWatch.currentTaskName());
        stopWatch.stop();

        // 任务一模拟休眠10秒钟
        stopWatch.start("TaskTwoName");
        Thread.sleep(1000 * 10);
        System.out.println("当前任务名称：" + stopWatch.currentTaskName());
        stopWatch.stop();

        // 任务一模拟休眠10秒钟
        stopWatch.start("TaskThreeName");
        Thread.sleep(1000 * 10);
        System.out.println("当前任务名称：" + stopWatch.currentTaskName());
        stopWatch.stop();

        // 打印出耗时
        System.out.println(stopWatch.prettyPrint());
        System.out.println(stopWatch.shortSummary());
        // stop后它的值为null
        System.out.println(stopWatch.currentTaskName());

        // 最后一个任务的相关信息
        System.out.println(stopWatch.getLastTaskName());
        System.out.println(stopWatch.getLastTaskInfo());

        // 任务总的耗时  如果你想获取到每个任务详情（包括它的任务名、耗时等等）可使用
        System.out.println("所有任务总耗时：" + stopWatch.getTotalTimeMillis());
        System.out.println("任务总数：" + stopWatch.getTaskCount());
        System.out.println("所有任务详情：" + stopWatch.getTaskInfo());
    }
//

}
```

### 常用的方法

| 方法                         | 说明                               |
| ---------------------------- | ---------------------------------- |
| **new StopWatch()**          | 构建一个新的秒表，不开始任何任务。 |
| **new StopWatch(String id)** | 创建一个指定了id的StopWatch        |
| **String getId()** | 返回此秒表的ID |
| **void start(String taskName)** | 不传入参数，开始一个**无名称的任务**的计时。 传入String类型的参数来开始指定任务名的任务计时 |
| **void stop()** | 停止当前任务的计时 |
| **boolean isRunning()** | 是否正在计时某任务 |
| **String currentTaskName()** | 当前正在运行的任务的名称（如果有） |
| **long getTotalTimeMillis()** | 所有任务的总体执行时间(毫秒单位) |
| **double getTotalTimeSeconds()** | 所有任务的总时间（以秒为单位） |
| **String getLastTaskName()** | 上一个任务的名称 |
| **long getLastTaskTimeMillis()** | 上一个任务的耗时(毫秒单位) |
| **int getTaskCount()** | 定时任务的数量 |
| **String shortSummary()** | 总运行时间的简短描述 |
| **String prettyPrint()** | 优美地打印所有任务的详细耗时情况 |

### 注意

StopWatch对象不是设计为线程安全的，并且不使用同步。

一个StopWatch实例一次只能开启一个task，不能同时start多个task

在该task还没stop之前不能start一个新的task，必须在该task stop之后才能开启新的task

若要一次开启多个，需要new不同的StopWatch实例

## apache下的stopwatch

 StopWath是 **apache commons lang3** 包下的一个任务执行时间监视器，与我们平时常用的秒表的行为比较类似，我们先看一下其中的一些重要方法：

依赖的jar

```xml
<!-- https://mvnrepository.com/artifact/org.apache.commons/commons-lang3 -->
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-lang3</artifactId>
    <version>3.6</version>
</dependency>

```

  `Apache`提供的这个任务执行监视器功能丰富强大，灵活性强，如下经典实用案例：

### 代码案例

```java

import org.apache.commons.lang3.time.StopWatch;

import java.util.concurrent.TimeUnit;

public class ApacheStopWatchDemo {
//     作者：独泪了无痕
//    链接：https://juejin.cn/post/6935807854188167175
//    来源：稀土掘金
//    著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

    public static void main(String[] args) throws InterruptedException {
        //创建后立即start，常用
        StopWatch watch = StopWatch.createStarted();

        // StopWatch watch = new StopWatch();
        // watch.start();

        Thread.sleep(1000);
        System.out.println(watch.getTime());
        System.out.println("统计从开始到现在运行时间：" + watch.getTime() + "ms");  //1008ms

        Thread.sleep(1000);
        watch.split();
        System.out.println("从start到此刻为止的时间：" + watch.getTime());  //2018
        System.out.println("从开始到第一个切入点运行时间：" + watch.getSplitTime()); //2018


        Thread.sleep(1000);
        watch.split();
        System.out.println("从开始到第二个切入点运行时间：" + watch.getSplitTime());  //3025

        // 复位后, 重新计时
        watch.reset();
        watch.start();
        Thread.sleep(1000);
        System.out.println("重新开始后到当前运行时间是：" + watch.getTime());  //1004

        // 暂停 与 恢复
        watch.suspend();
        System.out.println("暂停2秒钟");
        Thread.sleep(2000);

        // 上面suspend，这里要想重新统计，需要恢复一下
        watch.resume();
        System.out.println("恢复后执行的时间是：" + watch.getTime());

        Thread.sleep(1000);
        watch.stop();

        System.out.println("花费的时间》》" + watch.getTime() + "ms");
        // 直接转成s
        System.out.println("花费的时间》》" + watch.getTime(TimeUnit.SECONDS) + "s");
    }

}
```

### 常用的方法

StopWath是 **apache commons lang3** 包下的一个任务执行时间监视器，与我们平时常用的秒表的行为比较类似，我们先看一下其中的一些重要方法：

| 方法                                      | 说明                                   |
| ----------------------------------------- | -------------------------------------- |
| **new StopWatch()**                       | 构建一个新的秒表，不开始任何任务。     |
| **static StopWatch createStarted()**      |                                        |
| **void start()**                          | 开始计时                               |
| **void stop()**                           | 停止当前任务的计时                     |
| **void reset()**                          | 重置计时                               |
| **void split()**                          | 设置split点                            |
| **void unsplit()**                        |                                        |
| **void suspend()**                        | 暂停计时, 直到调用resume()后才恢复计时 |
| **void resume()**                         | 恢复计时                               |
| **long getTime()**                        | 统计从start到现在的计时                |
| **long getTime(final TimeUnit timeUnit)** |                                        |
| **long getNanoTime()**                    |                                        |
| **long getSplitTime()**                   | 获取从start 到 最后一次split的时间     |
| **long getSplitNanoTime()**               |                                        |
| **long getStartTime()**                   |                                        |
| **boolean isStarted()**                   |                                        |
| **boolean isSuspended()**                 |                                        |
| **boolean isStopped()**                   |                                        |