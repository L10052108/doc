资料来源：<br/>
[websocket系列:基于netty-websocket-spring-boot-starter轻松实现高性能websocket](https://laowan.blog.csdn.net/article/details/113985267?spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7EPayColumn-1-113985267-blog-113845879.235%5Ev36%5Epc_relevant_default_base3&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7EPayColumn-1-113985267-blog-113845879.235%5Ev36%5Epc_relevant_default_base3&utm_relevant_index=1)<br/>
[github netty-websocket-spring-boot-starter](https://github.com/YeautyYE/netty-websocket-spring-boot-starter/blob/master/README_zh.md)<br/>

## netty 介绍
netty-websocket-spring-boot-starter是一个开源的框架。通过它，我们可以像spring-boot-starter-websocket一样使用注解进行开发，只需关注需要的事件(如OnMessage)。并且底层是使用Netty,netty-websocket-spring-boot-starter其他配置和spring-boot-starter-websocket完全一样，当需要调参的时候只需要修改配置参数即可，无需过多的关心handler的设置。

Netty的传输快其实也是依赖了NIO的一个特性——零拷贝。我们知道，Java的内存有堆内存、栈内存和字符串常量池等等，其中堆内存是占用内存空间最大的一块，也是Java对象存放的地方，一般我们的数据如果需要从IO读取到堆内存，中间需要经过

Netty针对这种情况，使用了NIO中的另一大特性——零拷贝，当他需要接收数据的时候，他会在堆内存之外开辟一块内存，数据就直接从IO读到了那块内存中去，在netty里面通过ByteBuf可以直接对这些数据进行直接操作，从而加快了传输速度。

 Netty和Tomcat最大的区别就在于通信协议，Tomcat是基于Http协议的，他的实质是一个基于http协议的web容器，但是Netty不一样，他能通过编程自定义各种协议，因为netty能够通过codec自己来编码/解码字节流，完成类似redis访问的功能，这就是netty和tomcat最大的不同。

 ## 项目中使用

 ### 简单demo

**添加依赖**<br/>
```
  		<!-- websocket 推送 -->
        <dependency>
            <groupId>org.yeauty</groupId>
            <artifactId>netty-websocket-spring-boot-starter</artifactId>
            <version>0.12.0</version>
        </dependency>
```

启动配置

```
import org.yeauty.annotation.ServerEndpoint;

@ServerEndpoint(path = "/myWs")
public class MyWebSocket2 {

}
```

启动服务就会打印日志

![image-20230526091655304](img\image-20230526091655304.png ':size=70%')

定义接收处理事件

```
import com.sun.javafx.collections.MappingChange;
import io.netty.handler.codec.http.HttpHeaders;
import io.netty.handler.timeout.IdleStateEvent;
import org.springframework.util.MultiValueMap;
import org.yeauty.annotation.*;
import org.yeauty.pojo.Session;

import java.io.IOException;


@ServerEndpoint(path = "/ws/{arg}",port = "90")
public class MyWebSocket {
    

    @OnOpen
    public void onOpen(Session session, HttpHeaders headers, @RequestParam String req, @RequestParam MultiValueMap reqMap, @PathVariable String arg, @PathVariable MappingChange.Map pathMap){
        System.out.println("new connection");
    }

    @OnClose
    public void onClose(Session session) throws IOException {
        System.out.println("one connection closed");
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        throwable.printStackTrace();
    }

    @OnMessage
    public void onMessage(Session session, String message) {
        System.out.println("接收的消息为：" + message);
        session.sendText("Hello Netty!");
    }

    @OnBinary
    public void onBinary(Session session, byte[] bytes) {
        for (byte b : bytes) {
            System.out.println(b);
        }
        session.sendBinary(bytes);
    }

    @OnEvent
    public void onEvent(Session session, Object evt) {
        if (evt instanceof IdleStateEvent) {
            IdleStateEvent idleStateEvent = (IdleStateEvent) evt;
            switch (idleStateEvent.state()) {
                case READER_IDLE:
                    System.out.println("read idle");
                    break;
                case WRITER_IDLE:
                    System.out.println("write idle");
                    break;
                case ALL_IDLE:
                    System.out.println("all idle");
                    break;
                default:
                    break;
            }
        }
    }
}
```

### 案例使用