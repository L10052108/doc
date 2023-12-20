资料来源:<br/>
[Spring Boot结合Redis优雅地实现数据缓存!](https://www.toutiao.com/article/7313083013112431143/?app=news_article&timestamp=1702943228&use_new_style=1&req_id=202312190747074C3EB6F525B8E6499288&group_id=7313083013112431143&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=c154a030-1002-4a48-86ad-7dfa31388f70&source=m_redirect&wid=1703038532839)



## Spring Boot结合Redis优雅地实现数据缓存

缓存是项目运行性能保障的重要一环，Spring Boot为此构建了一套标准的缓存集成体系。

Redis是一个非常高效且流行的内存数据库，很多项目中都会选择Redis做为实际的缓存载体。

# Spring Boot结合Redis优雅地实现数据缓存!

首发2023-12-17 22:48·[SnowTiger](https://www.toutiao.com/c/user/token/MS4wLjABAAAAxZ5K_DJgim-9mqTQHfLFFoZiMGZs30yTlA8FI4f6ZOE/?source=tuwen_detail)

缓存是项目运行性能保障的重要一环，Spring Boot为此构建了一套标准的缓存集成体系。

Redis是一个非常高效且流行的内存数据库，很多项目中都会选择Redis做为实际的缓存载体。

今天这篇文章，就Spring Boot集成Redis实现缓存的优雅管理，通过简单的5小节进行说明。不求精通，但求扫盲。

![img](img/3b6fc6c47d754a42a29e994e1f78fbe0~noop.image)

主要为包含以下依赖:

- **Spring Data Redis**
- **Spring Cache Abstraction**

对应pom.xml中:

```java
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-cache</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-redis</artifactId>
    </dependency>
</dependencies>
```

# 二. 配置Redis缓存支持

- **2.1 首先配置Redis连接**

```yaml
spring:
  redis:
     host: 127.0.0.1
     port: 6379
     database: 5
    # 此处完成是Redis连接的配置
    # 这里以最简单的单例连接示范，同样支持哨兵和集群.
```

- **2.2缓存配置**

```java
spring:
  cache:
    type: redis
    cache-names: c1,c2,c3
    redis:
      key-prefix: 'test-caching:'
      time-to-live: 1m
      use-key-prefix: true
      cache-null-values: true
```

- **spring.cache.type**
  此属性并不是必须项, spring boot 会根据运行环境中cache的提供者情况自行选择，但是如果环境中有多 个可以提供缓存支持的选项，则应自行指定.
- **spring.cache.cache-names**
  此属性为初始化缓存命名空间,非必须项.
  在这里初始化的命名空间会使用这里配置的相关属性进行初始化.
- **spring.cache.redis.key-prefix**
  redis作为缓存时可以定义**redis-key**的前缀，可以是Redis中的**伪命名空间**.
- **spring.cache.redis.time-to-live**
  缓存默认的过期时间，对应Redis中的TTL时间.
  参数类型是Duration, 如: 10s,1d;
- **spring.cache.redis.use-key-prefix*
  此参数作为是否使用前缀的开关，对应上面的**key-prefix**的使用与否.
  默认为: true,即使用前缀.
- **spring.cache.redis.cache-null-values**
  字如其意，就是决定是否缓存**Null**值.
  默认为: true,实际中根据情况可以设置为false.

# 三. 缓存相关注解

- **3.1 @EnableCaching**
  Spring Boot 中缓存自动配置的开关，会自动配置缓存管理器及相关的缓存读写等一系列Bean的初始化操作.

```java
public @interface EnableCaching {
/**
	* 此参数决定是否使用 (CGLIB) 进行代理，默认(false)是使用的 Java 接口代理方式. 
	* 此参数只适用于 {@link #mode()} 值 {@link AdviceMode#PROXY} 时.
	* 注意: 此参数设置为 { true} 会开启所有 
	* Spring 管理的Bean的代理行为转为使用 (CGLIB) 进行代理，而不只是缓存的代理. 
	*/
boolean proxyTargetClass() default false;
/**
	* 决定缓存参与的方式，默认是{@link AdviceMode#PROXY}.
	* 代理模式下缓存只在通过代理类调用时生效.
	* 注意: 这意味着在当前类中直接调用当前类方法不会触发缓存.
	* 如果想让缓存在所有场景生效，那你可以尝试使用 {@link AdviceMode#ASPECTJ} 模式.
	* 一般情况下，建议仅使用{@link AdviceMode#PROXY}.
	*/
AdviceMode mode() default AdviceMode.PROXY;
/**
	* 仅作为在Spring Boot中多个切面进行的时候，缓存切面默认的顺序为Lowest.
	* 一般情况下保留此默认值.
	*/
int order() default Ordered.LOWEST_PRECEDENCE;
}
```

# Spring Boot结合Redis优雅地实现数据缓存!

首发2023-12-17 22:48·[SnowTiger](https://www.toutiao.com/c/user/token/MS4wLjABAAAAxZ5K_DJgim-9mqTQHfLFFoZiMGZs30yTlA8FI4f6ZOE/?source=tuwen_detail)

缓存是项目运行性能保障的重要一环，Spring Boot为此构建了一套标准的缓存集成体系。

Redis是一个非常高效且流行的内存数据库，很多项目中都会选择Redis做为实际的缓存载体。

![img](https://p3-sign.toutiaoimg.com/tos-cn-i-6w9my0ksvp/1e66768128bf4c5ebe3e32e001f9c8cb~noop.image?_iz=58558&from=article.pc_detail&lk3s=953192f4&x-expires=1703643351&x-signature=Z4J1Mp2Id68%2BNxC3XE4Bg%2FNrhAc%3D)



今天这篇文章，就Spring Boot集成Redis实现缓存的优雅管理，通过简单的5小节进行说明。不求精通，但求扫盲。

# 一. Spring Initializr 创建项目

![img](https://p3-sign.toutiaoimg.com/tos-cn-i-6w9my0ksvp/3b6fc6c47d754a42a29e994e1f78fbe0~noop.image?_iz=58558&from=article.pc_detail&lk3s=953192f4&x-expires=1703643351&x-signature=wtuMma6oCODwELkbmGbqfheaF%2BY%3D)

Spring Initializr

主要为包含以下依赖:

- **Spring Data Redis**
- **Spring Cache Abstraction**

对应pom.xml中:

```
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-cache</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-redis</artifactId>
    </dependency>
</dependencies>
```

# 二. 配置Redis缓存支持

- ***2.1\* 首先配置Redis连接**

```
spring:
  redis:
     host: 127.0.0.1
     port: 6379
     database: 5
    # 此处完成是Redis连接的配置
    # 这里以最简单的单例连接示范，同样支持哨兵和集群.
```

- ***2.2\* 缓存配置**

```
spring:
  cache:
    type: redis
    cache-names: c1,c2,c3
    redis:
      key-prefix: 'test-caching:'
      time-to-live: 1m
      use-key-prefix: true
      cache-null-values: true
```

- ***spring.cache.type\***
  此属性并不是必须项, spring boot 会根据运行环境中cache的提供者情况自行选择，但是如果环境中有多 个可以提供缓存支持的选项，则应自行指定.
- ***spring.cache.cache-names\***
  此属性为初始化缓存命名空间,非必须项.
  在这里初始化的命名空间会使用这里配置的相关属性进行初始化.
- ***spring.cache.redis.key-prefix\***
  redis作为缓存时可以定义**redis-key**的前缀，可以是Redis中的**伪命名空间**.
- ***spring.cache.redis.time-to-live\***
  缓存默认的过期时间，对应Redis中的TTL时间.
  参数类型是Duration, 如: 10s,1d;
- ***spring.cache.redis.use-key-prefix\***
  此参数作为是否使用前缀的开关，对应上面的**key-prefix**的使用与否.
  默认为: true,即使用前缀.
- ***spring.cache.redis.cache-null-values\***
  字如其意，就是决定是否缓存**Null**值.
  默认为: true,实际中根据情况可以设置为false.

# 三. 缓存相关注解

- ***3.1\* @EnableCaching**
  Spring Boot 中缓存自动配置的开关，会自动配置缓存管理器及相关的缓存读写等一系列Bean的初始化操作.

```java
public @interface EnableCaching {
/**
	* 此参数决定是否使用 (CGLIB) 进行代理，默认(false)是使用的 Java 接口代理方式. 
	* 此参数只适用于 {@link #mode()} 值 {@link AdviceMode#PROXY} 时.
	* 注意: 此参数设置为 { true} 会开启所有 
	* Spring 管理的Bean的代理行为转为使用 (CGLIB) 进行代理，而不只是缓存的代理. 
	*/
boolean proxyTargetClass() default false;
/**
	* 决定缓存参与的方式，默认是{@link AdviceMode#PROXY}.
	* 代理模式下缓存只在通过代理类调用时生效.
	* 注意: 这意味着在当前类中直接调用当前类方法不会触发缓存.
	* 如果想让缓存在所有场景生效，那你可以尝试使用 {@link AdviceMode#ASPECTJ} 模式.
	* 一般情况下，建议仅使用{@link AdviceMode#PROXY}.
	*/
AdviceMode mode() default AdviceMode.PROXY;
/**
	* 仅作为在Spring Boot中多个切面进行的时候，缓存切面默认的顺序为Lowest.
	* 一般情况下保留此默认值.
	*/
int order() default Ordered.LOWEST_PRECEDENCE;
}
```

开关注解一般都是用在启动类或其它配置类中即可.

- **3.2 @Cacheable**
  使用在类或方法上标记其对缓存的支持，使用此注解后，如果调用的时候未找到缓存，则会进入方法执行，将结果缓存.

如果找到缓存，则直接返回缓存，不会实际执行方法内容.

```java
public @interface Cacheable {
	/**
	 * 别名: {@link #cacheNames}.
	 */
	@AliasFor("cacheNames")
	String[] value() default {};
	/**
	 * 对应缓存的命名空间，声明此缓存存储的位置.
	 * 注意: 如果有单独定义{Cache的实例Bean}也可以配成Bean名称，
	 * 此缓存将直接交由对应Bean处理.
	 * 这种情况一般不建议也不常见,这里不再展开.
	 */
	@AliasFor("value")
	String[] cacheNames() default {};
	/**
	 * (SpEL) 表达式来动态计算key.
	 * 默认是{ ""},意味着所有方法参数都参与key的计算，
	 * 具体计算逻辑由对应的缓存管理器提供.
	 * 也可以使用下面的参数{@link #keyGenerator},自定义逻辑.
	 * 表达式支持如下参数:
	 * { #root.method}, { #root.target}, 
	 * { #root.caches},{ #root.methodName},{ #root.targetClass}
	 * 还可以通过这些方式获取参数: { #root.args[1]}, { #p1}, { #a1}
	 */
	String key() default "";
	/**
	 * 可以自定义一个Bean实现 
	 * {@link org.springframework.cache.interceptor.KeyGenerator}接口
	 */
	String keyGenerator() default "";
	/**
	 * 略过此参数，一般不建议一个应用中用多种缓存管理器.
	 */
	String cacheManager() default "";
	/** 同上.*/
	String cacheResolver() default "";
	/**
	 * (SpEL) 表达式来声明一个条件语句
	 * 此条件语句返回{true}时才执行缓存.
	 * 默认是"",即：总会执行缓存.
	 * 表达式支持如下参数:
	 * { #root.method}, { #root.target}, { #root.caches}
	 * { #root.methodName}),{ #root.targetClass}
	 * { #root.args[1]}, { #p1} or { #a1}.
	 */
	String condition() default "";

	/**
	 * 和 {@link #condition} 表达式相反, 
	 * 这个表达式是在方法内容执行之后，执行判断是否例外的不缓存.
	 * 除了{@link #condition} 表达式支持的那些参数之外，
	 * 还支持： { #result}
	 */
	String unless() default "";
	/**
	 * 这个属性是指：在有另外的线程正在更新缓存的时候，当前线程的缓存获取是否同步等待.
	 * 默认是{false}，就是不等待。
	 */
	boolean sync() default false;
}
```

- ***3.3\* @CachePut**
  这个注解呢，和上面的 **@Cacheable** 非常相像，不再展开细说。
  **唯一需要注意的一点就是：@CachePut** 是不管缓存是否有效的，只会依赖于 **condition() 和 unless()** 来决定缓存是否执行更新.
- ***3.4\* @CacheEvict**
  和上面的 **@CachePut** 对应，这个注解是用来标记缓存清除的.

```java
public @interface CacheEvict {
	@AliasFor("cacheNames")
	String[] value() default {};
	@AliasFor("value")
	String[] cacheNames() default {};
	String key() default "";
	String keyGenerator() default "";
	String cacheManager() default "";
	String cacheResolver() default "";
	/**
	 * 表达式定义和{@Cacheable}中的参数定义一致.
	 * 目的不同： 这里的condition满足条件则会执行缓存清除.
	 */
	String condition() default "";
	/**
	 * allEntries就是指所有条目,
	 * 在这里的含义就是指是否清除指定命名空间的所有key的缓存.
	 * 这里为{true}时,{@link #key}无效.
	 */
	boolean allEntries() default false;
	/**
	 * 标记缓存清除发生的时机，默认为{false}.
	 * 即: 在方法内容执行成功无异常再清除缓存.
	 * 设置为{true}则反之.
	 */
	boolean beforeInvocation() default false;
}
```

- **3.5 @Caching**
  直接看定义:

```java
public @interface Caching {
Cacheable[] cacheable() default {};
CachePut[] put() default {};
CacheEvict[] evict() default {};
}
```

很简单明了，就是上面3个注解的合并支持.
**建议大家酌情使用.**

# 四. 实操验证

- **4.1 启动类**

```java
@SpringBootApplication
@EnableCaching
public class MvcTestApplication {
	public static void main(String[] args) {
		SpringApplication.run(MvcTestApplication.class, args);
	}
}
```

- ***4.2\* CachingAdapter 缓存适配类**

```java
@Component
public class CachingAdapter {
	static String timing() {
		return LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
	}
	/**
	 * 根据key清理对应缓存值.
	 * @param key 要清理缓存的key
	 */
	@CacheEvict(cacheNames = { "c1", "c2", "c3" })
	public boolean clearCache(String key) {
		return true;
	}
	/**
	 * 根据用户名缓存信息。
	 * @param userName 名称
	 * @param age      年龄
	 * @return 返回值
	 */
	@Cacheable(cacheNames = "c3", key = "#userName")
	public String nameUser(String userName, int age) {
		return String.format("%s:%s >> %s", userName, age, timing());
	}
	/**
	 * 根据用户名缓存信息。
	 * @param userName 名称
	 * @param age      年龄
	 * @return 返回值
	 */
	@Cacheable(cacheNames = "c4", key = "#userName", condition = "#age>20")
	public String otherUser(String userName, int age) {
		return String.format("Other: %s:%s >> %s", userName, age, timing());
	}
	/**
	 * 根据name缓存随机伪密码值.
	 * @param name 缓存key
	 * @return 返回值
	 */
	@Caching(
		cacheable = @Cacheable(cacheNames = { "c1", "c2" }),
		put = @CachePut(cacheNames = "c5"))
	public String pwd(String name) {
		return new Random().nextInt(1000) + "#" + name + "#" + timing();
	}
}
```

- **4.3 定义请求接口**

```java
@RestController
public class CachingTestController {
	private final CachingAdapter cachingAdapter;
	public CachingTestController(CachingAdapter cachingAdapter) {
		this.cachingAdapter = cachingAdapter;
	}
	@GetMapping("/clearCache")
	public ResponseEntity<String> clearCache(@RequestParam String key) {
		cachingAdapter.clearCache(key);
		return ResponseEntity.ok("Did");
	}
	@GetMapping("/nameUser")
	public ResponseEntity<String> nameUser(@RequestParam String userName, @RequestParam int age) {
		return ResponseEntity.ok(cachingAdapter.nameUser(userName, age));
	}
	@GetMapping("/otherNameUser")
	public ResponseEntity<String> otherNameUser(@RequestParam String userName, @RequestParam int age) {
		return ResponseEntity.ok(cachingAdapter.otherUser(userName, age));
	}
	@GetMapping("/apiPwd")
	public ResponseEntity<String> apiPwd(@RequestParam String name) {
		return ResponseEntity.ok(cachingAdapter.pwd(name));
	}
}
```

- ***4.4\* 请求验证**

**⛄请求接口，验证缓存生效.**

```shell
###
GET http://localhost:8080/nameUser?userName=老六&age=23

HTTP/1.1 200 
Content-Type: text/plain;charset=UTF-8
Content-Length: 40
Date: Sat, 16 Dec 2023 06:07:10 GMT

老六:23 >> 2023-12-16T14:07:10.4196887
### 
HTTP/1.1 200 
Content-Type: text/plain;charset=UTF-8
Content-Length: 40
Date: Sat, 16 Dec 2023 06:07:35 GMT
Keep-Alive: timeout=60
Connection: keep-alive

老六:23 >> 2023-12-16T14:07:10.4196887

### 一分钟内使用缓存,直接返回结果.
```

**⛄Redis中缓存存储.**

![img](img/8bba0b92e2b84a0ba59668c25bca73b0~noop.image)



```shell
> keys *
test-caching:c3::老六
> ttl test-caching:c3::老六
58
> get test-caching:c3::老六
��t(老六:23 >> 2023-12-16T14:07:10.4196887
```

**⛄其它接口大家可以自行验证，是很奇妙的体验.**

# 五. 自定义Redis缓存行为

大家有没有注意到，上面的Redis里面看到的缓存值:

```shell
> get test-caching:c3::老六
��t(老六:23 >> 2023-12-16T14:07:10.4196887
```

这里**看起像乱码**一样, 其实只是因为在缓存写入Redis时使用的**序列化方式**的缘故.
Redis在缓存写入时默认使用的序列化方式:

```java
static RedisSerializer<Object> java(@Nullable ClassLoader classLoader) {
    return new JdkSerializationRedisSerializer(classLoader);
}
```

所以这里我们看到的其实是值的Java序列化结果，并不是直接以Redis中的String类型存入Redis中的.

**Spring Boot Data Redis** 模块默认提供了如下序列化方式可选:

```java
public interface RedisSerializer<T> {
static RedisSerializer<Object> java() {
    return java((ClassLoader)null);
}
static RedisSerializer<Object> java(@Nullable ClassLoader classLoader) {
    return new JdkSerializationRedisSerializer(classLoader);
}
static RedisSerializer<Object> json() {
    return new GenericJackson2JsonRedisSerializer();
}
static RedisSerializer<String> string() {
    return StringRedisSerializer.UTF_8;
}
static RedisSerializer<byte[]> byteArray() {
    return ByteArrayRedisSerializer.INSTANCE;
}
}
```

所以如果我们想让Redis直接以其对应的String类型来存储这里的缓存值，让查看的时候更直观，那么我们是可以选择:
**StringRedisSerializer** 来达到效果的.

- **✨\*RedisCacheManagerBuilderCustomizer\* 实现 Redis Cache 行为自定义.**

```java
@Bean
public RedisCacheManagerBuilderCustomizer customRedis(CacheProperties cacheProperties) {
return new RedisCacheManagerBuilderCustomizer() {
	@Override
	public void customize(RedisCacheManager.RedisCacheManagerBuilder builder) {
		builder.withCacheConfiguration("c3", RedisCacheConfiguration.defaultCacheConfig()	.serializeValuesWith(RedisSerializationContext.SerializationPair
.fromSerializer(RedisSerializer.string()))
.prefixCacheNameWith(cacheProperties.getRedis().getKeyPrefix()
.entryTtl(Duration.ofMinutes(2)));
	}
};
}
```

这里我们自定义，以实现在使用**c3**缓存空间时，所有的值使用**StringRedisSerializer**来向Redis写入,同时修改其TTL值为**2分钟**

- **验证自定义效果**

```
###
GET http://localhost:8080/nameUser?userName=张老头&age=90
HTTP/1.1 200 
Content-Type: text/plain;charset=UTF-8
Content-Length: 43
Date: Sat, 16 Dec 2023 06:46:17 GMT

张老头:90 >> 2023-12-16T14:46:17.2907173
###

> keys *
test-caching:c3::张老头
> ttl test-caching:c3::张老头
109
> get test-caching:c3::张老头
张老头:90 >> 2023-12-16T14:46:17.2907173
```

完美，就是我们想要的效果.

- **更丰富的自定义行为**
  其实，看到这里，应该有很多小伙伴就会有很多想法了，这里明显可以实现更复杂更有扩展性的自定义.
  比如: 自己根据配置文件对每个缓存都定义不同的缓存行为，不同的过期时间等等.
  记住这个接口即可: **RedisCacheManagerBuilderCustomizer**

# 结语

虽然Spring Boot的缓存知识牵扯很多，但是今天这些内容基本也扫盲了主要的使用流程和一些注意事项.

> 更多Java知识，Spring Boot知识，实用干货，点击关注，持续更新!