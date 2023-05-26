资料来源:<br/>
[SpringBoot--访问静态页面](https://blog.csdn.net/feiying0canglang/article/details/118912375)<br/>
[SpringBoot的html页面引入jquery，layui](https://blog.csdn.net/K881009/article/details/88656170)

[SpringBoot项目中访问HTML页面](https://blog.csdn.net/pan_junbiao/article/details/105615906)

## SpringBoot--访问静态页面
SpringBoot默认的页面映射路径（即模板文件存放的位置）为“classpath:/templates/*.html”。静态文件路径为“classpath:/static/”，其中可以存放JS、CSS等模板共用的静态文件。

1、将HTML页面存放在resources/static目录下的访问
将HTML页面存放在 resources（资源目录）下的 static 目录中。

【示例】在static目录下创建test1.html页面，然后在static目录下创建view目录，在view目录下创建test2.html页面，实现在浏览器中的访问。项目结构如下图：

![20200419152354174](img\20200419152354174.jpg)



（1）在static目录下创建test1.html页面，页面代码如下：

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>测试页面1</title>
    <meta name="author" content="pan_junbiao的博客">
</head>
<body>
    <h3>测试页面1</h3>
    <p>您好，欢迎访问 pan_junbiao的博客</p>
    <p>https://blog.csdn.net/pan_junbiao</p>
</body>
</html>
```

**执行结果：**

![20200419152947422](img\20200419152947422.png)

### 解决SpringBoot不能直接访问templates目录下的静态资源（不推荐）

SpringBoot项目下的templates目录的资源默认是受保护的，没有开放访问权限。这是因为templates文件夹，是放置模板文件的，因此需要视图解析器来解析它。所以必须通过服务器内部进行访问，也就是要走控制器 → 服务 → 视图解析器这个流程才行。同时，存在安全问题，比如说，你把你后台的html文件放到templates，而这个文件夹对外又是开放的，就会存在安全隐患。

解决方法：在application.yml或者application.properties配置文件中将访问权限开放（不推荐）

application.yml文件配置：

~~~
spring:
  resources:
    static-locations: classpath:/META-INF/resources/, classpath:/resources/, classpath:/static/, classpath:/public/, classpath:/templates/
~~~

**application.properties文件配置：**

~~~
spring.resources.static-locations=classpath:/META-INF/resources/,classpath:/resources/,classpath:/static/,classpath:/public/,classpath:/templates/
~~~

配置完成后，启动SpringBoot，在浏览器中输入地址就可以直接访问templates目录下的静态资源了。


### HTML存放于templates目录（推荐）
**步骤1：引入thymeleaf 依赖**

```
<!--访问静态资源-->
<dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```

**步骤2：写一个简单的HTML，放置到templates路径**

```
<!doctype html>
<html lang="en">
 
<head>
    <meta charset="UTF-8">
    <title>this is title</title>
</head>
 
<body>
 
<div>
    这是templates的demo
</div>
 
</body>
</html>
```

**步骤3：编写Controller**

```
package com.example.demo.views;
 
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
 
@Controller
@RequestMapping("view")
public class ViewController {
    @GetMapping("demo")
    public String demo() {
        return "demo";
    }
}
```

需要注意：必须使用@Controller，不能使用@RestController。

因为@RestController返回的是  JSON，且不走SpringMVC的视图解析流程，所以跳不到html那里。

测试

访问：Node Exporter  （我端口配成了9100，没有配置其他东西）

![20210720002722260](img\20210720002722260.png)


