资料来源：<br/>
[Spring Boot项目使用maven-assembly-plugin根据不同环境打包成tar.gz或者zip](https://blog.csdn.net/fygkchina/article/details/98882605)<br/>
[我们公司使用了 6 年的Spring Boot 项目部署方案！打包 + Shell 脚本部署详解，稳的一批!](https://mp.weixin.qq.com/s/WI4nB_B52MQ5gcFW2x2b5A)<br/>
[Spring Boot 项目部署方案！打包 + Shell 脚本部署详解！真tm详细！](https://mp.weixin.qq.com/s/qivnCvzTrQCYnx3RBxTLPg)<br/>
[基于 DolphinDB 搭建微服务的 SpringBoot 项目](https://www.toutiao.com/article/7148265288654488097/?app=news_article&timestamp=1669894821&use_new_style=1&req_id=2022120119402001021207523207057EE9&group_id=7148265288654488097&share_token=145CF9E5-D680-40C0-AEEC-E28AC5DD3C73&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_ios&utm_campaign=client_share&wxshare_count=1&source=m_redirect&wid=1669901407728)<br/>
[java中jar包运行之-jar和-cp命令](https://blog.csdn.net/firstendhappy/article/details/119209167)<br/>
[SpringBoot项目部署](https://www.toutiao.com/article/7171832911283470851/?app=news_article&timestamp=1669894972&use_new_style=1&req_id=202212011942510101981121550F065469&group_id=7171832911283470851&share_token=C5EAE761-FE4E-45C7-A19B-0B97625A92D0&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_ios&utm_campaign=client_share&wxshare_count=1&source=m_redirect)<br/>


## Springboot 打包

#### 普通的打成fatjar

~~~~xml
    <!-- 打包配置 -->
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
~~~~


#### lombok

依赖的jar包
~~~~xml
    <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
~~~~


配置文件
~~~~xml
<build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
~~~~


### 拆分配置文件和jar
~~~~xml
 <build>
        <!--项目生成jar包的最终名称-->
        <finalName>${project.artifactId}</finalName>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
                <filtering>true</filtering>
            </resource>
        </resources>
        <!--项目打包成jar,过滤掉配置文件-->
        <plugins>
            <!--maven的测试用例插件，建议跳过。-->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <configuration>
                    <skip>true</skip>
                </configuration>
            </plugin>

            <!--  去掉配置文件 -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jar-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>*.xml</exclude>
                        <exclude>*.yaml</exclude>
                        <exclude>*.properties</exclude>
                    </excludes>
                </configuration>
            </plugin>

            <!--项目依赖jar包都放在lib目录下-->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-dependency-plugin</artifactId>
                <executions>
                    <execution>
                        <id>copy-dependencies</id>
                        <phase>package</phase>
                        <goals>
                            <goal>copy-dependencies</goal>
                        </goals>
                        <configuration>
                            <outputDirectory>${project.build.directory}/lib</outputDirectory>
                        </configuration>
                    </execution>
                </executions>
            </plugin>

            <!--resources目录下配置文件都放到config目录下-->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-resources-plugin</artifactId>
                <executions>
                    <execution>
                        <id>copy-resources</id>
                        <phase>package</phase>
                        <goals>
                            <goal>copy-resources</goal>
                        </goals>
                        <configuration>
                            <encoding>UTF-8</encoding>
                            <outputDirectory>${project.build.directory}/config</outputDirectory>
                            <resources>
                                <resource>
                                    <directory>src/main/resources/</directory>
                                    <filtering>true</filtering>
                                </resource>
                            </resources>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
~~~~

这样打出来的包，把配置文件和依赖的jar都拆分出来了

![image-20221201232701971](D:\file\docs\springboot\功能\images\image-20221201232701971.png)

解压后查看`META-INF`的内容

~~~~
Manifest-Version: 1.0
Implementation-Title: simple-package
Implementation-Version: 1.0-SNAPSHOT
Build-Jdk-Spec: 1.8
Created-By: Maven Archiver 3.4.0
~~~~

这个里面没有启动类的信息，也没有依赖的jar包信息，也没有启动类。很明显通过通常的`java -jar` 命令已经无法启动服务了

如果想启动服务肯定要其他的办法

~~~~
java -cp  C:\Users\23961\Desktop\jar\package\config;simple-package.jar;C:\Users\23961\Desktop\jar\package\lib\* store.liuwei.blog.pack.PackageApplication
~~~~

或者使用相对路径

~~~
java -cp  config;simple-package.jar;lib\* store.liuwei.blog.pack.PackageApplication
~~~

注意：jar包之间的分隔符在windows上是分号";"，而在linux中是冒号":"。

综上所述：

java -jar用来执行可执行jar包，其可执行的特性，由jar包中的清单属性Main-Class决定；

java -cp命令是纯粹的java命令，在指定的classpath中查找java类文件并执行，使用更灵活；



