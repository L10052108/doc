资料来源：

[java多线程六(Thread类中yield方法)](https://www.cnblogs.com/lingfeng-zhu/p/10537335.html)

[Java多线程的操作,比如yield方法](https://blog.csdn.net/weixin_43249530/article/details/88064361)



## 线程让步

线程让步用于正在执行的线程，在某些情况下让出CPU资源，让给其它线程执行

一般分为四种状态 new runnable runing dead 四种状态。下面我们来看一下图

![dsefrgghty6uj7i8k9lo](img\dsefrgghty6uj7i8k9lo.png)

由运行态到就绪态，停止一下后再由就绪态到运行态

暂停当前正在执行的线程对象，并执行其他线程。
意思就是调用yield方法会让当前线程交出CPU权限，让CPU去执行其他的线程。它跟sleep方法类似，同样不会释放锁。
但是yield不能立刻交出CPU，会出现同一个线程一直执行的情况，另外，yield方法只能让拥有相同优先级的线程有获取CPU执行时间的机会。
注意调用yield方法并不会让线程进入阻塞状态，而是让线程重回就绪状态，它只需要等待重新获取CPU执行时间，这一点是和sleep方法不一样的

```java
    @SneakyThrows
    @Test
    public void test02(){
//        Thread.sleep(1000L *10);

        ThreadTest t1=new ThreadTest("A");
        t1.setName("A");
        t1.start();
        Thread.sleep(1000L * 2);
        t1.yield();

        ThreadTest t2=new ThreadTest("B");
        t2.setName("B");
        t2.start();

        Thread.sleep(1000L * 10);
    }

```

运行结果

~~~~java
A-1
A-2
B-1
A-3
B-2
A-4
B-3
A-5
B-4
B-5
~~~~

实际结果并不明显