资料来源：<br/>
[Netty解决粘包和拆包问题的四种方案](https://blog.csdn.net/tianyaleixiaowu/article/details/123070954)<br/>
[【Netty - 解码器】did not read anything but decoded a message 异常](https://blog.csdn.net/baidu_35751704/article/details/105346833)<br/>
[Netty服务开发及性能优化](https://blog.csdn.net/qq_46225886/article/details/130075570)

## netty编码和解码



### 介绍

客户端与服务端进行通信，通信的消息是以二进制字节流的形式通过 `Channel` 进行传递的，所以当我们在客户端封装好`Java`业务对象后，需要将其按照协议转换成字节数组，并且当服务端接受到该二进制字节流时，需要将其根据协议再次解码成`Java`业务对象进行逻辑处理，这就是编码和解码的过程。`Netty` 为我们提供了`MessageToByteEncoder` 用于编码，`ByteToMessageDecoder` 用于解码。

### 举例

在[03_netty中client的断开后重连](netty_client2.md)基础上进行修改

`NettyClient`进行修改

```java
import io.netty.handler.codec.string.StringDecoder;
import io.netty.handler.codec.string.StringEncoder;


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
                        ch.pipeline()
                                // 接收到请求时进行解码
                                .addLast(new StringEncoder(Charset.defaultCharset()))
                                // 发送请求时进行编码
                                .addLast(new StringDecoder(Charset.defaultCharset()))
                                .addLast(new NettyClientHandler(NettyClient.this))

                        ;
                    }
                });
    }
```

在之前的代码基础上增加了

![image-20230609105413639](img\image-20230609105413639.png)

可以看出`store.liuwei.blog.netty.client.NettyClientHandler.channelRead`中进行修改

```java
    /**
     * 读取数据
     * @param ctx
     * @param msg
     * @throws Exception
     */
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
        System.out.println(msg);
        System.out.println(msg.getClass());
        System.out.println("收到服务端的消息:" + msg);
    }
```

发送程序进行修改

```java
    /**
     * 发送数据
     * @param message
     */
    public void send(String message){
        boolean active = socketChannel.isActive();
        if (active) {
            socketChannel.writeAndFlush(message);
        } else {
            System.out.println("已经断开了连接");
        }
    }
```

可以直接发送字符串

### 注意

ByteBuf默认情况下使用的是**堆外内存**，不进行内存释放会发生内存溢出。不过 `ByteToMessageDecoder `和 `MessageToByteEncoder `这两个解码和编码Handler 会自动帮我们完成内存释放的操作，无需再次手动释放。因为我们实现的 `encode() `和 `decode() `方法只是这两个` Handler `源码中执行的一个环节，最终会在` finally `代码块中完成对内存的释放，具体内容可阅读 `MessageToByteEncoder` 中第99行 `write()` 方法源码。



### 自定义编码和解码

编码只需要集成`MessageToMessageEncoder<CharSequence>`重写`protected void encode(ChannelHandlerContext ctx, CharSequence msg, List<Object> out) throws Exception`方法

同样道理解码`MessageToMessageDecoder<ByteBuf>`重写`protected void decode(ChannelHandlerContext ctx, ByteBuf msg, List<Object> out) throws Exception `方法

