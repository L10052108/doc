资料来源：<br/>
[别在重复造轮子欢迎使用apache的commons-lang3工具-帮你书写优雅代码](https://mp.weixin.qq.com/s/h4V2VWgxU-KECF7cVINQmQ)



## 介绍

其实apache给我们提供了一个很强大的开源工具包，大家只要使用的好，能减少很多不必要的代码，它就是apache提供的众多commons工具包，而common里面lang3包更是被我们使用得最多的。因此本文主要详细讲解lang3包里面类的使用，希望以后大家使用此工具包，写出优雅的代码。

要使用common里面的lang3需要在pom里面添加如下的依赖：

```xml
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-lang3</artifactId>
    <version>3.10</version>
</dependency>
```

## 常用的工具类

### ArrayUtils

> ArrayUtils：用于对数组的操作，如添加、查找、删除、子数组、倒序、元素类型转换等

它首先给我们提供了8中基本数据类型以及包装类以及各种类型的长度为0的空数组。所以以后需要长度为0的数组，可以不用new了，直接用这个即可，并且是线程安全的。如下：

- toArray：可以简便的构建一个数组,如下：

```java
 public static void main(String[] args) {
        String[] strings = ArrayUtils.toArray("苹果", "香蕉", "西瓜");
        System.out.println(strings);
    }
```

- add：可以向数组里面添加一个元素【注意它返回的是一个新数组】，如下

```java
 String[] strings = ArrayUtils.toArray("苹果", "香蕉", "西瓜");
 strings = ArrayUtils.add(strings,"橘子") ;
 strings = ArrayUtils.add(strings,"啥都不是的") ;
 System.out.println(strings.length);
```

- toObject/toPrimitive：这两个方法很有用 可以实现比如int[]和Integer[]数组之间的互转。

```java
Integer[] inArr = new Integer[]{3, 6, 9};
int[] ints = ArrayUtils.toPrimitive(inArr);
Integer[] integers = ArrayUtils.toObject(ints);
System.out.println(integers.length);
```

这个数组工具里面还有很多方法，由于要讲的其他类还有很多。就不一一展示了，它的方法都很好懂，都是那种见名知意的方法。欢迎大家使用到数组工具的时候去使用这个工具类。

### ClassPathUtils

- toFullyQualifiedName(Class<?> context, String resourceName) 返回一个由class包名+resourceName拼接的字符串。有了这个方法在开发中你需要找一个类的包名，一下子就找到了。如下使用

```java
String fullPath = ClassPathUtils.toFullyQualifiedName(BeanDefinition.class, "");
 System.out.println(fullPath); // result : org.springframework.beans.factory.config.
 String fullPath1 = ClassPathUtils.toFullyQualifiedName(BeanDefinition.class, "BeanDefinition");
 System.out.println(fullPath1); // result : org.springframework.beans.factory.config.BeanDefinition
```

- toFullyQualifiedPath(Class<?> context, String resourceName) 返回一个由class包名+resourceName拼接的字符串。看下面结果你如果想要包名这样展示，也是可以的，太方便啦开发中如果有获取类似包的需求请直接使用这个。

```java
String stringUtils = ClassPathUtils.toFullyQualifiedPath(StringUtils.class, "StringUtils");
 System.out.println(stringUtils); // result: org/apache/commons/lang3/StringUtils
TH
```

### CharUtils

- toIntValue(Char char):将字符转换为其表示的整数，字符如果不是数字会抛出异常。

```java

System.out.println(CharUtils.toIntValue('1')); // result :1
System.out.println(CharUtils.toIntValue('a')); // 抛出异常
```

- isAscii(Char char) 检查字符是否为ASCII 7位。

```java

System.out.println(CharUtils.isAscii('a') ); // result :true
System.out.println(CharUtils.isAscii('在') ); //  result :false
```

### ObjectUtils

- isEmpty(Object obj)检查对象是空的还是null。如下用途很广，也可以对String进行判断，当然对String判断不建议使用这个，后面关于String的工具方法有更好用的。【PS关于这个类的很多方法同样对于String成立，但由于关于String有更好用的工具类，所以String类型不建议使用这个类的方法】

```java

 System.out.println( ObjectUtils.isEmpty(null));  // true
 System.out.println( ObjectUtils.isEmpty("")); // true
 System.out.println(ObjectUtils.isEmpty("ab")) ; // false
 System.out.println(ObjectUtils.isEmpty(new int[]{}) );  // true
 System.out.println( ObjectUtils.isEmpty(new int[]{1,2,3})) ; // false
 System.out.println(ObjectUtils.isEmpty(1234) ) ;   // false
```

- notEqual(Object o1,Object o2)：比较两个对象是否不相等，其中一个或两个对象都可以null。

```java
System.out.println(ObjectUtils.notEqual(null, null) ); // false
 System.out.println( ObjectUtils.notEqual(null, "")); // true
 System.out.println( ObjectUtils.notEqual("", null));// true
 System.out.println(ObjectUtils.notEqual("", "")); // false
 System.out.println(ObjectUtils.notEqual(Boolean.TRUE, null) ); // true
 System.out.println( ObjectUtils.notEqual(Boolean.TRUE, "true")); // true
 System.out.println( ObjectUtils.notEqual(Boolean.TRUE, Boolean.TRUE)); // false
 System.out.println(ObjectUtils.notEqual(Boolean.TRUE, Boolean.FALSE)); // true
```

### StringUtils

- equals(String str1,String str2)判断2个字符串是否相同，这里你也不需要去管null的字符串，它都会给你判断的，不用去关注空指针异常了，非常好用。

```java
System.out.println( StringUtils.equals(null, null) ); // true
 System.out.println(StringUtils.equals(null, "abc")); // false
 System.out.println(StringUtils.equals("abc", null)); // false
 System.out.println(StringUtils.equals("abc", "abc")); // true
 System.out.println(StringUtils.equals("abc", "ABC")); // false
```

- isAllBlank( CharSequence... css) ：判断字符串是否全部为null 空或者空白的字符。

```java

 System.out.println(StringUtils.isAllBlank(null)  ); // true
 System.out.println(StringUtils.isAllBlank(null, "foo") ); // false
 System.out.println(StringUtils.isAllBlank(null, null) ); // true
 System.out.println(StringUtils.isAllBlank("", "bar") ); // false
 System.out.println(StringUtils.isAllBlank("bob", "") ); // false
 System.out.println(StringUtils.isAllBlank("  bob  ", null) ); // false
 System.out.println(StringUtils.isAllBlank(" ", "bar")); // false
 System.out.println(StringUtils.isAllBlank("foo", "bar") ); // false
 System.out.println(StringUtils.isAllBlank(new String[] {})); // true
```

- isAnyBlank( CharSequence... css)：判断字符串是否有空的，如果有一个为空直接返回为true。

```JavaScript
 System.out.println(StringUtils.isAnyBlank((String) null) ); // true System.out.println(StringUtils.isAnyBlank((String[]) null)); // false System.out.println(StringUtils.isAnyBlank(null, "foo"));// true System.out.println(StringUtils.isAnyBlank(null, null) ); // true System.out.println(StringUtils.isAnyBlank("", "bar")); // true System.out.println(StringUtils.isAnyBlank("bob", "")); // true System.out.println(StringUtils.isAnyBlank("  bob  ", null) );// true System.out.println(StringUtils.isAnyBlank(" ", "bar")); // true System.out.println(StringUtils.isAnyBlank(new String[] {})); // false System.out.println(StringUtils.isAnyBlank(new String[]{""})); // true System.out.println(StringUtils.isAnyBlank("foo", "bar") ); // false
```

- isBlank(String str)：判断字符串是否为空（null,"",或者空白的字符串）。

```java
System.out.println(StringUtils.isBlank(null)); // true
System.out.println(StringUtils.isBlank("")); // true
System.out.println(StringUtils.isBlank(" ") ); // true
System.out.println(StringUtils.isBlank("bob")); // false
System.out.println( StringUtils.isBlank("  bob  "));  // false
```

- isNumeric(String str)：判断字符串是否仅包含数字，小数点不是数字返回false。

```java

System.out.println( StringUtils.isNumeric(null)); // false
System.out.println(StringUtils.isNumeric("") ); // false
System.out.println(StringUtils.isNumeric("  ") ); // false
System.out.println(StringUtils.isNumeric("123")); // true
System.out.println(StringUtils.isNumeric("12 3")); // false
System.out.println(StringUtils.isNumeric("ab2c")); // false
System.out.println(StringUtils.isNumeric("12.3")); // false
System.out.println(StringUtils.isNumeric("+123")); // false
```

- join：将数组中的元素按照指定的字符，连接成一个字符串，非常的好用，当然这个方法也适适用于集合中元素的连接。

```java
System.out.println(StringUtils.join(Arrays.asList("a","b","c"),";")); // a;b;c
System.out.println(StringUtils.join(Arrays.asList("a","b","c"), null)); // abc
System.out.println( StringUtils.join(Arrays.asList("a","b","c"), "") ); //abc
```

- length(String str)：返回字符串的长度，null返回0。不会报空指针异常很好用。

```java

 System.out.println(StringUtils.length(null)); // 0
 System.out.println(StringUtils.length("aa")); //2
```

- deleteWhitespace(String str)：删除空格，方法比较好用比trim好用。

```java
 System.out.println(StringUtils.deleteWhitespace(null)); // null
 System.out.println(StringUtils.deleteWhitespace("")  ); // ""
 System.out.println(StringUtils.deleteWhitespace("abc")); // abd
 System.out.println(StringUtils.deleteWhitespace("   ab  c  ")); // abc
```

- rightPad(final String str, final int size, final char padChar)：这个方法还是蛮管用的。对于生成统一长度的字符串的时候。比如生成订单号，为了保证长度统一，可以右边自动用指定的字符补全至指定长度。非常好用写的代码多了你就知道这个方法有多好了。【对应的：leftPad 左边自动补全】

```java
System.out.println(StringUtils.rightPad("bat", 3,"0")); // bat
System.out.println(StringUtils.rightPad("bat", 5,"0")) ; // bat00
System.out.println(StringUtils.rightPad("bat", 1,"0"));  // bat
System.out.println(StringUtils.rightPad("bat", -1,"0")); // bat
```

- isAlpha(String str)：判断字符串是否全由字母组成 （只要存在汉字、中文、数字都为false）。

```java

System.out.println(StringUtils.isAlpha(null)); //false
System.out.println(StringUtils.isAlpha("") ); // false
System.out.println(StringUtils.isAlpha("  ")); //false
System.out.println(StringUtils.isAlpha("abc")); // true
System.out.println(StringUtils.isAlpha("ab2c")); //false
System.out.println(StringUtils.isAlpha("ab-c")); //false
```

- uncapitalize(String str)：首字母转换为小写。

```java

System.out.println(StringUtils.uncapitalize(null)); // null
System.out.println(StringUtils.uncapitalize("cat")); // cat
System.out.println(StringUtils.uncapitalize("Cat")); // cat
System.out.println(StringUtils.uncapitalize("CAT")); // cAT
```

- reverse(String str)：字符串反转。

```java
System.out.println(StringUtils.reverse(null));// null
 System.out.println(StringUtils.reverse("") ); // ""
 System.out.println(StringUtils.reverse("bat") ); // tab
```

好了给大家总结了其中的一些工具类的使用，也是写了很长时间，当然也只是介绍了一部分，里面当然还有很多很好用的方法。欢迎大家去理解使用。俗话说师傅领进门，修行靠个人。我们开发的时候要学会使用工具类，站在前人的肩膀上开发，长江后浪推前浪，一浪更比一浪强，也期待大家能开发出更有用的工具类。

