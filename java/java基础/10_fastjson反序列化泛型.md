资料来源：<br/>
[fastjson反序列化多层嵌套泛型类与java中的Type类型](https://www.cnblogs.com/liqipeng/p/9148545.html)


## fastjson反序列化泛型

在使用springmvc时，我们通常会定义类似这样的通用类与前端进行交互，以便于前端可以做一些统一的处理：

```csharp
public class Result<T> {
    private int ret;
    private String msg;
    private T data;
    // 此处省略getter和setter方法
}
```

这样的类序列化为json后，js反序列化处理起来毫无压力。但是如果rest接口的消费端就是java呢，java泛型的类型擦除却容易引入一些障碍。

### 一个反序列化的迭代

先定义一个类，后面的例子会用到：

```typescript
public class Item {
    private String name;
    private String value;
    // 此处省略getter和setter方法
}
```

JSON数据：

```json
{
	"data":{
		"name":"username",
		"value":"root"
	},
	"msg":"Success",
	"ret":0
}
```

当拿到上面的数据时，我们想到其对应的类型是`Result<Item>`，所以得想办法将这个json数据反序列化为这个类型才行。

#### v1

`JSONObject.parseObject(json, Result<Item>.class);`，编译器就报错了`Cannot select parameterized type`。

#### v2

`JSONObject.parseObject(json, Result.class);`，执行没问题。但是没有Item类型信息，fastjson不可能跟你心有灵犀一点通知道该把data转为Item类型，`result.getData().getClass()`结果是`com.alibaba.fastjson.JSONObject`，也算是个妥善处理吧。

#### v3

找了一下前人的经验，使用TypeReference来处理，`JSONObject.parseObject(json, new TypeReference<Result<Item>>(){});`，终于“完美”解决！

#### v4

有了v3的经验，以为找到了通用处理的捷径，遂封装了一个处理这种类型的工具方法：

```typescript
private static <T> Result<T> parseResultV1(String json) {
    return JSONObject.parseObject(json, new TypeReference<Result<T>>() {
    });
}
```

并且把采用v3的地方改用了此parseResult方法：

```sql
Result<Item> result = parseResultV1(json);
```

以为万事大吉，连测都没测试就把代码提交了。测都不测试，当然难以有好结果了：

```csharp
System.out.println(result.getData());
// java.lang.ClassCastException: com.alibaba.fastjson.JSONObject cannot be cast to Item
```

很显然parseResultV1把Item的类型信息丢掉了。

```json
{
	"data":"Hello,world!",
	"msg":"Success",
	"ret":0
}
```

试了一下Result形式的，parseResultV1可以成功将其反序列化。推测（没有看fastjson具体实现）是fastjson刚好检测到data字段就是String类型，并将其赋值到data字段上了。仔细看parseObject并没有报错，而是在getData()时报错的，联系到java的泛型擦除，我们在用getData()，应该把data当作Object类型这么看：

```haskell
String data = (String)result.getData();
System.out.println(data);
```

#### v5

原来TypeReference的构造器是可以传入参数的，

```typescript
private static <T> Result<T> parseResultV2(String json, Class<T> clazz) {
    return JSONObject.parseObject(json, new TypeReference<Result<T>>(clazz) {
    });
}
```

这个可以真的可以完美反序列化`Result<Item>`了。

#### v6

后来发现parseResultV2无法处理类似`Result<List<T>>`，原来TypeReference无法处理嵌套的泛型（这里指的是类型参数未确定，而不是类似`Result<List<Item>>`类型参数已经确定）。借用[Fastjson解析多级泛型的几种方式—使用class文件来解析多级泛型](https://www.cnblogs.com/itar/p/7427971.html)里的方法，新增加一个专门处理List类型的方法：

```typescript
private static <T> Result<List<T>> parseListResult(String json, Class<T> clazz) {
    return JSONObject.parseObject(json, buildType(Result.class, List.class, Item.class));
}

private static Type buildType(Type... types) {
    ParameterizedTypeImpl beforeType = null;
    if (types != null && types.length > 0) {
        for (int i = types.length - 1; i > 0; i--) {
            beforeType = new ParameterizedTypeImpl(new Type[]{beforeType == null ? types[i] : beforeType}, null, types[i - 1]);
        }
    }
    return beforeType;
}
```

或者根据这里只有两层，简单如下：

```typescript
private static <T> Result<List<T>> parseListResult(String json, Class<T> clazz) {
    ParameterizedTypeImpl inner = new ParameterizedTypeImpl(new Type[]{clazz}, null, List.class);
    ParameterizedTypeImpl outer = new ParameterizedTypeImpl(new Type[]{inner}, null, Result.class);
    return JSONObject.parseObject(json, outer);
}
```

#### v7

todo: 上面两个方法已经可以满足现有需要，有时间再看看能否将两个方法统一为一个。

### com.alibaba.fastjson.TypeReference

看看TypeReference的源码：

```dart
protected TypeReference(Type... actualTypeArguments) {
    Class<?> thisClass = this.getClass();
    Type superClass = thisClass.getGenericSuperclass();
    ParameterizedType argType = (ParameterizedType)((ParameterizedType)superClass).getActualTypeArguments()[0];
    Type rawType = argType.getRawType();
    Type[] argTypes = argType.getActualTypeArguments();
    int actualIndex = 0;

    for(int i = 0; i < argTypes.length; ++i) {
        if (argTypes[i] instanceof TypeVariable) {
            argTypes[i] = actualTypeArguments[actualIndex++];
            if (actualIndex >= actualTypeArguments.length) {
                break;
            }
        }
    }

    Type key = new ParameterizedTypeImpl(argTypes, thisClass, rawType);
    Type cachedType = (Type)classTypeCache.get(key);
    if (cachedType == null) {
        classTypeCache.putIfAbsent(key, key);
        cachedType = (Type)classTypeCache.get(key);
    }

    this.type = cachedType;
}
```

实际上它首先获取到了泛型的类型参数argTypes，然后遍历这些类型参数，如果遇到是`TypeVariable`类型的则用构造函数传入的Type将其替换，然后此处理后的argTypes基于ParameterizedTypeImpl构造出一个新的Type，这样的新的Type就可以具备我们期待的Type的各个泛型类型参数的信息了。所以fastjson就能够符合我们期望地反序列化出了`Result<Item>`。

正是由于这个处理逻辑，所以对于v6里的`Result<List<T>>`就无法处理了，它只能处理单层多类型参数的情况，而无法处理嵌套的泛型参数。

没找到TypeReference的有参构造函数用法的比较正式的文档，但是基于源码的认识，我们应该这么使用TypeReference的有参构造函数：

```mipsasm
new TypeReference<Map<T1, T2>>(clazz1, clazz2){}
new TypeReference<Xxx<T1, T2, T3>>(clazz1, clazz2, clazz3){}
```

也就是构造器里的Type列表要与泛型类型参数一一对应。

### com.alibaba.fastjson.util.ParameterizedTypeImpl

那至于`ParameterizedTypeImpl`怎么回事呢？

```java
import java.lang.reflect.ParameterizedType;
// ...其他省略...

public class ParameterizedTypeImpl implements ParameterizedType {
    public ParameterizedTypeImpl(Type[] actualTypeArguments, Type ownerType, Type rawType){
        this.actualTypeArguments = actualTypeArguments;
        this.ownerType = ownerType;
        this.rawType = rawType;
    }
    // ...其他省略...
}
```

以前也没了解过ParameterizedType，与它相关的还有

```delphi
Type
所有已知子接口： 
GenericArrayType, ParameterizedType, TypeVariable<D>, WildcardType 
所有已知实现类： 
Class
```

先看看这次已经用到的ParameterizedType接口（下列注释是从jdk中文文档拷贝过来，不太好理解）

```csharp
public interface ParameterizedType extends Type {
    //返回表示此类型实际类型参数的 Type 对象的数组。
    //注意，在某些情况下，返回的数组为空。如果此类型表示嵌套在参数化类型中的非参数化类型，则会发生这种情况。 
    Type[] getActualTypeArguments();
    //返回 Type 对象，表示此类型是其成员之一的类型。
    Type getOwnerType();
    //返回 Type 对象，表示声明此类型的类或接口。
    Type getRawType();
}
```

结合`ParameterizedTypeImpl(Type[] actualTypeArguments, Type ownerType, Type rawType)`的例子来理解：
`new ParameterizedTypeImpl(new Type[]{clazz}, null, List.class)`用于构造`List<T>`。

### 关于Type

泛型是Java SE 1.5的新特性，`Type`也是1.5才有的。它是在java加入泛型之后为了扩充类型引入的。与Type相关的一些类或者接口来表示与Class类似但是又因泛型擦除丢失的一些类型信息。

### ParameterizedTypeImpl使用踩坑

详见：[fastjson反序列化使用不当导致内存泄露](https://www.cnblogs.com/liqipeng/p/11665889.html)