资料来源：

[@Autowired和@Resource注解的区别和联系（十分详细，不看后悔）](https://blog.csdn.net/qq_45590494/article/details/114444371)

[@Scope注解 详细讲解及示例](https://blog.csdn.net/lzb348110175/article/details/114387477)



## 注解的方式

### @Autowired VS @Resource

- 联系

> 1. @Autowired和@Resource注解都是作为bean对象注入的时候使用的
> 2. 两者都可以声明在字段和setter方法上

- 注意：

> 如果声明在字段上，那么就不需要再写setter方法。但是本质上，该对象还是作为set方法的实参，通过执行set方法注入，只是省略了setter方法罢了

- 区别

> @Autowired注解是Spring提供的，而@Resource注解是J2EE本身提供的<br/>
> @Autowird注解默认通过byType方式注入，而@Resource注解默认通过byName方式注入<br/>
> @Autowired注解注入的对象需要在IOC容器中存在，否则需要加上属性required=false，表示忽略当前要注入的bean，如果有直接注入，没有跳过，不会报错<br/>

简单来说，**byName就是变量名去匹配bean的id属性，而byType则是变量类型去匹配bean的class属性**

~~~~java
<bean id="userService" class="com.test.UserServiceImpl">
</bean> 
~~~~

~~~java
@Autowired
private UserService userService;
~~~

此处byName就是拿变量名userService去匹配IOC容器的iduserService，匹配成功；

而byType就是拿变量类型UserService去匹配IOC容器的idcom.test.UserService.UserServiceImpl，因为UserServiceImpl是UserService实现，所以也匹配成功

### autword注解的使用

步骤：@Autowird默认的注入方式为byType，也就是根据类型匹配，当有多个实现时，则通过byName注入，也可以通过配合@Qualifier注解来显式指定name值，指明要使用哪个具体的实现类

举例：

首先有一个接口UserService和两个实现类UserServiceImpl1和UserServiceImpl2，并且这两个实现类已经加入到Spring的IOC容器中了

~~~~java
@Service
public class UserServiceImpl1 implements UserService

@Service
public class UserServiceImpl2 implements UserService
~~~~

通过@Autowired注入使用

~~~~java
@Autowired
private UserService userService;
~~~~

根据上面的步骤，可以很容易判断出，直接这么使用是会报错的
原因：首先通过byType注入，判断UserService类型有两个实现，无法确定具体是哪一个，于是通过byName方式，这里的变量名userService也无法匹配IOC容器中id（此处指的userServiceImpl1和userServiceImpl2），于是报错。

**解决方案**

方式一：

~~~~java
// 方式一：改变变量名
@Autowired
private UserService userServiceImpl1;
~~~~

方式二：

```java
// 方式二：配合@Qualifier注解来显式指定name值
@Autowired
@Qualifier(value = "userServiceImpl1")
private UserService userService;
```

### Resource注解的使用

**步骤**：@Resource默认通过byName注入，如果没有匹配则通过byType注入

举例：

~~~~java
@Service
public class UserServiceImpl1 implements UserService

@Service
public class UserServiceImpl2 implements UserService
~~~~

~~~~java
@Resource
private UserService userService;
~~~~

首先通过byName匹配，变量名userService无法匹配IOC容器中任何一个id（这里指的userServiceImpl1和userServiceImpl2），于是通过byType匹配，发现类型UserService的实现类有两个，仍然无法确定，于是报错。

同时@Resource还有两个重要的属性：name和type，用来显式指定byName和byType方式注**使用**：

对应4种情况

~~~~java
// 1. 默认方式：byName
@Resource  
private UserService userDao; 

// 2. 指定byName
@Resource(name="userService")  
private UserService userService; 

// 3. 指定byType
@Resource(type=UserService.class)  
private UserService userService; 

// 4. 指定byName和byType
@Resource(name="userService",type=UserService.class)  
private UserService userService; 
~~~~

?>  既没指定name属性，也没指定type属性：默认通过byName方式注入，如果byName匹配失败，则使用byType方式注入（也就是上面的那个例子）<br/>
指定name属性：通过byName方式注入，把变量名和IOC容器中的id去匹配，匹配失败则报错<br/>
指定type属性：通过byType方式注入，在IOC容器中匹配对应的类型，如果匹配不到或者匹配到多个则报错<br/>
同时指定name属性和type属性：在IOC容器中匹配，名字和类型同时匹配则成功，否则失败<br/>

### @autowird中使用map注入

举例：

```
@Service
public class UserServiceImpl1 implements UserService

@Service
public class UserServiceImpl2 implements UserService
```

通过@Autowired注入使用

```
@Autowired
private UserService userService;
```

根据上面的步骤，可以很容易判断出，直接这么使用是会报错的原因：首先通过byType注入，判断UserService类型有两个实现，无法确定具体是哪一个，于是通过byName方式，这里的变量名userService也无法匹配IOC容器中id（此处指的userServiceImpl1和userServiceImpl2），于是报错。

**解决方案**

方式一：

```
// 方式一：改变变量名
@Autowired
private UserService userServiceImpl1;
```

方式二：

```
// 方式二：配合@Qualifier注解来显式指定name值
@Autowired
@Qualifier(value = "userServiceImpl1")
private UserService userService;
```

## spring直接获取

### scope注解是什么

**@Scope注解是 Spring IOC 容器中的一个作用域**，在 Spring  IOC 容器中，他用来配置Bean实例的作用域对象。@Scope 具有以下几种作用域：

> singleton 单实例的(单例)(默认)   ----全局有且仅有一个实例<br/>
> prototype 多实例的(多例)   ---- 每次获取Bean的时候会有一个新的实例<br/>
> reqeust    同一次请求 ----request：每一次HTTP请求都会产生一个新的bean，同时该bean仅在当前HTTP request内有效<br/>
> session    同一个会话级别 ---- session：每一次HTTP请求都会产生一个新的bean，同时该bean仅在当前HTTP session内有效

### @Scope注解怎么使用

### 单利 & 多例

① 在不指定@Scope的情况下，所有的bean都是单实例的bean，而且是`饿汉`模式加载(容器启动实例就创建好了）

~~~~java
@Bean 
public Person person() { 
	return new Person(); 
}
~~~~

②指定@Scope为 `prototype` 表示为多实例的，而且还是`懒汉`模式加载（IOC容器启动的时候，并不会创建对象，而是 在第一次使用的时候才会创建）

~~~~java
@Bean 
@Scope(value = "prototype") 
public Person person() { 
	return new Person(); 
}
~~~~

测试service

```Java
@Service
@Scope(value = "prototype")
public class MyScopService {

    public String doWord() {
        return "success";
    }
}
```

测试demo

~~~java
import org.springframework.beans.factory.BeanFactory;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = ProjectApplication.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ConditonDemo {

    @Autowired
    private BeanFactory beanFactory;

    @Test
    public void test02(){
        MyScopService bean = beanFactory.getBean(MyScopService.class);
        MyScopService bean2 = beanFactory.getBean(MyScopService.class);

        System.out.println(bean);
        System.out.println(bean2);
        System.out.println(bean == bean2);
    }
}
~~~

运行效果

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1p7zbo31yj20qs07mwfd.jpg ':size=50%')

###  Bean实例对象的销毁


  针对单实例bean的话，容器启动的时候，bean的对象就创建了，而且容器销毁的时候，也会调用Bean的销毁方法；<br/>
  针对多实例bean的话,容器启动的时候，bean是不会被创建的而是在获取bean的时候被创建，而且bean的销毁不受IOC容器的管理，是由GC来处理的<br/>
  针对每一个Bean实例，都会有一个initMethod() 和 destroyMethod() 方法，我们可以在Bean 类中自行定义，也可以使用 Spring 默认提供的这两个方法。<br/>

!>  当设置为**prototype**多例时：每次连接请求，都会生成一个bean实例，也会导致一个问题，当请求数越多，性能会降低，因为创建的实例，导致GC频繁，GC时长增加。

需要考虑[对象的回收](springboot/功能/05Spring Bean的销毁.md)

###  恶汉式 & 懒汉式

?> 使用singleton单例，采用饿汉加载（容器启动，Bean实例就创建好了）<br/>?> 使用prototype多例，采用懒汉加载（IOC容器启动的时候，并不会创建对象实例，而是在第一次使用的时候才会创建）

**如何将 singleton 单例模式的 恶汉式 变更为 懒汉式，只需要再添加一个 @Lazy 注解即可。** 如下所示：

~~~~java
@Configuration
public class BeanConfig {

    @Bean
    @Scope
    @Lazy
    public Person person(){
        return new Person();
    }
}
~~~~

