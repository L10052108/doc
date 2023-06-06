资料来源:<br/>
[24x24 点阵 java](https://blog.csdn.net/llapton/article/details/108462002)<br/>

## SpringBoot--获取resource文件夹的

需要用到的工具类

```xml
        <dependency>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-all</artifactId>
            <version>5.8.5</version>
        </dependency>
```

通过`ClassPathResource`来获取`resource`路径下的文件

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class HanZiDemo {

    @Test
    public void test01() throws Exception {
        ClassPathResource classPathResource = new ClassPathResource("application.yml");
        InputStream inputStream = classPathResource.getInputStream();
        String read = IoUtil.read(inputStream, StandardCharsets.UTF_8);
        System.out.println(read);
    }
}
```

