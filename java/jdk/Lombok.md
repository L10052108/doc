https://www.toutiao.com/a6812598735315403268/?log_from=87b31d6de7c0c_1647510590102  

对于 Lombok 我相信大部分人都不陌生，但对于它的实现原理以及缺点却鲜为人知，而本文将会从 Lombok 的原理出发，手撸一个简易版的 Lombok，让你理解这个热门技术背后的执行原理，以及它的优缺点分析。

## 简介

在讲原理之前，我们先来复习一下 Lombok (老司机可直接跳过本段)。

Lombok 是一个非常热门的开源项目 (
https://github.com/rzwitserloot/lombok)，使用它可以有效的解决 Java 工程中那些繁琐又重复代码，例如 Setter、Getter、toString、equals、hashCode 以及非空判断等，都可以使用 Lombok 有效的解决。

## 使用

### 添加 Lombok 插件

在 IDE 中必须安装 Lombok 插件，才能正常调用被 Lombok 修饰的代码，以 Idea 为例，添加的步骤如下：

- 点击 File > Settings > Plugins 进入插件管理页面
- 点击 Browse repositories...
- 搜索 Lombok Plugin
- 点击 Install plugin 安装插件
- 重启 IntelliJ IDEA

安装完成，如下图所示：

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0e65dmb5vj210t0u076u.jpg)

### 添加 Lombok 库

接下来我们需要**在项目中添加最新的 Lombok 库**，如果是 Maven 项目，直接在 pom.xml 中添加如下配置：

```
<dependencies>
  <!-- https://mvnrepository.com/artifact/org.projectlombok/lombok -->
 <dependency>
  <groupId>org.projectlombok</groupId>
  <artifactId>lombok</artifactId>
  <version>1.18.12</version>
  <scope>provided</scope>
 </dependency>
</dependencies>
```

如果是 **JDK 9+** 可使用模块的方式添加，配置如下：

```
<annotationProcessorPaths>
 <path>
  <groupId>org.projectlombok</groupId>
  <artifactId>lombok</artifactId>
  <version>1.18.12</version>
 </path>
</annotationProcessorPaths>
```

###  使用 Lombok

接下来到了前半部分中最重要的 Lombok 使用环节了，我们先来看在没有使用 Lombok 之前的代码：

```
public class Person {
    private Integer id;
    private String name;
    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
}
```

这是使用 Lombok 之后的代码：

```
@Getter
@Setter
public class Person {
    private Integer id;
    private String name;
}
```

可以看出在 Lombok 之后，**用一个注解就搞定了之前所有 Getter/Setter 的代码，让代码瞬间优雅了很多**。

Lombok 所有注解如下：

