资料来源：

[如何在Spring Boot应用启动之后立刻执行一段逻辑](https://www.toutiao.com/article/6833566023392690699/?app=news_article&timestamp=1651680983&use_new_style=1&req_id=202205050016220101581651511F7EB1CC&group_id=6833566023392690699&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=6adb844a-83a3-4c70-b38c-669ce9113d61)<br/>
[SpringBoot 实现启动项目后立即执行方法的几种方式](https://www.toutiao.com/article/7237293681273733692/?app=news_article&timestamp=1685238263&use_new_style=1&req_id=202305280944238D3A7BEFFCFF4B27D599&group_id=7237293681273733692&wxshare_count=2&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=f397a208-55e0-4a95-94af-d9319f873353&source=m_redirect&wid=1703214207437)



## Spring Boot应用启动之后立刻执行一段逻辑

### 介绍

不知道你有没有接到这种需求，项目启动后立马执行一些逻辑。比如简单的缓存预热，或者上线后的广播之类等等。如果你使用 **Spring Boot** 框架的话就可以借助其提供的接口CommandLineRunner和 ApplicationRunner来实现。

### CommandLineRunner

org.springframework.boot.CommandLineRunner 是**Spring Boot**提供的一个接口，当你实现该接口并将之注入**Spring IoC**容器后，**Spring Boot**应用启动后就会执行其run方法。一个**Spring Boot**可以存在多个CommandLineRunner的实现，当存在多个时，你可以实现Ordered接口控制这些实现的执行顺序(**Order 数值越大优先级越低**)。接下来我们来声明两个实现并指定顺序：

优先执行：

~~~~java
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.Ordered;
import org.springframework.stereotype.Component;

/**
 * 优先级最高
 * 该类期望在springboot 启动后第一顺位执行
 * @author felord.cn
 * @since 12:57
 **/
@Slf4j
@Component
public class HighOrderCommandLineRunner implements CommandLineRunner, Ordered {
    @Override
    public void run(String... args) throws Exception {
        for (String arg : args) {
            log.info("arg = " + arg);
        }
        log.info("i am highOrderRunner");
    }

    @Override
    public int getOrder() {
        return Integer.MIN_VALUE+1;
    }
}
~~~~

### ApplicationRunner

在**Spring Boot 1.3.0**又引入了一个和CommandLineRunner功能一样的接口ApplicationRunner。CommandLineRunner接收可变参数String... args，而ApplicationRunner 接收一个封装好的对象参数ApplicationArguments。除此之外它们功能完全一样，甚至连方法名都一样。 声明一个ApplicationRunner并让它优先级最低:

~~~~java
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.Ordered;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;
import java.util.Set;

/**
 * 优先级最低
 * @author felord.cn
 * @since 13:00
 **/
@Slf4j
@Component
public class DefaultApplicationRunner implements ApplicationRunner, Ordered {
    @Override
    public void run(ApplicationArguments args) throws Exception {
        log.info("i am applicationRunner");
        Set<String> optionNames = args.getOptionNames();
        log.info("optionNames = " + optionNames);
        String[] sourceArgs = args.getSourceArgs();
        log.info("sourceArgs = " + Arrays.toString(sourceArgs));
        List<String> nonOptionArgs = args.getNonOptionArgs();
        log.info("nonOptionArgs = " + nonOptionArgs);
        List<String> optionValues = args.getOptionValues("foo");
        log.info("optionValues = " + optionValues);
    }

    @Override
    public int getOrder() {
        return Integer.MIN_VALUE+2;
    }
}
~~~~

相信很多同学看到这里都开始对这两个run方法的入参感兴趣了。**Spring Boot**应用启动时是可以接受参数的，换句话说也就是Spring Boot的main方法是可以接受参数的。这些参数通过命令行 **java -jar yourapp.jar **来传递。CommandLineRunner会原封不动照单全收这些接口，这些参数也可以封装到ApplicationArguments对象中供ApplicationRunner调用。 我们来认识一下ApplicationArguments的相关方法：

- **getSourceArgs()** 被传递给应用程序的原始参数，返回这些参数的字符串数组。
- **getOptionNames()** 获取选项名称的Set字符串集合。如 --spring.profiles.active=dev --debug 将返回["spring.profiles.active","debug"] 。
- **getOptionValues(String name)** 通过名称来获取该名称对应的选项值。如--foo=bar --foo=baz 将返回["bar","baz"]。
- **containsOption(String name)** 用来判断是否包含某个选项的名称。
- **getNonOptionArgs()** 用来获取所有的无选项参数。 接下来我们试验一波，你可以通过下面的命令运行一个 **Spring Boot**应用 **Jar**

```
java -jar yourapp.jar --foo=bar --foo=baz --dev.name=码农小胖哥 java felordcn
```

或者在**IDEA**开发工具中打开**Spring Boot**应用main方法的配置项，进行如下配置，其他**IDE**工具同理。

![](large/e6c9d24ely1h3a6oa4zg0j20vk082q3q.jpg ':size=60%')

运行**Spring Boot**应用，将会打印出：

```
2020-06-01 15:04:31.490  INFO 13208 --- [           main] c.f.HighOrderCommandLineRunner   : arg = --foo=bar
2020-06-01 15:04:31.490  INFO 13208 --- [           main] c.f.HighOrderCommandLineRunner   : arg = --foo=baz
2020-06-01 15:04:31.490  INFO 13208 --- [           main] c.f.HighOrderCommandLineRunner   : arg = --dev.name=码农小胖哥
2020-06-01 15:04:31.490  INFO 13208 --- [           main] c.f.HighOrderCommandLineRunner   : arg = java
2020-06-01 15:04:31.490  INFO 13208 --- [           main] c.f.HighOrderCommandLineRunner   : arg = felordcn
2020-06-01 15:04:31.491  INFO 13208 --- [           main] c.f.HighOrderCommandLineRunner   : i am highOrderRunner
2020-06-01 15:04:31.491  INFO 13208 --- [           main] c.f.LowOrderCommandLineRunner    : i am lowOrderRunner
2020-06-01 15:04:31.491  INFO 13208 --- [           main] c.f.DefaultApplicationRunner     : i am applicationRunner
2020-06-01 15:04:31.491  INFO 13208 --- [           main] c.f.DefaultApplicationRunner     : optionNames = [dev.name, foo]
2020-06-01 15:04:31.491  INFO 13208 --- [           main] c.f.DefaultApplicationRunner     : sourceArgs = [--foo=bar, --foo=baz, --dev.name=码农小胖哥, java, felordcn]
2020-06-01 15:04:31.491  INFO 13208 --- [           main] c.f.DefaultApplicationRunner     : nonOptionArgs = [java, felordcn]
2020-06-01 15:04:31.491  INFO 13208 --- [           main] c.f.DefaultApplicationRunner     : optionValues = [bar, baz]
```

然后你就可以根据实际需要动态地执行一些逻辑。

## JDK所提供的@PostConstruct

@PostConstruct是JDK所提供的注解，使用该注解的方法会在服务器加载Servlet的时候运行。也可以在一个类中写多个方法并添加这个注解

```java
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;

@Component
public class PostConstructTest {
    @PostConstruct
    public void start() {
        System.out.println("@PostConstruct方法执行");
    }

    @PostConstruct
    public void start01() {
        System.out.println("@PostConstruct1111方法执行");
    }
}
```



## 其他方法(不常用)

**1. ApplicationContextAware**

```java
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

@Component
public class ApplicationContextAwareImpl implements ApplicationContextAware {
    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        System.out.println("ApplicationContextAwareImpl方法执行");
    }
}
```

**ApplicationListener**(会执行多次)

```java
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

@Component
public class ApplicationListenerImpl implements ApplicationListener {
    @Override
    public void onApplicationEvent(ApplicationEvent event) {
        System.out.println("ApplicationListenerImpl方法执行");
    }
}
```

**InitializingBean**

```java
org.springframework.beans.factory.InitializingBean;
import org.springframework.stereotype.Component;

@Component
public class InitializingBeanImpl implements InitializingBean {

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("InitializingBeanImpl方法执行");
    }
}
```

这些方法也都可以实现在启动项目后立即执行，但是不太常用。