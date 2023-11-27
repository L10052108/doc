资料来源：<br/>
[SpringBoot 整合 Sa-Token 让鉴权更简单](https://mp.weixin.qq.com/s/pY2T_49rTkrKAfBZLO3vYQ)



## 介绍

Sa-Token 是一个轻量级 Java 权限认证框架，主要解决：登录认证、权限认证、单点登录、OAuth2.0、分布式Session会话、微服务网关鉴权 等一系列权限相关问题。

**官方文档：**https://sa-token.cc/doc.html

**pom.xml 依赖**

```xml
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-spring-boot-starter</artifactId>
    <version>1.34.0</version>
</dependency>
```

**application.yml 配置**

```yaml
# Sa-Token 配置
sa-token:
  # token名称 (同时也是cookie名称)
  token-name: token
  # token有效期，单位s 默认30天, -1代表永不过期
  timeout: 2592000
  # token临时有效期 (指定时间内无操作就视为token过期) 单位: 秒
  activity-timeout: -1
  # 是否允许同一账号并发登录 (为true时允许一起登录, 为false时新登录挤掉旧登录)
  is-concurrent: true

  # 在多人登录同一账号时，是否共用一个token (为true时所有登录共用一个token, 为false时每次登录新建一个token)
  is-share: true
  # token风格
  token-style: uuid
  # 是否输出操作日志
  is-log: false
  # 是否在cookie读取不到token时，继续从请求header里继续尝试读取
  is-read-header: true
```

- 默认返回到cookie中
- 如果需要请求头中，需要`sa-token.token-name` 放名称，`sa-token.is-read-header=true`

**鉴权拦截器配置**

```java
package com.example.satoken.config;

import cn.dev33.satoken.interceptor.SaInterceptor;
import cn.dev33.satoken.router.SaRouter;
import cn.dev33.satoken.stp.StpUtil;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * @ClassName：SaTokenConfigure.java
 * @ClassPath：com.example.satoken.config.SaTokenConfigure.java
 * @Description： 鉴权拦截器
 * @Author：tanyp
 * @Date：2023/10/24  09:14
 **/
@Configuration
public class SaTokenConfigure implements WebMvcConfigurer {

    /**
     * @MonthName：addInterceptors
     * @Description： 注册 Sa-Token 拦截器，打开注解式鉴权功能
     * @Author：tanyp
     * @Date： 023/10/24  09:19
     * @Param： [registry]
     * @return：void
     **/
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 注册 Sa-Token 拦截器，打开注解式鉴权功能
        registry.addInterceptor(new SaInterceptor(handle -> StpUtil.checkLogin()))
                // 验证所有接口
                .addPathPatterns("/**")
                // 忽略校验
                .excludePathPatterns("/user/login");
    }
}
```

**路由拦截鉴权配置**

```java
// 根据路由划分模块，不同模块不同鉴权 
registry.addInterceptor(new SaInterceptor(handler -> {
    SaRouter.match("/user/**", r -> StpUtil.checkPermission("user"));
    SaRouter.match("/admin/**", r -> StpUtil.checkPermission("admin"));
    // 更多模块... 
})).addPathPatterns("/**");
```

**全局异常拦截配置**

```java
package com.example.satoken.exception;

import cn.dev33.satoken.util.SaResult;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * @ClassName：GlobalExceptionHandler.java
 * @ClassPath：com.example.satoken.exception.GlobalExceptionHandler.java
 * @Description： 全局异常拦截
 * @Author：tanyp
 * @Date：2023/10/24 10:25
 **/
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler
    public SaResult handlerException(Exception e) {
        e.printStackTrace();
        return SaResult.error(e.getMessage());
    }

}
```

**用户信息（UserController.java）**

```java
package com.example.satoken.controller;

import cn.dev33.satoken.stp.StpUtil;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.example.satoken.domain.User;
import com.example.satoken.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Objects;

/**
 * @ClassName：UserController.java
 * @ClassPath：com.example.satoken.controller.UserController.java
 * @Description： 用户信息
 * @Author：tanyp
 * @Date：2023/10/24 10:28
 **/
@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("login")
    public Object login(String username, String password) {
        User user = userService.getOne(Wrappers.<User>lambdaQuery().ge(User::getUsername, username));
        if (Objects.nonNull(user) && Objects.equals(user.getUsername(), username) && Objects.equals(user.getPassword(), password)) {
            // 登录鉴权
            StpUtil.login(user.getId());
            // 返回token信息
            return StpUtil.getTokenInfo();
        }
        return "登录失败，用户名或密码有误！";
    }

    @GetMapping("logout")
    public Object logout() {
        StpUtil.logout();
        return "登出成功!";
    }

}
```

- • `StpUtil.login()`：会话登录，参数填登录人的账号id；
- • `StpUtil.checkLogin()`：校验当前客户端是否已经登录；
- • `StpUtil.getTokenInfo()`：获取当前会话的 token 信息参数；
- • `StpUtil.getTokenValue()`：获取当前会话的 token 值；
- • `StpUtil.getTokenTimeout()`：获取当前会话剩余有效期（单位：s，返回-1代表永久有效）；
- • `StpUtil.getLoginId()`：获取当前会话账号id；
- • `StpUtil.kickout()`：将指定账号踢下线；
- • `StpUtil.logout()`：强制指定账号注销下线；

**注解鉴权（TestController.java）**

```java
package com.example.satoken.controller;

import cn.dev33.satoken.annotation.SaCheckLogin;
import cn.dev33.satoken.annotation.SaIgnore;
import cn.dev33.satoken.stp.StpUtil;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @ClassName：TestController.java
 * @ClassPath：com.example.satoken.controller.TestController.java
 * @Description： 注解鉴权
 * @Author：tanyp
 * @Date：2023/10/24 10:30
 **/
@SaCheckLogin // 登录校验 —— 只有登录之后才能进入该方法。
@RestController
@RequestMapping("/test")
public class TestController {

    /**
     * @MonthName：test
     * @Description： 忽略校验 —— 表示被修饰的方法或类无需进行注解鉴权和路由拦截器鉴权。
     * @Author：tanyp
     * @Date：2023/10/24 10:30
     * @Param： []
     * @return：java.lang.String
     **/
    @SaIgnore // 忽略校验
    @GetMapping("test")
    public String test() {
        return "当前会话是否登录：" + StpUtil.isLogin();
    }

}
```

- `@SaCheckLogin`：登录校验，只有登录之后才能进入该方法；
- `@SaIgnore`：忽略校验；
-  `@SaCheckDisable("comment")`：账号服务封禁校验，校验当前账号指定服务是否被封禁。

**Session 会话**

Session 是会话中专业的数据缓存组件，通过 Session 我们可以很方便的缓存一些高频读写数据，提高程序性能。

设置登录信息缓存 user 对象 ：

```java
StpUtil.getSession().set("user", user);
```

在任意处使用这个 user 对象

```java
SysUser user = (SysUser) StpUtil.getSession().get("user");
```

### 登录测试

请求地址：

http://localhost:8080/user/login?username=admin&password=123456

结果：

```yaml
"tokenName": "token",
"tokenValue": "f2e6563b-9aed-44ef-8e3e-6d2e48ca6cef",
"isLogin": true,
"loginId": "u00001",
"loginType": "login",
"tokenTimeout": 2591999,
"sessionTimeout": 2591999,
"tokenSessionTimeout": -2,
"tokenActivityTimeout": -1,
"loginDevice": "default-device",
"tag": null
```

**更多API文档：**

https://sa-token.cc/doc.html#/use/login-auth