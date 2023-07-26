资料来源：<br/>
[扯下@EventListener这个注解的神秘面纱](https://juejin.cn/post/7220251777685602363)<br/>
[spring事件监听（eventListener)](https://juejin.cn/post/6988040622984658958)

## EventListener注解方式

**原理：观察者模式**

spring的事件监听有三个部分组成，事件（ApplicationEvent)、监听器(ApplicationListener)和事件发布操作。

### 事件

```java
@Data
public class RegisterSuccessEvent {
    private String userName;

    public RegisterSuccessEvent(String userName) {
        this.userName = userName;
    }
}
```

### 监听器

```java
@Slf4j
@Component
public class RegisterEventListener {
    @EventListener
    public void handleNotifyEvent(RegisterSuccessEvent event){
        log.info("监听到用户注册成功事件：" +
                "{}，你注册成功了哦。记得来玩儿~", event.getUserName());
    }
}
```

可以有多个事件监听器

### 事件发布

采用接口请求触发

```java
@RestController
public class ListenController {

    @Resource
    private ApplicationContext applicationContext;

    @GetMapping("/publishEvent")
    public String start(){
        applicationContext.publishEvent(new RegisterSuccessEvent("歪歪"));
        return "success";
    }
}
```

访问`http://127.0.0.1:8003/publishEvent`可以看到触发成功

## 其他方式

### 事件

事件类需要继承ApplicationEvent，代码如下：

```java
public class HelloEvent extends ApplicationEvent {
    
    private String name;
    
    public HelloEvent(Object source, String name) {
        super(source);
        this.name = name;
    }
    
    public String getName() {
        return name;
    }
}
```

事件类是一种很简单的pojo，除了需要继承ApplicationEvent也没什么了，这个类有一个构造方法需要super。

### 事件监听器

```java
public class HelloEventListener implements ApplicationListener<HelloEvent> {

    private static final Logger logger = LoggerFactory.getLogger(HelloEventListener.class);

    @Override
    public void onApplicationEvent(HelloEvent event) {
        logger.info("receive {} say hello!",event.getName());
    }
}
```

事件监听器需要实现ApplicationListener接口，这是个泛型接口，泛型类类型就是事件类型，其次需要是spring容器托管的bean，所以这里加了@component，只有一个方法，就是onApplicationEvent。

### 事件发布操作

有了事件和监听器，不发布事件也不用，事件发布方式很简单

```java
applicationContext.publishEvent(new HelloEvent(this,"lgb"));
```