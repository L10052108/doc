资料来源：<br/>
[用netty实现客户端断线重连](https://blog.csdn.net/haohaoxuexiyai/article/details/116497444)



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