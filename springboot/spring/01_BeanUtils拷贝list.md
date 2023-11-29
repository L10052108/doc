资料来源：<br/>
[BeanUtils 如何拷贝 List](https://blog.csdn.net/TIANTIAN_ZZ/article/details/103990378)<br/>

## 一、背景

我们在`DO`、`Model`、`VO`层数据间可能经常转换数据:

1. `Entity`对应的是持久层数据结构（一般是数据库表的映射模型）;
2. `Model` 对应的是业务层的数据结构;
3. `VO` 就是`Controller`和客户端交互的数据结构。

> 例如：数据库查询出来的用户信息(表的映射模型)是`UserDO`，但是我们需要传递给客户端的是`UserVO`,这时候就需要把`UserDO`实例的属性一个一个赋值到`UserVO`实例中。

**在这些数据结构之间很大一部分属性都可能会相同，也可能不同。**

## 二、数据拷贝

### 2.1、数据模型

- `UserDO.java`

```java
@Data
public class UserDO {

    private Long userId;
    private String userName;
    private Integer age;
    private Integer sex;
    public UserDO() {

    }

    public UserDO(Long userId, String userName, Integer age, Integer sex) {
        this.userId = userId;
        this.userName = userName;
        this.age = age;
        this.sex = sex;
    }
}
```

- `UserVO.java`

```java
@Data
public class UserVO {
    private Long userId;
    private String userName;
    private Integer age;
    private String sex;
}
```

**注意：** `UserDO.java` 和`UserVO.java` 最后一个字段`sex`类型不一样，分别是：`Integer`/`String`

### 2.2、常规使用-`BeanUtils`

`Spring` 提供了 `org.springframework.beans.BeanUtils` 类进行快速赋值。

例如：我们把数据库查询出来的`UserDO.java` 拷贝到 `UserVO.java`

```java
@Test
public void commonCopy() {
    UserDO userDO = new UserDO(1L, "Van", 18, 1);
    UserVO userVO = new UserVO();
    BeanUtils.copyProperties(userDO, userVO);
    log.info("userVO:{}",userVO);
}
```

日志打印：

```shell
.... userVO:UserVO(userId=1, userName=Van, age=18, sex=null)
```

通过打印结果我们可以发现：除了类型不同的`sex`，其他数值都成功拷贝。

### 2.3、集合拷贝

刚刚拷贝的是一个对象，但是有时候我们想拷贝一组`UerDO.java`，是一个集合的时候就不能这样直接赋值了。如果还按照这种逻辑，如下：

```java
@Test
public void listCopyFalse() {
    List<UserDO> userDOList = new ArrayList();
    userDOList.add(new UserDO(1L, "Van", 18, 1));
    userDOList.add(new UserDO(2L, "VanVan", 18, 2));
    List<UserVO> userVOList = new ArrayList();
    BeanUtils.copyProperties(userDOList, userVOList);
    log.info("userVOList:{}",userVOList);
}
```

日志打印如下：

```shell
.... userVOList:[]
```

通过日志可以发现，直接拷贝集合是无效的，那么怎么解决呢？

## 三、集合拷贝

### 3.1、暴力拷贝（不推荐）

> 将需要拷贝的集合遍历，暴力拷贝。

- 测试方式

```java
@Test
public void listCopyCommon() {
    List<UserDO> userDOList = new ArrayList();
    userDOList.add(new UserDO(1L, "Van", 18, 1));
    userDOList.add(new UserDO(2L, "VanVan", 20, 2));
    List<UserVO> userVOList = new ArrayList();
    userDOList.forEach(userDO ->{
        UserVO userVO = new UserVO();
        BeanUtils.copyProperties(userDO, userVO);
        userVOList.add(userVO);
    });
    log.info("userVOList:{}",userVOList);
}
```

- 拷贝结果

```shell
.... userVOList:[UserVO(userId=1, userName=Van, age=18, sex=null), UserVO(userId=2, userName=VanVan, age=20, sex=null)]
```

虽然该方式可以解决，但是一点都不优雅，特别是写起来麻烦。

### 3.2、优雅拷贝（**本文推荐**）

通过`JDK 8` 的函数式接口封装`org.springframework.beans.BeanUtils`

- 定义一个函数式接口

函数式接口里是可以包含默认方法，这里我们定义默认回调方法。

```java
@FunctionalInterface
public interface BeanCopyUtilCallBack <S, T> {

    /**
     * 定义默认回调方法
     * @param t
     * @param s
     */
    void callBack(S t, T s);
}
```

- 封装一个数据拷贝工具类 `BeanCopyUtil.java`

```java
public class BeanCopyUtil extends BeanUtils {

    /**
     * 集合数据的拷贝
     * @param sources: 数据源类
     * @param target: 目标类::new(eg: UserVO::new)
     * @return
     */
    public static <S, T> List<T> copyListProperties(List<S> sources, Supplier<T> target) {
        return copyListProperties(sources, target, null);
    }


    /**
     * 带回调函数的集合数据的拷贝（可自定义字段拷贝规则）
     * @param sources: 数据源类
     * @param target: 目标类::new(eg: UserVO::new)
     * @param callBack: 回调函数
     * @return
     */
    public static <S, T> List<T> copyListProperties(List<S> sources, Supplier<T> target, BeanCopyUtilCallBack<S, T> callBack) {
        List<T> list = new ArrayList<>(sources.size());
        for (S source : sources) {
            T t = target.get();
            copyProperties(source, t);
            list.add(t);
            if (callBack != null) {
                // 回调
                callBack.callBack(source, t);
            }
        }
        return list;
    }
}
```

- 简单拷贝测试

```java
@Test
public void listCopyUp() {
    List<UserDO> userDOList = new ArrayList();
    userDOList.add(new UserDO(1L, "Van", 18, 1));
    userDOList.add(new UserDO(2L, "VanVan", 20, 2));
    List<UserVO> userVOList = BeanCopyUtil.copyListProperties(userDOList, UserVO::new);
    log.info("userVOList:{}",userVOList);
}
```

打印结果：

```
.... userVOList:[UserVO(userId=1, userName=Van, age=18, sex=null), UserVO(userId=2, userName=VanVan, age=20, sex=null)]
```

通过如上方法，我们基本实现了集合的拷贝，但是从返回结果我们可以发现：**属性不同的字段无法拷贝**。所以，我们这里需要借助刚定义的回调方法实现自定义转换。

- 性别枚举类

```java
public enum SexEnum {
    UNKNOW("未设置",0),
    MEN("男生", 1),
    WOMAN("女生",2),

    ;
    private String desc;
    private int code;

    SexEnum(String desc, int code) {
        this.desc = desc;
        this.code = code;
    }

    public static SexEnum getDescByCode(int code) {
        SexEnum[] typeEnums = values();
        for (SexEnum value : typeEnums) {
            if (code == value.getCode()) {
                return value;
            }
        }
        return null;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }
}
```

- 带回调函数的拷贝

```Java
@Test
public void listCopyUpWithCallback() {
    List<UserDO> userDOList = new ArrayList();
    userDOList.add(new UserDO(1L, "Van", 18, 1));
    userDOList.add(new UserDO(2L, "VanVan", 20, 2));
    List<UserVO> userVOList = BeanCopyUtil.copyListProperties(userDOList, UserVO::new, (userDO, userVO) ->{
        // 这里可以定义特定的转换规则
        userVO.setSex(SexEnum.getDescByCode(userDO.getSex()).getDesc());
    });
    log.info("userVOList:{}",userVOList);
}
```

打印结果：

```shell
... userVOList:[UserVO(userId=1, userName=Van, age=18, sex=男生), UserVO(userId=2, userName=VanVan, age=20, sex=女生)]
```

通过打印结果可以发现，`UserDO.java` 中`Integer`类型的`sex`复制到`UserVO.java`成了`String`类型的男生/女生。

