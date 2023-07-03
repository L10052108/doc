资料来源：<br/>
[websocket系列:基于netty-websocket-spring-boot-starter轻松实现高性能websocket](https://laowan.blog.csdn.net/article/details/113985267?spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7EPayColumn-1-113985267-blog-113845879.235%5Ev36%5Epc_relevant_default_base3&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7EPayColumn-1-113985267-blog-113845879.235%5Ev36%5Epc_relevant_default_base3&utm_relevant_index=1)<br/>
[github netty-websocket-spring-boot-starter](https://github.com/YeautyYE/netty-websocket-spring-boot-starter/blob/master/README_zh.md)<br/>



案例使用资料来源：

[springBoot集成webSocket并使用postMan进行测试](https://www.toutiao.com/article/7177193271481860619/?app=news_article&timestamp=1671119163&use_new_style=1&req_id=202212152346037A22732ED825E889A450&group_id=7177193271481860619&share_token=032BBC14-0454-4D6F-BCFF-CB532E817C69&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_ios&utm_campaign=client_share&wxshare_count=1&source=m_redirect)

[SpringBoot2.0集成WebSocket，实现后台向前端推送信息](https://blog.csdn.net/moshowgame/article/details/80275084?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522168507354216800184186229%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=168507354216800184186229&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~top_positive~default-3-80275084-null-null.142^v88^control,239^v2^insert_chatgpt&utm_term=WebSocket&spm=1018.2226.3001.4187)

## netty 介绍
netty-websocket-spring-boot-starter是一个开源的框架。通过它，我们可以像spring-boot-starter-websocket一样使用注解进行开发，只需关注需要的事件(如OnMessage)。并且底层是使用Netty,netty-websocket-spring-boot-starter其他配置和spring-boot-starter-websocket完全一样，当需要调参的时候只需要修改配置参数即可，无需过多的关心handler的设置。

Netty的传输快其实也是依赖了NIO的一个特性——零拷贝。我们知道，Java的内存有堆内存、栈内存和字符串常量池等等，其中堆内存是占用内存空间最大的一块，也是Java对象存放的地方，一般我们的数据如果需要从IO读取到堆内存，中间需要经过

Netty针对这种情况，使用了NIO中的另一大特性——零拷贝，当他需要接收数据的时候，他会在堆内存之外开辟一块内存，数据就直接从IO读到了那块内存中去，在netty里面通过ByteBuf可以直接对这些数据进行直接操作，从而加快了传输速度。

 Netty和Tomcat最大的区别就在于通信协议，Tomcat是基于Http协议的，他的实质是一个基于http协议的web容器，但是Netty不一样，他能通过编程自定义各种协议，因为netty能够通过codec自己来编码/解码字节流，完成类似redis访问的功能，这就是netty和tomcat最大的不同。

 ## 项目中使用

 ### 简单demo

**添加依赖**<br/>
```xml
  		<!-- websocket 推送 -->
        <dependency>
            <groupId>org.yeauty</groupId>
            <artifactId>netty-websocket-spring-boot-starter</artifactId>
            <version>0.12.0</version>
        </dependency>
```

启动服务就会打印日志

![image-20230526091655304](img\image-20230526091655304.png ':size=70%')

定义接收处理事件

```java
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

对应测试前端页面

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My WebSocke</title>
</head>

<body>
<input id="text" type="text" />
<button onclick="send()">Send</button>
<button onclick="closeWebSocket()">Close</button>
<div id="message"></div>
</body>
<script type="text/javascript">
    let ws = null;
    //判断当前浏览器是否支持WebSocket
    if ('WebSocket' in window) {
        ws = new WebSocket("ws://localhost:90/ws");
    }
    else {
        alert('当前浏览器 Not support websocket')
    }

    //连接发生错误的回调方法
    ws.onerror = function () {
        setMessageInnerHTML("WebSocket连接发生错误");
    };

    //连接成功建立的回调方法
    ws.onopen = function(event) {
        console.log("ws调用连接成功回调方法")
        //ws.send("")
    }
    //接收到消息的回调方法
    ws.onmessage = function(message) {
        console.log("接收消息：" + message.data);
        if (typeof(message.data) == 'string') {
            setMessageInnerHTML(message.data);
        }
    }
    //ws连接断开的回调方法
    ws.onclose = function(e) {
        console.log("ws连接断开")
        //console.log(e)
        setMessageInnerHTML("ws close");
    }

    //将消息显示在网页上
    function setMessageInnerHTML(innerHTML) {
        console.log(innerHTML)
        document.getElementById('message').innerHTML += '接收的消息:' + innerHTML + '<br/>';
    }

    //关闭连接
    function closeWebSocket() {
        ws.close();
    }


    //发送消息
    function send(msg) {
        if(!msg){
            msg = document.getElementById('text').value;
            document.getElementById('message').innerHTML += "发送的消息:" + msg + '<br/>';
            ws.send(msg);
        }
    }
</script>
</html>
```

测试结果

![image-20230526155321153](\img\image-20230526155321153.png ':size=60%')

### 案例使用

webSocket经常被用作聊天室，两个客户端，通过一个服务端分发请求，进行沟通

```java

import com.alibaba.fastjson.JSONObject;
import com.sun.javafx.collections.MappingChange;
import io.netty.handler.codec.http.HttpHeaders;
import io.netty.handler.timeout.IdleStateEvent;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.util.MultiValueMap;
import org.yeauty.annotation.*;
import org.yeauty.pojo.Session;

import javax.websocket.server.PathParam;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;


@Slf4j
@ServerEndpoint(path = "/server/{userId}",port = "80")
public class MyWebSocket2 {

    /**静态变量，用来记录当前在线连接数。应该把它设计成线程安全的。*/
    private static int onlineCount = 0;
    /**concurrent包的线程安全集合，也可以map改成set，用来存放每个客户端对应的MyWebSocket对象。*/
    private static ConcurrentHashMap<String,MyWebSocket2> webSocketMap = new ConcurrentHashMap<>();
    /**与某个客户端的连接会话，需要通过它来给客户端发送数据*/
    private Session session;
    /**接收userId*/
    private String userId="";

    /**
     *建立ws连接前的配置
     */
//   @BeforeHandshake
//    public void handshake(Session session, HttpHeaders headers, @RequestParam String req, @RequestParam MultiValueMap reqMap, @PathVariable String arg, @PathVariable MappingChange.Map pathMap){
//        //采用stomp子协议
//        session.setSubprotocols("stomp");
//        if (!"ok".equals(req)){
//            System.out.println("Authentication failed!");
//            session.close();
//        }
//    }

    @OnOpen
    public void onOpen(Session session, HttpHeaders headers, @RequestParam String req, @RequestParam MultiValueMap reqMap, @PathVariable String userId, @PathVariable MappingChange.Map pathMap){
        this.session = session;
        this.userId=userId;

        if(!webSocketMap.containsKey(userId)){
            //加入集合中
            webSocketMap.put(userId,this);
            //在线数加1
            addOnlineCount();
        }

        log.info("用户连接:"+userId+",当前在线人数为:" + getOnlineCount());

        try {
            sendMessage("连接成功");
        } catch (IOException e) {
            log.error("用户:"+userId+",网络异常!!!!!!");
        }
    }

    @OnClose
    public void onClose(Session session) throws IOException {
        if(webSocketMap.containsKey(userId)){
            webSocketMap.remove(userId);
            //从集合中删除
            subOnlineCount();
        }
        log.info("用户退出:"+userId+",当前在线人数为:" + getOnlineCount());
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        log.error("用户错误:" + this.userId + ",原因:" + throwable.getMessage());
        throwable.printStackTrace();
    }

    @OnMessage
    public void onMessage(Session session, String message) {
        log.info("【websocket消息】收到客户端发来的消息:{}", message);

//        {"toUserId":"10","contentText":"hello websocket"}
        JSONObject jsonObject = JSONObject.parseObject(message);
        String toUserId = jsonObject.getString("toUserId");
        String contentText = jsonObject.getString("contentText");

        try {
            sendInfo(contentText,toUserId);
        } catch (IOException e) {
            e.printStackTrace();
        }
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

    /**
     * 实现服务器主动推送
     */
    public void sendMessage(String message) throws IOException {
        this.session.sendText(message);
    }

    /**
     * 发送自定义消息
     * */
    public static void sendInfo(String message,@PathParam("userId") String userId) throws IOException {
        log.info("发送消息到:"+userId+"，报文:"+message);
        if(StringUtils.isNotBlank(userId)&&webSocketMap.containsKey(userId)){
            webSocketMap.get(userId).sendMessage(message);
        }else{
            log.error("用户"+userId+",不在线！");
        }
    }

    public static synchronized int getOnlineCount() {
        return onlineCount;
    }

    public static synchronized void addOnlineCount() {
        MyWebSocket2.onlineCount++;
    }

    public static synchronized void subOnlineCount() {
        MyWebSocket2.onlineCount--;
    }

}
```

对应的前端页面

```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>websocket通讯</title>
</head>
<script src="https://cdn.bootcss.com/jquery/3.3.1/jquery.js"></script>
<script>
    var socket;
    function openSocket() {
        if(typeof(WebSocket) == "undefined") {
            console.log("您的浏览器不支持WebSocket");
        }else{
            console.log("您的浏览器支持WebSocket");
            //实现化WebSocket对象，指定要连接的服务器地址与端口  建立连接
            //等同于socket = new WebSocket("ws://localhost:8888/xxxx/im/25");
            //var socketUrl="${request.contextPath}/im/"+$("#userId").val();
            var socketUrl="http://localhost:80/server/"+$("#userId").val();
            socketUrl=socketUrl.replace("https","ws").replace("http","ws");
            console.log(socketUrl);
            if(socket!=null){
                socket.close();
                socket=null;
            }
            socket = new WebSocket(socketUrl);
            //打开事件
            socket.onopen = function() {
                console.log("websocket已打开");
                //socket.send("这是来自客户端的消息" + location.href + new Date());
            };
            //获得消息事件
            socket.onmessage = function(msg) {
                console.log(msg.data);
                //发现消息进入    开始处理前端触发逻辑
            };
            //关闭事件
            socket.onclose = function() {
                console.log("websocket已关闭");
            };
            //发生了错误事件
            socket.onerror = function() {
                console.log("websocket发生了错误");
            }
        }
    }
    function sendMessage() {
        if(typeof(WebSocket) == "undefined") {
            console.log("您的浏览器不支持WebSocket");
        }else {
            // console.log("您的浏览器支持WebSocket");
            // console.log('{"toUserId":"'+$("#toUserId").val()+'","contentText":"'+$("#contentText").val()+'"}');
            socket.send('{"toUserId":"'+$("#toUserId").val()+'","contentText":"'+$("#contentText").val()+'"}');
        }
    }
</script>
<body>
<p>【userId】：<div><input id="userId" name="userId" type="text" value="10"></div>
<p>【toUserId】：<div><input id="toUserId" name="toUserId" type="text" value="10"></div>
<p>【toUserId】：<div><input id="contentText" name="contentText" type="text" value="hello websocket"></div>
<p>【操作】：<div>
    <button onclick="openSocket()">开启socket</button></div>
<p>【操作】：<div><button onclick="sendMessage()">发送消息</button></button></div>
</body>

</html>

```

使用结果

![image-20230526154744049](img\image-20230526154744049.png ':size=50%')



