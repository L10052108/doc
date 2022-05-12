资料来源：

[Jedis工具类](https://www.jianshu.com/p/ff7c02cf0f3b)



## springboot 集成jedisPool

[参考代码：](https://gitee.com/L10052108/springboot_project)

Spring Boot 提供了对 Redis 集成的组件包：`spring-boot-starter-data-redis`，`spring-boot-starter-data-redis`依赖于`spring-data-redis` 和 `lettuce` 。Spring Boot 1.0 默认使用的是 Jedis 客户端，2.0 替换成 Lettuce，但如果你从 Spring Boot 1.5.X 切换过来，几乎感受不大差异，这是因为 `spring-boot-starter-data-redis` 为我们隔离了其中的差异性。

### 依赖的jar

Jedis连接池是基于apache-commons pool2实现的。在构建连接池对象的时候，需要提供池对象的配置对象，及JedisPoolConfig(继承自GenericObjectPoolConfig)。我们可以通过这个配置对象对连接池进行相关参数的配置(如最大连接数，最大空数等)。

~~~~Xml
  <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-pool2</artifactId>
        </dependency>
~~~~

### 配置文件

和之前一样，使用`applicaiton.yml` 和`application-redis.yml`

**applicaiton.yml**

~~~~yaml
server:
  port: 8082

spring:
  profiles:
    include: redis

~~~~

**applicaiton-redis.yml**

~~~~yaml
## redis
redis:
  host: 121.36.8.180
  port: 6379
  timeout: 3000
  password: foobared
  poolMaxWait: 3
  maxIdle: 8
  minIdle: 8
  maxWaitMillis: 3000
~~~~

### 配置类

读取redis的配置

~~~~java
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix="redis")
@Data
public class RedisConfig {
    private String host;
    private int port;
    private int timeout;
    private String password;
    private int maxIdle;
    private int minIdle;
    private int maxWaitMillis;
}
~~~~

jedisPool的使用

~~~~java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

@Component
public class PoolFactory {

	@Autowired
	RedisConfig redisConfig;
	
	private static final Logger logger = LoggerFactory.getLogger(PoolFactory.class);
	
	 @Bean
	 public JedisPool jedisPoolFactory(){
		 
		 // 1. 创建 config
		 JedisPoolConfig poolConfig = new JedisPoolConfig();
		 
		 // 2. 设置参数
		poolConfig.setMaxIdle(redisConfig.getMaxIdle());
		poolConfig.setMinIdle(redisConfig.getMinIdle());
		poolConfig.setMaxWaitMillis(redisConfig.getMaxWaitMillis());

		
		// 3. 创建线程链接池
		JedisPool jedisPool = new JedisPool(poolConfig, redisConfig.getHost(), redisConfig.getPort(), 
				redisConfig.getTimeout(), redisConfig.getPassword());
		 
		logger.info("---- 创建jedis 线程池成功！ ----");
		
		return jedisPool;
	 }
}
~~~~

###  测试使用

~~~~java
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import xyz.guqing.redis.utils.RedisUtils;

@SpringBootTest
@RunWith(SpringRunner.class)
public class RedisDemo {

    @Autowired
    private JedisPool jedisPool;

    @Autowired
    private RedisUtils redisUtils;

    @Test
    public void test01(){
        Jedis jedis = jedisPool.getResource();
        String liu = jedis.get("liu");
        System.out.println(liu);
        jedis.close();
    }

    @Test
    public void test0(){
        redisUtils.set("SSS", "EEEE");
    }

    @Test
    public void test04(){
        String sss = redisUtils.get("SSS");
        System.out.println(sss);
    }
}
~~~~











