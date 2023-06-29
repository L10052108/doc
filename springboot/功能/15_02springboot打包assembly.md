资料来源：

[Maven assembly多模块多环境（dev|test|prod）定制化打包SpringBoot项目详解](https://blog.csdn.net/L_15156024189/article/details/126192991?spm=1001.2101.3001.6650.7&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-7-126192991-blog-98882605.235%5Ev38%5Epc_relevant_sort_base1&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7EBlogCommendFromBaidu%7ERate-7-126192991-blog-98882605.235%5Ev38%5Epc_relevant_sort_base1&utm_relevant_index=8)



## SpringBoot项目详解

### 单模块场景
#### 介绍

> 这种方式适用于SpringBoot项目中仅有一个模块的场景。

需求：

1、启停可执行jar包的shell脚本单独打包到某个目录下，例如bin目录；

2、项目resources下的配置从jar包分离出来，单独打包到某个目录下，例如config目录；

3、项目的所有依赖jar包单独打到某个目录下，例如lib目录。

打包完成后，可直接执行bin目录下的启停shell脚本运行程序。


文件结构

![image-20230629172323629](img\image-20230629172323629.png)

#### pom.xml

```xml
 <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jar-plugin</artifactId>
                <configuration>
                    <archive>
                        <manifest>
                            <!-- 修改启动的类 -->
                            <mainClass>store.liuwei.db.sqllite.SqlListApplication</mainClass>
                            <addClasspath>true</addClasspath>
                            <classpathPrefix>lib</classpathPrefix>
                        </manifest>
                    </archive>
                    <!-- 排除resources下配置文件 -->
                    <excludes>
                        <exclude>*.*</exclude>
                    </excludes>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <descriptors>
                        <!--在resource文件夹下src/main/assembly/assembly.xml -->
                        <descriptor>assembly/assembly.xml</descriptor>
                    </descriptors>
                    <outputDirectory>target</outputDirectory>
                </configuration>
            </plugin>
        </plugins>
    </build>
```

需要修改的地方

> - <mainClass> 根据实际情况进行修改
> - assembly 文件所在位置

#### assembly.xml打包配置文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<assembly>
    <!-- 可自定义，这里指定的是项目环境 -->
    <!-- spring-boot-assembly-local-1.0.RELEASE.tar.gz  -->
    <id>${project.version}</id>

    <!-- 打包的类型，如果有N个，将会打N个类型的包 -->
    <formats>
        <format>tar.gz</format>
        <!--<format>zip</format>-->
    </formats>

    <includeBaseDirectory>true</includeBaseDirectory>

    <dependencySets>
        <!--    依赖jar包    -->
        <dependencySet>
            <outputDirectory>/lib</outputDirectory>
            <excludes>
                <exclude>${project.groupId}:${project.artifactId}</exclude>
            </excludes>
        </dependencySet>
        <!--   jar包     -->
       <!-- <dependencySet>
            <outputDirectory>/</outputDirectory>
            <includes>
                <include>${project.groupId}:${project.artifactId}</include>
            </includes>
        </dependencySet>-->
    </dependencySets>

    <fileSets>
        <!--
            0755->即用户具有读/写/执行权限，组用户和其它用户具有读写权限；
            0644->即用户具有读写权限，组用户和其它用户具有只读权限；
        -->
        <!-- 将src/bin目录下的所有文件输出到打包后的bin目录中 -->
        <fileSet>
            <directory>${basedir}/bin</directory>
            <outputDirectory>bin</outputDirectory>
            <fileMode>0755</fileMode>
            <includes>
                <include>**.sh</include>
                <include>**.bat</include>
            </includes>
        </fileSet>

        <!-- 指定输出target/classes中的配置文件到config目录中 -->
        <fileSet>
            <directory>${basedir}/target/classes</directory>
            <outputDirectory>config</outputDirectory>
            <fileMode>0644</fileMode>
            <includes>
                <include>application.yml</include>
<!--                <include>application-${profileActive}.yml</include>-->
                <include>application-*.yml</include>
                <include>mapper/**/*.xml</include>
                <include>static/**</include>
                <include>templates/**</include>
                <include>*.xml</include>
                <include>*.properties</include>
            </includes>
        </fileSet>

        <!-- 将第三方依赖打包到lib目录中 -->
        <fileSet>
            <directory>${basedir}/target/lib</directory>
            <outputDirectory>lib</outputDirectory>
            <includes>
                <include>${project.groupId}:${project.artifactId}</include>
            </includes>
            <fileMode>0755</fileMode>
        </fileSet>

        <!-- 将项目启动jar打包到boot目录中 -->
        <fileSet>
            <directory>${basedir}/target</directory>
<!--            <outputDirectory>boot</outputDirectory>-->
            <outputDirectory></outputDirectory>
            <fileMode>0755</fileMode>
            <includes>
                <include>${project.build.finalName}.jar</include>
            </includes>
        </fileSet>

        <!-- 包含根目录下的文件 -->
        <fileSet>
            <directory>${basedir}</directory>
            <includes>
                <include>NOTICE</include>
                <include>LICENSE</include>
                <include>*.md</include>
            </includes>
        </fileSet>
    </fileSets>

</assembly>
```

!>  根据项目的实际情况进行修改，每个目录下包含的文件

### 多模块场景 

需求：

除了单模块场景的需求外，新增一个多模块的需求：

（1）将每个模块项目自身的jar包打成一个jar包。例如项目结构如图：

![img](img\515dcbaeafea49938639767a1aa8ec62.png)

 api模块依赖其他子模块（bean、dao、service），当然外部依赖还是打包到lib目录下。

这里需要在api的pom.xml中配置上面单模块的相关配置，还需要新增一个plugin配置：

```xml
<plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>2.1.3.RELEASE</version>
                <configuration>
                    <mainClass>马赛克.DevopsBrainManagerApplication</mainClass>
                    <includes>
                        <include>
                            <groupId>马赛克</groupId>
                            <artifactId>马赛克-service</artifactId>
                        </include>
                        <include>
                            <groupId>马赛克</groupId>
                            <artifactId>马赛克-dao</artifactId>
                        </include>
                        <include>
                            <groupId>马赛克</groupId>
                            <artifactId>马赛克-bean</artifactId>
                        </include>
                    </includes>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
```

其中includes部分就是将bean、dao、service模块项目自身的jar包打到api模块项目jar中。打包后的效果如图：

![img](img\c1839451e15142cc921a8954adb797ec.png)

![img](img\97b41fa716be443faa3c7467ea7b62b2.png)