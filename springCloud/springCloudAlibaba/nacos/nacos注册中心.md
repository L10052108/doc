

[项目代码](https://gitee.com/L10052108/springboot_project/tree/modus-nacos/)

资料来源：https://www.cnblogs.com/mrhelloworld/p/nacos1.html

## 创建项目

我们创建聚合项目来讲解 Nacos，首先创建一个 pom 父工程。

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0jk223ifhj20oc0ei750.jpg 'size=60%')创建过程省略

>  service作为服务端<br/>
>
>  client作为客户端<br/>
>
>  common公共的类<br/>



## 父模块的pom

父模块做统一jar管理

pom.xml

~~~~java
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-parent</artifactId>
		<version>2.1.10.RELEASE</version>
		<!-- <version>2.2.6.RELEASE</version> -->
		<relativePath /> <!-- lookup parent from repository -->
	</parent>

	<groupId>xyz.guqing</groupId>
	<artifactId>project</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<name>project</name>
	<packaging>pom</packaging>
	<description>Demo project for Spring Boot</description>

	<modules>
		<module>nacos-service</module>
		<module>nacos-client</module>
		<module>nacos-common</module>
	</modules>


	<!-- 统计版本管理 -->
	<properties>
		<java.version>8</java.version>
		<!-- Spring Cloud Hoxton.SR4 依赖 -->
		<spring-cloud.version>Hoxton.SR4</spring-cloud.version>
		<!-- spring cloud alibaba 依赖 -->
		<spring-cloud-alibaba.version>2.1.0.RELEASE</spring-cloud-alibaba.version>
	</properties>


	<!-- 版本管理 -->
	<dependencyManagement>
		<dependencies>
			<!-- 工具类 -->
			<dependency>
				<groupId>cn.hutool</groupId>
				<artifactId>hutool-all</artifactId>
				<version>5.0.5</version>
			</dependency>

			<!--fastjson -->
			<dependency>
				<groupId>com.alibaba</groupId>
				<artifactId>fastjson</artifactId>
				<version>1.1.41</version>
			</dependency>

			<!-- spring cloud alibaba nacos discovery 依赖 -->
			<dependency>
				<groupId>com.alibaba.cloud</groupId>
				<artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
				<version>${spring-cloud-alibaba.version}</version>
			</dependency>

		</dependencies>
	</dependencyManagement>
	
		<!--公共依赖的框架 -->
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter</artifactId>
		</dependency>

		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-tomcat</artifactId>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>

		<!-- 添加支持web的模块 -->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>

		<dependency>
			<groupId>javax.servlet</groupId>
			<artifactId>javax.servlet-api</artifactId>
			<scope>provided</scope>
		</dependency>

		<!-- 开发环境的调试 -->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-devtools</artifactId>
			<optional>true</optional>
		</dependency>

		<!-- 日志 -->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-thymeleaf</artifactId>
		</dependency>

		<!--lombok -->
		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<scope>provided</scope>
		</dependency>

		<dependency>
			<groupId>ch.qos.logback</groupId>
			<artifactId>logback-classic</artifactId>
		</dependency>

		<!--fastjson -->
		<dependency>
			<groupId>com.alibaba</groupId>
			<artifactId>fastjson</artifactId>
		</dependency>

		<!--工具类文档地址： https://hutool.cn/docs/#/ -->
		<dependency>
			<groupId>cn.hutool</groupId>
			<artifactId>hutool-all</artifactId>
		</dependency>

			<!--常用工具类 -->
		<dependency>
			<groupId>org.apache.commons</groupId>
			<artifactId>commons-lang3</artifactId>
		</dependency>
	</dependencies>


</project>
~~~~





## 公共模块

product公共类，放在公共依赖模块中

```java
package com.example.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product implements Serializable {

    private Integer id;
    private String productName;
    private Integer productNum;
    private Double productPrice;

}
```

## 服务端

### 主要依赖

~~~~java
<!-- spring cloud alibaba nacos discovery 依赖 -->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>

~~~~

### 完整的依赖