- val：用在局部变量前面，相当于将变量声明为 final；
- @NonNull：给方法参数增加这个注解会自动在方法内对该参数进行是否为空的校验，如果为空，则抛出 NPE（NullPointerException）；
- @Cleanup：自动管理资源，用在局部变量之前，在当前变量范围内即将执行完毕退出之前会自动清理资源，自动生成 try-finally 这样的代码来关闭流；
- @Getter/@Setter：用在属性上，再也不用自己手写 setter 和 getter 方法了，还可以指定访问范围；
- @ToString：用在类上可以自动覆写 toString 方法，当然还可以加其他参数，例如 @ToString(exclude=”id”) 排除 id 属性，或者 @ToString(callSuper=true, includeFieldNames=true) 调用父类的 toString 方法，包含所有属性；
- @EqualsAndHashCode：用在类上自动生成 equals 方法和 hashCode 方法；
- @NoArgsConstructor, @RequiredArgsConstructor and @AllArgsConstructor：用在类上，自动生成无参构造和使用所有参数的构造函数以及把所有 @NonNull 属性作为参数的构造函数，如果指定 staticName="of" 参数，同时还会生成一个返回类对象的静态工厂方法，比使用构造函数方便很多；
- @Data：注解在类上，相当于同时使用了 @ToString、@EqualsAndHashCode、@Getter、@Setter 和 @RequiredArgsConstrutor 这些注解，对于 POJO 类十分有用；
- @Value：用在类上，是 @Data 的不可变形式，相当于为属性添加 final 声明，只提供 getter 方法，而不提供 setter 方法；
- @Builder：用在类、构造器、方法上，为你提供复杂的 builder APIs，让你可以像如下方式一样调用Person.builder().name("xxx").city("xxx").build()；
- @SneakyThrows：自动抛受检异常，而无需显式在方法上使用 throws 语句；
- @Synchronized：用在方法上，将方法声明为同步的，并自动加锁，而锁对象是一个私有的属性 LOCK，而 Java 中的 synchronized 关键字锁对象是 this，锁在 this 或者自己的类对象上存在副作用，就是你不能阻止非受控代码去锁 this 或者类对象，这可能会导致竞争条件或者其它线程错误；
- @Getter(lazy=true)：可以替代经典的 Double Check Lock 样板代码；
- @Log：根据不同的注解生成不同类型的 log 对象，但是实例名称都是 log，有六种可选实现类 @CommonsLog Creates log = org.apache.commons.logging.LogFactory.getLog(LogExample.class);@Log Creates log = java.util.logging.Logger.getLogger(LogExample.class.getName());@Log4j Creates log = org.apache.log4j.Logger.getLogger(LogExample.class);@Log4j2 Creates log = org.apache.logging.log4j.LogManager.getLogger(LogExample.class);@Slf4j Creates log = org.slf4j.LoggerFactory.getLogger(LogExample.class);@XSlf4j Creates log = org.slf4j.ext.XLoggerFactory.getXLogger(LogExample.class);

它们的具体使用如下：

### ① val 使用

```
val sets = new HashSet<String>();  
// 相当于
final Set<String> sets = new HashSet<>();
```

###  ② NonNull 使用

```
public void notNullExample(@NonNull String string) {
    string.length();
}
// 相当于
public void notNullExample(String string) {
    if (string != null) {
        string.length();
    } else {
        throw new NullPointerException("null");
    }
}

```

### ③ Cleanup 使用

```
public static void main(String[] args) {
    try {
        @Cleanup InputStream inputStream = new FileInputStream(args[0]);
    } catch (FileNotFoundException e) {
        e.printStackTrace();
    }
    // 相当于
    InputStream inputStream = null;
    try {
        inputStream = new FileInputStream(args[0]);
    } catch (FileNotFoundException e) {
        e.printStackTrace();
    } finally {
        if (inputStream != null) {
            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}

```

###  ④ Getter/Setter 使用

```
@Setter(AccessLevel.PUBLIC)
@Getter(AccessLevel.PROTECTED)
private int id;
private String shap;

```

###  ⑤ ToString 使用

```
@ToString(exclude = "id", callSuper = true, includeFieldNames = true)
public class LombokDemo {
    private int id;
    private String name;
    private int age;
    public static void main(String[] args) {
        // 输出 LombokDemo(super=LombokDemo@48524010, name=null, age=0)
        System.out.println(new LombokDemo());
    }
}
```

###  ⑥ EqualsAndHashCode 使用

```
@EqualsAndHashCode(exclude = {"id", "shape"}, callSuper = false)
public class LombokDemo {
    private int id;
    private String shap;
}

```

###  ⑦ NoArgsConstructor、RequiredArgsConstructor、AllArgsConstructor 使用

```
@NoArgsConstructor
@RequiredArgsConstructor(staticName = "of")
@AllArgsConstructor
public class LombokDemo {
    @NonNull
    private int id;
    @NonNull
    private String shap;
    private int age;
    public static void main(String[] args) {
        new LombokDemo(1, "Java");
        // 使用静态工厂方法
        LombokDemo.of(2, "Java");
        // 无参构造
        new LombokDemo();
        // 包含所有参数
        new LombokDemo(1, "Java", 2);
    }
}
```

###  ⑧ Builder 使用

```
@Builder
public class BuilderExample {
    private String name;
    private int age;
    @Singular
    private Set<String> occupations;
    public static void main(String[] args) {
        BuilderExample test = BuilderExample.builder().age(11).name("Java").build();
    }
}

```

