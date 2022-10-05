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


### Spring Bean 生命周期的执行流程

资料来源：[Spring Bean 生命周期的执行流程](#)

Spring Bean 生命周期的执行流程


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