资料来源：

[为什么很多 SpringBoot 开发者放弃了 Tomcat，选择了 Undertow?](https://mp.weixin.qq.com/s/KiGeAhSPNS1T2Cr57jCBkA)

[spring-boot-starter-undertow和tomcat的区别](https://blog.csdn.net/weixin_49456013/article/details/110877262)


## 为什么选择Undertow

在SpringBoot框架中，我们使用最多的是Tomcat，这是SpringBoot默认的容器技术，而且是内嵌式的Tomcat。

同时，SpringBoot也支持Undertow容器，我们可以很方便的用Undertow替换Tomcat，而Undertow的性能和内存使用方面都优于Tomcat，那我们如何使用Undertow技术呢？本文将为大家细细讲解。

对于Tomcat技术，Java程序员应该都非常熟悉，它是Web应用最常用的容器技术。我们最早的开发的项目基本都是部署在Tomcat下运行，那除了Tomcat容器，SpringBoot中我们还可以使用什么容器技术呢？

没错，就是题目中的Undertow容器技术。SrpingBoot已经完全继承了Undertow技术，我们只需要引入Undertow的依赖即可

### 使用过程

1.排除SpingBoot中自带的tomcat

~~~~Xml
        <!--springboot web-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-starter-tomcat</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
~~~~

2.添加Undertow的依赖

```Xml
  <!--undertow-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-undertow</artifactId>
        </dependency>
```

这样即可，使用默认参数启动undertow服务器。如果需要修改undertow参数，继续往下看。
undertow的参数设置：

~~~~yaml
server:  
    port: 8084  
    http2:  
        enabled: true  
    undertow:  
        io-threads: 16  
        worker-threads: 256  
        buffer-size: 1024  
        buffers-per-region: 1024  
        direct-buffers: true
~~~~

> io-threads：IO线程数, 它主要执行非阻塞的任务，它们会负责多个连接，默认设置每个CPU核心一个线程，不可设置过大，否则启动项目会报错：打开文件数过多。



> worker-threads：阻塞任务线程池，当执行类似servlet请求阻塞IO操作，undertow会从这个线程池中取得线程。它的值取决于系统线程执行任务的阻塞系数，默认值是 io-threads*8
>
> 以下配置会影响buffer，这些buffer会用于服务器连接的IO操作，有点类似netty的池化内存管理。
>
> buffer-size：每块buffer的空间大小，越小的空间被利用越充分，不要设置太大，以免影响其他应用，合适即可
>
> buffers-per-region：每个区分配的buffer数量，所以pool的大小是buffer-size * buffers-per-region
>
> direct-buffers：是否分配的直接内存(NIO直接分配的堆外内存)

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h3a8chlupij20je0lota4.jpg)



通过测试发现，在高并发系统中，Tomcat相对来说比较弱。在相同的机器配置下，模拟相等的请求数，Undertow在性能和内存使用方面都是最优的。并且Undertow新版本默认使用持久连接，这将会进一步提高它的并发吞吐能力。所以，如果是高并发的业务系统，Undertow是最佳选择。

- 总结

SpingBoot中我们既可以使用Tomcat作为Http服务，也可以用Undertow来代替。Undertow在高并发业务场景中，性能优于Tomcat。所以，如果我们的系统是高并发请求，不妨使用一下Undertow，你会发现你的系统性能会得到很大的提升。