```
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>xyz.guqing</groupId>
        <artifactId>project</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </parent>
    <artifactId>nacos-service</artifactId>


    <!-- 项目依赖 -->
    <dependencies>
        <!-- spring cloud alibaba nacos discovery 依赖 -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
        </dependency>

        <dependency>
            <groupId>xyz.guqing</groupId>
            <artifactId>nacos-common</artifactId>
            <version>0.0.1-SNAPSHOT</version>
        </dependency>
    </dependencies>


    <!-- 打包配置 -->
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>
```

配置文件

~~~~java
server:
  port: 8003
  servlet:
    # 项目contextPath
    context-path: /
  tomcat:
    # tomcat的URI编码
    uri-encoding: UTF-8
    threads:
      # Tomcat启动初始化的线程数，默认值25
      min-spare: 30
      # tomcat最大线程数，默认为200
      max: 200


# 配置nacos
spring:
  application:
    name: product-service # 应用名称
  # 配置 Nacos 注册中心
  cloud:
    nacos:
      discovery:
        enabled: true # 如果不想使用 Nacos 进行服务注册和发现，设置为 false 即可
        server-addr: 124.221.127.60:8848 # Nacos 服务器地址
~~~~

- 下面需要创建一个http服务

### control

~~~~Java
@RestController
@RequestMapping("/product")
public class ProductController {

    @Autowired
    private ProductService productService;

    /**
     * 查询商品列表
     *
     * @return
     */
    @GetMapping("/list")
    public List<Product> selectProductList() {
        return productService.selectProductList();
    }
}
~~~~

### service

接口

~~~~java 
public interface ProductService {

    /**
     * 查询商品列表
     *
     * @return
     */
    List<Product> selectProductList();

}
~~~~

实现类

```Java
@Slf4j
@Service
public class ProductServiceImpl implements ProductService {

    /**
     * 查询商品列表
     *
     * @return
     */
    @Override
    public List<Product> selectProductList() {
        log.info("商品服务查询商品信息...");
        return Arrays.asList(
                new Product(1, "华为手机", 1, 5800D),
                new Product(2, "联想笔记本", 1, 6888D),
                new Product(3, "小米平板", 5, 2020D)
        );
    }

}
```

### 启动类

```Java
// 开启 @EnableDiscoveryClient 注解，当前版本默认会开启该注解
@EnableDiscoveryClient
@SpringBootApplication
public class NacosServiceApplication {

   public static void main(String[] args) {
      SpringApplication.run(NacosServiceApplication.class, args);
   }

}
```

　通过 Spring Cloud 原生注解 `@EnableDiscoveryClient` 开启服务注册发现功能。

### 注册中心

　　刷新 Nacos 服务器，可以看到服务已注册至 Nacos。

