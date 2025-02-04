资料来源：<br/>
[Java工具篇之反射框架Reflections](https://developer.aliyun.com/article/1000269)


## 反射工具

在[03_工厂后置处理器使用案例](springboot/spring/bean/03_工厂后置处理器使用案例.md)中使用到了这个工具

Reflections通过扫描classpath，索引元数据，并且允许在运行时查询这些元数据。

使用Reflections可以很轻松的获取以下元数据信息：

- [x] 获取某个类型的全部子类
- [x] 只要类型、构造器、方法，字段上带有特定注解，便能获取带有这个注解的全部信息（类型、构造器、方法，字段）
- [x] 获取所有能匹配某个正则表达式的资源
- [x] 获取所有带有特定签名的方法，包括参数，参数注解，返回类型
- [x] 获取所有方法的名字
- [x] 获取代码里所有字段、方法名、构造器的使用权

### Maven依赖

```xml
<dependency>
    <groupId>org.reflections</groupId>
    <artifactId>reflections</artifactId>
    <version>0.9.11</version>
</dependency>
```

### 使用方法

####  实例化

指定要扫描的包名

```java
// 实例化Reflections，并指定要扫描的包名
Reflections reflections = new Reflections("my.project");
// 获取某个类的所有子类
Set<Class<? extends SomeType>> subTypes = reflections.getSubTypesOf(SomeType.class);
// 获取包含某个注解的所有类
Set<Class<?>> annotated = reflections.getTypesAnnotatedWith(SomeAnnotation.class);
  
```

指定要扫描的包名并添加过滤器

ConfigurationBuilder API

```java
Reflections reflections = new Reflections(
  new ConfigurationBuilder()
    .forPackage("com.my.project")
    .filterInputsBy(new FilterBuilder().includePackage("com.my.project")));
```

添加扫描器

Scanners API

```java
// scan package with specific scanners
Reflections reflections = new Reflections(
  new ConfigurationBuilder()
    .forPackage("com.my.project")
    .filterInputsBy(new FilterBuilder().includePackage("com.my.project").excludePackage("com.my.project.exclude"))
    .setScanners(TypesAnnotated, MethodsAnnotated, MethodsReturn));

// scan package with all standard scanners
Reflections reflections = new Reflections("com.my.project", Scanners.values());
```

#### 扫描子类

```java
Set<Class<? extends Module>> modules = 
    reflections.getSubTypesOf(com.google.inject.Module.class);
```

#### 扫描注解

```java
//TypeAnnotationsScanner 
Set<Class<?>> singletons = 
    reflections.getTypesAnnotatedWith(javax.inject.Singleton.class);
```

####  扫描资源

```java
//ResourcesScanner
Set<String> properties = 
    reflections.getResources(Pattern.compile(".*\\.properties"));
```

#### 扫描方法、构造注解

```java
//MethodAnnotationsScanner
Set<Method> resources =
    reflections.getMethodsAnnotatedWith(javax.ws.rs.Path.class);
Set<Constructor> injectables = 
    reflections.getConstructorsAnnotatedWith(javax.inject.Inject.class);
```

####  扫描字段注解

```java
Set<Field> ids = 
    reflections.getFieldsAnnotatedWith(javax.persistence.Id.class);
```

####  扫描方法参数

```java
//MethodParameterScanner
Set<Method> someMethods =
    reflections.getMethodsMatchParams(long.class, int.class);
Set<Method> voidMethods =
    reflections.getMethodsReturn(void.class);
Set<Method> pathParamMethods =
    reflections.getMethodsWithAnyParamAnnotated(PathParam.class);
```

####  扫描方法参数名

```java
List<String> parameterNames = 
    reflections.getMethodParamNames(Method.class)
```

#### 扫描方法调用情况

```java
//MemberUsageScanner
Set<Member> usages = 
    reflections.getMethodUsages(Method.class)
```

