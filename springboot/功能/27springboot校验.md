资料来源：<br/>
[必须拿下的Springboot参数校验](https://www.toutiao.com/article/7229238286496121399/?app=news_article&timestamp=1686868537&use_new_style=1&req_id=202306160635376F107725F128F42DB912&group_id=7229238286496121399&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=d55e3b9d-5bfc-4ac0-87c2-f5820e0f3738&source=m_redirect)

## Springboot参数校验

实际项目中不仅仅前端需要做必填项等校验，为防止非法参数对业务造成影响，后端也需要对相关参数做校验，接下来就学习一下在Springboot项目中如何对参数进行校验。**本文Springboot版本为2.6.8**

# 引入依赖

如果Springboot版本小于2.3.x，spring-boot-starter-web会自动传入hibernate-validator依赖。如果Springboot版本大于2.3.x，则需要手动引入依赖： **温馨提示：7.x.x版本可能会不起效**

```xml
<!-- https://mvnrepository.com/artifact/org.hibernate/hibernate-validator -->
<dependency>
    <groupId>org.hibernate</groupId>
    <artifactId>hibernate-validator</artifactId>
    <version>6.2.0.Final</version>
</dependency>
复制代码
```

或者直接引入springboot的场景启动器

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
            <version>2.7.0</version>
        </dependency>
复制代码
```

# @Validated和@Valid区别

**@Validated**对**@Valid**进行了二次封装，但是二者有以下的区别：

- **@Validated**提供分组功能，可以在参数验证时，根据不同的分组采用不同的验证机制。**@Valid**没有分组功能
- **@Validated**用在类型、方法和方法参数上。但不能用于成员属性（field），**@Valid**可以用在方法、构造函数、方法参数和成员属性（field）上
- 一个待验证的pojo类，其中还包含了待验证的对象属性，需要在待验证对象上注解**@Valid**，才能验证待验证对象中的成员属性，这里不能使用**@Validated**

# 统一异常处理

如果校验不通过会报**
MethodArgumentNotValidException或者****
ConstraintViolationException**

```java
@RestControllerAdvice
public class ParamException {

    @ExceptionHandler({MethodArgumentNotValidException.class})
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ResultReturn handleMethodArgumentNotValidException(MethodArgumentNotValidException ex) {
        BindingResult bindingResult = ex.getBindingResult();
        StringBuilder sb = new StringBuilder("校验失败:");
        for (FieldError fieldError : bindingResult.getFieldErrors()) {
            sb.append(fieldError.getField()).append("：").append(fieldError.getDefaultMessage()).append(", ");
        }
        String msg = sb.toString();
        return ResultReturnUtil.fail(ErrorCodeEnum.PARAM_ERROR.getCode(),msg);
    }

    @ExceptionHandler({ConstraintViolationException.class})
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ResultReturn handleConstraintViolationException(ConstraintViolationException ex) {
        return ResultReturnUtil.fail(ErrorCodeEnum.PARAM_ERROR.getCode(),ex.getMessage());
    }
}
复制代码
```

我们可以把要返回的错误信息定义在枚举中

```java
@Getter
@ToString
public enum ErrorCodeEnum {

    PARAM_ERROR(10001,"参数错误");

    private Integer code;

    private String msg;

    ErrorCodeEnum(Integer code, String msg) {
        this.code = code;
        this.msg = msg;
    }
}
复制代码
```

再来个统一返回格式

```java
@Data
public class ResultReturn implements Serializable {

    private static final long serialVersionUID = 5805792987639183304L;
    private Integer code;

    private String msg;

    private Object data;

    public ResultReturn(){
        super();
    }

    public ResultReturn(Integer code, String msg){
        this.code = code;
        this.msg = msg;
    }

    public ResultReturn(Integer code, String msg, Object data){
        this.code = code;
        this.msg = msg;
        this.data = data;
    }
}
复制代码
public class ResultReturnUtil {

    /**
     * 成功 返回默认码值
     * @param msg
     * @return
     */
    public static ResultReturn success(String msg){
        return new ResultReturn(0,msg);
    }

    /**
     * 成功  返回自定义码值
     * @param code
     * @param msg
     * @return
     */
    public static ResultReturn success(Integer code, String msg){
        return new ResultReturn(code,msg);
    }

    public static ResultReturn success(String msg, Object data){
        return  new ResultReturn(0,msg,data);
    }

    public static ResultReturn fail(String msg){
        return new ResultReturn(-1,msg);
    }

    public static ResultReturn fail(Integer code, String msg){
        return new ResultReturn(code,msg);
    }
}
复制代码
```

# RequestBody参数校验

当我们使用POST、PUT请求时会使用 @RequestBody+实体类 来接收参数。此时只需要给实体类加上**@Validated**注解就能实现自动参数校验。

```java
@RestController
public class TestController {

    @PostMapping("/addUser")
    public Boolean addUser(@RequestBody @Validated User user){
        //忽略service处理相关业务
        return true;
    }
}
复制代码
```

那么具体到每个参数的校验则需要在实体类中处理。

```java
@Data
public class User {

    private Long id;

    @NotBlank(message = "用户账号不能为空")
    @Length(min = 4, max = 10,message = "账号长度为4-10位")
    private String userName;

    @NotBlank(message = "密码不能为空")
    @Length(min = 6,max = 12,message = "密码长度为6-12位")
    private String password;

    @NotNull(message = "邮箱不能为空")
    @Email(message = "邮箱格式错误")
    private String email;
    /**
     * 性别 1为男生  2为女生
     */
    @Min(value = 1,message = "最小值为1")
    @Max(value = 2,message = "最大值为2")
    private Integer sex;

}
复制代码
```

先请求一次试试

![img](img\ac3e073f0a4a41afa696f0e4dfb3ebfe~noop.image)



![img](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/19a7907f9afe4113a3b7c6883c7690c6~noop.image?_iz=58558&from=article.pc_detail&x-expires=1687486342&x-signature=EGb2bf43kgO2mw1xB24Vol0R8Mc%3D)



# requestParam/PathVariable参数校验

这种方式下参数都较少，必须在Controller类上标注**@Validated**注解，并在入参上声明约束注解

![img](img\509eff33c1bc48e8b8a3f3b543f04194~noop.image)



![img](img\9f6066cebe4142dba48ca66066c380d5~noop.image)



接下来请求试一下

![img](img\b3387f61e90445a6b039759fd0434474~noop.image)





![img](https://p3-sign.toutiaoimg.com/tos-cn-i-qvj2lq49k0/ba7fb2eb517a408e8c93c5b464eb3a10~noop.image?_iz=58558&from=article.pc_detail&x-expires=1687486342&x-signature=N5SfdvUM9r8aucKhs5Wuh2QPNWc%3D)



# 特殊情况

也是上文提到的，pojo参数中有对象属性，那么要对这个对象中的属性校验该怎么做？

比如我这里有个学生类

```
@Data
public class Student {
    @NotBlank(message = "用户名不能为空")
    private String name;
    @Min(value = 10, message = "年龄不能小于10岁")
    private Integer age;

    @Email(message = "邮箱格式错误")
    private String email;

    @NotBlank(message = "班级名不能为空")
    private String className;

    @NotEmpty(message = "任课老师不能为空")
    @Size(min = 1, message = "至少有一个老师")
    private List<Teacher> teachers;
}
复制代码
@Data
public class Teacher {
    @NotBlank(message = "老师姓名不能为空")
    private String teacherName;
    @Min(value = 1, message = "学科类型从1开始计算")
    private Integer type;
}
复制代码
```

测试一下

![img](img\568e08cfa04e4fc6afbc53983a685b28~noop.image)





![img](img\cba6e67678b54e85975aa243b296bf51~noop.image)



很明显这个type的值并不符合要求， 需要在学生类的教师属性上加上**@Valid**注解

![img](img\cc2260d0010b4d568b627af1da5cd568~noop.image)





![img](img\8e80f4f6371946c0a8a87978b8ae4665~noop.image)



<!-- ![img](img\a71e4f7f1db04f5e90cd82c41409ccad~noop.image) -->



# 参数校验注解大全

| 注解             | 作用类型                                              | 解释                                                         | null是否能通过验证 |
| ---------------- | ----------------------------------------------------- | ------------------------------------------------------------ | ------------------ |
| @AssertFalse     | Boolean、boolean                                      | 该字段值为false时，验证才能通过                              | YES                |
| @AssertTrue      | Boolean、boolean                                      | 该字段值为true时，验证才能通过                               | YES                |
| @DecimalMax      | 数字类型（原子和包装）                                | 验证小数的最大值`@DecimalMax(value = "12.35") private double money;` | YES                |
| @DecimalMin      | 数字类型（原子和包装）                                | 验证小数的最小值                                             | YES                |
| @Digits          | 数字类型（原子和包装）                                | 验证数字的整数位和小数位的位数是否超过指定的长度`@Digits(integer = 2, fraction = 2) private double money;` | YES                |
| @Email           | String                                                | 该字段为Email格式，才能通过                                  | YES                |
| @Future          | 时期、时间                                            | 验证日期是否在当前时间之后，否则无法通过校验`@Future private Date date;` | YES                |
| @FutureOrPresent | 时期、时间                                            | 时间在当前时间之后 或者等于此时                              | YES                |
| @Max             | 数字类型（原子和包装）                                | `//该字段的最大值为18，否则无法通过验证 @Max(value = 18) private Integer age;` | YES                |
| @Min             | 数字类型（原子和包装）                                | 同上，不能低于某个值否则无法通过验证                         | YES                |
| @Negative        |                                                       | 数字<0                                                       | YES                |
| @NegativeOrZero  |                                                       | 数字=<0                                                      | YES                |
| @NotBlank        | String 该注解用来判断字符串或者字符，只用在String上面 | 字符串不能为null,字符串trim()后也不能等于“”                  | NO                 |
| @NotEmpty        | String、集合、数组、Map、链表List                     | 不能为null，不能是空字符，集合、数组、map等size()不能为0；字符串trim()后可以等于“” | NO                 |
| @NotNull         | 任何类型                                              | 使用该注解的字段的值不能为null，否则验证无法通过             | NO                 |
| @Null            |                                                       | 修饰的字段在验证时必须是null，否则验证无法通过               | YES                |
| @Past            | 时间、日期                                            | 验证日期是否在当前时间之前，否则无法通过校验,必须是一个过去的时间或日期 | YES                |
| @PastOrPresent   | 时间、日期                                            | 验证日期是否在当前时间之前或等于当前时间                     | YES                |
| @Pattern         |                                                       | 用于验证字段是否与给定的正则相匹配`@Pattern(regexp = "正则") private String name;` | YES                |
| @Positive        |                                                       | 数字>0                                                       | YES                |
| @PositiveOrZero  |                                                       | 数字>=0                                                      | YES                |
| @Size            | 字符串String、集合Set、数组Array、Map，List           | 修饰的字段长度不能超过5或者低于1@Size(min = 1, max = 5)private String name;集合、数组、map等的size()值必须在指定范围内//只能一个@Size(min = 1, max = 1)private List<String> names; | YES                |