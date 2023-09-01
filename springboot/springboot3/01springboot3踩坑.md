资料来源：

[Spring Boot3.0升级，踩坑之旅，附解决方案](https://blog.51cto.com/u_13971202/5910023?articleABtest=0)<br/>
[JDK8升级JDK17过程中遇到的那些坑](http://michael007js.cn/news/shownews.php?id=319)

## Spring Boot3.0升级，踩坑之旅，附解决方案

这个报错主要是`Spring Boot3.0`已经为所有依赖项从 `Java EE `迁移到` Jakarta EE API`，导致 `servlet `包名的修改，`Spring`团队这样做的原因，主要是避免 `Oracle` 的版权问题，解决办法很简单，两步走：

1 添加 `jakarta.servlet` 依赖

```xml
<dependency>
    <groupId>jakarta.servlet</groupId>
    <artifactId>jakarta.servlet-api</artifactId>
</dependency>
```

修改项目内所有代码的导入依赖

```java
修改前：
import javax.servlet.*
修改后：
import jakarta.servlet.*
```



下载JDK17的最新版本`jdk-17_linux-x64_bin.tar.gz`，解压缩后移动到`/usr/lib/jvm/`目录下

```
$ sudo su -
# tar -xzf jdk-17_linux-x64_bin.tar.gz
# mv jdk-17.0.2 /usr/lib/jvm/java-17
```

修改`~/.bashrc`，设置java相关环境变量为JDK17

```
# vim ~/.bashrc

export JAVA_HOME=/usr/lib/jvm/java-17
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
```

环境变量生效后，检查当前的jdk版本为JDK17

```
# source ~/.bashrc

# java -version
openjdk version "17.0.2" 2022-01-18
OpenJDK Runtime Environment (build 17.0.2+8-86)
OpenJDK 64-Bit Server VM (build 17.0.2+8-86, mixed mode, sharing)
```

## 2.2 升级spring版本到最新版本，编译

修改项目的`pom.xml`文件，将spring boot和spring cloud版本由

```
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.12.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    
    <properties>
        <spring-cloud.version>Greenwich.SR3</spring-cloud.version>
    </properties>
    
```

修改为最新正式发布版本：

```
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.0.6</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    
    <properties>
        <spring-cloud.version>2022.0.2</spring-cloud.version>
    </properties>
```

编译项目，报以下错误：

```
程序包javax.servlet.http不存在
程序包javax.validation不存在
```

原因是原先`javax`包的名字改为`jakarta`了，将项目中所有依赖`javax`包的地方替换为`jakarta`

继续编译，报以下错误：

```
[ERROR] 找不到符号
[ERROR]   符号:   类 EnableEurekaClient
[ERROR]   位置: 程序包 org.springframework.cloud.netflix.eureka
```

原因是新版本没有`@EnableEurekaClient`注解了，替换为`@EnableDiscoveryClient`

继续编译，报以下错误：

```
[ERROR]找不到符号
[ERROR]   符号:   方法 apply()
[ERROR]   位置: 接口 io.github.resilience4j.core.functions.CheckedSupplier<java.lang.Object>
```

原因是`resilience4j`的`CheckedSupplier`接口新版本没有`apply()`方法了，改为`get()`方法

继续编译，报以下错误：

```
[ERROR]对于RetryableException(int,java.lang.String,feign.Request.HttpMethod,java.util.Date), 找不到合适的构造器
[ERROR]     构造器 feign.RetryableException.RetryableException(int,java.lang.String,feign.Request.HttpMethod,java.lang.Throwable,java.util.Date,feign.Request)不适用
[ERROR]       (实际参数列表和形式参数列表长度不同)
[ERROR]     构造器 feign.RetryableException.RetryableException(int,java.lang.String,feign.Request.HttpMethod,java.util.Date,feign.Request)不适用
[ERROR]       (实际参数列表和形式参数列表长度不同)
```

原因是`openfeign`新版本的`RetryableException`异常类的构造函数发生了变化，根据需要将旧代码：

```
    @Bean
    public ErrorDecoder feignError() {
        return (key, response) -> {
            if (response.status() >= 500) {
                FeignException exception = FeignException.errorStatus(key, response);
                return new RetryableException(
                        response.status(),
                        exception.getMessage(),
                        response.request().httpMethod(),
                        new Date());
          }

            // 其他异常交给Default去解码处理
            return defaultErrorDecoder.decode(key, response);
      };
  }
```

改为以下代码

```
    @Bean
    public ErrorDecoder feignError() {
        return (key, response) -> {
            if (response.status() >= 500) {
                FeignException exception = FeignException.errorStatus(key, response);
                return new RetryableException(
                        response.status(),
                        exception.getMessage(),
                        response.request().httpMethod(),
                        new Date(),
                        response.request());
          }

            // 其他异常交给Default去解码处理
            return defaultErrorDecoder.decode(key, response);
      };
  }
```

改为后继续编译，报以下错误：

```
程序包org.junit不存在
程序包org.junit.runner不存在
程序包junit.framework不存在
```

这是因为旧版本使用的是`junit4`，改为`junit5`相应的注解。即将：

```
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;

@Ignore
@RunWith(MockitoJUnitRunner.class)
public class FileSyncerTest {
    
    @Before
    public void setUp() {

  }
    
    @Test
    public void testCase1() throws Exception {
    
  }

}
```

改为

```
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;


@Disabled
@ExtendWith(MockitoExtension.class)
public class FileSyncerTest {
    
    @BeforeEach
    public void setUp() {

  }
    
    @Test
    public void testCase1() throws Exception {
    
  }

}
```

改为后继续编译，编译通过。

```
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 8.582 s (Wall Clock)
[INFO] Finished at: 2023-05-04T16:39:42+08:00
[INFO] Final Memory: 59M/214M
[INFO] ------------------------------------------------------------------------
```

## 2.3 启动项目

编译通过后启动项目，启动失败，报以下错误：

```
Caused by: java.lang.reflect.InaccessibleObjectException: Unable to make protected final java.lang.Class java.lang.ClassLoader.defineClass(java.lang.String,byte[],int,int,java.security.ProtectionDomain) throws java.lang.ClassFormatError accessible: module java.base does not "opens java.lang" to unnamed module @7634b327
 at java.base/java.lang.reflect.AccessibleObject.checkCanSetAccessible(AccessibleObject.java:354)
 at java.base/java.lang.reflect.AccessibleObject.checkCanSetAccessible(AccessibleObject.java:297)
 at java.base/java.lang.reflect.Method.checkCanSetAccessible(Method.java:199)
 at java.base/java.lang.reflect.Method.setAccessible(Method.java:193)
 at net.sf.cglib.core.ReflectUtils$2.run(ReflectUtils.java:56)
 at java.base/java.security.AccessController.doPrivileged(AccessController.java:318)
 at net.sf.cglib.core.ReflectUtils.<clinit>(ReflectUtils.java:46)
```

这是因为从JDK9开始支持模块化了，项目中使用的部分组件可能还没有支持模块化，所以需要在jar包启动时添加`add-opens` jvm启动参数参数，我是通过在pom文件中添加build参数实现的：

```
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <!-- 添加 add-opens jvm参数 -->
                    <jvmArguments>
                      --add-opens=java.base/java.lang=ALL-UNNAMED
                      --add-opens=java.base/java.util=ALL-UNNAMED
                      --add-exports=java.base/sun.security.ssl=ALL-UNNAMED
                      --add-opens=java.base/sun.security.ssl.internal.ssl=ALL-UNNAMED
                    </jvmArguments>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
```

修改完后重新编译启动，启动仍然失败，报一下错误：

```
Caused by: java.lang.IllegalArgumentException: @RequestMapping annotation not allowed on @FeignClient interfaces
```

根据错误提示，@RequestMapping注解不能添加在@FeignClient接口上了，改为通过在@FeignClient注解的path属性携带，即由：

```
@FeignClient(url = "127.0.0.1:8080", name = "service-feign")
@RequestMapping("/service")
public interface ServiceFeign {

}
```

改为：

```
@FeignClient(url = "127.0.0.1:8080", name = "service-feign", path = "/service")
public interface ServiceFeign {

}
```

修改完后重新编译启动，启动仍然失败，报以下错误：

```
org.springframework.context.ApplicationContextException: Failed to start bean 'documentationPluginsBootstrapper'; nested exception is java.lang.NullPointerException
Caused by: java.lang.NullPointerException: null
```

这是因为项目中使用了knife4j，由于版本比较低，底层依赖的是spring-fox，支持的是openapi 2.x版本，而spring boot 3.0只支持openapi 3.x版本，所以knife4j版本依赖由：

```
    <dependency>
        <groupId>com.github.xiaoymin</groupId>
        <artifactId>knife4j-spring-boot-starter</artifactId>
        <version>2.0.5</version>
    </dependency>
```

改为：

```
    <dependency>
        <groupId>com.github.xiaoymin</groupId>
        <artifactId>knife4j-openapi3-jakarta-spring-boot-starter</artifactId>
        <version>4.1.0</version>
    </dependency>
```

同时将swagger的相关注解`@Api`、`@ApiOperation`、`@ApiParam`、`@ApiModel` 、`@ApiModelProperty`替换为`openapi3`对应的注解：`@Tag`、`@Operation`、 `@Parameter`、 `@Schema`、 `@SchemaProperty`

最后将swagger的配置类内容由

```
    @Bean(value = "oasConfig")
    public Docket oasConfig() {
        Docket docket=new Docket(DocumentationType.SWAGGER_2)
              .apiInfo(new ApiInfoBuilder()
                      .title("spring-project-framework")
                      .description("spring项目骨架")
                      .version("v1")
                      .build())
              .groupName("backup-v1")
              .select()
              .apis(RequestHandlerSelectors.basePackage("movee.api.v1"))
              .paths(PathSelectors.any())
              .build();
        return docket;
  }
```

改为：

```
    @Bean(value = "oasConfig")
    public GroupedOpenApi oasConfig(){
        return GroupedOpenApi.builder()
                .group("spring-project-framework-v1")
                .addOpenApiCustomizer(api -> api.info(new Info()
                        .title("spring-project-framework")
                        .description("spring项目骨架")
                        .version("v1")))
                .packagesToScan("movee.api.v1")
                .build();
  }
```

修改完后，重新编译启动，这次能正常启动了

但是web访问项目接口时报以下错误：

```
Caused by: java.lang.IllegalArgumentException: When allowCredentials is true, allowedOrigins cannot contain the special value "*" since that cannot be set on the "Access-Control-Allow-Origin" response header. To allow credentials to a set of origins, list them explicitly or consider using "allowedOriginPatterns" instead.
 at org.springframework.web.cors.CorsConfiguration.validateAllowCredentials(CorsConfiguration.java:516)
 at org.springframework.web.servlet.handler.AbstractHandlerMapping.getHandler(AbstractHandlerMapping.java:538)
 at org.springframework.web.servlet.DispatcherServlet.getHandler(DispatcherServlet.java:1275)
 at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:1057)
 at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:974)
 at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:1011)
 ... 36 common frames omitted
```

这个是跨域的问题，新版本spring MVC的`CorsRegistry`已经没有`allowedOrigin()` 方法了，替换为新接口`allowedOriginPatterns()`即可，代码示例如下：

```
@Configuration
public class WebCorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
              .allowedOriginPatterns("*")
              .allowedMethods("GET", "HEAD", "POST", "PUT", "DELETE", "OPTIONS")
              .allowCredentials(true)
              .maxAge(3600)
              .allowedHeaders("*");
  }
}
```

这时因为之前项目的`spring cloud`、`actuator`的相关配置写在`bootstrap.yml`文件中，升级到`spring boot 3`之后actuator的端点(如`/actuator/info`等)无法访问，要想启动时系统读取bootstrap.yml中的配置，使bootstrap.yml文件中的配置生效，需要在项目的pom.xml文件中添加下面的依赖：

```
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bootstrap</artifactId>
        </dependency>
    </dependencies>
```

到此升级完成！

## 更进一步

之前项目中使用的GC收集器是CMS收集器，CMS收集器的调参非常繁琐，非常考验工程师的功底。`ZGC`声称能保证8MB~16TB的堆内存范围内都能保证GC的停顿时间在毫秒（官方声称小于10ms，也有些文章表示实际只有1、2ms）级别，尤其是一般情况下只要设置几个基本的GC参数就能让GC收集器很好的工作了，简直是工程师的福音。随着ZGC在JDK 15中正式GA，趁着升级JDK 17的机会立即把ZGC用起来。 设置几个基本的ZGC参数：

```
# log
JVM_OPTS="$JVM_OPTS -XX:+PrintCommandLineFlags"
JVM_OPTS="$JVM_OPTS -Xlog:gc*:file=${LOG_DIR}/${PROJ_NAME}-gc-%p.log:time,uptime:filecount=10,filesize=50M"
JVM_OPTS="$JVM_OPTS -XX:+HeapDumpOnOutOfMemoryError"
JVM_OPTS="$JVM_OPTS -XX:HeapDumpPath=${LOG_DIR}/${PROJ_NAME}-`date +%s`-pid$$.hprof"
JVM_OPTS="$JVM_OPTS -XX:ErrorFile=${LOG_DIR}/${PROJ_NAME}-`date +%s`-pid%p.log"
# memory
JVM_OPTS="$JVM_OPTS -Xms4g"
JVM_OPTS="$JVM_OPTS -Xmx4g"
JVM_OPTS="$JVM_OPTS --add-opens=java.base/java.lang=ALL-UNNAMED"
JVM_OPTS="$JVM_OPTS --add-opens=java.base/java.util=ALL-UNNAMED"
JVM_OPTS="$JVM_OPTS --add-exports=java.base/sun.security.ssl=ALL-UNNAMED"
JVM_OPTS="$JVM_OPTS --add-opens=java.base/sun.security.ssl.internal.ssl=ALL-UNNAMED"
# gc collector
JVM_OPTS="$JVM_OPTS -XX:+UseZGC"
# JVM_OPTS="$JVM_OPTS -XX:ConcGCThreads=4"
JVM_OPTS="$JVM_OPTS -XX:+UnlockDiagnosticVMOptions"
JVM_OPTS="$JVM_OPTS -XX:ZStatisticsInterval=10"
```