资料来源：<br/>
[Redis key过期事件的监听](https://blog.csdn.net/qq_35385687/article/details/120454902?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-0-120454902-blog-125929717.pc_relevant_3mothn_strategy_and_data_recovery&spm=1001.2101.3001.4242.1&utm_relevant_index=3)<br/>
[SpringBoot实现监听redis key失效事件](https://www.jianshu.com/p/106f0eae07c8)

## 需求：

处理订单过期自动取消，比如下单30分钟未支付自动更改订单状态

## 解决方案1：

可以利用redis天然的key自动过期机制，下单时将订单id写入redis，过期时间30分钟，30分钟后检查订单状态，如果未支付，则进行处理但是key过期了redis有通知吗？答案是肯定的。

### 开启redis key过期提醒

修改redis相关事件配置。找到redis配置文件redis.conf，查看“notify-keyspace-events”的配置项，如果没有，添加“notify-keyspace-events Ex”，如果有值，添加Ex，相关参数说明如下：



```bash
K：keyspace事件，事件以__keyspace@<db>__为前缀进行发布；         
E：keyevent事件，事件以__keyevent@<db>__为前缀进行发布；         
g：一般性的，非特定类型的命令，比如del，expire，rename等；        
$：字符串特定命令；         
l：列表特定命令；         
s：集合特定命令；         
h：哈希特定命令；         
z：有序集合特定命令；         
x：过期事件，当某个键过期并删除时会产生该事件；         
e：驱逐事件，当某个键因maxmemore策略而被删除时，产生该事件；         
A：g$lshzxe的别名，因此”AKE”意味着所有事件。
```

#### redis测试：

打开一个redis-cli ,监控db0的key过期事件



```ruby
127.0.0.1:6379> PSUBSCRIBE __keyevent@0__:expired
Reading messages... (press Ctrl-C to quit)
1) "psubscribe"
2) "__keyevent@0__:expired"
3) (integer) 1
```

打开另一个redis-cli ,发送定时过期key



```css
127.0.0.1:6379> setex test_key 3 test_value
```

观察上一个redis-cli ,会发现收到了过期的key`test_key`，但是无法收到过期的value `test_value`



```ruby
127.0.0.1:6379> PSUBSCRIBE __keyevent@0__:expired
Reading messages... (press Ctrl-C to quit)
1) "psubscribe"
2) "__keyevent@0__:expired"
3) (integer) 1
1) "pmessage"
2) "__keyevent@0__:expired"
3) "__keyevent@0__:expired"
4) "test_key"
```

### 在springboot中使用

- 1.pom 中添加依赖



```xml
        <!-- redis -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
```

- 2.定义配置`RedisListenerConfig`



```kotlin
import edu.zut.ding.listener.RedisExpiredListener;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.listener.PatternTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;

/**
 * @Author lsm
 * @Date 2018/10/27 20:56
 */
@Configuration
public class RedisListenerConfig {
    @Bean
    RedisMessageListenerContainer container(RedisConnectionFactory connectionFactory) {

        RedisMessageListenerContainer container = new RedisMessageListenerContainer();
        container.setConnectionFactory(connectionFactory);
//        container.addMessageListener(new RedisExpiredListener(), new PatternTopic("__keyevent@0__:expired"));
        return container;
    }
}
```

- 3.定义监听器，实现`KeyExpirationEventMessageListener`接口，查看源码发现，该接口监听所有db的过期事件**keyevent@\***:expired"



```swift
import edu.zut.ding.constants.SystemConstant;
import edu.zut.ding.enums.OrderState;
import edu.zut.ding.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.listener.KeyExpirationEventMessageListener;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.stereotype.Component;


/**
 * 监听所有db的过期事件__keyevent@*__:expired"
 * @author lsm
 */
@Component
public class RedisKeyExpirationListener extends KeyExpirationEventMessageListener {

    public RedisKeyExpirationListener(RedisMessageListenerContainer listenerContainer) {
        super(listenerContainer);
    }

    /**
     * 针对redis数据失效事件，进行数据处理
     * @param message
     * @param pattern
     */
    @Override
    public void onMessage(Message message, byte[] pattern) {
        // 用户做自己的业务处理即可,注意message.toString()可以获取失效的key
        String expiredKey = message.toString();
        if(expiredKey.startsWith("Order:")){
            //如果是Order:开头的key，进行处理
        }
    }
}
```

- 或者打开`RedisListenerConfig`中 `container.addMessageListener(new RedisExpiredListener(), new PatternTopic("__keyevent@0__:expired"));` 注释，再定义监听器，监控`__keyevent@0__:expired`事件，即`db0过期事件`。这个地方定义的比较灵活，可以自己定义监控什么事件。



```dart
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;

/**
 * @author lsm
 */
public class RedisExpiredListener implements MessageListener {

    /**
     * 客户端监听订阅的topic，当有消息的时候，会触发该方法;
     * 并不能得到value, 只能得到key。
     * 姑且理解为: redis服务在key失效时(或失效后)通知到java服务某个key失效了, 那么在java中不可能得到这个redis-key对应的redis-value。
     *      * 解决方案:
     *  创建copy/shadow key, 例如 set vkey "vergilyn"; 对应copykey: set copykey:vkey "" ex 10;
     *  真正的key是"vkey"(业务中使用), 失效触发key是"copykey:vkey"(其value为空字符为了减少内存空间消耗)。
     *  当"copykey:vkey"触发失效时, 从"vkey"得到失效时的值, 并在逻辑处理完后"del vkey"
     * 
     * 缺陷:
     *  1: 存在多余的key; (copykey/shadowkey)
     *  2: 不严谨, 假设copykey在 12:00:00失效, 通知在12:10:00收到, 这间隔的10min内程序修改了key, 得到的并不是 失效时的value.
     *  (第1点影响不大; 第2点貌似redis本身的Pub/Sub就不是严谨的, 失效后还存在value的修改, 应该在设计/逻辑上杜绝)
     *  当"copykey:vkey"触发失效时, 从"vkey"得到失效时的值, 并在逻辑处理完后"del vkey"
     * 
     */
    @Override
    public void onMessage(Message message, byte[] bytes) {
        byte[] body = message.getBody();// 建议使用: valueSerializer
        byte[] channel = message.getChannel();
        System.out.print("onMessage >> " );
        System.out.println(String.format("channel: %s, body: %s, bytes: %s"
                ,new String(channel), new String(body), new String(bytes)));
    }

}
```

## 解决方案2

使用spring + quartz定时任务（`支持任务信息写入mysql,多节点分布式执行任务`），下单成功后，生成一个30分钟后运行的任务，30分钟后检查订单状态，如果未支付，则进行处理

## 解决方案3

将订单过期时间信息写入mysql，按分钟轮询查询mysql，如果超时则进行处理，效率差！时间精准度底！

## 解决方案4

使用Java的定时器，不支持高可用，设置定时器的节点挂掉或者重启，任务失效！

## 结论

推荐使用方案1和方案2

> 参考：https://spring.io/guides/gs/messaging-redis/



作者：LI木水
链接：https://www.jianshu.com/p/106f0eae07c8
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。