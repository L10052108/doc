## jdk介绍

资料来源：[如何理解 Java8 的函数式编程，面试必进](https://m.toutiaocdn.com/i7075583769079677452/?app=news_article&timestamp=1647577110&use_new_style=1&req_id=20220318121830010158156021082FD71F&group_id=7075583769079677452&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=4f1ac4d6-609a-4c85-98d9-659b9a6dea0c)

代码上传[参考代码](https://gitee.com/L10052108/springboot_project/tree/simple/src/test/java/xyz/guqing/project/simple)

### 介绍：

Java8 出现的时间已经不算短了，免费维护期马上也要到期了，官方已经开始推荐使用 Java11。

Java8 是革命性的一个版本，一直以来，Java 最受诟病的地方就是代码写起来很啰嗦，仅仅写一个 HelloWorld 都需要些很多的样板代码。

在 Java8 推出之后，啰嗦的代码有了很大的改观，Java 也可以写出简单优美的代码。最明显的改观就是 Java 开始支持函数式编程。

函数式编程的定义很晦涩，但是我们可以将函数式编程理解为函数本身可以作为参数进行传递，就是说，参数不仅仅可以是数据，也可以是行为（函数或者方法的实现其实就是逻辑行为）。

可能是 Java8 步子跨的太大，以至于现在还有很多人没有赶上来，依然用 Java8 在写 Java5 风格的代码。这篇文章的目的就是彻底说清楚 Java8 的变化，以及快速全面的使用 Java8 的特性，让 Java 代码优雅起来。

### 函数式接口

在开始说 Java8 的函数式编程之前，我们需要说明一下，在 Java8 中新增加的一个概念，叫**函数式接口**。

这个函数式接口是 Java8 实现函数式编程的基础，正是这类接口的存在，才能把函数（方法）当做参数进行传递，至少表面上看起来是这样的，但是实际上传递的还是对象，这个问题我们下面再讨论，先回到函数式接口。

- 普通接口

~~~~java
public interface Action {
    public void action();
}
~~~~

- 函数式接口

~~~~java
@FunctionalInterface
public interface Action {
    public void action();
}
~~~~

!> 这个函数式看起来和普通的接口没有什么区别，唯一的区别是函数式接口只能有**一个抽象方法**。

加上 @FunctionalInterface 注解，这个注解不会提供任何额外的功能，仅仅用来表示这个接口是一个函数式接口

- JDK 为了使用方便，内置了很多函数式接口，日常使用完全够了

常用的函数接口有：

- Function
- Predicate
- Consumer

> 看到这里你可能还是对函数式接口不是很理解，没关系，现在你仅仅只需要记住**函数式接口就是模板**。

### lambda表达式

通过一个直观的例子来了解一下 lambda

~~~~java
public class LambdaDemo {

    @Test
    public void test01() {
        int compare = getComparator1().compare(1, 2);
        System.out.println(compare);
    }

    // jdk8以前的写法
    public Comparator getComparator1() {
        Comparator<Integer> comparator = new Comparator<Integer>() {
            public int compare(Integer i1, Integer i2) {
                return i1.compareTo(i2);
            }
        };
        return comparator;
    }

    // 真正有用的代码也有比较大小的那行，其他的都是样板代码。在这样的情况下，lambda 就很有用。
    public Comparator getComparator2() {
        Comparator<Integer> comparator = (Integer i1, Integer i2) -> {
            return i1.compareTo(i2);
        };
        return comparator;
    }

    //继续优化，可以把返回参数的部分也省略
    public Comparator getComparator3() {
        Comparator<Integer> comparator = (Integer i1, Integer i2) -> i1.compareTo(i2);
        return comparator;
    }

    // 既然两个参数都是 Integer 那是不是也可以省略
    public Comparator getComparator4() {
        Comparator<Integer> comparator = (Integer i1, Integer i2) -> i1.compareTo(i2);
        return comparator;
    }

    // 方法引用可以被认为是 lambda 的语法糖，
    // 使用方法引用可以让代码更加简洁，更直观，看到方法引用的名称就能大概知道代码的逻辑，并且还可以对一些代码进行复用。
    public Comparator getComparator5() {
        Comparator<Integer> comparator = Integer::compare;
        return comparator;
    }
}
~~~~

- 函数签名

函数签名为可以表示一类函数，如果两个函数的以下部分相同，就可以说这两个函数的签名一致 

>- 函数参数及其类型
>- 返回值及其类型
>- 可能会抛出的异常
>- 还有访问控制符（public 等等）

**只要 lambda 和函数式接口方法的签名一致，lambda 表达式就可以作为参数传入到以该函数式接口为参数类型的方法中**。

~~~~java
@FunctionalInterface
public interface Comparator<T> {
    int compare(T o1, T o2);
}
~~~~

虽然 Comparator 中方法不止一个，但是抽象方法只有 compare 一个，上面的 lambda 完全可以作为 compare 方法的实现，实际上，**lambda 表达式确实是作为函数式接口抽象方法的实现，而且，lambda 表达式为作为整个函数接口的实例**。

- 方法引用

使用方法引用的时候，要使用 :: ，而且任何方法都可以这样被引用，无论是静态方法还是实例方法。
方法引用可以被认为是 lambda 的语法糖，使用方法引用可以让代码更加简洁，更直观，看到方法引用的名称就能大概知道代码的逻辑，并且还可以对一些代码进行复用。

### 类型推断
在上面我们说到了只要函数式接口抽象方法的函数签名与 lambda 一致，那么就可以把 lambda 表达式作为该函数式接口的实现。
上面的例子中， lambda 的参数类型也是可以省略的，那么 Java 是如何判断 lambda 是否与函数式接口匹配呢？
如果 lambda 表达式中，参数和返回值的类型都省略之后，需要从使用 lambda 的上下文推断出来。
![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0e5hfoqd0j215i0j474z.jpg)
### 举例
- 执行异步任务
~~~~java
public class ThreadDemo {
    @Test
    public void test01(){
        new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println("OK");
            }
        }).start();
    }
    
    // 修改版本
    @Test
    public void test02(){
        new Thread(
                ()-> System.out.println("OK")
        ).start();
    }
}
~~~~
- 数组遍历
~~~~java
public class ListDemo {
    @Test
    public void test01(){
        String s[] = {"aa", "bb", "cc"};
        List<String> list = Arrays.asList(s);
        for (String s1 : list) {
            System.out.println(s1);
        }
    }
    
    // 优化后
    @Test
    public void test02(){
        String s[] = {"aa", "bb", "cc"};
        List<String> list = Arrays.asList(s);
    
        list.forEach(System.out::println);
    }

}
~~~~