资料来源：


[IDEA创建新的模块SPRINGBOOT](https://www.cnblogs.com/jthr/p/15504032.html)

## 创建maven模块

file— new moduel — maven — 选择jdk

![](file/Apr-28-2022%2013-24-12.gif ':size=60%')

在项目pom文件加入模块依赖(版本管理)

~~~~java
　　　　　　　　<dependency>
                <groupId>com.ruoyi</groupId>
                <artifactId>test</artifactId>
                <version>${ruoyi.version}</version>
            </dependency>
~~~~

在主模块(Application所在模块)加入该模块依赖

~~~~java
<dependency>
                <groupId>com.ruoyi</groupId>
                <artifactId>test</artifactId>
                
 </dependency>
~~~~

