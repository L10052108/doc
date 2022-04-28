资料来源：<br/>
[深入浅出@Conditional注解使用方法](https://www.jianshu.com/p/9c7b897f0697)

### Spring提供的Condition
Spring还提供了很多Condition给我们用

<font color='red'>（a）@ConditionalOnBean</font>

仅仅在当前上下文中存在某个对象时，才会实例化一个Bean。

<font color='red'>（b）@ConditionalOnClass</font>

某个class位于类路径上，才会实例化一个Bean

<font color='red'>（c）@ConditionalOnExpression</font>

当表达式为true的时候，才会实例化一个Bean。

比如：

~~~~java
@ConditionalOnExpression("true")

@ConditionalOnExpression("${my.controller.enabled:false}")
~~~~

<font color='red'>（d）@ConditionalOnMissingBean</font><br/>

仅仅在当前上下文中不存在某个对象时，才会实例化一个Bean

<font color='red'>（e）@ConditionalOnMissingClass </font>

某个class类路径上不存在的时候，才会实例化一个Bean

<font color='red'>（f）@ConditionalOnNotWebApplication </font>

不是web应用

8. 题外话：怎么在Condition中获取application.properties的配置项

在实际开发中，我们的条件可能保存在application.properties中，那么怎么在Condition中获取呢，这个很简单，主要通过ConditionContext进行获取，具体代码如下：

Java代码
~~~~java
String port = context.getEnvironment().getProperty("server.port");  
System.out.println(port); 
~~~~