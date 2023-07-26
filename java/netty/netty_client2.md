资料来源：<br/>
[用netty实现客户端断线重连](https://blog.csdn.net/haohaoxuexiyai/article/details/116497444)<br/>
[Spring Boot 如何实现扫码登录](https://mp.weixin.qq.com/s/2STaw4J8hXDpalyM5e_94Q)



导入使用的jar

```xml
        <!-- netty -->
        <dependency>
            <groupId>io.netty</groupId>
            <artifactId>netty-all</artifactId>
            <version>4.1.39.Final</version>
        </dependency>
```



### 一、NettyClient

```java
import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.string.StringDecoder;
import io.netty.util.CharsetUtil;

import java.util.concurrent.TimeUnit;


public class NettyClient {

    private String host;
    private int port;
    private Bootstrap bootstrap;
    private EventLoopGroup group;

    private SocketChannel socketChannel;

    public NettyClient(String host, int port) {
        this.host = host;
        this.port = port;
        init();
    }

    public void init() {
        //客户端需要一个事件循环组
        group = new NioEventLoopGroup();
        //创建客户端启动对象
        // bootstrap 可重用, 只需在NettyClient实例化的时候初始化即可.
        bootstrap = new Bootstrap();
        bootstrap.group(group)
                .channel(NioSocketChannel.class)
                .handler(new ChannelInitializer<SocketChannel>() {
                    @Override
                    protected void initChannel(SocketChannel ch) throws Exception {
                        //加入处理器
                        ch.pipeline().addLast(new NettyClientHandler(NettyClient.this));
                    }
                });
    }

    public void connect() throws Exception {
        System.out.println("netty client start。。");
        //启动客户端去连接服务器端
        ChannelFuture cf = bootstrap.connect(host, port);
        Channel channel = cf.channel();
        socketChannel = (SocketChannel) channel;
        cf.addListener(new ChannelFutureListener() {
            @Override
            public void operationComplete(ChannelFuture future) throws Exception {
                if (!future.isSuccess()) {
                    //重连交给后端线程执行
                    future.channel().eventLoop().schedule(() -> {
                        System.err.println("重连服务端...");
                        try {
                            connect();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }, 3000, TimeUnit.MILLISECONDS);
                } else {
                    System.out.println("服务端连接成功...");
                }
            }
        });
        //对通道关闭进行监听
        cf.channel().closeFuture().sync();
    }

    /**
     * 发送数据
     * @param str
     */
    public void send(String str){
        boolean active = socketChannel.isActive();
        if (active) {
            socketChannel.writeAndFlush(Unpooled.copiedBuffer("hello，服务器~", CharsetUtil.UTF_8));
        } else {
            System.out.println("已经断开了连接");
        }
    }

}
```

### 二、NettyClientHandler 

```java
import com.yuandi.demo.netty.util.HexUtils;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.util.CharsetUtil;

public class NettyClientHandler extends ChannelInboundHandlerAdapter {

    private NettyClient nettyClient;

    /**
     * 构造方法
     * @param nettyClient
     */
    public NettyClientHandler(NettyClient nettyClient){
        this.nettyClient = nettyClient;
    }

    /**
     * 当通道准备就绪（激活）时触发
     * @param ctx
     * @throws Exception
     */
    @Override
    public void channelActive(ChannelHandlerContext ctx) {
        ctx.channel().writeAndFlush(Unpooled.copiedBuffer("hello，服务器~", CharsetUtil.UTF_8));
    }
    /**
     * 读取数据
     * @param ctx
     * @param msg
     * @throws Exception
     */
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
        ByteBuf buf = (ByteBuf) msg;
        String str = buf.toString(CharsetUtil.UTF_8);
        System.out.println("收到服务端的消息:" + HexUtils.getFormatHexStr(str.getBytes()));
        System.out.println("服务端的地址： " + ctx.channel().remoteAddress());
        System.out.println("本地的地址： " + ctx.channel().localAddress());
    }
    /**
     * 发生异常时的处理
     * @param ctx
     * @param cause
     * @throws Exception
     */
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        cause.printStackTrace();
        System.out.println("发生了异常处理======================");
        ctx.close();
    }

    /**
     * 连接断开了
     * @param ctx
     * @throws Exception
     */
    public void channelInactive(ChannelHandlerContext ctx) throws Exception {
        System.out.println("----------------------------------断开了连接----------------------------");

        System.out.println("休眠一秒后，进行重连");
        Thread.sleep(1000L);
        nettyClient.connect();
    }

}
```

### 集成到springboot中

```java
import com.yuandi.demo.start.netty.NettyClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class NettyClientConfiguration {

    NettyClient nettyClient;

    @Bean
    public NettyClient NettyClientBean() throws Exception {
        NettyClient nettyClient = new NettyClient("192.168.1.104", 7000);
        nettyClient.connect();

        return nettyClient;
    }

}
```

注意：在`NettyClient.connect()`中 ` cf.channel().closeFuture().sync();`

是异步的会产生阻塞。导致`springboot`启动后，无法运行到启动端口服务

```java
 @Bean
    public NettyClient getClient() throws Exception{
        String host = "127.0.0.1";
        int port = 7000;

        NettyClient client = new NettyClient(host,port);
        client.init();

//        client.connect();
        Thread thread = new Thread(() -> {
            try {
                client.connect();
            } catch (Exception e) {
                e.printStackTrace();
            }
        });

        thread.setName("t_netty_");
        thread.start();
        return client;
    }
```



因而进行修改版本，增加一个新的线程启动

![image-20230607172644477](img\image-20230607172644477.png)



### 简单测试发送数据

```java
import com.yuandi.demo.start.netty.NettyClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class SimpleControl {

    @Autowired
    private NettyClient client;

    @GetMapping("/hello")
    public Map<String,Object> sayHello(){
        Map<String,Object> map = new HashMap<>();
        map.put("hello", "hello world");

        client.send("hello");
        return map;
    }
}
```

运行效果

![image-20230506181000273](img\image-20230506181000273.png)

推荐使用网络传输助手来测试

![image-20230506181039437](img\image-20230506181039437.png)

### 扫描登录项目中使用

**增加pom.xml**

```xml
<dependency>  
    <groupId>org.springframework.boot</groupId>  
    <artifactId>spring-boot-starter-websocket</artifactId>  
</dependency>
```

增加一个Bean

```java
/**  
 \* WebSocket的支持  
 * @return  
 */  
@Bean  
public ServerEndpointExporter serverEndpointExporter() {  
    return new ServerEndpointExporter();  
}
```

**定义WebSocketServer**

```java
package com.stylefeng.guns.rest.modular.inve.websocket;  
   
/**  
 \* Created by jiangjiacheng on 2019/6/4.  
 */  
import java.io.IOException;  
import java.util.concurrent.CopyOnWriteArraySet;  
   
import javax.websocket.OnClose;  
import javax.websocket.OnError;  
import javax.websocket.OnMessage;  
import javax.websocket.OnOpen;  
import javax.websocket.Session;  
import javax.websocket.server.PathParam;  
import javax.websocket.server.ServerEndpoint;  
import org.springframework.stereotype.Component;  
import cn.hutool.log.Log;  
import cn.hutool.log.LogFactory;  
   
@ServerEndpoint("/websocket/{sid}")  
@Component  
public class WebSocketServer {  
   
    static Log log=LogFactory.get(WebSocketServer.class);  
   
    //静态变量，用来记录当前在线连接数。应该把它设计成线程安全的。  
    private static int onlineCount = 0;  
   
    //concurrent包的线程安全Set，用来存放每个客户端对应的MyWebSocket对象。  
    private static CopyOnWriteArraySet<WebSocketServer> webSocketSet = new CopyOnWriteArraySet<WebSocketServer>();  
   
    //与某个客户端的连接会话，需要通过它来给客户端发送数据  
    private Session session;  
   
    //接收sid  
    private String sid="";  
   
    /**  
     \* 连接建立成功调用的方法*/  
    @OnOpen  
    public void onOpen(Session session,@PathParam("sid") String sid) {  
        this.session = session;  
        webSocketSet.add(this); //加入set中  
        addOnlineCount(); //在线数加1  
        log.info("有新窗口开始监听:"+sid+",当前在线人数为" \+ getOnlineCount());  
        this.sid=sid;  
        /*try {  
            sendMessage("连接成功");  
        } catch (IOException e) {  
            log.error("websocket IO异常");  
        }*/  
    }  
   
    /**  
     \* 连接关闭调用的方法  
     */  
    @OnClose  
    public void onClose() {  
        webSocketSet.remove(this); //从set中删除  
        subOnlineCount(); //在线数减1  
        log.info("有一连接关闭！当前在线人数为" \+ getOnlineCount());  
    }  
   
    /**  
     \* 收到客户端消息后调用的方法  
     *  
     * @param message 客户端发送过来的消息*/  
    @OnMessage  
    public void onMessage(String message, Session session) {  
        log.info("收到来自窗口"+sid+"的信息:"+message);  
        //群发消息  
        for (WebSocketServer item : webSocketSet) {  
            try {  
                item.sendMessage(message);  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  
        }  
    }  
   
    /**  
     *  
     * @param session  
     * @param error  
     */  
    @OnError  
    public void onError(Session session, Throwable error) {  
        log.error("发生错误");  
        error.printStackTrace();  
    }  
    /**  
     \* 实现服务器主动推送  
     */  
    public void sendMessage(String message) throws IOException {  
        this.session.getBasicRemote().sendText(message);  
    }  
   
   
    /**  
     \* 群发自定义消息  
     \* */  
    public static void sendInfo(String message,@PathParam("sid") String sid) throws IOException {  
        log.info("推送消息到窗口"+sid+"，推送内容:"+message);  
        for (WebSocketServer item : webSocketSet) {  
            try {  
                //这里可以设定只推送给这个sid的，为null则全部推送  
                if(sid == null) {  
                    item.sendMessage(message);  
                }else if(item.sid.equals(sid)){  
                    item.sendMessage(message);  
                }  
            } catch (IOException e) {  
                continue;  
            }  
        }  
    }  
   
    public static synchronized int getOnlineCount() {  
        return onlineCount;  
    }  
   
    public static synchronized void addOnlineCount() {  
        WebSocketServer.onlineCount++;  
    }  
   
    public static synchronized void subOnlineCount() {  
        WebSocketServer.onlineCount--;  
    }  
}
```



