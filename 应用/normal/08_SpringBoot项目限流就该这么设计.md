资料来源：

[SpringBoot项目限流就该这么设计（万能通用），稳的一批！](https://mp.weixin.qq.com/s/26PYkpA48AAjCCiS08IQiw)

## SpringBoot项目限流

### 背景

限流对于一个微服务架构系统来说具有非常重要的意义，否则其中的某个微服务将成为整个系统隐藏的雪崩因素，为什么这么说？

举例来讲，某个SAAS平台有100多个微服务应用，但是作为底层的某个或某几个应用来说，将会被所有上层应用频繁调用，业务高峰期时，如果底层应用不做限流处理，该应用必将面临着巨大的压力，尤其是那些个别被高频调用的接口来说，最直接的表现就是导致后续新进来的请求阻塞、排队、响应超时...最后直到该服务所在JVM资源被耗尽。

### 限流概述

在大多数的微服务架构在设计之初，比如在技术选型阶段，架构师会从一个全局的视角去规划技术栈的组合，比如结合当前产品的现状考虑是使用dubbo？还是springcloud？作为微服务治理的底层框架。甚至为了满足快速的上线、迭代和交付，直接以springboot为基座进行开发，后续再引入新的技术栈等...

所以在谈论某个业务场景具体的技术解决方案时不可一概而论，而是需要结合产品和业务的现状综合评估，以限流来说，在下面的不同的技术架构下具体在选择的时候可能也不一样。

### 常用限流策略

不管是哪种限流组件，其底层的限流实现算法大同小异，这里列举几种常用的限流算法以供了解。

#### 令牌桶算法

令牌桶算法是目前应用最为广泛的限流算法，顾名思义，它有以下两个关键角色：

- 令牌 ：获取到令牌的Request才会被处理，其他Requests要么排队要么被直接丢弃；
- 桶 ：用来装令牌的地方，所有Request都从这个桶里面获取令牌

![image-20230630120140293](img\image-20230630120140293.png)

令牌桶主要涉及到2个过程，即令牌的生成，令牌的获取

#### 漏桶算法

漏桶算法的前半段和令牌桶类似，但是操作的对象不同，结合下图进行理解。

令牌桶是将令牌放入桶里，而漏桶是将访问请求的数据包放到桶里。同样的是，如果桶满了，那么后面新来的数据包将被丢弃。

![image-20230630120218645](img\image-20230630120218645.png)

####  滑动时间窗口

根据下图，简单描述下滑动时间窗口这种过程：

- 黑色大框为时间窗口，可以设定窗口时间单位为5秒，它会随着时间推移向后滑动。我们将窗口内的时间划分为五个小格子，每个格子代表1秒钟，同时这个格子还包含一个计数器，用来计算在当前时间内访问的请求数量。那么这个时间窗口内的总访问量就是所有格子计数器累加后的数值；
- 比如说，我们在每一秒内有5个用户访问，第5秒内有10个用户访问，那么在0到5秒这个时间窗口内访问量就是15。如果我们的接口设置了时间窗口内访问上限是20，那么当时间到第六秒的时候，这个时间窗口内的计数总和就变成了10，因为1秒的格子已经退出了时间窗口，因此在第六秒内可以接收的访问量就是20-10=10个；

![image-20230630120300895](img\image-20230630120300895.png)

滑动窗口其实也是一种计算器算法，它有一个显著特点，当时间窗口的跨度越长时，限流效果就越平滑。打个比方，如果当前时间窗口只有两秒，而访问请求全部集中在第一秒的时候，当时间向后滑动一秒后，当前窗口的计数量将发生较大的变化，拉长时间窗口可以降低这种情况的发生概率

### 通用限流实现方案

抛开网关层的限流先不说，在微服务应用中，考虑到技术栈的组合，团队人员的开发水平，以及易维护性等因素，一个比较通用的做法是，利用AOP技术+自定义注解实现对特定的方法或接口进行限流，下面基于这个思路来分别介绍下几种常用的限流方案的实现。

### 基于guava限流实现

guava为谷歌开源的一个比较实用的组件，利用这个组件可以帮助开发人员完成常规的限流操作，接下来看具体的实现步骤。

#####  引入guava依赖

版本可以选择更高的或其他版本

```xml
<dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>23.0</version>
</dependency>
```

#####  自定义限流注解

自定义一个限流用的注解，后面在需要限流的方法或接口上面只需添加该注解即可；

```java
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
 
@Target(value = ElementType.METHOD)
@Retention(value = RetentionPolicy.RUNTIME)
public @interface RateConfigAnno {
 
    String limitType();
 
    double limitCount() default 5d;
}
```

##### 限流AOP类

通过AOP前置通知的方式拦截添加了上述自定义限流注解的方法，解析注解中的属性值，并以该属性值作为guava提供的限流参数，该类为整个实现的核心所在。

```java
import com.alibaba.fastjson2.JSONObject;
import com.google.common.util.concurrent.RateLimiter;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
 
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.Objects;
 
@Aspect
@Component
public class GuavaLimitAop {
 
    private static Logger logger = LoggerFactory.getLogger(GuavaLimitAop.class);
 
    @Before("execution(@RateConfigAnno * *(..))")
    public void limit(JoinPoint joinPoint) {
        //1、获取当前的调用方法
        Method currentMethod = getCurrentMethod(joinPoint);
        if (Objects.isNull(currentMethod)) {
            return;
        }
        //2、从方法注解定义上获取限流的类型
        String limitType = currentMethod.getAnnotation(RateConfigAnno.class).limitType();
        double limitCount = currentMethod.getAnnotation(RateConfigAnno.class).limitCount();
        //使用guava的令牌桶算法获取一个令牌，获取不到先等待
        RateLimiter rateLimiter = RateLimitHelper.getRateLimiter(limitType, limitCount);
        boolean b = rateLimiter.tryAcquire();
        if (b) {
            System.out.println("获取到令牌");
        }else {
            HttpServletResponse resp = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getResponse();
            JSONObject jsonObject=new JSONObject();
            jsonObject.put("success",false);
            jsonObject.put("msg","限流中");
            try {
                output(resp, jsonObject.toJSONString());
            }catch (Exception e){
                logger.error("error,e:{}",e);
            }
        }
    }
 
    private Method getCurrentMethod(JoinPoint joinPoint) {
        Method[] methods = joinPoint.getTarget().getClass().getMethods();
        Method target = null;
        for (Method method : methods) {
            if (method.getName().equals(joinPoint.getSignature().getName())) {
                target = method;
                break;
            }
        }
        return target;
    }
 
    public void output(HttpServletResponse response, String msg) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        ServletOutputStream outputStream = null;
        try {
            outputStream = response.getOutputStream();
            outputStream.write(msg.getBytes("UTF-8"));
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            outputStream.flush();
            outputStream.close();
        }
    }
}
```

其中限流的核心API即为RateLimiter这个对象，涉及到的RateLimitHelper类如下

```java
import com.google.common.util.concurrent.RateLimiter;
 
import java.util.HashMap;
import java.util.Map;
 
public class RateLimitHelper {
 
    private RateLimitHelper(){}
 
    private static Map<String,RateLimiter> rateMap = new HashMap<>();
 
    public static RateLimiter getRateLimiter(String limitType,double limitCount ){
        RateLimiter rateLimiter = rateMap.get(limitType);
        if(rateLimiter == null){
            rateLimiter = RateLimiter.create(limitCount);
            rateMap.put(limitType,rateLimiter);
        }
        return rateLimiter;
    }
 
}
```

##### 测试接口

下面添加一个测试接口，测试一下上面的代码是否生效

```java
@RestController
public class OrderController {
 
    //localhost:8081/save
    @GetMapping("/save")
    @RateConfigAnno(limitType = "saveOrder",limitCount = 1)
    public String save(){
        return "success";
    }
 
}
```

在接口中为了模拟出效果，我们将参数设置的非常小，即QPS为1，可以预想当每秒请求超过1时将会出现被限流的提示，启动工程并验证接口，每秒1次的请求，可以正常得到结果，效果如下：

![image-20230630120541556](img\image-20230630120541556.png)

快速刷接口，将会看到下面的效果

![image-20230630120608276](img\image-20230630120608276.png)

### 基于redis+lua限流实现

redis是线程安全的，天然具有线程安全的特性，支持原子性操作，限流服务不仅需要承接超高QPS，还要保证限流逻辑的执行层面具备线程安全的特性，利用Redis这些特性做限流，既能保证线程安全，也能保证性能。基于redis的限流实现完整流程如下图：

![image-20230630120652993](img\image-20230630120652993.png)

结合上面的流程图，这里梳理出一个整体的实现思路：

- 编写lua脚本，指定入参的限流规则，比如对特定的接口限流时，可以根据某个或几个参数进行判定，调用该接口的请求，在一定的时间窗口内监控请求次数；
- 既然是限流，最好能够通用，可将限流规则应用到任何接口上，那么最合适的方式就是通过自定义注解形式切入；
- 提供一个配置类，被spring的容器管理，redisTemplate中提供了DefaultRedisScript这个bean；
- 提供一个能动态解析接口参数的类，根据接口参数进行规则匹配后触发限流；

##### 引入redis依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

##### 4.3.2 自定义注解

```java
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
@Documented
public @interface RedisLimitAnnotation {
 
    /**
     * key
     */
    String key() default "";
    /**
     * Key的前缀
     */
    String prefix() default "";
    /**
     * 一定时间内最多访问次数
     */
    int count();
    /**
     * 给定的时间范围 单位(秒)
     */
    int period();
    /**
     * 限流的类型(用户自定义key或者请求ip)
     */
    LimitType limitType() default LimitType.CUSTOMER;
 
}
```

##### 4.3.3 自定义redis配置类

```java
import org.springframework.context.annotation.Bean;
import org.springframework.core.io.ClassPathResource;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import org.springframework.scripting.support.ResourceScriptSource;
import org.springframework.stereotype.Component;
 
import java.io.Serializable;
 
@Component
public class RedisConfiguration {
 
    @Bean
    public DefaultRedisScript<Number> redisluaScript() {
        DefaultRedisScript<Number> redisScript = new DefaultRedisScript<>();
        redisScript.setScriptSource(new ResourceScriptSource(new ClassPathResource("limit.lua")));
        redisScript.setResultType(Number.class);
        return redisScript;
    }
 
    @Bean("redisTemplate")
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory redisConnectionFactory) {
        RedisTemplate<String, Object> redisTemplate = new RedisTemplate<>();
        redisTemplate.setConnectionFactory(redisConnectionFactory);
        Jackson2JsonRedisSerializer jackson2JsonRedisSerializer = new Jackson2JsonRedisSerializer(Object.class);
 
        //设置value的序列化方式为JSOn
        redisTemplate.setValueSerializer(jackson2JsonRedisSerializer);
        //设置key的序列化方式为String
        redisTemplate.setKeySerializer(new StringRedisSerializer());
 
        redisTemplate.setHashKeySerializer(new StringRedisSerializer());
        redisTemplate.setHashValueSerializer(jackson2JsonRedisSerializer);
        redisTemplate.afterPropertiesSet();
 
        return redisTemplate;
    }
 
}
```

##### 4.3.4 自定义限流AOP类

```java

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
 
import javax.servlet.http.HttpServletRequest;
import java.io.Serializable;
import java.lang.reflect.Method;
import java.util.Collections;
import java.util.List;
 
@Aspect
@Configuration
public class LimitRestAspect {
 
    private static final Logger logger = LoggerFactory.getLogger(LimitRestAspect.class);
 
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
 
    @Autowired
    private DefaultRedisScript<Number> redisluaScript;
 
 
    @Pointcut(value = "@annotation(com.congge.config.limit.RedisLimitAnnotation)")
    public void rateLimit() {
 
    }
 
    @Around("rateLimit()")
    public Object interceptor(ProceedingJoinPoint joinPoint) throws Throwable {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Class<?> targetClass = method.getDeclaringClass();
        RedisLimitAnnotation rateLimit = method.getAnnotation(RedisLimitAnnotation.class);
        if (rateLimit != null) {
            HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
            String ipAddress = getIpAddr(request);
            StringBuffer stringBuffer = new StringBuffer();
            stringBuffer.append(ipAddress).append("-")
                    .append(targetClass.getName()).append("- ")
                    .append(method.getName()).append("-")
                    .append(rateLimit.key());
            List<String> keys = Collections.singletonList(stringBuffer.toString());
            //调用lua脚本，获取返回结果，这里即为请求的次数
            Number number = redisTemplate.execute(
                    redisluaScript,
                    keys,
                    rateLimit.count(),
                    rateLimit.period()
            );
            if (number != null && number.intValue() != 0 && number.intValue() <= rateLimit.count()) {
                logger.info("限流时间段内访问了第：{} 次", number.toString());
                return joinPoint.proceed();
            }
        } else {
            return joinPoint.proceed();
        }
        throw new RuntimeException("访问频率过快，被限流了");
    }
 
    /**
     * 获取请求的IP方法
     * @param request
     * @return
     */
    private static String getIpAddr(HttpServletRequest request) {
        String ipAddress = null;
        try {
            ipAddress = request.getHeader("x-forwarded-for");
            if (ipAddress == null || ipAddress.length() == 0 || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getHeader("Proxy-Client-IP");
            }
            if (ipAddress == null || ipAddress.length() == 0 || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getHeader("WL-Proxy-Client-IP");
            }
            if (ipAddress == null || ipAddress.length() == 0 || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getRemoteAddr();
            }
            // 对于通过多个代理的情况，第一个IP为客户端真实IP,多个IP按照','分割
            if (ipAddress != null && ipAddress.length() > 15) {
                if (ipAddress.indexOf(",") > 0) {
                    ipAddress = ipAddress.substring(0, ipAddress.indexOf(","));
                }
            }
        } catch (Exception e) {
            ipAddress = "";
        }
        return ipAddress;
    }
 
}
```

该类要做的事情和上面的两种限流措施类似，不过在这里核心的限流是通过读取lua脚步，通过参数传递给lua脚步实现的。

##### 4.3.5 自定义lua脚本

在工程的resources目录下，添加如下的lua脚本

```lua
local key = "rate.limit:" .. KEYS[1]
 
local limit = tonumber(ARGV[1])
 
local current = tonumber(redis.call('get', key) or "0")
 
if current + 1 > limit then
  return 0
else
   -- 没有超阈值，将当前访问数量+1，并设置2秒过期（可根据自己的业务情况调整）
   redis.call("INCRBY", key,"1")
   redis.call("expire", key,"2")
   return current + 1
end
```

##### 4.3.6 添加测试接口

```
@RestController
public class RedisController {
 
    //localhost:8081/redis/limit
    @GetMapping("/redis/limit")
    @RedisLimitAnnotation(key = "queryFromRedis",period = 1, count = 1)
    public String queryFromRedis(){
        return "success";
    }
 
}
```

为了模拟效果，这里将QPS设置为1 ，启动工程后（提前启动redis服务），调用一下接口，正常的效果如下：