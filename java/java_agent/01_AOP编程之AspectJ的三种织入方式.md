资料来源：<br/>
[AOP编程之AspectJ的三种织入方式](https://www.toutiao.com/article/7320139363025748490/?app=news_article&timestamp=1704612460&use_new_style=1&req_id=20240107152740FDA431BEB8BB2963E578&group_id=7320139363025748490&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=683b65c7-863f-4934-b24b-b64e0078417e&source=m_redirect&wid=1704699698816)

### 介绍

aspectj有三种织入方式,即编译时,编译后,加载时,本文简要介绍这三种方式

#### **怎么使用aspectj呢**

引入依赖

```xml
<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjrt</artifactId>
    <version>1.9.20.1</version>
</dependency>

<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjweaver</artifactId>
    <version>1.9.20.1</version>
</dependency>
```

创建待编织类

```java
public class Account {
    int balance = 20;

    public boolean withdraw(int amount) {
        if (balance < amount) {
            return false;
        } 
        balance = balance - amount;
        return true;
    }
}
```

创建aspectj类,用于编织目标类

```xml
public aspect AccountAspect {
    final int MIN_BALANCE = 10;

    pointcut callWithDraw(int amount, Account acc) : 
     call(boolean Account.withdraw(int)) && args(amount) && target(acc);

    before(int amount, Account acc) : callWithDraw(amount, acc) {
    }

    boolean around(int amount, Account acc) : 
      callWithDraw(amount, acc) {
        if (acc.balance < amount) {
            return false;
        }
        return proceed(amount, acc);
    }

    after(int amount, Account balance) : callWithDraw(amount, balance) {
    }
}
```

注意:aspectj类的后缀为.aj文件,javac不能编译,需要使用ajc编译器

一切准备就绪了,下面介绍三种编织方式

#### **编译时编织**

顾名思义,所谓编译时编织,就是在源代码阶段编译时,直接用aspectj类织入目标类中,输出成已经编织的类了,即上述示例的Account类的字节码被修改了.

为了编译aspectj类,我们需要引入插件

```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>aspectj-maven-plugin</artifactId>
    <version>1.14.0</version>
    <configuration>
        <complianceLevel>1.8</complianceLevel>
        <source>1.8</source>
        <target>1.8</target>
        <showWeaveInfo>true</showWeaveInfo>
        <verbose>true</verbose>
        <Xlint>ignore</Xlint>
        <encoding>UTF-8 </encoding>
    </configuration>
    <executions>
        <execution>
            <goals>
                <!-- use this goal to weave all your main classes -->
                <goal>compile</goal>
                <!-- use this goal to weave all your test classes -->
                <goal>test-compile</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

下面我们写下测试类,看看效果

```java
public class AccountUnitTest {

    private Account account;

    @Before
    public void before() {
        account = new Account();
    }

    @Test
    public void givenBalance20AndMinBalance10_whenWithdraw5_thenSuccess() {
        assertTrue(account.withdraw(5));
    }

    @Test
    public void givenBalance20AndMinBalance10_whenWithdraw100_thenFail() {
        assertFalse(account.withdraw(100));
    }
}
```

运行测试类,输出如下,表明编织成功了

```
15:33:52.313 [main] INFO  org.lyan.aspectj.AccountAspect -  Balance before withdrawal: 20
15:33:52.313 [main] INFO  org.lyan.aspectj.AccountAspect -  Withdraw ammout: 5
15:33:52.313 [main] INFO  org.lyan.aspectj.AccountAspect - Balance after withdrawal : 15
15:33:52.313 [main] INFO  org.lyan.aspectj.AccountAspect -  Balance before withdrawal: 20
15:33:52.313 [main] INFO  org.lyan.aspectj.AccountAspect -  Withdraw ammout: 100
15:33:52.313 [main] INFO  org.lyan.aspectj.AccountAspect - Withdrawal Rejected!
15:33:52.313 [main] INFO  org.lyan.aspectj.AccountAspect - Balance after withdrawal : 20
```

#### **编译后编织**

编译后编织也称为二进制编织,主要用在已经存在的class文件或jar文件需要编织的目标类,此时我们要对插件增加配置参数

```xml
                      <configuration>
                            <weaveDependencies>
                                <weaveDependency>
                                    <groupId>org.lyan.tutorials</groupId>
                                    <artifactId>spring-aop-share</artifactId>
                                </weaveDependency>
                            </weaveDependencies>
                        </configuration>
```

<weaveDependency>..</weaveDependency>中的配置即为需要编织的目标类,此处为jar文件引入,即在maven依赖中引入,在复制过来

```xml
     <dependency>
            <groupId>org.lyan.tutorials</groupId>
            <artifactId>spring-aop-share</artifactId>
            <version>1.0.0-SNAPSHOT</version>
        </dependency>
```

在spring-aop-sharejar包中有一个AccountDemo类为目标类

```java
public class AccountDemo {
    int balance = 20;

    public boolean withdraw(int amount) {
        if (balance < amount) {
            return false;
        }
        balance = balance - amount;
        return true;
    }
}
```

我们在自己的工程中编写aspectj类来编织引入的jar文件中AccoutDemo类

```java
public aspect AccountDemoAspect {
   
    private static final Logger logger = LoggerFactory.getLogger(AccountDemoAspect.class);
    final int MIN_BALANCE = 5;

    pointcut callWithDraw(int amount, AccountDemo account):
             call(boolean org.lyan.aspectj.AccountDemo.withdraw(int)) && args(amount) && target(account);

    before(int amount, AccountDemo account) : callWithDraw(amount, account) {
        logger.info(" Balance before withdrawal: {}", account.balance);
        logger.info(" Withdraw ammout: {}", amount);
    }

    boolean around(int amount, AccountDemo account) : callWithDraw(amount, account) {
        if (account.balance < amount) {
            logger.info("Withdrawal Rejected!");
            return false;
        }
        return proceed(amount, account);
    }

    after(int amount, AccountDemo balance) : callWithDraw(amount, balance) {
        logger.info("Balance after withdrawal : {}", balance.balance);
    }
}
```

测试运行一下

```
15:47:13.631 [main] INFO  org.lyan.aspectj.AccountDemoAspect -  Balance before withdrawal: 20
15:47:13.631 [main] INFO  org.lyan.aspectj.AccountDemoAspect -  Withdraw ammout: 5
15:47:13.631 [main] INFO  org.lyan.aspectj.AccountDemoAspect - Balance after withdrawal : 15
15:47:13.631 [main] INFO  org.lyan.aspectj.AccountDemoAspect -  Balance before withdrawal: 20
15:47:13.631 [main] INFO  org.lyan.aspectj.AccountDemoAspect -  Withdraw ammout: 100
15:47:13.631 [main] INFO  org.lyan.aspectj.AccountDemoAspect - Withdrawal Rejected!
15:47:13.631 [main] INFO  org.lyan.aspectj.AccountDemoAspect - Balance after withdrawal : 20
```

**加载时编织**

加载时编织是通过aspectj的特殊类加载器加载class文件时,重新修改字节码并定义类到JVM中完成编织.为了完成这个功能我们需要"weaving agent".可以在运行时环境指定javaagent,也可以使用插件的方式,在此使用插件

```
									<plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-surefire-plugin</artifactId>
                        <version>2.22.2</version>
                        <configuration>
                            <argLine>
                                -javaagent:D:/repository/org/aspectj/aspectjweaver/${aspectj.version}/aspectjweaver-${aspectj.version}.jar
                            </argLine>
                            <useSystemClassLoader>true</useSystemClassLoader>
                            <forkMode>always</forkMode>
                        </configuration>
                    </plugin>
```

或者在VM启动参数指定

```
-javaagent:D:/repository/org/aspectj/aspectjweaver/${aspectj.version}/aspectjweaver-${aspectj.version}.jar
```

然后在*META-INF目录下配置aop.xml文件*

```xml
<aspectj>
    <aspects>
        <aspect name="org.lyan.aspectj.AccountAspect"/>
        <weaver options="-verbose -showWeaveInfo">
            <include within="org.lyan.aspectj.*"/>
        </weaver>
    </aspects>
    <aspects>
        <aspect name="org.lyan.aspectj.SecuredMethodAspect"/>
        <weaver options="-verbose -showWeaveInfo">
            <include within="com.baeldung.aspectj.*"/>
        </weaver>
</aspectj>
```

*我们也可以使用@AspectJ*注解编写aspectj类,在加载时编织目标类

```java
@Aspect
public class SecuredMethodAspect {
    private static final Logger logger = LoggerFactory.getLogger(SecuredMethodAspect.class);

    @Pointcut("@annotation(secured)")
    public void callAt(Secured secured) {
    }

    @Around("callAt(secured)")
    public Object around(ProceedingJoinPoint pjp, Secured secured) throws Throwable {
        if (secured.isLocked()) {
            logger.info(pjp.getSignature().toLongString() + " is load time waving and locked");
            return null;
        } else {
            return pjp.proceed();
        }
    }
}
---
  public class SecuredMethod {
    private static final Logger logger = LoggerFactory.getLogger(SecuredMethod.class);

    @Secured(isLocked = true)
    public void lockedMethod() throws Exception {
        logger.info("no waving lockedMethod");
    }

    @Secured(isLocked = false)
    public void unlockedMethod() {
        logger.info("unlockedMethod");
    }
}
```

我们来测试一下加载时编织

```java
public class SecuredMethodUnitTest {

    @Test
    public void testMethod() throws Exception {
        SecuredMethod service = new SecuredMethod();
        service.unlockedMethod();
        service.lockedMethod();
    }
}
```

测试效果.通过日志可以看出运行时使用了类加载器加载了类并进行编织

```
[AppClassLoader@18b4aac2] info register aspect org.lyan.aspectj.SecuredMethodAspect
[AppClassLoader@18b4aac2] info register aspect org.lyan.aspectj.AccountDemoAspect
[AppClassLoader@18b4aac2] info processing reweavable type org.lyan.aspectj.SecuredMethodUnitTest: org\lyan\aspectj\SecuredMethodUnitTest.java
[AppClassLoader@18b4aac2] info successfully verified type org.lyan.aspectj.SecuredMethodAspect exists.  Originates from org\lyan\aspectj\SecuredMethodAspect.java
[AppClassLoader@18b4aac2] weaveinfo Join point 'method-call(void org.lyan.aspectj.SecuredMethod.unlockedMethod())' in Type 'org.lyan.aspectj.SecuredMethodUnitTest' (SecuredMethodUnitTest.java:18) advised by around advice from 'org.lyan.aspectj.SecuredMethodAspect' (SecuredMethodAspect.java)
[AppClassLoader@18b4aac2] weaveinfo Join point 'method-call(void org.lyan.aspectj.SecuredMethod.lockedMethod())' in Type 'org.lyan.aspectj.SecuredMethodUnitTest' (SecuredMethodUnitTest.java:19) advised by around advice from 'org.lyan.aspectj.SecuredMethodAspect' (SecuredMethodAspect.java)
[AppClassLoader@18b4aac2] info processing reweavable type org.lyan.aspectj.SecuredMethod: org\lyan\aspectj\SecuredMethod.java
[AppClassLoader@18b4aac2] info successfully verified type org.lyan.aspectj.SecuredMethodAspect exists.  Originates from org\lyan\aspectj\SecuredMethodAspect.java
[AppClassLoader@18b4aac2] weaveinfo Join point 'method-execution(void org.lyan.aspectj.SecuredMethod.lockedMethod())' in Type 'org.lyan.aspectj.SecuredMethod' (SecuredMethod.java:10) advised by around advice from 'org.lyan.aspectj.SecuredMethodAspect' (SecuredMethodAspect.java)
[AppClassLoader@18b4aac2] weaveinfo Join point 'method-execution(void org.lyan.aspectj.SecuredMethod.unlockedMethod())' in Type 'org.lyan.aspectj.SecuredMethod' (SecuredMethod.java:15) advised by around advice from 'org.lyan.aspectj.SecuredMethodAspect' (SecuredMethodAspect.java)
[AppClassLoader@18b4aac2] info processing reweavable type org.lyan.aspectj.SecuredMethodAspect: org\lyan\aspectj\SecuredMethodAspect.java
[AppClassLoader@18b4aac2] info successfully verified type org.lyan.aspectj.SecuredMethodAspect exists.  Originates from org\lyan\aspectj\SecuredMethodAspect.java
16:13:10.689 [main] INFO  org.lyan.aspectj.SecuredMethod - unlockedMethod
16:13:10.694 [main] INFO  org.lyan.aspectj.SecuredMethodAspect - public void org.lyan.aspectj.SecuredMethod.lockedMethod() is load time waving and locked
```

