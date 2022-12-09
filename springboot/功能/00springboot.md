
资料来源：<br/>
[application.properties](https://github.com/L316476844/springbootexample/blob/master/src/main/resources/application.properties)
[什么是springboot？一文带你读懂springboot](https://www.toutiao.com/article/7033562358853255710/?log_from=7fd8e7d0e309d_1670080050134)

## Spring boot配置

### 设置返回压缩
~~~properties
#http://docs.spring.io/spring-boot/docs/current-SNAPSHOT/reference/htmlsingle/#how-to-enable-http-response-compression
server.compression.enabled=true 
server.compression.mime-types=application/json,application/xml,text/html,text/xml,text/plain
server.compression.min-response-size=4096
~~~

### 端口号

~~~ymal
server:
  port: 8000
  servlet:
    # 项目contextPath
    context-path: /
  tomcat:
    # tomcat的URI编码
    uri-encoding: UTF-8
    # tomcat最大线程数，默认为200
    max-threads: 800
    # Tomcat启动初始化的线程数，默认值25
    min-spare-threads: 30
 ~~~   