###  ⑨ SneakyThrows 使用

```
public class ThrowsTest {
    @SneakyThrows()
    public void read() {
        InputStream inputStream = new FileInputStream("");
    }
    @SneakyThrows
    public void write() {
        throw new UnsupportedEncodingException();
    }
    // 相当于
    public void read() throws FileNotFoundException {
        InputStream inputStream = new FileInputStream("");
    }
    public void write() throws UnsupportedEncodingException {
        throw new UnsupportedEncodingException();
    }
}
```

###  ⑩ Synchronized 使用

```
public class SynchronizedDemo {
    @Synchronized
    public static void hello() {
        System.out.println("world");
    }
    // 相当于
    private static final Object $LOCK = new Object[0];
    public static void hello() {
        synchronized ($LOCK) {
            System.out.println("world");
        }
    }
}

```

###  ⑪ Getter(lazy = true) 使用

```
public class GetterLazyExample {
    @Getter(lazy = true)
    private final double[] cached = expensive();
    private double[] expensive() {
        double[] result = new double[1000000];
        for (int i = 0; i < result.length; i++) {
            result[i] = Math.asin(i);
        }
        return result;
    }
}
// 相当于
import java.util.concurrent.atomic.AtomicReference;
public class GetterLazyExample {
    private final AtomicReference<java.lang.Object> cached = new AtomicReference<>();
    public double[] getCached() {
        java.lang.Object value = this.cached.get();
        if (value == null) {
            synchronized (this.cached) {
                value = this.cached.get();
                if (value == null) {
                    final double[] actualValue = expensive();
                    value = actualValue == null ? this.cached : actualValue;
                    this.cached.set(value);
                }
            }
        }
        return (double[]) (value == this.cached ? null : value);
    }
    private double[] expensive() {
        double[] result = new double[1000000];
        for (int i = 0; i < result.length; i++) {
            result[i] = Math.asin(i);
        }
        return result;
    }
}

```

### 原理分析

我们知道 Java 的编译过程大致可以分为三个阶段：

1. 解析与填充符号表
2. 注解处理
3. 分析与字节码生成

编译过程如下图所示：

而 Lombok 正是利用「注解处理」这一步进行实现的，Lombok 使用的是 JDK 6 实现的 JSR 269: Pluggable Annotation Processing API (编译期的注解处理器) ，它是在编译期时把 Lombok 的注解代码，转换为常规的 Java 方法而实现优雅地编程的。

这一点可以在程序中得到验证，比如本文刚开始用 @Data 实现的代码：

在我们编译之后，查看 Person 类的编译源码发现，代码竟然是这样的：

可以看出 Person 类在编译期被注解翻译器修改成了常规的 Java 方法，添加 Getter、Setter、equals、hashCode 等方法。

Lombok 的执行流程如下：

可以看出，在编译期阶段，当 Java 源码被抽象成语法树 (AST) 之后，Lombok 会根据自己的注解处理器动态的修改 AST，增加新的代码 (节点)，在这一切执行之后，再通过分析生成了最终的字节码 (.class) 文件，这就是 Lombok 的执行原理。

### 手撸一个 Lombok

我们实现一个简易版的 Lombok 自定义一个 Getter 方法，我们的实现步骤是：

1. 自定义一个注解标签接口，并实现一个自定义的注解处理器；
2. 利用 tools.jar 的 javac api 处理 AST (抽象语法树)
3. 使用自定义的注解处理器编译代码。

这样就可以实现一个简易版的 Lombok 了。

### 1.定义自定义注解和注解处理器

首先创建一个 MyGetter.java 自定义一个注解，代码如下：

```
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.SOURCE) // 注解只在源码中保留
@Target(ElementType.TYPE) // 用于修饰类
public @interface MyGetter { // 定义 Getter

}
```

再实现一个自定义的注解处理器，代码如下：

