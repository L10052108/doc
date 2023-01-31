资料来源：<br/>
[bootstrap.yml无法加载](https://blog.csdn.net/lizz861109/article/details/116646960)<br/>
[Springboot 中配置文件的优先级和加载顺序](https://www.cnblogs.com/panchanggui/p/10788652.html)<br/>
[Spring Boot配置文件的位置和优先级](https://blog.csdn.net/ai97926/article/details/127618284)

### 加载顺序

- 若application.yml 和bootStrap.yml 在同一目录下，则bootStrap.yml 的加载顺序要高于application.yml,即bootStrap.yml  会优先被加载。

>   原理：
>
>   bootstrap.yml 用于应用程序上下文的引导阶段。
>
>   bootstrap.yml 由父Spring ApplicationContext加载。
>
>    •bootstrap.yml 可以理解成系统级别的一些参数配置，这些参数一般是不会变动的。<br/>
>   ​ •application.yml 可以用来定义应用级别的，如果搭配 spring-cloud-config 使用 application.yml 里面定义的文件可以实现动态替换。

- 不同位置的配置文件的加载顺序：

> 在不指定要被加载文件时，默认的加载顺序：由里向外加载，所以最外层的最后被加载，会覆盖里层的属性（参考官网介绍）

?> 直接先说结论 `*.properties` 优于`*.yml`<br/>`bootStrap.yml `的加载顺序要高于`application.yml`<br/>

- 举例

![](large/e6c9d24egy1h1pj937dalj20q20gsq4c.jpg ':size=40%')



因而加载的顺序

~~~~Shell
bootstrap.yml > application.yml > application.properties
~~~~

### 配置文件顺序
1、file:./config/（项目路径下的config文件夹配置文件优先级最高）


### bootstrap无法加载问题

在spring boot项目中加载bootstrap.yml配置

我们可以看到在idea中bootstrap.yml文件的格式yml，这样的标识无法启动时加载。

![](large/e6c9d24egy1h1pjc680mdj20de07u74j.jpg)

无法加载的原因是因为bootstrap.yml配置是spring cloud中带有的功能，当你只使用了springboot组件启动项目时，是无法自动加载的。

<div style='color: red'>另外在升级springboot到2.4+时，也无法进行加</div>

?> 解决方法： 引入spring-cloud-context的jar包

方法一：

在项目引入spring-cloud-context组件

~~~~java
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-context</artifactId>
            <version>2.1.0.RELEASE</version>
        </dependency>
~~~~

方法二：

使用其他spring cloud starter组件时，会内置context组件。

![77065cf1399d4dd088d00d14c67b2041](img\77065cf1399d4dd088d00d14c67b2041.png)

2、file:/（项目路径下的配置文件优先级其后）

![a4f9aa4a98a4449492a796e5280a14b6](img\a4f9aa4a98a4449492a796e5280a14b6.png)

3、classpath:/config/（资源路径下的config文件夹配置文件优先级为三）

![6749d04b27c84c0f8f14e174a39c051e](img\6749d04b27c84c0f8f14e174a39c051e.png)

4、classpath:/（资源路径下的配置文件优先级最低）

![2e1279337d26485c882aab952e424932](img\2e1279337d26485c882aab952e424932.png)

?>  文件加载位置的优先级为：1 > 2 > 3 > 4 