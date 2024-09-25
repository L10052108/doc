资料来源：
[Spring学习笔记：Spring Bean的销毁](https://www.jianshu.com/p/6f2cbbbc8781)

Spring Bean能通过不同方式进行销毁操作，下面将展示Spring Bean的各种销毁方法回调方式。

## 1.通过@PreDestroy

@PreDestroy是java的注解类，如果需要通过这种方式回调销毁方法，需要容器具备扫描注解的能力
 以下例子通过@PreDestroy的方式展示

- Bean的类定义

```tsx
public class SubUser {
   private String type;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

      /**
     * 通过@PreDestroy设定的销毁方法
     */
    @PreDestroy
    public void initByPreDestroy() {
        System.out.println("destroy method by @PreDestroy");
    }
}
```

## 2. 实现DisposableBean

- Bean的类定义



```tsx
public class SubUser implements  DisposableBean {
 private String type;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }


/**
     * 实现DisposableBean接口的销毁方法
     *
     * @throws Exception
     */
    @Override
    public void destroy() throws Exception {
        System.out.println("destroy by DisposableBean#destroy()");
    }
}
```

## 3.通过Xml方式设定销毁方法

通过<bean>标签的destroy-method属性配置销毁方法

- Bean的类定义



```tsx
public class SubUser {
   private String type;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

     /**
     * 通过Xml配置的destroy-method设定销毁方法
     */
    public void destroyByXml() {
        System.out.println("destroy by xml destroy-method");
    }

}
```

- Xml配置



```xml
    <!-- 自定义销毁方法-->
    <bean id="destroy-by-xml" destroy-method="destroyByXml" class="com.kgyam.domain.SubUser"></bean>
```

## 4.通过@Bean方式设定销毁方法

通过@Bean的destroyMethod属性设定销毁方法

- Bean的类定义



```tsx
public class SubUser {
   private String type;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

   public void destroyByBeanAnnotation() {
        System.out.println("destroy by @Bean destroy-method");
    }
}
```

- Bean元信息类



```java
     @Bean(name = "sub-user", destroyMethod = "destroyByBeanAnnotation")
        public SubUser subUser() {
            return new SubUser();
        }
```

## 5.通过BeanDefinition方式设定销毁方法



```java
/**
     * 通过BeanDefinition设定销毁方法的示例
     */
    static void destroyByBeanDefinition() {
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext();

        BeanDefinitionBuilder builder = BeanDefinitionBuilder.genericBeanDefinition(SubUser.class);
        builder.setDestroyMethodName("destroyByBeanDefinition");
        applicationContext.refresh();
        applicationContext.registerBeanDefinition("sub-user", builder.getBeanDefinition());
        applicationContext.getBean("sub-user", SubUser.class);
        System.out.println("准备关闭应用上下文");
        applicationContext.close();
        System.out.println("已经关闭应用上下文");
    }
```

##  销毁方法的执行顺序

@PreDestroy -> DisposableBean#destroy() -> 自定义销毁方法

