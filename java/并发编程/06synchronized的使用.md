参考资料：
[synchronized有几种用法？](https://www.toutiao.com/article/7084973304461083147/?log_from=7edae50a4468c_1650417067942)<br/>
[synchronized底层是如何实现的？](https://www.toutiao.com/article/7085975495283638824/?log_from=889e4364d5fe9_1650417725485)<br/>
[死磕synchronized关键字底层原理](https://github.com/yehongzhi/learningSummary/blob/master/%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B%E7%9A%84%E8%89%BA%E6%9C%AF/%E6%AD%BB%E7%A3%95synchronized%E5%85%B3%E9%94%AE%E5%AD%97%E5%BA%95%E5%B1%82%E5%8E%9F%E7%90%86.md)

## synchronized有几种用法？

在 Java 语言中，保证线程安全性的主要手段是加锁，而 Java 中的锁主要有两种：synchronized 和 Lock，我们今天重点来看一下 synchronized 的几种用法。

使用 synchronized 无需手动执行加锁和释放锁的操作，我们只需要声明 synchronized 关键字就可以了，JVM 层面会帮我们自动的进行加锁和释放锁的操作。

synchronized 可用于修饰**普通方法、静态方法和代码块**，接下来我们分别来看。

### 修饰普通方法

synchronized 修饰普通方法的用法如下：

```java
/**
 * synchronized 修饰普通方法
 */
public synchronized void method() {
    // ....
}
```

当 synchronized 修饰普通方法时，被修饰的方法被称为同步方法，其作用范围是整个方法，作用的对象是调用这个方法的对象。

### 修饰静态方法
synchronized 修饰静态方法和修饰普通方法类似，它的用法如下：


```java
/**
 * synchronized 修饰静态方法
 */
public static synchronized void staticMethod() {
    // .......
}
```

当 synchronized 修饰静态方法时，其作用范围是整个程序，这个锁对于所有调用这个锁的对象都是互斥的。

所谓的互斥，指的是同一时间只能有一个线程能使用，其他线程只能排队等待。

### 修饰普通方法 VS 修饰静态方法

synchronized 修饰普通方法和静态方法看似相同，但二者完全不同，**对于静态方法来说 synchronized 加锁是全局的，也就是整个程序运行期间，所有调用这个静态方法的对象都是互斥的，而普通方法是针对对象级别的，不同的对象对应着不同的锁**，比如以下代码，同样是调用两次方法，但锁的获取完全不同，实现代码如下：

```java
import java.time.LocalDateTime;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class SynchronizedUsage {
    public static void main(String[] args) throws InterruptedException {
        // 创建线程池同时执行任务
        ExecutorService threadPool = Executors.newFixedThreadPool(10);

        // 执行两次静态方法
        threadPool.execute(() -> {
            staticMethod();
        });
        threadPool.execute(() -> {
            staticMethod();
        });
        
        // 执行两次普通方法
        threadPool.execute(() -> {
            SynchronizedUsage usage = new SynchronizedUsage();
            usage.method();
        });
        threadPool.execute(() -> {
            SynchronizedUsage usage2 = new SynchronizedUsage();
            usage2.method();
        });
    }

    /**
     * synchronized 修饰普通方法
     * 本方法的执行需要 3s（因为有 3s 的休眠时间）
     */
    public synchronized void method() {
        System.out.println("普通方法执行时间：" + LocalDateTime.now());
        try {
            // 休眠 3s
            TimeUnit.SECONDS.sleep(3);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    /**
     * synchronized 修饰静态方法
     * 本方法的执行需要 3s（因为有 3s 的休眠时间）
     */
    public static synchronized void staticMethod() {
        System.out.println("静态方法执行时间：" + LocalDateTime.now());
        try {
            // 休眠 3s
            TimeUnit.SECONDS.sleep(3);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

以上程序的执行结果如下：

![img](img\c3b76bf4eda5481d9987eefaac449824~noop.image)

从上述结果可以看出，**静态方法加锁是全局的，针对的是所有调用者；而普通方法加锁是对象级别的，不同的对象拥有的锁也不同。**

### 修饰代码块

我们在日常开发中，最常用的是给代码块加锁，而不是给方法加锁，因为给方法加锁，相当于给整个方法全部加锁，这样的话锁的粒度就太大了，程序的执行性能就会受到影响，所以通常情况下，我们会使用 synchronized 给代码块加锁，它的实现语法如下：

```java
public void classMethod() throws InterruptedException {
    // 前置代码...
    
    // 加锁代码
    synchronized (SynchronizedUsage.class) {
        // ......
    }
    
    // 后置代码...
}
```

从上述代码我们可以看出，相比于修饰方法，修饰代码块需要自己手动指定加锁对象，加锁的对象通常使用 this 或 xxx.class 这样的形式来表示，比如以下代码：

```java
// 加锁某个类
synchronized (SynchronizedUsage.class) {
    // ......
}

// 加锁当前类对象
synchronized (this) {
    // ......
}
```

使用 `synchronized `加锁` this `和` xxx.class` 是完全不同的，当加锁 `this `时，表示用当前的对象进行加锁，每个对象都对应了一把锁；而当使用` xxx.class` 加锁时，表示使用某个类（而非类实例）来加锁，它是应用程序级别的，是全局生效的，如以下代码所示：

```java
import java.time.LocalDateTime;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class SynchronizedUsageBlock {
    public static void main(String[] args) throws InterruptedException {
        // 创建线程池同时执行任务
        ExecutorService threadPool = Executors.newFixedThreadPool(10);

        // 执行两次 synchronized(this)
        threadPool.execute(() -> {
            SynchronizedUsageBlock usage = new SynchronizedUsageBlock();
            usage.thisMethod();
        });
        threadPool.execute(() -> {
            SynchronizedUsageBlock usage2 = new SynchronizedUsageBlock();
            usage2.thisMethod();
        });

        // 执行两次 synchronized(xxx.class)
        threadPool.execute(() -> {
            SynchronizedUsageBlock usage3 = new SynchronizedUsageBlock();
            usage3.classMethod();
        });
        threadPool.execute(() -> {
            SynchronizedUsageBlock usage4 = new SynchronizedUsageBlock();
            usage4.classMethod();
        });
    }

    /**
     * synchronized(this) 加锁
     * 本方法的执行需要 3s（因为有 3s 的休眠时间）
     */
    public void thisMethod() {
        synchronized (this) {
            System.out.println("synchronized(this) 加锁：" + LocalDateTime.now());
            try {
                // 休眠 3s
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * synchronized(xxx.class) 加锁
     * 本方法的执行需要 3s（因为有 3s 的休眠时间）
     */
    public void classMethod() {
        synchronized (SynchronizedUsageBlock.class) {
            System.out.println("synchronized(xxx.class) 加锁：" + LocalDateTime.now());
            try {
                // 休眠 3s
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
```

以上程序的执行结果如下：

![img](img\60051486548941b69139d82f633b9cd3~noop.image)

## synchronized锁的原理

在讲原理前，我们先讲一下Java对象的构成。在JVM中，对象在内存中分为三块区域：对象头，实例数据和对齐填充。

**对象头**：

- Mark Word，用于存储对象自身运行时的数据，如哈希码(Hash Code)，GC分代年龄，锁状态标志，偏向线程ID、偏向时间戳等信息，它会根据对象的状态复用自己的存储空间。它是**实现轻量级锁和偏向锁的关键**。
- 类型指针，对象会指向它的类的元数据的指针，虚拟机通过这个指针确定这个对象是哪个类的实例。
- Array length，如果对象是一个数组，还必须记录数组长度的数据。

**实例数据**：

- 存放类的属性数据信息，包括父类的属性信息。

**对齐填充**：

- 由于虚拟机要求 对象起始地址必须是8字节的整数倍。填充数据不是必须存在的，仅仅是为了字节对齐。

### 同步代码块原理

为了看底层实现原理，使用`javap -v xxx.class`命令进行反编译。

这是使用同步代码块被标志的地方就是刚刚提到的对象头，它会关联一个monitor对象，也就是括号括起来的对象。

1、**monitorenter**，如果当前monitor的进入数为0时，线程就会进入monitor，并且把进入数+1，那么该线程就是monitor的拥有者(owner)。

2、如果该线程已经是monitor的拥有者，又重新进入，就会把进入数再次+1。也就是可重入的。

3、**monitorexit**，执行monitorexit的线程必须是monitor的拥有者，指令执行后，monitor的进入数减1，如果减1后进入数为0，则该线程会退出monitor。其他被阻塞的线程就可以尝试去获取monitor的所有权。

> monitorexit指令出现了两次，第1次为同步正常退出释放锁；第2次为发生异步退出释放锁；

总的来说，synchronized的底层原理是通过monitor对象来完成的。

### 同步方法原理

比如说使用synchronized修饰的实例方法。

```java
public synchronized void hello(){
    System.out.println("hello world");
}
```

同理使用`javap -v`反编译。

可以看到多了一个标志位**ACC_SYNCHRONIZED**，作用就是一旦执行到这个方法时，就会先判断是否有标志位，如果有这个标志位，就会先尝试获取monitor，获取成功才能执行方法，方法执行完成后再释放monitor。**在方法执行期间，其他线程都无法获取同一个monitor**。归根结底还是对monitor对象的争夺，只是同步方法是一种隐式的方式来实现。

### Monitor

上面经常提到monitor，它内置在每一个对象中，任何一个对象都有一个monitor与之关联，synchronized在JVM里的实现就是基于进入和退出monitor来实现的，底层则是通过成对的MonitorEnter和MonitorExit指令来实现，因此每一个Java对象都有成为Monitor的潜质。所以我们可以理解monitor是一个同步工具。

## synchronized锁的优化

前面讲过JDK1.5之前，synchronized是属于重量级锁，重量级需要依赖于底层操作系统的Mutex Lock实现，然后操作系统需要切换用户态和内核态，这种切换的消耗非常大，所以性能相对来说并不好。

既然我们都知道性能不好，JDK的开发人员肯定也是知道的，于是在JDK1.6后开始对synchronized进行优化，增加了自适应的CAS自旋、锁消除、锁粗化、偏向锁、轻量级锁这些优化策略。锁的等级从无锁，偏向锁，轻量级锁，重量级锁逐步升级，并且是单向的，不会出现锁的降级。

### 自适应性自旋锁

在说自适应自旋锁之前，先讲自旋锁。上面已经讲过，当线程没有获得monitor对象的所有权时，就会进入阻塞，当持有锁的线程释放了锁，当前线程才可以再去竞争锁，但是如果按照这样的规则，就会浪费大量的性能在阻塞和唤醒的切换上，特别是线程占用锁的时间很短的话。

为了避免阻塞和唤醒的切换，在没有获得锁的时候就不进入阻塞，而是不断地循环检测锁是否被释放，这就是自旋。在占用锁的时间短的情况下，自旋锁表现的性能是很高的。

但是又有问题，由于线程是一直在循环检测锁的状态，就会占用cpu资源，如果线程占用锁的时间比较长，那么自旋的次数就会变多，占用cpu时间变长导致性能变差，当然我们也可以通过参数`-XX:PreBlockSpin`设置自旋锁的自旋次数，当自旋一定的次数(时间)后就挂起，但是设置的自旋次数是多少比较合适呢？

如果设置次数少了或者多了都会导致性能受到影响，而且占用锁的时间在业务高峰期和正常时期也有区别，所以在JDK1.6引入了自适应性自旋锁。

自适应性自旋锁的意思是，自旋的次数不是固定的，而是由前一次在同一个锁上的自旋时间及锁的拥有者的状态来决定。

表现是如果此次自旋成功了，很有可能下一次也能成功，于是允许自旋的次数就会更多，反过来说，如果很少有线程能够自旋成功，很有可能下一次也是失败，则自旋次数就更少。这样能最大化利用资源，随着程序运行和性能监控信息的不断完善，虚拟机对锁的状况预测会越来越准确，也就变得越来越智能。

### 锁消除

锁消除是一种锁的优化策略，这种优化更加彻底，在JVM编译时，通过对运行上下文的扫描，去除不可能存在共享资源竞争的锁。这种优化策略可以消除没有必要的锁，节省毫无意义的请求锁时间。比如StringBuffer的append()方法，就是使用synchronized进行加锁的。

```java
public synchronized StringBuffer append(String str) {
    toStringCache = null;
    super.append(str);
    return this;
}
```

如果在实例方法中StringBuffer作为局部变量使用append()方法，StringBuffer是不可能存在共享资源竞争的，因此会自动将其锁消除。例如：

```java
public String add(String s1, String s2) {
    //sb属于不可能共享的资源,JVM会自动消除内部的锁
    StringBuffer sb = new StringBuffer();
    sb.append(s1).append(s2);
    return sb.toString();
}
```

### 锁粗化

如果一系列的连续加锁解锁操作，可能会导致不必要的性能损耗，所以引入锁粗话的概念。意思是将多个连续加锁、解锁的操作连接在一起，扩展成为一个范围更大的锁。

### 偏向锁

偏向锁是JDK1.6引入的一个重要的概念，JDK的开发人员经过研究发现，在大多数情况下，锁不仅不存在多线程竞争，而且总是由同一线程多次获得。也就是说在很多时候我们是假设有多线程的场景，但是实际上却是单线程的。所以偏向锁是在单线程执行代码块时使用的机制。

原理是什么呢，我们前面提到锁的争夺实际上是Monitor对象的争夺，还有每个对象都有一个对象头，对象头是由Mark Word和Klass pointer 组成的。一旦有线程持有了这个锁对象，标志位修改为1，就进入**偏向模式**，同时会把这个**线程的ID记录在对象的Mark Word中**，当同一个线程再次进入时，就不再进行同步操作，这样就省去了大量的锁申请的操作，从而提高了性能。

一旦有多个线程开始竞争锁的话呢？那么偏向锁并不会一下子升级为重量级锁，而是先升级为轻量级锁。

### 轻量级锁

如果获取偏向锁失败，也就是有多个线程竞争锁的话，就会升级为JDK1.6引入的轻量级锁，Mark Word 的结构也变为轻量级锁的结构。

执行同步代码块之前，JVM会在线程的栈帧中创建一个锁记录（Lock Record），并将Mark Word拷贝复制到锁记录中。然后尝试通过CAS操作将Mark Word中的锁记录的指针，指向创建的Lock Record。如果成功表示获取锁状态成功，如果失败，则进入自旋获取锁状态。

自旋锁的原理在上面已经讲过了，如果自旋获取锁也失败了，则升级为重量级锁，也就是把线程阻塞起来，等待唤醒。

### 重量级锁

重量级锁就是一个悲观锁了，但是其实不是最坏的锁，因为升级到重量级锁，是因为线程占用锁的时间长(自旋获取失败)，锁竞争激烈的场景，在这种情况下，让线程进入阻塞状态，进入阻塞队列，能减少cpu消耗。所以说在不同的场景使用最佳的解决方案才是最好的技术。synchronized在不同的场景会自动选择不同的锁，这样一个升级锁的策略就体现出了这点。

### 小结

偏向锁：适用于单线程执行。

轻量级锁：适用于锁竞争较不激烈的情况。

重量级锁：适用于锁竞争激烈的情况。

## Lock锁与synchronized的区别

我们看一下他们的区别：

- synchronized是Java语法的一个关键字，加锁的过程是在JVM底层进行。Lock是一个类，是JDK应用层面的，在JUC包里有丰富的API。
- synchronized在加锁和解锁操作上都是自动完成的，Lock锁需要我们手动加锁和解锁。
- Lock锁有丰富的API能知道线程是否获取锁成功，而synchronized不能。
- synchronized能修饰方法和代码块，Lock锁只能锁住代码块。
- Lock锁有丰富的API，可根据不同的场景，在使用上更加灵活。
- synchronized是非公平锁，而Lock锁既有非公平锁也有公平锁，可以由开发者通过参数控制。

个人觉得在锁竞争不是很激烈的场景，使用synchronized，语义清晰，实现简单，JDK1.6后引入了偏向锁，轻量级锁等概念后，性能也能保证。而在锁竞争激烈，复杂的场景下，则使用Lock锁会更灵活一点，性能也较稳定。