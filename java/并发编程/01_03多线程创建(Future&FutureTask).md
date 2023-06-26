资料来源：

[Java 线程详解(上)](https://blog.csdn.net/sermonlizhi/article/details/122223118?spm=1001.2014.3001.5501)<br/>
[CompletableFuture使用详解](https://blog.csdn.net/sermonlizhi/article/details/123356877)<br/>
[CompletionService使用与源码分析](https://blog.csdn.net/sermonlizhi/article/details/123314335?spm=1001.2014.3001.5502)

## Future&FutureTask

### 使用介绍

介绍了创建一个Java线程的三种方式，其中继承`Thread`类或实现`Runnable`接口都可以创建线程，但这两种方法都有一个问题就是：没有返回值，不能获取执行完的结果。因此后面在`JDK1.5`才新增了一个`Callable`接口来解决上面的问题，而`Future`和`FutureTask`就可以与`Callable`配合起来使用。

而`Callable`只能在线程池中提交任务使用，且只能在`submit()`和`invokeAnay()`以及`invokeAll()`这三个任务提交的方法中使用，如果需要直接使用`Thread`的方式启动线程，则需要使用`FutureTask`对象作为`Thread`的构造参数，而`FutureTask`的构造参数又是`Callable`的对象


**Callable的call方法可以有返回值，可以声明抛出异常**。和 `Callable`配合的有一个`Future`类，通过`Future`可以了解任务执行情况，或者取消任务的执行，还可获取任务执行的结果，这些功能都是`Runnable`做不到的，`Callable` 的功能要比`Runnable`强大。

```java
new Thread(new Runnable() {
    @Override
    public void run() {
        System.out.println("通过Runnable方式执行任务");
    }
}).start();

// 需要借助FutureTask
FutureTask task = new FutureTask(new Callable() {
    @Override
    public Object call() throws Exception {
        System.out.println("通过Callable方式执行任务");
        Thread.sleep(3000);
        return "返回任务结果";
    }
});
new Thread(task).start();

```

### 使用案例

**直接`Future`方式**

向不同电商平台询价，并保存价格，采用`ThreadPoolExecutor+Future`的方案：异步执行询价然后再保存

```java
//    创建线程池 
ExecutorService    executor = Executors.newFixedThreadPool(2); 
//    异步向电商S1询价 
Future<Integer>    f1 = executor.submit(()->getPriceByS1()); 
//    异步向电商S2询价 
Future<Integer>    f2=    executor.submit(()->getPriceByS2());             
//    获取电商S1报价并异步保存 
executor.execute(()->save(f1.get()));        
//    获取电商S2报价并异步保存 
executor.execute(()->save(f2.get())   
```

如果获取电商S1报价的耗时很长，那么即便获取电商S2报价的耗时很短，也无法让保存S2报价的操作先执行，因为这个主线程都阻塞 在了`f1.get()`操作上。

**`CompletionService`方式**

使用`CompletionService`实现先获取的报价先保存到数据库

```java
//创建线程池
ExecutorService executor = Executors.newFixedThreadPool(10);
//创建CompletionService
CompletionService<Integer> cs = new ExecutorCompletionService<>(executor);
//异步向电商S1询价
cs.submit(() -> getPriceByS1());
//异步向电商S2询价
cs.submit(() -> getPriceByS2());
//将询价结果异步保存到数据库
for (int i = 0; i < 2; i++) {
    Integer r = cs.take().get();
    executor.execute(() -> save(r));
}
```