![nacos注册中心](https://tva1.sinaimg.cn/large/e6c9d24ely1h0jkd8kajkj21ko0ksabr.jpg ':size=60%')


## 客户端

### 依赖jar包

pom.xml文件

```Java
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>xyz.guqing</groupId>
        <artifactId>project</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </parent>
    <artifactId>nacos-client</artifactId>


    <!-- 项目依赖 -->
    <dependencies>
        <!-- spring cloud alibaba nacos discovery 依赖 -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
        </dependency>

        <dependency>
            <groupId>xyz.guqing</groupId>
            <artifactId>nacos-common</artifactId>
            <version>0.0.1-SNAPSHOT</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-commons</artifactId>
            <version>2.1.2.RELEASE</version>
            <scope>compile</scope>
        </dependency>
    </dependencies>


    <!-- 打包配置 -->
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>
```

### 配置文件

application.yml

```Java
// 开启 @EnableDiscoveryClient 注解，当前版本默认会开启该注解
@EnableDiscoveryClient
@SpringBootApplication
public class NacosClientApplication {

   public static void main(String[] args) {
      SpringApplication.run(NacosClientApplication.class, args);
   }

}
```

### 接口

```
public interface ProductListService {

    /**
     * 通过远程调用获取商品的信息
     * @return
     */
    List<Product> selectProductListByDiscoveryClient();
}
```

对于服务的消费我们这里讲三种实现方式：

- DiscoveryClient：通过元数据获取服务信息
- LoadBalancerClient：Ribbon 的负载均衡器
- @LoadBalanced：通过注解开启 Ribbon 的负载均衡器

### DiscoveryClient

配置文件

```Java
@Configuration
public class RestTemplateConf {


    @Bean
//    @LoadBalanced // 负载均衡注解
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

- 实现类

```java
@Slf4j
@Service("discoveryClientProductLIstService")
public class DiscoveryClientProductLIstService implements ProductListService {

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private DiscoveryClient discoveryClient;


    /**
     * 查询所有的商品信息
     *
     * @return
     */
    @Override
    public List<Product> selectProductListByDiscoveryClient() {
        StringBuffer sb = null;

        // 获取服务列表
        List<String> serviceIds = discoveryClient.getServices();
        if (CollectionUtils.isEmpty(serviceIds))
            return null;

        // 根据服务名称获取服务
        List<ServiceInstance> serviceInstances = discoveryClient.getInstances("product-service");
        if (CollectionUtils.isEmpty(serviceInstances))
            return null;

        // 构建远程服务调用地址
        ServiceInstance si = serviceInstances.get(0);
        sb = new StringBuffer();
        sb.append("http://" + si.getHost() + ":" + si.getPort() + "/product/list");
        log.info("订单服务调用商品服务...");
        log.info("从注册中心获取到的商品服务地址为：{}", sb.toString());

        // 远程调用服务
        // ResponseEntity: 封装了返回数据
        ResponseEntity<List<Product>> response = restTemplate.exchange(
                sb.toString(),
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<List<Product>>() {});
        log.info("商品信息查询结果为：{}", JSON.toJSONString(response.getBody()));
        return response.getBody();
    }
}

```

测试方法

```Java
@SpringBootTest
@RunWith(SpringRunner.class )
public class ProductDemo01 {

    @Resource(name = "discoveryClientProductLIstService")
    private ProductListService productListService;

    @Autowired
    @Qualifier(value = "ribbonProductService")
    private ProductListService ribbonProductService;

    @Resource(name = "loadBalancedProductService")
    private ProductListService loadBalancedProductService;

    @Test
    public void test01(){
        List<Product> products = productListService.selectProductListByDiscoveryClient();
        for (Product product : products) {
            System.out.println(product);
        }
    }
}

```

运行效果

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0jkjt5e20j222s0biadh.jpg ':size=80%')

### LoadBalancerClient


> RestTemplateConf 和DiscoveryClient相同


实现类

```Java
@Slf4j
@Service("loadBalancedProductService")
public class LoadBalancedProductService implements ProductListService {

    @Autowired
    private RestTemplate restTemplate;  // 这个类上面需要有@LoadBalanced负载均衡注解

    @Override
    public List<Product> selectProductListByDiscoveryClient() {
        String url = "http://product-service/product/list";
        log.info("订单服务调用商品服务...");
        log.info("从注册中心获取到的商品服务地址为：{}", url);
        // ResponseEntity: 封装了返回数据
        ResponseEntity<List<Product>> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<List<Product>>() {});
        log.info("商品信息查询结果为：{}", JSON.toJSONString(response.getBody()));
        return response.getBody();
    }
}
```
测试类（略）

###  LoadBalanced

配置文件

`RestTemplate` 时添加 `@LoadBalanced` 负载均衡注解，表示这个 `RestTemplate` 在请求时拥有客户端负载均衡的能力。

```
@Configuration
public class RestTemplateConf {


    @Bean
    @LoadBalanced // 负载均衡注解
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```





```java
@Slf4j
@Service("ribbonProductService")
public class RibbonProductService implements ProductListService {

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private LoadBalancerClient loadBalancerClient; // Ribbon 负载均衡器

    @Override
    public List<Product> selectProductListByDiscoveryClient() {
        StringBuffer sb = null;

        // 根据服务名称获取服务
        ServiceInstance si = loadBalancerClient.choose("product-service");
        if (null == si)
            return null;

        sb = new StringBuffer();
        sb.append("http://" + si.getHost() + ":" + si.getPort() + "/product/list");
        log.info("订单服务调用商品服务...");
        log.info("从注册中心获取到的商品服务地址为：{}", sb.toString());

        // ResponseEntity: 封装了返回数据
        ResponseEntity<List<Product>> response = restTemplate.exchange(
                sb.toString(),
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<List<Product>>() {});
        log.info("商品信息查询结果为：{}", JSON.toJSONString(response.getBody()));
        return response.getBody();
    }
}
```