```
import com.sun.source.tree.Tree;
import com.sun.tools.javac.api.JavacTrees;
import com.sun.tools.javac.code.Flags;
import com.sun.tools.javac.code.Type;
import com.sun.tools.javac.processing.JavacProcessingEnvironment;
import com.sun.tools.javac.tree.JCTree;
import com.sun.tools.javac.tree.TreeMaker;
import com.sun.tools.javac.tree.TreeTranslator;
import com.sun.tools.javac.util.*;

import javax.annotation.processing.*;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.TypeElement;
import javax.tools.Diagnostic;
import java.util.Set;

@SupportedSourceVersion(SourceVersion.RELEASE_8)
@SupportedAnnotationTypes("com.example.lombok.MyGetter")
public class MyGetterProcessor extends AbstractProcessor {

    private Messager messager; // 编译时期输入日志的
    private JavacTrees javacTrees; // 提供了待处理的抽象语法树
    private TreeMaker treeMaker; // 封装了创建AST节点的一些方法
    private Names names; // 提供了创建标识符的方法

    @Override
    public synchronized void init(ProcessingEnvironment processingEnv) {
        super.init(processingEnv);
        this.messager = processingEnv.getMessager();
        this.javacTrees = JavacTrees.instance(processingEnv);
        Context context = ((JavacProcessingEnvironment) processingEnv).getContext();
        this.treeMaker = TreeMaker.instance(context);
        this.names = Names.instance(context);
    }

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        Set<? extends Element> elementsAnnotatedWith = roundEnv.getElementsAnnotatedWith(MyGetter.class);
        elementsAnnotatedWith.forEach(e -> {
            JCTree tree = javacTrees.getTree(e);
            tree.accept(new TreeTranslator() {
                @Override
                public void visitClassDef(JCTree.JCClassDecl jcClassDecl) {
                    List<JCTree.JCVariableDecl> jcVariableDeclList = List.nil();
                    // 在抽象树中找出所有的变量
                    for (JCTree jcTree : jcClassDecl.defs) {
                        if (jcTree.getKind().equals(Tree.Kind.VARIABLE)) {
                            JCTree.JCVariableDecl jcVariableDecl = (JCTree.JCVariableDecl) jcTree;
                            jcVariableDeclList = jcVariableDeclList.append(jcVariableDecl);
                        }
                    }
                    // 对于变量进行生成方法的操作
                    jcVariableDeclList.forEach(jcVariableDecl -> {
                        messager.printMessage(Diagnostic.Kind.NOTE, jcVariableDecl.getName() + " has been processed");
                        jcClassDecl.defs = jcClassDecl.defs.prepend(makeGetterMethodDecl(jcVariableDecl));
                    });
                    super.visitClassDef(jcClassDecl);
                }
            });
        });
        return true;
    }

    private JCTree.JCMethodDecl makeGetterMethodDecl(JCTree.JCVariableDecl jcVariableDecl) {
        ListBuffer<JCTree.JCStatement> statements = new ListBuffer<>();
        // 生成表达式 例如 this.a = a;
        JCTree.JCExpressionStatement aThis = makeAssignment(treeMaker.Select(treeMaker.Ident(
                names.fromString("this")), jcVariableDecl.getName()), treeMaker.Ident(jcVariableDecl.getName()));
        statements.append(aThis);
        JCTree.JCBlock block = treeMaker.Block(0, statements.toList());

        // 生成入参
        JCTree.JCVariableDecl param = treeMaker.VarDef(treeMaker.Modifiers(Flags.PARAMETER),
                jcVariableDecl.getName(), jcVariableDecl.vartype, null);
        List<JCTree.JCVariableDecl> parameters = List.of(param);

        // 生成返回对象
        JCTree.JCExpression methodType = treeMaker.Type(new Type.JCVoidType());
        return treeMaker.MethodDef(treeMaker.Modifiers(Flags.PUBLIC),
                getNewMethodName(jcVariableDecl.getName()), methodType, List.nil(),
                parameters, List.nil(), block, null);

    }

    private Name getNewMethodName(Name name) {
        String s = name.toString();
        return names.fromString("get" + s.substring(0, 1).toUpperCase() + s.substring(1, name.length()));
    }

    private JCTree.JCExpressionStatement makeAssignment(JCTree.JCExpression lhs, JCTree.JCExpression rhs) {
        return treeMaker.Exec(
                treeMaker.Assign(
                        lhs,
                        rhs
                )
        );
    }
}
```

