
## springboot 创建对象
单利，多列


~~~~java
@RunWith(SpringRunner.class)
@SpringBootTest(classes = AppApplication.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ScopDemo {

    @Autowired
    private org.springframework.beans.factory.BeanFactory beanFactory;

    @Test
    public void test01(){
        SchedulingJob s1 = beanFactory.getBean(SchedulingJob.class);
        SchedulingJob s2 = beanFactory.getBean(SchedulingJob.class);

        System.out.println(s1);
        System.out.println(s2);
        System.out.println(s1 == s2);
    }
}
~~~~
