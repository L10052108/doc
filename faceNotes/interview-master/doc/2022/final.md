> 重要说明：本篇为博主《面试题精选-基础篇》系列中的一篇，查看系列面试文章**请关注我**。
> Gitee 开源地址：[https://gitee.com/mydb/interview](https://gitee.com/mydb/interview)

## final 定义
final 翻译成中文是“最终”的意思，**它是 Java 中一个常见关键字，使用 final 修饰的对象不允许修改或替换其原始值或定义。**
![image.png](https://cdn.nlark.com/yuque/0/2021/png/92791/1637915800169-1656bce6-9e16-4bd3-a3d5-361a5e9c44fa.png#clientId=u034eda2f-e552-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=316&id=u3d2bccf9&margin=%5Bobject%20Object%5D&name=image.png&originHeight=631&originWidth=985&originalType=binary&ratio=1&rotation=0&showTitle=false&size=73564&status=done&style=none&taskId=u629ed8fa-b308-42fd-9702-564ad47b0ae&title=&width=492.5)
比如类被 final 修饰之后，就不能被其他类继承了，如下图所示：
![image.png](https://cdn.nlark.com/yuque/0/2021/png/92791/1637917506584-6e7f5ed1-875a-4a5d-95a3-534b879bd677.png#clientId=u8304792d-3d35-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=160&id=ucaa58d07&margin=%5Bobject%20Object%5D&name=image.png&originHeight=319&originWidth=958&originalType=binary&ratio=1&rotation=0&showTitle=false&size=26470&status=done&style=none&taskId=u73582563-37ef-4d49-a1fa-f774b694340&title=&width=479)
## final 的 4 种用法
final 的用法有以下 4 种：

1. 修饰类
1. 修饰方法
1. 修饰变量
1. 修饰参数



### 1.修饰类
```java
final class Animal {

}
```
![image.png](https://cdn.nlark.com/yuque/0/2021/png/92791/1637917840481-54f3c8c6-dc8e-46b6-92f7-6793ce5a5c53.png#clientId=u8304792d-3d35-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=125&id=u0675e2e9&margin=%5Bobject%20Object%5D&name=image.png&originHeight=250&originWidth=593&originalType=binary&ratio=1&rotation=0&showTitle=false&size=15073&status=done&style=none&taskId=u886d9533-f553-42ac-ae7e-8b59a0a0767&title=&width=296.5)
说明：被 final 修饰的类不允许被继承，表示此类设计的很完美，不需要被修改和扩展。
### 2.修饰方法
```java
public class FinalExample {
    public final void sayHi() {
        System.out.println("Hi~");
    }
}
```
![image.png](https://cdn.nlark.com/yuque/0/2021/png/92791/1637917822982-2ec07de0-e316-4ad5-a1fe-750112e984ef.png#clientId=u8304792d-3d35-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=121&id=ud2801db0&margin=%5Bobject%20Object%5D&name=image.png&originHeight=242&originWidth=675&originalType=binary&ratio=1&rotation=0&showTitle=false&size=24131&status=done&style=none&taskId=ud9d37e6f-21f7-4d1b-b64b-6c8e0a6267e&title=&width=337.5)
说明：被 final 修饰的方法表示此方法提供的功能已经满足当前要求，不需要进行扩展，并且也不允许任何从此类继承的类来重写此方法。
### 3.修饰变量
```java
public class FinalExample {
    private static final String MSG = "hello";
	//......
}
```
![image.png](https://cdn.nlark.com/yuque/0/2021/png/92791/1637917802198-cd080abe-b755-4554-bb3c-4e9f1b4135a7.png#clientId=u8304792d-3d35-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=96&id=ud2bb3d8a&margin=%5Bobject%20Object%5D&name=image.png&originHeight=191&originWidth=865&originalType=binary&ratio=1&rotation=0&showTitle=false&size=19752&status=done&style=none&taskId=u1c96fddf-538c-4aad-ab7a-6a1cb3a388b&title=&width=432.5)
说明：当 final 修饰变量时，表示该属性一旦被初始化便不可以被修改。
### 4.修饰参数
```java
public class FinalExample {
    public void sayHi(final String name) {
        System.out.println("Hi," + name);
    }
}
```
![image.png](https://cdn.nlark.com/yuque/0/2021/png/92791/1637917763253-6ef514ff-7c6d-4e96-bb06-49fdf4866755.png#clientId=u8304792d-3d35-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=118&id=uff77ecfd&margin=%5Bobject%20Object%5D&name=image.png&originHeight=235&originWidth=769&originalType=binary&ratio=1&rotation=0&showTitle=false&size=28571&status=done&style=none&taskId=u9304eaad-d75f-48f7-98ae-cdabd09e798&title=&width=384.5)
说明：当 final 修饰参数时，表示此参数在整个方法内不允许被修改。
## final 作用
使用 final 修饰类可以防止被其他类继承，如 JDK 代码中 String 类就是被 final 修饰的，从而防止被其他类继承，导致内部逻辑被破坏。
​

String 类部分源码如下：
![image.png](https://cdn.nlark.com/yuque/0/2021/png/92791/1637918243307-e8545eb9-3403-47be-839a-aab0ec9d1d6c.png#clientId=u8304792d-3d35-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=217&id=u8e9797dc&margin=%5Bobject%20Object%5D&name=image.png&originHeight=434&originWidth=1123&originalType=binary&ratio=1&rotation=0&showTitle=false&size=82221&status=done&style=none&taskId=u21adafe5-30f5-451f-af90-4b74de30590&title=&width=561.5)
## 总结
final 是 Java 中常见的一个关键字，被它修饰的对象不允许修改、替换其原始值或定义。final 有 4 种用法，可以用来修饰类、方法、变量或参数。
​

> 关注公众号：Java面试真题解析，查看更多 Java 面试题。

