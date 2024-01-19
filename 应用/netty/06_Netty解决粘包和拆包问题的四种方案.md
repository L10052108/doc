资料来源：<br/>
[Netty解决粘包和拆包问题的四种方案](https://blog.csdn.net/tianyaleixiaowu/article/details/123070954)


## Netty解决粘包和拆包问题的四种方案

### 产生的原因

​    在RPC框架中，粘包和拆包问题是必须解决一个问题，因为RPC框架中，各个微服务相互之间都是维系了一个TCP长连接，比如dubbo就是一个全双工的长连接。由于微服务往对方发送信息的时候，所有的请求都是使用的同一个连接，这样就会产生粘包和拆包的问题。

​    产生粘包和拆包问题的主要原因是，操作系统在发送TCP数据的时候，底层会有一个缓冲区，例如1024个字节大小，如果一次请求发送的数据量比较小，没达到缓冲区大小，TCP则会将多个请求合并为同一个请求进行发送，这就形成了粘包问题；如果一次请求发送的数据量比较大，超过了缓冲区大小，TCP就会将其拆分为多次发送，这就是拆包，也就是将一个大的包拆分为多个小包进行发送。如下图展示了粘包和拆包的一个示意图：

![0f42a20db29c788dfc1db038ab4d43de](img\0f42a20db29c788dfc1db038ab4d43de.png)

![7579d6452c5f27c46d207a7233078b59](img\7579d6452c5f27c46d207a7233078b59.png)

![78de86e7280e290d7a41eaadb1f71286](img\78de86e7280e290d7a41eaadb1f71286.png)

上图中演示了粘包和拆包的三种情况：

- A和B两个包都刚好满足TCP缓冲区的大小，或者说其等待时间已经达到TCP等待时长，从而还是使用两个独立的包进行发送；
- A和B两次请求间隔时间内较短，并且数据包较小，因而合并为同一个包发送给服务端；
- B包比较大，因而将其拆分为两个包B_1和B_2进行发送，而这里由于拆分后的B_2比较小，其又与A包合并在一起发送。

### 解决方案

对于粘包和拆包问题，常见的解决方案有四种：

- 客户端在发送数据包的时候，每个包都固定长度，比如1024个字节大小，如果客户端发送的数据长度不足1024个字节，则通过补充空格的方式补全到指定长度；
- 客户端在每个包的末尾使用固定的分隔符，例如\r\n，如果一个包被拆分了，则等待下一个包发送过来之后找到其中的\r\n，然后对其拆分后的头部部分与前一个包的剩余部分进行合并，这样就得到了一个完整的包；
- 将消息分为头部和消息体，在头部中保存有当前整个消息的长度，只有在读取到足够长度的消息之后才算是读到了一个完整的消息；
- 通过自定义协议进行粘包和拆包的处理。

### FixedLengthFrameDecoder

 对于使用固定长度的粘包和拆包场景，可以使用`FixedLengthFrameDecoder`，该解码一器会每次读取固定长度的消息，如果当前读取到的消息不足指定长度，那么就会等待下一个消息到达后进行补足。其使用也比较简单，只需要在构造函数中指定每个消息的长度即可。这里需要注意的是，`FixedLengthFrameDecoder`只是一个解码一器，Netty也只提供了一个解码一器，这是因为对于解码是需要等待下一个包的进行补全的，代码相对复杂，而对于编码器，用户可以自行编写，因为编码时只需要将不足指定长度的部分进行补全即可。下面的示例中展示了如何使用`FixedLengthFrameDecoder`来进行粘包和拆包处理：

### LineBasedFrameDecoder与DelimiterBasedFrameDecoder

 对于通过分隔符进行粘包和拆包问题的处理，Netty提供了两个编解码的类，`LineBasedFrameDecoder`和`DelimiterBasedFrameDecoder`。这里`LineBasedFrameDecoder`的作用主要是通过换行符，即`\n`或者`\r\n`对数据进行处理；而`DelimiterBasedFrameDecoder`的作用则是通过用户指定的分隔符对数据进行粘包和拆包处理。同样的，这两个类都是解码一器类，而对于数据的编码，也即在每个数据包最后添加换行符或者指定分割符的部分需要用户自行进行处理。这里以`DelimiterBasedFrameDecoder`为例进行讲解，如下是`EchoServer`中使用该类的代码片段，其余部分与前面的例子中的完全一致：

```java
@Override
protected void initChannel(SocketChannel ch) throws Exception {
    String delimiter = "_$";
    // 将delimiter设置到DelimiterBasedFrameDecoder中，经过该解码一器进行处理之后，源数据将会
    // 被按照_$进行分隔，这里1024指的是分隔的最大长度，即当读取到1024个字节的数据之后，若还是未
    // 读取到分隔符，则舍弃当前数据段，因为其很有可能是由于码流紊乱造成的
    ch.pipeline().addLast(new DelimiterBasedFrameDecoder(1024,
        Unpooled.wrappedBuffer(delimiter.getBytes())));
    // 将分隔之后的字节数据转换为字符串数据
    ch.pipeline().addLast(new StringDecoder());
    // 这是我们自定义的一个编码器，主要作用是在返回的响应数据最后添加分隔符
    ch.pipeline().addLast(new DelimiterBasedFrameEncoder(delimiter));
    // 最终处理数据并且返回响应的handler
    ch.pipeline().addLast(new EchoServerHandler());
}
```

### LengthFieldBasedFrameDecoder与LengthFieldPrepender

 这里`LengthFieldBasedFrameDecoder`与`LengthFieldPrepender`需要配合起来使用，其实本质上来讲，这两者一个是解码，一个是编码的关系。它们处理粘拆包的主要思想是在生成的数据包中添加一个长度字段，用于记录当前数据包的长度。`LengthFieldBasedFrameDecoder`会按照参数指定的包长度偏移量数据对接收到的数据进行解码，从而得到目标消息体数据；而`LengthFieldPrepender`则会在响应的数据前面添加指定的字节数据，这个字节数据中保存了当前消息体的整体字节数据长度。`LengthFieldBasedFrameDecoder`的解码过程如下图所示：

![7579d6452c5f27c46d207a7233078b59](img\7579d6452c5f27c46d207a7233078b59-1686281561486.png)

​    `LengthFieldPrepender`的编码过程如下图所示：

![78de86e7280e290d7a41eaadb1f71286](img\78de86e7280e290d7a41eaadb1f71286-1686281576510.png)



​    关于`LengthFieldBasedFrameDecoder`，这里需要对其构造函数参数进行介绍：

- maxFrameLength：指定了每个包所能传递的最大数据包大小；
- lengthFieldOffset：指定了长度字段在字节码中的偏移量；
- lengthFieldLength：指定了长度字段所占用的字节长度；
- lengthAdjustment：对一些不仅包含有消息头和消息体的数据进行消息头的长度的调整，这样就可以只得到消息体的数据，这里的lengthAdjustment指定的就是消息头的长度；
- initialBytesToStrip：对于长度字段在消息头中间的情况，可以通过initialBytesToStrip忽略掉消息头以及长度字段占用的字节。

​    这里我们以json序列化为例对`LengthFieldBasedFrameDecoder`和`LengthFieldPrepender`的使用方式进行讲解。如下是`EchoServer`的源码：

```java
public class EchoServer {
 
  public void bind(int port) throws InterruptedException {
    EventLoopGroup bossGroup = new NioEventLoopGroup();
    EventLoopGroup workerGroup = new NioEventLoopGroup();
    try {
      ServerBootstrap bootstrap = new ServerBootstrap();
      bootstrap.group(bossGroup, workerGroup)
        .channel(NioServerSocketChannel.class)
        .option(ChannelOption.SO_BACKLOG, 1024)
        .handler(new LoggingHandler(LogLevel.INFO))
        .childHandler(new ChannelInitializer<SocketChannel>() {
          @Override
          protected void initChannel(SocketChannel ch) throws Exception {
            // 这里将LengthFieldBasedFrameDecoder添加到pipeline的首位，因为其需要对接收到的数据
            // 进行长度字段解码，这里也会对数据进行粘包和拆包处理
            ch.pipeline().addLast(new LengthFieldBasedFrameDecoder(1024, 0, 2, 0, 2));
            // LengthFieldPrepender是一个编码器，主要是在响应字节数据前面添加字节长度字段
            ch.pipeline().addLast(new LengthFieldPrepender(2));
            // 对经过粘包和拆包处理之后的数据进行json反序列化，从而得到User对象
            ch.pipeline().addLast(new JsonDecoder());
            // 对响应数据进行编码，主要是将User对象序列化为json
            ch.pipeline().addLast(new JsonEncoder());
            // 处理客户端的请求的数据，并且进行响应
            ch.pipeline().addLast(new EchoServerHandler());
          }
        });
 
      ChannelFuture future = bootstrap.bind(port).sync();
      future.channel().closeFuture().sync();
    } finally {
      bossGroup.shutdownGracefully();
      workerGroup.shutdownGracefully();
    }
  }
 
  public static void main(String[] args) throws InterruptedException {
    new EchoServer().bind(8080);
  }
}
```

   这里`EchoServer`主要是在pipeline中添加了两个编码器和两个解码一器，编码器主要是负责将响应的User对象序列化为json对象，然后在其字节数组前面添加一个长度字段的字节数组；解码一器主要是对接收到的数据进行长度字段的解码，然后将其反序列化为一个User对象。下面是`JsonDecoder`的源码：

```java
public class JsonDecoder extends MessageToMessageDecoder<ByteBuf> {
 
  @Override
  protected void decode(ChannelHandlerContext ctx, ByteBuf buf, List<Object> out) 
      throws Exception {
    byte[] bytes = new byte[buf.readableBytes()];
    buf.readBytes(bytes);
    User user = JSON.parseObject(new String(bytes, CharsetUtil.UTF_8), User.class);
    out.add(user);
  }
}
```

​    `JsonDecoder`首先从接收到的数据流中读取字节数组，然后将其反序列化为一个User对象。下面我们看看`JsonEncoder`的源码：

```scala
public class JsonDecoder extends MessageToMessageDecoder<ByteBuf> {
 
  @Override
  protected void decode(ChannelHandlerContext ctx, ByteBuf buf, List<Object> out) 
      throws Exception {
    byte[] bytes = new byte[buf.readableBytes()];
    buf.readBytes(bytes);
    User user = JSON.parseObject(new String(bytes, CharsetUtil.UTF_8), User.class);
    out.add(user);
  }
}
```

`JsonEncoder`将响应得到的User对象转换为一个json对象，然后写入响应中。对于`EchoServerHandler`，其主要作用就是接收客户端数据，并且进行响应，如下是其源码：

```scala
@Override
protected void initChannel(SocketChannel ch) throws Exception {
    ch.pipeline().addLast(new LengthFieldBasedFrameDecoder(1024, 0, 2, 0, 2));
    ch.pipeline().addLast(new LengthFieldPrepender(2));
    ch.pipeline().addLast(new JsonDecoder());
    ch.pipeline().addLast(new JsonEncoder());
    ch.pipeline().addLast(new EchoClientHandler());
}
```

​    对于客户端，其主要逻辑与服务端的基本类似，这里主要展示其pipeline的添加方式，以及最后发送请求，并且对服务器响应进行处理的过程：

```java
public class EchoClientHandler extends SimpleChannelInboundHandler<User> {
 
  @Override
  public void channelActive(ChannelHandlerContext ctx) throws Exception {
    ctx.write(getUser());
  }
 
  private User getUser() {
    User user = new User();
    user.setAge(27);
    user.setName("zhangxufeng");
    return user;
  }
 
  @Override
  protected void channelRead0(ChannelHandlerContext ctx, User user) throws Exception {
    System.out.println("receive message from server: " + user);
  }
}
```

​    这里客户端首先会在连接上服务器时，往服务器发送一个User对象数据，然后在接收到服务器响应之后，会打印服务器响应的数据。

### 自定义粘包与拆包器

​    对于粘包与拆包问题，其实前面三种基本上已经能够满足大多数情形了，但是对于一些更加复杂的协议，可能有一些定制化的需求。对于这些场景，其实本质上，我们也不需要手动从头开始写一份粘包与拆包处理器，而是通过继承`LengthFieldBasedFrameDecoder`和`LengthFieldPrepender`来实现粘包和拆包的处理。

​    如果用户确实需要不通过继承的方式实现自己的粘包和拆包处理器，这里可以通过实现`MessageToByteEncoder`和`ByteToMessageDecoder`来实现。这里`MessageToByteEncoder`的作用是将响应数据编码为一个ByteBuf对象，而`ByteToMessageDecoder`则是将接收到的ByteBuf数据转换为某个对象数据。通过实现这两个抽象类，用户就可以达到实现自定义粘包和拆包处理的目的。如下是这两个类及其抽象方法的声明：

```java
public abstract class ByteToMessageDecoder extends ChannelInboundHandlerAdapter {
    protected abstract void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) 
        throws Exception;
}
```

```java
public abstract class MessageToByteEncoder<I> extends ChannelOutboundHandlerAdapter {
    protected abstract void encode(ChannelHandlerContext ctx, I msg, ByteBuf out) 
        throws Exception;
}
```

