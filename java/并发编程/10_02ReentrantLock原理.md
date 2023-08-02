
资料来源：<br/>
[五千字详细讲解并发编程的AQS.md](https://github.com/yehongzhi/learningSummary/blob/master/%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B%E7%9A%84%E8%89%BA%E6%9C%AF/%E4%BA%94%E5%8D%83%E5%AD%97%E8%AF%A6%E7%BB%86%E8%AE%B2%E8%A7%A3%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B%E7%9A%84AQS.md)



书接上回[08_AQS](java/并发编程/08AQS.md)

## 认识ReentrantLock

ReentrantLock是一个很经典的使用AQS的案例，不妨以此为切入点来继续深入。ReentrantLock的特性有很多，首先它是一个悲观锁，其次有两种模式分别是公平锁和非公平锁，最后它是重入锁，也就是能够对共享资源重复加锁。

AQS通常是使用内部类实现，所以不难想象在ReentrantLock类里有两个内部类，我们看一张类图。

FairSync是公平锁的实现，NonfairSync则是非公平锁的实现。通过构造器传入的boolean值进行判断。

```java
public ReentrantLock(boolean fair) {
    //true则使用公平锁，false则使用非公平锁
    sync = fair ? new FairSync() : new NonfairSync();
}
//默认是非公平锁
public ReentrantLock() {
    sync = new NonfairSync();
}
```

公平锁是遵循**FIFO**（先进先出）原则的，先到的线程会优先获取资源，后到的线程会进行排队等待，能保证每个线程都能拿到锁，不会存在有线程饿死的情况。

非公平锁是则不遵守先进先出的原则，会出现有线程插队的情况，不能保证每个线程都能拿到锁，会存在有线程饿死的情况。

下面我们从源码分析去找出这两种锁的区别。

## 源码分析ReentrantLock

### 上锁

ReentrantLock是通过lock()方法上锁，所以看lock()方法。

```java
public void lock() {
    sync.lock();
}
```

sync就是NonfairSync或者FairSync。

```java
//这里就是调用AQS的acquire()方法，获取同步资源
final void lock() {
    acquire(1);
}
```

acquire()方法前面已经解析过了，主要看FairSync的tryAcquire()方法。

```java
protected final boolean tryAcquire(int acquires) {
    //获取当前线程
    final Thread current = Thread.currentThread();
    //获取同步状态
    int c = getState();
    //判断同步状态是否为0
    if (c == 0) {
        //关键在这里，公平锁会判断是否需要排队
        if (!hasQueuedPredecessors() &&
            //如果不需要排队，则直接cas操作更新同步状态为1
            compareAndSetState(0, acquires)) {
            //设置占用锁的线程为当前线程
            setExclusiveOwnerThread(current);
            //返回true，表示上锁成功
            return true;
        }
    }
    //判断当前线程是否是拥有锁的线程，主要是可重入锁的逻辑
    else if (current == getExclusiveOwnerThread()) {
        //如果是当前线程，则同步状态+1
        int nextc = c + acquires;
        if (nextc < 0)
            throw new Error("Maximum lock count exceeded");
        //设置同步状态
        setState(nextc);
        return true;
    }
    //以上情况都不是，则返回false，表示上锁失败。上锁失败根据AQS的框架设计，会入队排队
    return false;
}
```

如果是非公平锁NonfairSync的tryAcquire()，我们继续分析。

```java
protected final boolean tryAcquire(int acquires) {
    return nonfairTryAcquire(acquires);
}
//非公平式获取锁
final boolean nonfairTryAcquire(int acquires) {
    //这段跟公平锁是一样的操作
    final Thread current = Thread.currentThread();
    int c = getState();
    if (c == 0) {
        //关键在这里，不再判断是否需要排队，而是直接去更新同步状态，通俗点讲就是插队
        if (compareAndSetState(0, acquires)) {
            //如果获取同步状态成功，则设置占用锁的线程为当前线程
            setExclusiveOwnerThread(current);
            //返回true表示获取锁成功
            return true;
        }
    }
    //以下逻辑跟公平锁的逻辑一样
    else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0) // overflow
            throw new Error("Maximum lock count exceeded");
        setState(nextc);
        return true;
    }
    return false;
}
```

其实很明显了，关键的区别就在于尝试获取锁的时候，公平锁会判断是否需要排队再去更新同步状态，非公平锁是直接就更新同步，不判断是否需要排队。

从性能上来说，公平锁的性能是比非公平锁要差的，因为**公平锁要遵守FIFO(先进先出)的原则，这就会增加了上下文切换与等待线程的状态变换时间**。

非公平锁的缺点也是很明显的，因为允许插队，这就会存在有线程饿死的情况。

###  解锁

解锁对应的方法就是unlock()。

```java
public void unlock() {
    //调用AQS中的release()方法
    sync.release(1);
}
//这是AQS框架定义的release()方法
public final boolean release(int arg) {
    //当前锁是不是没有被线程持有,返回true表示该锁没有被任何线程持有
    if (tryRelease(arg)) {
        //获取头结点h
        Node h = head;
        //判断头结点是否为null并且waitStatus不是初始化节点状态，解除线程挂起状态
        if (h != null && h.waitStatus != 0)
            unparkSuccessor(h);
        return true;
    }
    return false;
}
```

关键在于tryRelease()，这就不需要分公平锁和非公平锁的情况，只需要考虑可重入的逻辑。

```java
protected final boolean tryRelease(int releases) {
    //减少可重入的次数
    int c = getState() - releases;
    //如果当前线程不是持有锁的线程，抛出异常
    if (Thread.currentThread() != getExclusiveOwnerThread())
        throw new IllegalMonitorStateException();
    boolean free = false;
    // 如果持有线程全部释放，将当前独占锁所有线程设置为null，并更新state
    if (c == 0) {
        //状态为0，表示持有线程被全部释放，设置为true
        free = true;
        setExclusiveOwnerThread(null);
    }
    setState(c);
    return free;
}
```

## 总结

JUC可谓是学习java的一个难点，而学习AQS其实关键在于并发的思维，因为需要考虑的情况很多，其次需要理解模板模式的思想，这才能理解为什么AQS作为一个框架的作用。ReentrantLock这个类我觉得是理解AQS一个很好的切入点，看懂了之后再去看AQS的其他应用类应该会轻松很多。