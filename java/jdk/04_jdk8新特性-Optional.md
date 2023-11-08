资料来源：<br/>
[jdk8新特性-Optional](https://blog.csdn.net/xiao_yu_gan/article/details/125661440)



### 介绍
什么是`Optional`：`Optional`是`jdk8`推出的一个新类，为了减少代码中的判空代码，使代码更加干净整洁优雅，不提高执行效率。

使用场景：当一个对象需要进行判空代码处理的时候，就可以考虑使用`Optional`。

`Optional`类作用：可以将`Optional`理解为一个容器类，其内部仅能存放一个对象元素，`Optional`提供了一系列的工具方法进行判断、操作存放的元素。



###  使用语法

| 方法声明                                                | 介绍                                                         |
| ------------------------------------------------------- | :----------------------------------------------------------- |
| Optional empty();                                       | 创建一个空的Optional对象。                                   |
| Optional of(T value);                                   | 使用一个非空的值创建Optional对象，传入null将抛出异常。       |
| Optional ofNullable(T value);                           | 使用任意值创建Optional对象，若值为null，则创建一个空的Optional对象。 |
| T get();                                                | 返回Optional对象中的值，若为null，则抛出异常。               |
| boolean isPresent()；                                   | 若Optional对象中的值不为null，则返回true，否则返回false。    |
| void ifPresent(Consumer<? super T> consumer);           | 若Optional对象中的值不为null，则执行Consumer对象，否则不执行。 |
| Optional filter(Predicate<? super T> predicate);        | 执行Predicate对象，执行结果返回true，返回Optional对象中的值 执行结果返回false或Optional对象中的值为空都返回空的Optional对象。 |
| Optional map(Function<? super T, ? extends U> mapper);  | 执行Function对象，Function的入参为Optional对象中的值，返回值将被包装成Optional返回。<br/>若原本Optional中的值为null，则直接返回空的Optional对象。 |
| Optional flatMap(Function<? super T, Optional> mapper); | 功能和map方法一样，差别在于执行的Function对象需要返回Optional对象，否则抛出异常，返回对象为null也将抛出异常。 |
| T orElse(T other);                                      | 若Optional对象中有值，则将值返回，否则返回给定值other值。    |
| T orElseGet(Supplier<? extends T> other);               | 若Optional对象中有值，则将值返回，否则将执行Supplier对象并返回执行结果。 |
| T orElseThrow(Supplier<? extends X> exceptionSupplier); | 若Optional对象中有值，则将值返回，否则将执行Supplier对象并将返回值作为异常抛出。 |



3、语法演示

**初始化**

```java
public class Demo {

    public static void main(String[] args) {

        //创建空的Optional
        Optional<Object> emptyOptional = Optional.empty();

        //使用of创建
        Optional<String> hello = Optional.of("hello");//正常
        Optional<Object> objectOptional = Optional.of(null);//运行时抛出异常

        //使用ofNullable创建
        Optional<String> hello2 = Optional.ofNullable("hello");//正常
        Optional<Object> objectOptional2 = Optional.ofNullable(null);//正常
    }

}
```

**获取Optional中的对象**

- get

```java
public class Demo {

    public static void main(String[] args) {

        Optional<String> helloOptional = Optional.ofNullable("hello");
        Optional<String> nullOptional = Optional.ofNullable(null);

        //使用get获取Optional中的对象
        System.out.println(helloOptional.get());
        /**
         * 运行结果：
         * hello
         */


        System.out.println(nullOptional.get());
        /**
         * 运行结果：
         * 抛出运行时异常 java.util.NoSuchElementException
         */

    }

}
```

- orElse

```java
public class Demo {

    public static void main(String[] args) {

        Optional<String> helloOptional = Optional.ofNullable("hello");
        Optional<String> nullOptional = Optional.ofNullable(null);

        //执行orElse
        String result1 = helloOptional.orElse("val is null");
        System.out.println(result1);
        /**
         * 运行结果：
         * hello
         */

        String result2 = nullOptional.orElse("val is null");
        System.out.println(result2);
        /**
         * 运行结果：
         * val is null
         */
    }
}
```

- orElseGet

```java
public class Demo {

    public static void main(String[] args) {

        Optional<String> helloOptional = Optional.ofNullable("hello");
        Optional<String> nullOptional = Optional.ofNullable(null);

        //执行orElse
        String result1 = helloOptional.orElseGet(()->{
                return "val is null";
        });
        System.out.println(result1);
        /**
         * 运行结果：
         * hello
         */

        String result2 = nullOptional.orElseGet(()->{
            return "val is null";
        });
        System.out.println(result2);
        /**
         * 运行结果：
         * val is null
         */
    }
}
```

**判断Optional中的值**

```java
public class Demo {

    public static void main(String[] args) {

        Optional<String> helloOptional = Optional.ofNullable("hello");
        Optional<String> nullOptional = Optional.ofNullable(null);

        //使用isPresent判断Optional中的值是否为null
        System.out.println(helloOptional.isPresent());
        /**
         * 运行结果：
         * true
         */

        System.out.println(nullOptional.isPresent());
        /**
         * 运行结果：
         * false
         */

    }
}
```

- ifPresent(Consumer<? super T> consumer)

```java
public class Demo {

    public static void main(String[] args) {
        Optional<String> helloOptional = Optional.ofNullable("hello");
        Optional<String> nullOptional = Optional.ofNullable(null);

        //执行ifPresent(Consumer<? super T> consumer)方法
        helloOptional.ifPresent(str->{
            System.out.println("Optional中的值："+str);
        });
        /**
         * 运行结果：
         * Optional中的值：hello
         */


        nullOptional.ifPresent(str->{
            System.out.println("Optional中的值："+str);
        });
        /**
         * 运行结果：
         * 因nullOptional中的对象为null，所以不执行Consumer对象
         */
    }

}

```

- filter

```java
public class Demo {

    public static void main(String[] args) {
        Optional<String> helloOptional = Optional.ofNullable("hello");
        Optional<String> nullOptional = Optional.ofNullable(null);

        //执行filter方法
        Optional<String> result1 = helloOptional.filter(str -> {
            if ("hello world".equals(str)) {
                return true;
            }
            return false;
        });
        System.out.println(result1.get());
        /**
         * 运行结果：
         * 返回空的Optional对象，执行get抛出运行时异常 java.util.NoSuchElementException
         */

        Optional<String> result2 = helloOptional.filter(str -> {
            if ("hello".equals(str)) {
                return true;
            }
            return false;
        });
        System.out.println(result2.get());
        /**
         * 运行结果：
         * hello
         */

        Optional<String> result3 = nullOptional.filter(str -> {
            return true;
        });
        System.out.println(result3.get());
        /**
         * 运行结果：
         * 因为nullOptional中的对象为null，所以不执行Predicate对象，直接返回空的Optional对象
         * 执行get抛出运行时异常 java.util.NoSuchElementException
         */

    }

}
```

- map

```java
public class Demo {

    public static void main(String[] args) {

        Optional<String> helloOptional = Optional.ofNullable("hello");
        Optional<String> nullOptional = Optional.ofNullable(null);

        //执行map方法
        Optional<String> result1 = helloOptional.map(str -> {
            if ("hello world".equals(str)) {
                return "你好世界";
            }
            return "unknown";
        });
        System.out.println(result1.get());
        /**
         * 运行结果：
         * unknown
         */

        Optional<String> result2 = nullOptional.map(str -> {
            return "你好世界";
        });
        System.out.println(result2.get());
        /**
         * 运行结果：
         * 因nullOptional中的值为null，则map方法直接返回空的Optional对象
         * 执行get抛出运行时异常 java.util.NoSuchElementException
         */
    }

}
```

- flatMap

```java
public class Demo {

    public static void main(String[] args) {

        Optional<String> helloOptional = Optional.ofNullable("hello");
        Optional<String> nullOptional = Optional.ofNullable(null);

        //执行flatMap方法
        helloOptional.flatMap(str -> {
            return "unknown";
        });
        /**
         * 运行结果：
         * 编译阶段报错，因flatMap的Function对象需要返回一个Optional对象。
         */
        
        Optional<String> unknown = helloOptional.flatMap(str -> {
            return Optional.ofNullable("unknown");
        });
        System.out.println(unknown.get());
        /**
         * 运行结果：
         * unknown
         */
    }

}

```

### 使用案例

```java
class Person{
    private String name;
    private int age;
    private EduBack eduBack;

    //省略getter、setter
}

class EduBack{
    private College college;
    private HighSchool highSchool;

    //省略getter、setter
}

class College{
    private String name;

    //省略getter、setter
}

class HighSchool{
    private String name;

    //省略getter、setter
}


public class Demo {

    /**
     * 传统方式获取高校名称
     * @param person
     * @return
     */
    public String getCollege(Person person){
        if(person==null){
            return null;
        }
        if(person.getEduBack()==null){
            return null;
        }
        if(person.getEduBack().getCollege()==null){
            return null;
        }
        return person.getEduBack().getCollege().getName();
    }

    /**
     * 使用Optional方式获取高中名称
     * @param person
     * @return
     */
    public String getHighSchool(Person person) {
        String highSchoolName = Optional.ofNullable(person)
                .map(p -> p.getEduBack())
                .map(edu -> edu.getHighSchool())
                .map(h -> h.getName())
                .orElse(null);
        return highSchoolName;
    }

    /**
     * 使用Optional方式获取高中名称(使用方法引用优化lambda)
     * @param person
     * @return
     */
    public String getHighSchoolQuot(Person person){
        String highSchoolName = Optional.ofNullable(person)
                .map(Person::getEduBack)
                .map(EduBack::getHighSchool)
                .map(HighSchool::getName)
                .orElse(null);

        return highSchoolName;
    }

    public static void main(String[] args) {
        HighSchool highSchool = new HighSchool();
        highSchool.setName("高中学校");

        College college = new College();
        college.setName("高校学校");

        EduBack eduBack = new EduBack();
        eduBack.setCollege(college);
        eduBack.setHighSchool(highSchool);

        Person person = new Person();
        person.setName("张三");
        person.setEduBack(eduBack);

        Demo demo = new Demo();
        System.out.println(demo.getCollege(person));

        System.out.println(demo.getHighSchool(person));
        System.out.println(demo.getHighSchoolQuot(person));
    }
}

```

### 实现原理

```java
//jdk8中Optional类部分源码
public final class Optional<T> {
    /**
     * Common instance for {@code empty()}.
     */
    private static final Optional<?> EMPTY = new Optional<>();

    /**
     * If non-null, the value; if null, indicates no value is present
     * Optional类中的value变量，实际就是Optional容器中存放的值，其它所有的方法都是围绕此变量操作。
     */
    private final T value;

    //empty方法初始化一个空的Optional对象，最终就是调用此方法，将value变量设为null。
    private Optional() {
        this.value = null;
    }
    
    private Optional(T value) {
        this.value = Objects.requireNonNull(value);
    }

    public static<T> Optional<T> empty() {
        @SuppressWarnings("unchecked")
        Optional<T> t = (Optional<T>) EMPTY;
        return t;
    }

    public static <T> Optional<T> of(T value) {
        return new Optional<>(value);
    }
    
    public static <T> Optional<T> ofNullable(T value) {
        return value == null ? empty() : of(value);
    }
    
    //value变量为null，直接抛出异常，否则直接返回value变量值。
    public T get() {
        if (value == null) {
            throw new NoSuchElementException("No value present");
        }
        return value;
    }
}    

```