自定义的注解处理器是我们实现简易版的 Lombok 的重中之重，我们需要继承 AbstractProcessor 类，重写它的 init() 和 process() 方法，在 process() 方法中我们先查询所有的变量，在给变量添加对应的方法。我们使用 TreeMaker 对象和 Names 来处理 AST，如上代码所示。

当这些代码写好之后，我们就可以新增一个 Person 类来试一下我们自定义的 @MyGetter 功能了，代码如下：

```
@MyGetter
public class Person {
    private String name;
}
```

## 使用自定义的注解处理器编译代码

上面的所有流程执行完成之后，我们就可以编译代码测试效果了。 首先，我们先进入代码的根目录，执行以下三条命令。

进入的根目录如下：

**① 使用 tools.jar 编译自定义的注解器**

> javac -cp $JAVA_HOME/lib/tools.jar MyGetter* -d .

注意：命令最后面有一个“.”表示当前文件夹。

**② 使用自定义注解器，编译 Person 类**

> javac -processor com.example.lombok.MyGetterProcessor Person.java

**③ 查看 Person 源码**

> javap -p Person.class

源码文件如下：

**可以看到我们自定义的 getName() 方法已经成功生成了**，到这里简易版的 Lombok 就大功告成了。

## Lombok 优缺点

Lombok 的优点很明显，它可以让我们写更少的代码，节约了开发时间，并且让代码看起来更优雅，它的缺点有以下几个。

###  缺点1： 降低了可调试性

Lombok 会帮我们自动生成很多代码，但这些代码是在编译期生成的，因此在开发和调试阶段这些代码可能是“丢失的”，这就给调试代码带来了很大的不便。

###  缺点2：可能会有兼容性问题

Lombok 对于代码有很强的侵入性，加上现在 JDK 版本升级比较快，每半年发布一个版本，而 Lombok 又属于第三方项目，并且由开源团队维护，因此就没有办法保证版本的兼容性和迭代的速度，进而可能会产生版本不兼容的情况。

###  缺点3：可能会坑到队友

尤其对于组人来的新人可能影响更大，假如这个之前没用过 Lombok，当他把代码拉下来之后，因为没有安装 Lombok 的插件，在编译项目时，就会提示找不到方法等错误信息，导致项目编译失败，进而影响了团结成员之间的协作。

### 缺点4：破坏了封装性

面向对象封装的定义是：通过访问权限控制，隐藏内部数据，外部仅能通过类提供的有限的接口访问和修改内部数据。

也就是说，我们不应该无脑的使用 Lombok 对外暴露所有字段的 Getter/Setter 方法，因为有些字段在某些情况下是不允许直接修改的，比如购物车中的商品数量，它直接影响了购物详情和总价，因此在修改的时候应该提供统一的方法，进行关联修改，而不是给每个字段添加访问和修改的方法。

## 总结

本文我们介绍了 Lombok 的使用以及执行原理，它是通过 JDK 6 实现的 JSR 269: Pluggable Annotation Processing API (编译期的注解处理器) ，在编译期时把 Lombok 的注解转换为 Java 的常规方法的，我们可以通过继承 AbstractProcessor 类，重写它的 init() 和 process() 方法，实现一个简易版的 Lombok。但同时 Lombok 也存在这一些使用上的缺点，比如：降低了可调试性、可能会有兼容性等问题，因此我们在使用时要根据自己的业务场景和实际情况，来选择要不要使用 Lombok，以及应该如何使用 Lombok。

最后提醒一句，再好的技术也不是万金油，就好像再好的鞋子也得适合自己的脚才行！

> 感谢阅读，希望本文对你能所启发。觉得不错的话，分享给需要的朋友，谢谢