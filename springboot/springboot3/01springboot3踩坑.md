资料来源：

[Spring Boot3.0升级，踩坑之旅，附解决方案](https://blog.51cto.com/u_13971202/5910023?articleABtest=0)

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

