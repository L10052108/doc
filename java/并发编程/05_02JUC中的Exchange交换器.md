资料来源：

[说一下 JUC 中的 Exchange 交换器？](https://mp.weixin.qq.com/s/pMVAK8Pja6ZPgmAV1Vk58w)

## 说一下 JUC 中的 Exchange 交换器？

### 介绍

Exchange（交换器）顾名思义，它是用来实现两个线程间的数据交换的，它诞生于 JDK 1.5，它有两个核心方法：

- exchange(V x)：等待另一个线程到达此交换点，然后将对象传输给另一个线程，并从另一个线程中得到交换的对象。如果另一个线程未到达此交换点，那么此线程会一直休眠（除非遇了线程中断）。
- exchange(V x, long timeout, TimeUnit unit)：等待另一个线程到达此交换点，然后将对象传输给另一个线程，并从另一个线程中得到交换的对象。如果另一个线程未到达此交换点，那么此线程会一直休眠，直到遇了线程中断，或等待的时间超过了设定的时间，那么它会抛出异常。

也就是说 exchange 方法就是一个交换点，线程会等待在此交换点，直到有另一个线程也调用了 exchange 方法（相当于进入到了此交换点），这时他们会互换数据，然后执行后续的代码。



### 举例

Exchange 的基础使用如下，我们创建两个线程来模拟“一手交钱、一手交货”的场景，线程 1 先准备好钱进入交换点，然后等待线程 2 在 2s 之后准备好货（物），之后再彼此交互数据，执行后续的流程，具体实现代码如下：

```java
import java.time.LocalDateTime;
import java.util.concurrent.Exchanger;

public class ExchangeExample {
    // 创建一个交互器
    private final static Exchanger<String> exchange = new Exchanger<>();
    public static void main(String[] args) {
        // 线程 1【准备钱】
        new Thread(() -> {
            System.out.println("线程1：准备筹钱中...| Time：" + LocalDateTime.now());
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            String moeny = "1000 万";
            System.out.println("线程1：钱准备好了【1000 万】。| Time：" + 
                               LocalDateTime.now());
            try {
                // 执行数据交换【交易】
                String result = exchange.exchange(moeny);
                System.out.println("线程1：交易完成，得到【" + result +
                        "】 | Time：" + LocalDateTime.now());
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }).start();
        // 线程 2【准备货】
        new Thread(() -> {
            System.out.println("线程2：准备物品中【西伯利亚新鲜空气】...| Time：" + 
                               LocalDateTime.now());
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            String goods = "西伯利亚新鲜空气";
            System.out.println("线程2：物品准备好了【西伯利亚新鲜空气】。| Time：" + 
                               LocalDateTime.now());
            try {
                // 执行数据交换【交易】
                String result = exchange.exchange(goods);
                System.out.println("线程2：交易完成，得到【" + result +
                        "】 | Time：" + LocalDateTime.now());
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }).start();
    }
}
```

以上程序的执行结果如下：

![6sss40](img\6sss40.png)

### 总结

`Exchange` 交换器是用来实现两个线程间的数据交换的，`Exchanger `可以交互任意数据类型的数据，只要在创建的时候定义泛型类型即可。它的核心方法为` exchange`，当线程执行到此方法之后，会休眠等待另一个线程也进入交换点，如果另一个线程也进入了交换点（也执行到了 `exchange` 方法），此时二者会交换数据，并执行后续的流程。