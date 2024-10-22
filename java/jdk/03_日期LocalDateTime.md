资料来源<br/>
[IDEA Web 项目中 Java 8 默认情况下 LocalDateTime 报错解决方法](https://blog.csdn.net/notthin/article/details/120469064)<br/>





## 介绍

 LocalDateTime是Java 8引入的日期和时间API (java.time包)中的一个类，不包含时区信息。它是一个不可变的类，提供了各种方法来处理日期和时间，且不关心时区的概念。若需要添加时区信息，可以使用atZone()方法转换为ZonedDateTime进行处理：

```
LocalDateTime now = LocalDateTime.now();
ZonedDateTime zonedDateTime = now.atZone(ZoneId.of("Asia/Shanghai"));
```



## 基本使用

#### 1、获取LocalDateTime时间

```
// 当前时间
LocalDateTime now = LocalDateTime.now();
 
// 5050年12月12日 14时30分 30秒 30纳秒 (秒和纳秒的部分可以省略)
LocalDateTime futureTime = LocalDateTime.of(5050, 12, 12, 14, 30, 30, 30);
 
// 添加: plus..()   plusDays、plusMonth、plusYears...
LocalDateTime newTime_01 = now.plusDays(1);   // 后一天
 
// 减少: minus..()   minusDays、minusMonth、minusYears...
LocalDateTime newTime_02 = now.minusDays(1);  // 前一天
 
// 设置各部分时间
LocalDateTime newYear = now.withYear(4040);     // 改为4040年
LocalDateTime newMonth = now.withMonth(10);     // 改为10月份
LocalDateTime newDay = now.withDayOfMonth(12);  // 改为12日
 
// 通过字符串获取
String timeString = "5050-12-12 14:30";
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
LocalDateTime parseTime = LocalDateTime.parse(timeString, formatter);

```

#### 2、时间比较

```java
boolean isBefore = now.isBefore(newTime_01);
boolean isAfter = now.isAfter(newTime_01);
boolean isEqual = now.isEqual(newTime_01);
```

#### 3、获取基本时间信息:

```java
// get..()   getHour、getMinute、getSecond...
int year = now.getYear();
Month month = now.getMonth(); // Month是枚举，返回值为月份的英文大写
int hour = now.getHour();
// 其余同理
```

#### 4、格式化 / 反格式化

```java
DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
 
// 转换为字符串
String timeString = format.format(futureTime);
// 字符串转换为LocalDateTime
LocalDateTime parseTime = LocalDateTime.parse(timeString, format);
```

#### 5、转换为数字时间戳

```java
 ZonedDateTime zonedDateTime = now.atZone(ZoneId.of("Asia/Shanghai"));
 Instant instant = zonedDateTime.toInstant();
 
 long milli = instant.toEpochMilli();     // 以毫秒为单位的时间戳
 long second = instant.getEpochSecond();  // 以秒为单位的时间戳
```

#### 6、数字时间戳转为LocalDateTime

```java
// 以 毫秒 为单位的时间戳转为LocalDateTime
LocalDateTime timeByMilli = Instant.ofEpochMilli(milli).atZone(ZoneId.of("Asia/Shanghai")).toLocalDateTime();
 
// 以 秒 为单位的时间戳转为LocalDateTime
LocalDateTime timeBySecond = Instant.ofEpochSecond(second).atZone(ZoneId.of("Asia/Shanghai")).toLocalDateTime();
// LocalDate、LocalTime同理
```

## 转化

### 转成date



hutool 提供了of 方法

```java
 import cn.hutool.core.date.LocalDateTimeUtil;

LocalDateTime localDateTime = LocalDateTimeUtil.of(date);

```

### date转成

```java
public class LocalDateTimeUtils {


    /**
     * 计算两个时间的时间差(单位毫秒)
     * 备注：开始时间 > 结束时间返回 0
     * @param start 开始时间
     * @param end 结束时间
     * @return
     */
    public static Long betweenMills(LocalDateTime start, LocalDateTime end) {
        return calcBetween(start,end, ChronoUnit.MILLIS );
    }

    /**
     * 计算时间差(单位秒)
     * @param start
     * @param end
     * @return
     */
    public static Long betweenSeconds(LocalDateTime start, LocalDateTime end) {
       return calcBetween(start,end, ChronoUnit.SECONDS );
    }

    private static long calcBetween(LocalDateTime start, LocalDateTime end, ChronoUnit unit) {
        long between = 0L;
        if(start==null || end==null){
            return between;
        }

        if (start.isBefore(end)) {
            between = LocalDateTimeUtil.between(start, end, unit);
        }
        return between;
    }

    /**
     * 时间转成日期
     * @param localDateTime
     * @return
     */
    public static Date toDate(LocalDateTime localDateTime) {
        return Date.from(localDateTime.atZone(ZoneId.systemDefault()).toInstant());
    }
}
```

## 请求返回

### 返回对象格式化输出

```java
    /**
     * 支付时间
     */
    @DateTimeFormat(fallbackPatterns = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime paymentTime;
```

### 请求对象

```java
    /**
     * 开票时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime billingTime;
```

### MQ 对象

```
Java 8 date/time type `java.time.LocalDateTime` not supported by default:
 add Module "com.fasterxml.jackson.datatype:jackson-datatype-jsr310" to enable handling 
 (through reference chain: net.queer.web.talker.push.bean.db.User["createAt"])

```

**意思：** 在默认情况下 Java 8 不支持 LocalDateTime 需要添加 com.fasterxml.jackson.datatype:jackson-datatype-jsr310 依赖。

**原因：** 是没有添加序列化和反序列化器。

1、在 **build.gradle -> dependencies** 里添加依赖：

```java
implementation 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310'
```

2、指定 LocalDateTime 的序列化以及反序列化器：

```java
	/**
	 * 项目的结束时间
	 */
	@JsonDeserialize(using = LocalDateTimeDeserializer.class)
	@JsonSerialize(using = LocalDateTimeSerializer.class)
	private LocalDateTime endTime;
```

**注意：** **LocalDateTimeDeserializer.class** 和 **LocalDateTimeSerializer.class** 必须添加依赖后才会引用，否则无法使用。Web 项目中没有 **pom.xml** 文件，所以依赖是添加在 **build.gradle** 里的。



