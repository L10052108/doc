资料来源：<br/>
[这次终于把Spring的监听机制讲明白了](https://mp.weixin.qq.com/s?__biz=MzUyMDAxMTE2Nw==&mid=2247510038&idx=1&sn=efeddd313e08e72f793763e539258100&chksm=f9f204e6ce858df01197380955a2d9e4eb253b13f75b84c24da6c8c47ad017d55af2721a98aa&scene=132#wechat_redirect)



## sping的监听机制

对Spring框架，老朱相信大家都已不陌生了，它给我们提供了很多功能，包括IoC、AOP、事务管理等。其中，Spring的事件监听机制是一项非常重要的功能，它允许开发人员定义和处理自定义事件，并在应用程序中发布和监听这些事件。

这个机制可以让我们更加灵活地响应应用程序中发生的事件，同时还可以减少不同组件之间的耦合度。本文老朱将介绍Spring的事件监听机制，包括如何使用Spring提供的标准事件和如何定义和处理自定义事件。同时，我们还将讨论这个机制的底层原理和常见的应用场景。

**Spring事件监听机制的原理**

Spring 的监听机制是非常优秀的思想，它能够很好地实现代码解耦，将业务逻辑与非业务逻辑分离，让程序变得更加灵活和可维护。在业务开发中，我们可以借鉴这种思想，例如电商下单场景，下单业务的核心逻辑只与下单有关，但下单完成后，我们需要执行非业务逻辑，如发通知和记录用户行为日志，这些非业务逻辑可以通过监听器来解耦，从而实现代码的灵活和可维护性。那么监听机制的底层原理是什么呢？我们一起分析下。

实现Spring事件机制主要有4个接口：

**1.ApplicationEventPublisher：事件发布**

```java
public interface ApplicationEventPublisher {
    void publishEvent(ApplicationEvent event);
    void publishEvent(Object event);
}
```



**2.ApplicationListener：事件监听**

```java
public interface ApplicationListener<E extends ApplicationEvent> extends EventListener {
    void onApplicationEvent(E event);
}
```



**3.ApplicationEvent：事件**

```java
public abstract class ApplicationEvent extends EventObject {
    private final long timestamp;
    public ApplicationEvent(Object source) {
        super(source);
        this.timestamp = System.currentTimeMillis();
    }
    public long getTimestamp() {
        return this.timestamp;
    }
    public String toString() {
        return getClass().getSimpleName() + "{timestamp=" + this.timestamp + ", source=" + getSource() + "}";
    }
}
```



**4.ApplicationEventMulticaster：事件广播器，Spring中负责事件的发布和监听的核心接口**

```java
public interface ApplicationEventMulticaster {
    //用于向事件广播器注册一个监听器。在广播器发送事件时，这个监听器将会接收到事件。
    void addApplicationListener(ApplicationListener<?> listener);
    //用于将一个已经注册的监听器从事件广播器中移除。
    void removeApplicationListener(ApplicationListener<?> listener);
     //用于移除所有注册的监听器。
    void removeAllListeners();
    //用于向所有已注册的监听器广播一个事件。
    void multicastEvent(ApplicationEvent event);
}
```



Spring的源码中，当初始化beanfacotory时，我们会发现Spring会初始化事件广播器以及注册事件监听器源码如下，标红的源码你们追进去看看，逻辑很简单。



![图片](img\dsafoejwie.png)


 **Spring框架内部事件监听机制的应用**



在Spring框架中，有许多预定义的事件，这些事件涵盖了Spring的生命周期、Web应用程序上下文的生命周期以及许多其他方面。下面是一些常见的Spring事件：

> 1.ContextRefreshedEvent：
> 当ApplicationContext被初始化或刷新时触发该事件。
>
> 2.ContextStartedEvent：
>
> 当ApplicationContext被启动时触发该事件，即在所有BeanDefinition都已加载和bean初始化之后。
> 3.ContextStoppedEvent：
>
> 当ApplicationContext被停止时触发该事件，即在所有singleton bean被销毁之前。
>
> 4.ContextClosedEvent：
>
> 当ApplicationContext被关闭时触发该事件，即在所有singleton bean被销毁之后。
>
> 5.RequestHandledEvent：
>
> 在Web应用程序上下文中，当HTTP请求被处理完毕后触发该事件。
>
> 6.ServletRequestHandledEvent：
>
> 与RequestHandledEvent类似，但是专为Spring的DispatcherServlet设计。

除了这些预定义的事件之外，开发人员还可以创建自己的自定义事件，并使用ApplicationEventPublisher接口将其发布到应用程序上下文中。

 **自定义监听**

假设我们正在开发一个在线商城应用程序，我们需要在用户下单时发送一个通知邮件给商家。为了实现这个功能，我们可以使用自定义事件来触发邮件发送操作。

首先，我们需要定义一个名为OrderPlacedEvent的自定义事件，用于表示用户下单的事件。代码如下：

```java
package com.qf.listener;

import org.springframework.context.ApplicationEvent;


public class OrderPlacedEvent extends ApplicationEvent {
    private Order order;

    public OrderPlacedEvent(Object source, Order order) {
        super(source);
        this.order = order;
    }

    public Order getOrder() {
        return order;
    }
}
```



在上述代码中，我们定义了一个名为OrderPlacedEvent的自定义事件，并通过实现构造函数和getOrder()方法来传递订单参数和获取订单参数。

然后，我们需要定义一个名为OrderPlacedEventListener的自定义事件监听器，用于处理用户下单事件并触发邮件发送操作。代码如下：

```java
package com.qf.listener;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;

import org.springframework.stereotype.Component;

@Component
public class OrderPlacedEventListener {


    @EventListener
    public void handleOrderPlacedEvent(OrderPlacedEvent event) {
        Order order = event.getOrder();
        String message = "您有一个新的订单，订单号为：" + order.getOid();
        //todo 发邮件
        System.out.println("message = " + message);
    }
}
```

在上述代码中，我们定义了一个名为OrderPlacedEventListener的自定义事件监听器，在handleOrderPlacedEvent()方法中，我们从事件对象中获取订单参数，然后发送邮件（具体邮件代码此处省略）最后，当用户下单成功时，我们需要在订单服务对象中触发OrderPlacedEvent事件，以便通知邮件能够被发送。代码如下：

```java
package com.qf.listener;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

@Service
public class OrderService {
    @Autowired
    private ApplicationEventPublisher eventPublisher;

    public void placeOrder(Order order) {
        // 订单保存逻辑
        // ...
        // 触发订单下单事件
        eventPublisher.publishEvent(new OrderPlacedEvent(this, order));
    }
}
```

在上述代码中，我们定义了一个名为OrderService的订单服务对象，并使用@Autowired注解来注入一个事件发布器对象。在placeOrder()方法中，我们调用订单保存逻辑，然后使用事件发布器对象触发OrderPlacedEvent事件，并传递订单参数。

通过上述代码，我们可以在用户下单时触发OrderPlacedEvent事件，并通过自定义事件监听器处理该事件并触发邮件发送操作。



 **Spring事件监听机制的优点**

Spring事件监听机制具有以下优点：

> 1.松耦合：通过事件监听机制，组件之间的耦合度得到了很大的降低，每个组件只需要监听自己感兴趣的事件，不需要关心其他组件的实现细节。
>
> 2.可扩展性：通过定义新的事件类型和监听器，应用程序的功能可以随着需求的变化而不断扩展。
>
> 3.高可靠性：事件监听机制可以保证应用程序的可靠性，即使某个组件出现异常或错误，其他组件仍然可以正常运行。

 **总结**

最后老朱给大家总结一下。Spring 监听机制是一种非常优秀的设计模式（观察者模式），它可以实现代码的解耦和模块化。通过定义事件和监听器，我们可以将代码的不同模块分离开来，以便更好地维护和修改。Spring 框架内置了许多事件和监听器，如上下文事件、Bean 事件、Web 事件等，开发者也可以根据具体需求自定义事件和监听器。

对于开发者来说，使用 Spring 监听机制非常简单。只需要实现事件和监听器接口，并在代码中注册监听器即可。Spring 会自动管理事件和监听器的生命周期，确保它们的正确运行。同时，由于 Spring 监听器使用了异步执行机制，因此不会影响主线程的运行效率，保证了应用程序的高并发和高效性。

