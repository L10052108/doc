
### 为什么要使用Spring 框架？

资料来源：[为什么要使用Spring 框架？](https://www.toutiao.com/video/7086770071976018445/?from_scene=all)


### 谈谈你对 Spring IOC 和 DI 的理解

资料来源：[Java高级开发必须要懂，谈谈你对 Spring IOC 和 DI 的理解](https://www.toutiao.com/video/7112251973440963109/?from_scene=all)

#### 回答

首先， Spring IOC， 全称控制反转（Inversion of Control） 。<br/>
在传统的 Java 程序开发中， 我们只能通过 new 关键字来创建对象， 这种导致程序中对象的依赖关系比较复杂， 耦合度较高。 <br/> 
![image-20221005164810480](img/image-20221005164810480.png ':size=50%')<br/>
而 IOC 的主要作用是实现了对象的管理， 也就是我们把设计好的对象交给了 IOC容器控制， 然后在需要用到目标对象的时候， 直接从容器中去获取。 <br/> 
![image-20221005164844234](img/image-20221005164844234.png ':size=50%')<br/>
有了 IOC 容器来管理 Bean 以后， 相当于把对象的创建和查找依赖对象的控制权交给了容器， 这种设计理念使得对象与对象之间是一种松耦合状态， 极大提升了程序的灵活性以及功能的复用性。 <br/> 
然后， DI 表示依赖注入， 也就是对于 IOC 容器中管理的 Bean， 如果 Bean 之间存在依赖关系， 那么 IOC 容器需要自动实现依赖对象的实例注入， 通常有三种方法来描述 Bean 之间的依赖关系。<br/>  

接口注入<br/>
setter 注入<br/>
构造器注入<br/>
另外， 为了更加灵活的实现 Bean 实例的依赖注入， Spring 还提供了@Resource和@Autowired 这两个注解。<br/>
分别是根据 bean 的 id 和 bean 的类型来实现依赖注入。<br/>
以上就是我对这个问题的理解！  

## 跟着mic 学架构
### @Conditional注解有什么用

`condition` 注解的一个作用为bean的装载做一个条件判断，只有在满足条件的情况下。`spring`才会把`bean`装载到`IOC`容器里面。而这个条件是我们可以自定义去完成的。我们可以实现`condition`这个接口，并且重写里面的`matches`这个方法，去实现自定义的逻辑。所以`@condition`这个注解，增加了bean的装配的灵活性。在`springboot`里面对`@condition`注解做了更进一步的扩展，比如增加了`@conditionalOnClass`,`@conditionOnBean`等这样的注解，使得我们在使用的过程中。不再需要些那些条件的逻辑判断。而是可以直接根据数据本身的语义去完成对应的条件的一个装配


### 介绍下Spring IoC的工作流程？

资料来源：[介绍下Spring IoC的工作流程？](https://www.toutiao.com/video/7090050239951962660/)


### Spring中有哪些方式可以把Bean注入到IOC容器

资料来源：[Spring中有哪些方式可以把Bean注入到IOC容器](https://www.toutiao.com/video/7098586416824713736/)


### Spring如何解决循环依赖问题的

资料来源：[Spring如何解决循环依赖问题的](https://www.toutiao.com/video/7038513985431437831/)


### 如何叙述Spring Bean 的生命周期

资料来源：[如何叙述Spring Bean 的生命周期](https://www.toutiao.com/video/7041875113050014238/)



### Spring 中Bean的作用域有哪些

资料来源：[Spring 中Bean的作用域有哪些](https://www.toutiao.com/video/7088874285007110687/)

<hr/>


### Spring中BeanFactory和FactoryBean的区别

资料来源：[Spring中BeanFactory和FactoryBean的区别](https://www.toutiao.com/video/7090791563147772424/)

<hr/>





### @Autowired 和 @Resource 有什么区别

资料来源：[@Autowired 和 @Resource 有什么区别](https://www.toutiao.com/video/7148039216365044254/)

`@Resource` 和@`Autowired `这两个注解的作用都是在` Spring `生态里面去实现`Bean `的依赖注入。<br/>
下面我分别说一下`@Autowired `和`@Resource` 这两个注解。<br/>
闪现 [@Autowired 的作用详解 ] 几个字。<br/>
首先， @Autowired 是 Spring 里面提供的一个注解， 默认是根据类型来实现 `Bean`的依赖注入。<br/>
@Autowired 注解里面有一个 `required `属性默认值是 `true，` 表示强制要求` bean`实例的注入，<br/>
在应用启动的时候， 如果 IOC 容器里面不存在对应类型的 Bean， 就会报错。<br/>
当然， 如果不希望自动注入， 可以把这个属性设置成 false。<br/>

![image-20221005204751145](img/image-20221005204751145.png ':size=40%')<br/>

其次呢， 如果在 `Spring IOC` 容器里面存在多个相同类型的 Bean 实例。 由于`@Autowired `注解是根据类型来注入` Bean `实例的<br/>

![image-20221005204857811](img/image-20221005204857811.png ':size=40%')<br/>

所以 `Spring` 启动的时候， 会提示一个错误， 大概意思原本只能注入一个单实例`Bean`，但是在 `IOC` 容器里面却发现有多个， 导致注入失败。<br/>

![image-20221005205125353](img/image-20221005205125353.png ':size=40%')<br/>

当然， 针对这个问题， 我们可以使用 `@Primary `或者@`Qualifier `这两个注解来解决。<br/>
`@Primary` 表示主要的 bean， 当存在多个相同类型的 Bean 的时候， 优先使用声明了`@Primary `的 Bean。<br/>
`@Qualifier` 的作用类似于条件筛选， 它可以根据 Bean 的名字找到需要装配的目标 Bean。 <br/>

 ![image-20221005205235285](img/image-20221005205235285.png ':size=40%')<br/>

闪现 [`@Resource` 的作用详解 ] 几个字。
接下来， 我再解释一下`@Resource` 注解<br/>。
`@Resource `是 `JDK `提供的注解， 只是 Spring 在实现上提供了这个注解的功能支持。<br/>
它的使用方式和`@Autowired` 完全相同， 最大的差异于`@Resource` 可以支持`ByName `和` ByType `两种注入方式。<br/>
如果使用`name`， `Spring`就根据`bean`的名字进行依赖注入， 如果使用`type`，` Spring`就根据类型实现依赖注入。<br/>
如果两个属性都没配置， 就先根据定义的属性名字去匹配， 如果没匹配成功， 再根据类型匹配。 两个都没匹配到， 就报错。 <br/> 

![image-20221005205543118](img/image-20221005205543118.png)

最后， 我再总结一下。<br/> 
`@Autowired`是根据 type 来匹配， `@Resource` 可以根据 name 和 type 来匹配，默认是 name 匹配。<br/> 
`@Autowired` 是 Spring 定义的注解，` @Resource `是 JSR 250 规范里面定义的注解， 而 Spring 对 JSR 250 规范提供了支持。<br/> 
`@Autowired` 如果需要支持 name 匹配， 就需要配合`@Primary` 或者`@Qualifier`来实现。<br/> 

<hr/>

### Spring里面两个id相同的bean会报错吗？

资料来源：[Spring里面两个id相同的bean会报错吗？](https://www.toutiao.com/video/7099349888562889252/?from_scene=all)

关于这个问题， 我从几个点来回答。<br/>
首先， 在同一个 XML 配置文件里面， 不能存在 id 相同的两个 bean， 否则 spring容器启动的时候会报错<br/>

![image-20221008140106393](img/image-20221008140106393.png)

因为 id 这个属性表示一个 Bean 的唯一标志符号， 所以 Spring 在启动的时候会去验证 id 的唯一性， 一旦发现重复就会报错，<br/>
这个错误发生 Spring 对 XML 文件进行解析转化为 BeanDefinition 的阶段。<br/>
但是在两个不同的 Spring 配置文件里面， 可以存在 id 相同的两个 bean。 IOC容器在加载 Bean 的时候， 默认会多个相同 id 的 bean 进行覆盖。<br/>
在 Spring3.x 版本以后， 这个问题发生了变化<br/>
我们知道 Spring3.x 里面提供@Configuration 注解去声明一个配置类， 然后使用@Bean 注解实现 Bean 的声明， 这种方式完全取代了 XMl。<br/>
在这种情况下， 如果我们在同一个配置类里面声明多个相同名字的 bean， 在Spring IOC 容器中只会注册第一个声明的 Bean 的实例。<br/>
后续重复名字的 Bean 就不会再注册了。<br/>
像这样一段代码， 在 Spring IOC 容器里面， 只会保存 UserService01 这个实例，后续相同名字的实例不会再加载。<br/>

![image-20221008140153727](img/image-20221008140153727.png)<br/>

如果使用@Autowired 注解根据类型实现依赖注入， 因为 IOC 容器只有UserService01的实例， 所以启动的时候会提示找不到UserService02这个实例  <br/>

![image-20221008140213740](img/image-20221008140213740.png)<br/>

如果使用@Resource 注解根据名词实现依赖注入， 在 IOC 容器里面得到的实例对象是 UserService01，<br/>
于是 Spring 把 UserService01 这个实例赋值给 UserService02， 就会提示类型不匹配错误。<br/>

![image-20221008140412395](img/image-20221008140412395.png)<br/>
这个错误， 是在 Spring IOC 容器里面的 Bean 初始化之后的依赖注入阶段发生的。<br/>
以上就是我对这个问题的理解<br/>



### Spring中事务的传播行为有哪些？

资料来源：[Spring中事务的传播行为有哪些？](https://www.toutiao.com/video/7087137193034318349/?from_scene=all)