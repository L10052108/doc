
参考资料
[Springboot中使用线程池](https://juejin.cn/post/7087526683430879240)<br/>
..........


如下方式会使@Async失效
一、异步方法使用static修饰
二、异步类没有使用@Component注解（或其他注解）导致spring无法扫描到异步类
三、异步方法不能与被调用的异步方法在同一个类中
四、类中需要使用@Autowired或@Resource等注解自动注入，不能自己手动new对象
五、如果使用SpringBoot框架必须在启动类中增加@EnableAsync注解
