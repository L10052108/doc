资料来源：<br/>
[springboot 加载一个properties文件转换为map](https://blog.csdn.net/changerzhuo_319/article/details/101388516 )

## 获取properties

### @value

配置文件

~~~~java
com.aiiju.title=天明开发者论坛
com.aiiju.description=分享生活和技术
~~~~

通过直接取值的方式获取

~~~~java
@value("${com.aiiju.title}")
private String title;
~~~~



### 批量获取

在 [application]().yml 中配置

~~~~java
redis:
  host: 121.36.8.180
  port: 6379
  timeout: 3000
  password: tiger
~~~~

通过实体类获取

~~~~java
@Component
@ConfigurationProperties(prefix="redis")
@Data
public class RedisConfig {
    private String host;
    private int port;
    private int timeout;
    private String password;
}
~~~~

### 从配置文件读取

举例：

```Java
# MinIO对象存储相关配置
minio.endpoint=http://121.36.8.180:9000
#存储桶名称
minio.bucketName=bname
#访问的key
minio.accessKey=minioadmin
#访问的秘钥
minio.secretKey=minioadmin
```

通过实体类

```Java
@Data
@Component
@PropertySource("classpath:minio.properties")
@ConfigurationProperties(prefix="minio")
public class MinioConf {

    /**
     * 存储桶名称
     */
    private String endpoint;
    /**
     * 访问的key
     */
    private String bucketName;
    /**
     * 访问的key
     */
    private String accessKey;
    /**
     * 访问的秘钥
     */
    private String secretKey;

}
```



### 读取所有

有时候我们不确定key有多少, 但是会有一定的规律(这个规律是根据业务来定的,如下), 这时候我们就可以考虑将properties中的信息转换为一个map, 然后根据key的规律操作响应的数据

~~~~java
@Data
@Component
// 指定配置文件
@PropertySource("classpath:minio.properties")
@ConfigurationProperties(prefix="minio")
public class WechatPropertiesConfig {
 
    // prefix的值+data变量名为properties key的前一部分, 将key剩余的部分作为map的key, value作为map的value
    public Map<String, String> data = new HashMap();
}

~~~~

