### 注解方式（Junit3）

在测试方法上，加上@Test注解

~~~~java
import org.junit.Test;

public class MyDemo2 {

    @Test
    public void test01(){
        System.out.println("Ok");
    }

}
~~~~



### 继承TestCase类（Junit2）

- 继承TestCase类
- 方法名test开头

```Java
public class MyDemo extends TestCase {

    public  void test01(){
        System.out.println("OK");
    }
}
```



### springboot 方法

- 可以加在springboot的开发环境

```Java
@RunWith(SpringRunner.class)
@SpringBootTest(classes = NacosConfigApplication.class,webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class H2Demo {

    @Autowired
    private UserMapper userMapper;

    @Test
    public void test01(){
        User user = this.userMapper.selectById(1L);
        System.out.println(user);
    }
}
```

