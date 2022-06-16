资料来源:

[Spring Boot返回JSON数据（三种方式）](https://tva1.sinaimg.cn/large/e6c9d24ely1h3a6oa4zg0j20vk082q3q.jpg)



## Spring Boot返回JSON数据（三种方式)

### 概述

- 默认实现
- 使用Gson
- 使用fastjson

### 默认实现

 spring-boot-starter-web依赖默认加入了jackson-databind作为json处理器，此时不需要添加额外的JSON处理器就能返回一段JSON了。

创建一个Book实体类

~~~~java
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.util.Date;

@Data
public class Book {
    private String name;
    private String author;
    @JsonIgnore
    private Double price;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date cationDate;
}
~~~~

注解：

> - @JsonIgnore:转换json的时候忽略此属性
>
> - @JsonFormat(pattern = “yyyy-MM-dd”)：对该属性的值进行格式化
>
>   创建BookController，返回Book对象

~~~~java
@RestController
public class BookController {

    @GetMapping("/book")
    public Book book(){
        Book book = new Book();
        book.setName("三国演义");
        book.setAuthor("罗贯中");
        book.setPrice(30D);
        book.setCationDate(new Date());
        return book;
    }
~~~~

返回结果

~~~java
{
  "name": "三国演义",
  "author": "罗贯中",
  "cationDate": "2021-05-03"
}
~~~

### 使用Gson

 Gson是Google的一个开源JSON解析框架。**使用Gson，需要先除去默认的jackson-databind，然后加入Gson依赖。**

```Xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>com.google.code.gson</groupId>
    <artifactId>gson</artifactId>
</dependency>
```

由于Spring Boot中默认提供了Gson的自动转换类：GsonHttpMessageConvertersConfigureation,因此Gson依赖添加后，可以像使用Jackson-databind那样直接使用Gson。**但是在Gson进行转换时，如果想对日期进行格式化，那么还需要开发者自定义HttpMessageConverter。**如下：

~~~~java
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.json.GsonHttpMessageConverter;

import java.lang.reflect.Modifier;

@Configuration
public class GsonConfig {
    @Bean
    public GsonHttpMessageConverter gsonHttpMessageConverter(){
        GsonHttpMessageConverter converter = new GsonHttpMessageConverter();
        GsonBuilder builder = new GsonBuilder();
        builder.setDateFormat("yyyy-MM-dd");
        builder.excludeFieldsWithModifiers(Modifier.PROTECTED);
        Gson gson = builder.create();
        converter.setGson(gson);
        return converter;
    }
}
~~~~

- 注意：

> - 开发者自己提供的一个GsonHttpMessageConverter实例
>
> - 设置了Gson解析日期的转化格式
>
> - 设置Gson解析时修饰符为protected的字段被过滤掉。（可自行选择）
>
>   创建Book实例

~~~~java
@Data
public class Book {
    private String name;
    private String author;
    protected Double price;
    private Date cationDate;
}
~~~~

 添加Controller：

```java
@RestController
public class BookController {

    @GetMapping("/book")
    public Book book(){
        Book book = new Book();
        book.setName("三国演义");
        book.setAuthor("罗贯中");
        book.setPrice(30D);
        book.setCationDate(new Date());
        return book;
    }
}
```

返回结果

~~~~json
{
  "name": "三国演义",
  "author": "罗贯中",
  "cationDate": "2021-05-03"
}
~~~~

 ### 使用fastjson（两种方式）
​ fastjson是阿里巴巴的一个开源JSON解析框架，是目前JSON解析速度最快的开源框架。Spring Boot继承fastjson后不能立马使用，需要开发者提供HttpMessageConverter后才能使用，继承步骤如下：

首先除去jackson-databind依赖，引入fastjson依赖：

~~~~xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
        </exclusion>
    </exclusions>
</dependency>

<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.47</version>
</dependency>
~~~~

#### 方法一

配置fastjson的HttpMessageConverter

~~~~java
@Configuration
public class MyFastJsonConfig {
    @Bean
    public FastJsonHttpMessageConverter fastJsonHttpMessageConverter(){
        FastJsonHttpMessageConverter converter = new FastJsonHttpMessageConverter();
        FastJsonConfig config = new FastJsonConfig();
        config.setDateFormat("yyyy-MM-dd");
        config.setCharset(Charset.forName("UTF-8"));
        /*
         * WriteClassName:是否在生成的JSON中输出类名
         * WriteMapNullValue：是否输出value为null的数据
         * PrettyFormat：生成的JSON格式化
         * WriteNullListAsEmpty：空集合输出[]而非null
         * WriteNullStringAsEmpty：空字符串输出“”而非null
         */

        config.setSerializerFeatures(
                SerializerFeature.WriteClassName,
                SerializerFeature.WriteMapNullValue,
                SerializerFeature.PrettyFormat,
                SerializerFeature.WriteNullListAsEmpty,
                SerializerFeature.WriteNullStringAsEmpty
        );
        converter.setFastJsonConfig(config);
        return converter;
    }
}
~~~~

- 自定义MyFastJsonConfig，完成对FastJsonHttpMessageConverter Bean的提供

配置响应编码：

```Properties
server.port=8081
#编码格式
server.servlet.encoding.force=true
server.servlet.encoding.charset=UTF-8
server.servlet.encoding.enabled=true
server.tomcat.uri-encoding=UTF-8
```

同样的controller 输出的结果

~~~~json
{
  "@type": "com.itlearn.springboot06fastjson.beans.Book",
  "author": "罗贯中",
  "cationDate": "2021-05-03",
  "name": "三国演义",
  "price": 30.0D
}
~~~~

#### 方法二

​ 在Spring Boot项目中，当开发者引入spring-boot-starter-web依赖后，该依赖又依赖了spring-boot-autoconfigure，在这个自动化配置中，有一个WebMvcAutoConfigureation类提供了对Spring MVC最基本的配置，如果某一项自动化配置不满足开发需求，开发者可针对该项目自定义配置，只需要实现WebMvcConfigurer接口即可。（spring 5.0之前是通过继承WebMvcConfigurerAdapter类实现的）

~~~~java
@Configuration
public class MyWebMvcConfig implements WebMvcConfigurer {
    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        FastJsonHttpMessageConverter converter = new FastJsonHttpMessageConverter();
        FastJsonConfig config = new FastJsonConfig();
        config.setDateFormat("yyyy-MM-dd");
        config.setCharset(Charset.forName("UTF-8"));
        config.setSerializerFeatures(
                SerializerFeature.WriteClassName,
                SerializerFeature.WriteMapNullValue,
                SerializerFeature.PrettyFormat,
                SerializerFeature.WriteNullListAsEmpty,
                SerializerFeature.WriteNullStringAsEmpty
        );
        converter.setFastJsonConfig(config);
        converters.add(converter);
    }
}
~~~~

运行结果

~~~~json 
{
  "@type": "com.itlearn.springboot06fastjson.beans.Book",
  "author": "罗贯中",
  "cationDate": "2021-05-03",
  "name": "三国演义",
  "price": 30.0D
}
~~~~






























