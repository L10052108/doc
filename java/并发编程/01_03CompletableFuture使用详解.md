资料来源：

[Java 线程详解(上)](https://blog.csdn.net/sermonlizhi/article/details/122223118?spm=1001.2014.3001.5501)<br/>
[CompletableFuture使用详解](https://blog.csdn.net/sermonlizhi/article/details/123356877)<br/>
[CompletionService使用与源码分析](https://blog.csdn.net/sermonlizhi/article/details/123314335?spm=1001.2014.3001.5502)
## CompletableFuture使用详解

### 概述

已经介绍过了Future的局限性，它没法直接对多个任务进行链式、组合等处理，需要借助并发工具类才能完成，实现逻辑比较复杂。

而CompletableFuture是对Future的扩展和增强。CompletableFuture实现了Future接口，并在此基础上进行了丰富的扩展，完美弥补了Future的局限性，同时CompletableFuture实现了对任务编排的能力。借助这项能力，可以轻松地组织不同任务的运行顺序、规则以及方式。从某种程度上说，这项能力是它的核心能力。而在以往，虽然通过CountDownLatch等工具类也可以实现任务的编排，但需要复杂的逻辑处理，不仅耗费精力且难以维护。

CompletableFuture的继承结构如下：

![4085268d255345c7a8fec3bed4eddb70](img\4085268d255345c7a8fec3bed4eddb70.png)

`CompletionStage`接口定义了任务编排的方法，执行某一阶段，可以向下执行后续阶段。异步执行的，默认线程池是`ForkJoinPool.commonPool()`，但为了业务之间互不影响，且便于定位问题，强烈推荐使用自定义线程池。

### 功能

依赖关系
-  `thenApply()`：把前面任务的执行结果，交给后面的`Function`
-  `thenCompose()`：用来连接两个有依赖关系的任务，结果由第二个任务返回

 and集合关系
-  `thenCombine()`：合并任务，有返回值
-  `thenAccepetBoth()`：两个任务执行完成后，将结果交给`thenAccepetBoth`处理，无返回值
-  `runAfterBoth()`：两个任务都执行完成后，执行下一步操作(`Runnable`类型任务)

or聚合关系
- `applyToEither()`：两个任务哪个执行的快，就使用哪一个结果，有返回值
- `acceptEither()`：两个任务哪个执行的快，就消费哪一个结果，无返回值
- `runAfterEither()`：任意一个任务执行完成，进行下一步操作(`Runnable`类型任务)

并行执行
- `allOf()`：当所有给定的 `CompletableFuture` 完成时，返回一个新的` CompletableFuture`
- `anyOf()`：当任何一个给定的`CompletablFuture`完成时，返回一个新的`CompletableFuture`

结果处理
- `whenComplete`：当任务完成时，将使用结果(或 null)和此阶段的异常(或 null如果没有)执行给定操作
- `exceptionally`：返回一个新的`CompletableFuture`，当前面的`CompletableFuture`完成时，它也完成，当它异常完成时，给定函数的异常触发这个`CompletableFuture`的完成

### 场景应用

#### 结果转化

将上一段任务的执行结果作为下一阶段任务的入参参与重新计算，产生新的结果。
**thenApply**
`thenApply`接收一个函数作为参数，使用该函数处理上一个`CompletableFuture`调用的结果，并返回一个具有处理结果的`Future`对象。

常用使用：

```java
public <U> CompletableFuture<U> thenApply(Function<? super T,? extends U> fn)
public <U> CompletableFuture<U> thenApplyAsync(Function<? super T,? extends U> fn)
```

具体使用：

```java
CompletableFuture<Integer> future = CompletableFuture
    .supplyAsync(new Supplier<Integer>() {
        @Override
        public Integer get() {
            int number = new Random().nextInt(30);
            System.out.println("第一次运算：" + number);
            return number;
        }
    })
    .thenCompose(new Function<Integer, CompletionStage<Integer>>() {
        @Override
        public CompletionStage<Integer> apply(Integer param) {
            return CompletableFuture.supplyAsync(new Supplier<Integer>() {
                @Override
                public Integer get() {
                    int number = param * 2;
                    System.out.println("第二次运算：" + number);
                    return number;
                }
            });
        }
    });
```

**thenCompose**

thenCompose的参数为一个返回CompletableFuture实例的函数，该函数的参数是先前计算步骤的结果。

常用方法：

```java
public <U> CompletableFuture<U> thenCompose(Function<? super T, ? extends CompletionStage<U>> fn);
public <U> CompletableFuture<U> thenComposeAsync(Function<? super T, ? extends CompletionStage<U>> fn) ;
```


具体使用：

```java
CompletableFuture<Integer> future = CompletableFuture
    .supplyAsync(new Supplier<Integer>() {
        @Override
        public Integer get() {
            int number = new Random().nextInt(30);
            System.out.println("第一次运算：" + number);
            return number;
        }
    })
    .thenCompose(new Function<Integer, CompletionStage<Integer>>() {
        @Override
        public CompletionStage<Integer> apply(Integer param) {
            return CompletableFuture.supplyAsync(new Supplier<Integer>() {
                @Override
                public Integer get() {
                    int number = param * 2;
                    System.out.println("第二次运算：" + number);
                    return number;
                }
            });
        }
    });
```

`thenApply` 和 `thenCompose`的区别：

`thenApply`转换的是泛型中的类型，返回的是同一个`CompletableFuture`；
`thenCompose`将内部的`CompletableFuture`调用展开来并使用上一个`CompletableFutre`调用的结果在下一步的`CompletableFuture`调用中进行运算，是生成一个新的`CompletableFuture`。
#### 结果消费
与结果处理和结果转换系列函数返回一个新的`CompletableFuture`不同，结果消费系列函数只对结果执行`Action`，而不返回新的计算值。

根据对结果的处理方式，结果消费函数又可以分为下面三大类：

`thenAccept()`：对单个结果进行消费
`thenAcceptBoth()`：对两个结果进行消费
`thenRun()`：不关心结果，只对结果执行Action
`thenAccept`
观察该系列函数的参数类型可知，它们是函数式接口Consumer，这个接口只有输入，没有返回值。

常用方法：

```java
public CompletionStage<Void> thenAccept(Consumer<? super T> action);
public CompletionStage<Void> thenAcceptAsync(Consumer<? super T> action);
```


具体使用：

```java
CompletableFuture<Void> future = CompletableFuture
    .supplyAsync(() -> {
        int number = new Random().nextInt(10);
        System.out.println("第一次运算：" + number);
        return number;
    }).thenAccept(number ->
                  System.out.println("第二次运算：" + number * 5));
```


`thenAcceptBoth`
`thenAcceptBoth`函数的作用是，当两个`CompletionStage`都正常完成计算的时候，就会执行提供的action消费两个异步的结果。

常用方法：

```java
public <U> CompletionStage<Void> thenAcceptBoth(CompletionStage<? extends U> other,BiConsumer<? super T, ? super U> action);
public <U> CompletionStage<Void> thenAcceptBothAsync(CompletionStage<? extends U> other,BiConsumer<? super T, ? super U> action);
```


具体使用：

```java
CompletableFuture<Integer> futrue1 = CompletableFuture.supplyAsync(new Supplier<Integer>() {
    @Override
    public Integer get() {
        int number = new Random().nextInt(3) + 1;
        try {
            TimeUnit.SECONDS.sleep(number);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("任务1结果：" + number);
        return number;
    }
});

CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(new Supplier<Integer>() {
    @Override
    public Integer get() {
        int number = new Random().nextInt(3) + 1;
        try {
            TimeUnit.SECONDS.sleep(number);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("任务2结果：" + number);
        return number;
    }
});

futrue1.thenAcceptBoth(future2, new BiConsumer<Integer, Integer>() {
    @Override
    public void accept(Integer x, Integer y) {
        System.out.println("最终结果：" + (x + y));
    }
});
```


`thenRun`
`thenRun`也是对线程任务结果的一种消费函数，与`thenAccept`不同的是，`thenRun`会在上一阶段 `CompletableFuture`计算完成的时候执行一个`Runnable`，而`Runnable`并不使用该`CompletableFuture`计算的结果。

常用方法：

```java
public CompletionStage<Void> thenRun(Runnable action);
public CompletionStage<Void> thenRunAsync(Runnable action);
```


具体使用：

```java
CompletableFuture<Void> future = CompletableFuture.supplyAsync(() -> {
    int number = new Random().nextInt(10);
    System.out.println("第一阶段：" + number);
    return number;
}).thenRun(() ->
           System.out.println("thenRun 执行"));
```


#### 结果组合
`thenCombine`
合并两个线程任务的结果，并进一步处理。

常用方法：

```java
public <U,V> CompletableFuture<V> thenCombine(CompletionStage<? extends U> other,BiFunction<? super T,? super U,? extends V> fn);

public <U,V> CompletableFuture<V> thenCombineAsync(CompletionStage<? extends U> other,BiFunction<? super T,? super U,? extends V> fn);

public <U,V> CompletableFuture<V> thenCombineAsync(CompletionStage<? extends U> other,BiFunction<? super T,? super U,? extends V> fn, Executor executor);
```


具体使用：

```java
CompletableFuture<Integer> future1 = CompletableFuture
    .supplyAsync(new Supplier<Integer>() {
        @Override
        public Integer get() {
            int number = new Random().nextInt(10);
            System.out.println("任务1结果：" + number);
            return number;
        }
    });
CompletableFuture<Integer> future2 = CompletableFuture
    .supplyAsync(new Supplier<Integer>() {
        @Override
        public Integer get() {
            int number = new Random().nextInt(10);
            System.out.println("任务2结果：" + number);
            return number;
        }
    });
CompletableFuture<Integer> result = future1
    .thenCombine(future2, new BiFunction<Integer, Integer, Integer>() {
        @Override
        public Integer apply(Integer x, Integer y) {
            return x + y;
        }
    });
System.out.println("组合后结果：" + result.get());
```

#### 任务交互
线程交互指将两个线程任务获取结果的速度相比较，按一定的规则进行下一步处理。

`applyToEither`
两个线程任务相比较，先获得执行结果的，就对该结果进行下一步的转化操作。

常用方法：

```java
public <U> CompletionStage<U> applyToEither(CompletionStage<? extends T> other,Function<? super T, U> fn);
public <U> CompletionStage<U> applyToEitherAsync(CompletionStage<? extends T> other,Function<? super T, U> fn);
```


具体使用：

```java
CompletableFuture<Integer> future1 = CompletableFuture
    .supplyAsync(new Supplier<Integer>() {
        @Override
        public Integer get() {
            int number = new Random().nextInt(10);
            try {
                TimeUnit.SECONDS.sleep(number);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("任务1结果:" + number);
            return number;
        }
    });
CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(new Supplier<Integer>() {
    @Override
    public Integer get() {
        int number = new Random().nextInt(10);
        try {
            TimeUnit.SECONDS.sleep(number);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("任务2结果:" + number);
        return number;
    }
});

future1.applyToEither(future2, new Function<Integer, Integer>() {
    @Override
    public Integer apply(Integer number) {
        System.out.println("最快结果：" + number);
        return number * 2;
    }
});
```


`acceptEither`
两个线程任务相比较，先获得执行结果的，就对该结果进行下一步的消费操作。

常用方法：

```java
public CompletionStage<Void> acceptEither(CompletionStage<? extends T> other,Consumer<? super T> action);
public CompletionStage<Void> acceptEitherAsync(CompletionStage<? extends T> other,Consumer<? super T> action);
```


具体使用：

```java
CompletableFuture<Integer> future1 = CompletableFuture.supplyAsync(new Supplier<Integer>() {
    @Override
    public Integer get() {
        int number = new Random().nextInt(10) + 1;
        try {
            TimeUnit.SECONDS.sleep(number);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("第一阶段：" + number);
        return number;
    }
});

CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(new Supplier<Integer>() {
    @Override
    public Integer get() {
        int number = new Random().nextInt(10) + 1;
        try {
            TimeUnit.SECONDS.sleep(number);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("第二阶段：" + number);
        return number;
    }
});

future1.acceptEither(future2, new Consumer<Integer>() {
    @Override
    public void accept(Integer number) {
        System.out.println("最快结果：" + number);
    }
});
```


`runAfterEither`
两个线程任务相比较，有任何一个执行完成，就进行下一步操作，不关心运行结果。

常用方法：

```java
public CompletionStage<Void> runAfterEither(CompletionStage<?> other,Runnable action);
public CompletionStage<Void> runAfterEitherAsync(CompletionStage<?> other,Runnable action);
```


具体使用：

```java
CompletableFuture<Integer> future1 = CompletableFuture.supplyAsync(new Supplier<Integer>() {
    @Override
    public Integer get() {
        int number = new Random().nextInt(5);
        try {
            TimeUnit.SECONDS.sleep(number);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("任务1结果：" + number);
        return number;
    }
});

CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(new Supplier<Integer>() {
    @Override
    public Integer get() {
        int number = new Random().nextInt(5);
        try {
            TimeUnit.SECONDS.sleep(number);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("任务2结果:" + number);
        return number;
    }
});

future1.runAfterEither(future2, new Runnable() {
    @Override
    public void run() {
        System.out.println("已经有一个任务完成了");
    }
}).join();
```


`anyOf`
anyOf() 的参数是多个给定的 CompletableFuture，当其中的任何一个完成时，方法返回这个 CompletableFuture。

常用方法：

```java
public static CompletableFuture<Object> anyOf(CompletableFuture<?>... cfs)
```

具体使用：

```java
Random random = new Random();
CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> {
    try {
        TimeUnit.SECONDS.sleep(random.nextInt(5));
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    return "hello";
});

CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> {
    try {
        TimeUnit.SECONDS.sleep(random.nextInt(1));
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    return "world";
});
CompletableFuture<Object> result = CompletableFuture.anyOf(future1, future2);`allOf`
```

`allOf`方法用来实现多 `CompletableFuture` 的同时返回。

常用方法：

```java
public static CompletableFuture<Void> allOf(CompletableFuture<?>... cfs)
```

具体使用：

```java
CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> {
    try {
        TimeUnit.SECONDS.sleep(2);
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    System.out.println("future1完成！");
    return "future1完成！";
});

CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> {
    System.out.println("future2完成！");
    return "future2完成！";
});

CompletableFuture<Void> combindFuture = CompletableFuture.allOf(future1, future2);

try {
    combindFuture.get();
} catch (InterruptedException e) {
    e.printStackTrace();
} catch (ExecutionException e) {
    e.printStackTrace();
}
```

`CompletableFuture`常用方法总结:

![98bc772d8bcc45d2ac509af826685cbf](img\98bc772d8bcc45d2ac509af826685cbf.png)

注：`CompletableFuture`中还有很多功能丰富的方法，这里就不一一列举。

### 使用案例
实现最优的“烧水泡茶”程序
著名数学家华罗庚先生在《统筹方法》这篇文章里介绍了一个烧水泡茶的例子，文中提到最优的工序应该是下面这样：


对于烧水泡茶这个程序，一种最优的分工方案：用两个线程 T1 和 T2 来完成烧水泡茶程序，T1 负责洗水壶、烧开水、泡茶这三道工序，T2 负责洗茶壶、洗茶杯、拿茶叶三道工序，其中 T1 在执行泡茶这道工序时需要等待 T2 完成拿茶叶的工序。

基于`Future`实现
```java
public class FutureTaskTest{

    public static void main(String[] args) throws ExecutionException, InterruptedException {
        // 创建任务T2的FutureTask
        FutureTask<String> ft2 = new FutureTask<>(new T2Task());
        // 创建任务T1的FutureTask
        FutureTask<String> ft1 = new FutureTask<>(new T1Task(ft2));
    
        // 线程T1执行任务ft2
        Thread T1 = new Thread(ft2);
        T1.start();
        // 线程T2执行任务ft1
        Thread T2 = new Thread(ft1);
        T2.start();
        // 等待线程T1执行结果
        System.out.println(ft1.get());
    
    }
}

// T1Task需要执行的任务：
// 洗水壶、烧开水、泡茶
class T1Task implements Callable<String> {
    FutureTask<String> ft2;
    // T1任务需要T2任务的FutureTask
    T1Task(FutureTask<String> ft2){
        this.ft2 = ft2;
    }
    @Override
    public String call() throws Exception {
        System.out.println("T1:洗水壶...");
        TimeUnit.SECONDS.sleep(1);

        System.out.println("T1:烧开水...");
        TimeUnit.SECONDS.sleep(15);
        // 获取T2线程的茶叶
        String tf = ft2.get();
        System.out.println("T1:拿到茶叶:"+tf);
    
        System.out.println("T1:泡茶...");
        return "上茶:" + tf;
    }
}
// T2Task需要执行的任务:
// 洗茶壶、洗茶杯、拿茶叶
class T2Task implements Callable<String> {
    @Override
    public String call() throws Exception {
        System.out.println("T2:洗茶壶...");
        TimeUnit.SECONDS.sleep(1);

        System.out.println("T2:洗茶杯...");
        TimeUnit.SECONDS.sleep(2);
    
        System.out.println("T2:拿茶叶...");
        TimeUnit.SECONDS.sleep(1);
        return "龙井";
    }
}
```


基于CompletableFuture实现
```java
public class CompletableFutureTest {
public static void main(String[] args) {

    //任务1：洗水壶->烧开水
    CompletableFuture<Void> f1 = CompletableFuture
        .runAsync(() -> {
            System.out.println("T1:洗水壶...");
            sleep(1, TimeUnit.SECONDS);

            System.out.println("T1:烧开水...");
            sleep(15, TimeUnit.SECONDS);
        });
    //任务2：洗茶壶->洗茶杯->拿茶叶
    CompletableFuture<String> f2 = CompletableFuture
        .supplyAsync(() -> {
            System.out.println("T2:洗茶壶...");
            sleep(1, TimeUnit.SECONDS);

            System.out.println("T2:洗茶杯...");
            sleep(2, TimeUnit.SECONDS);

            System.out.println("T2:拿茶叶...");
            sleep(1, TimeUnit.SECONDS);
            return "龙井";
        });
    //任务3：任务1和任务2完成后执行：泡茶
    CompletableFuture<String> f3 = f1.thenCombine(f2, (__, tf) -> {
        System.out.println("T1:拿到茶叶:" + tf);
        System.out.println("T1:泡茶...");
        return "上茶:" + tf;
    });
    //等待任务3执行结果
    System.out.println(f3.join());
}

static void sleep(int t, TimeUnit u){
    try {
        u.sleep(t);
    } catch (InterruptedException e) {
    }
}
}
```


