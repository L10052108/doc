# 项目介绍

##  项目的背景

为了方便学习springboot的功能，因而创建这个项目。主分支上使用最基本的功能，springboot的简单框架。不同分支介绍不同的功能

[项目代码](https://gitee.com/L10052108/springboot_project)


# 代码介绍

## 创建项目

从https://start.spring.io/ 拉去代码

![1](pic/1.png ':size=40%')

## 进行创建项目

###  创建步骤

1.增加需要依赖的jar

2. 修改yml 配置文件
3. 增加一个简单web测试类
4. 增加测试类

![2](pic/2.png ':size=40%')



添加依赖jar 

````java
	<!-- 统计版本管理 -->
	<properties>
		<java.version>8</java.version>
	</properties>


	<!-- 依赖的框架 -->
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter</artifactId>
		</dependency>

		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>

		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
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
			<!-- <version>1.18.10</version> -->
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
			<version>1.1.41</version>
		</dependency>

		<!--工具类文档地址： https://hutool.cn/docs/#/ -->
		<dependency>
			<groupId>cn.hutool</groupId>
			<artifactId>hutool-all</artifactId>
			<version>5.0.5</version>
		</dependency>

		<dependency>
			<groupId>javax.persistence</groupId>
			<artifactId>persistence-api</artifactId>
			<version>1.0</version>
		</dependency>
		
			<!--常用工具类 -->
		<dependency>
			<groupId>org.apache.commons</groupId>
			<artifactId>commons-lang3</artifactId>
		</dependency>
	</dependencies>
````



### 配置文件application.yml

配置文件中的内容

````Java
server:
  port: 8002
  servlet:
    # 项目contextPath
    context-path: /
  tomcat:
    # tomcat的URI编码
    uri-encoding: UTF-8
    # tomcat最大线程数，默认为200
    max-threads: 800
    # Tomcat启动初始化的线程数，默认值25
    min-spare-threads: 30
````

###  测试control
创建一个简单的测试，进行测试web服务

````
@RestController
public class SimpleControl {
	
	private static final Logger logger = LoggerFactory.getLogger(SimpleControl.class);
	
	// 简单的一个测试类
	@RequestMapping("/t1")
	public  List<String> getList() {
		logger.info("收到了请求");
		List<String> list = new ArrayList<String>();
		list.add("aa");
		list.add("bb");
		return list;
	}
}
````

通过启动 ProjectApplication.java 这个类的main 方法可以启动项目

请求测试地址：

`http://127.0.0.1:8002/t1`

项目运行成功

### 测试类

很多时候，需要进行写测试类。对方法进行测试

下面是测试的方法

````
@RunWith(SpringRunner.class)
@SpringBootTest(classes = ProjectApplication.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class SpringbootDemo {

	@Test
	public void test01() {
		System.out.println("系统启动正常");
	}
}
````

通过执行测试类，对项目进行测