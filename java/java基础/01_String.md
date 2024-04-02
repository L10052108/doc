资料来源：<br/>
[MessageFormat的用法,java动态替换String字符串中的占位符](https://www.cnblogs.com/hoonick/p/9841649.html)

[StringEscapeUtils转义](https://www.cnblogs.com/xfeiyun/p/17861057.html)

## MessageFormat 使用
MessageFormat的用法,java动态替换String字符串中的占位符
```java
import java.text.MessageFormat;
import java.util.GregorianCalendar;
import java.util.Locale;

public class Test3
{
    public static void main(String[] args) throws Exception
    {
        String pattern1 = "{0},你好!你于 {1} 存入 {2}元";
        String pattern2 = "At {1,time,short} on {1,date,long},{0} paid {2,number,currency}";
        
        //1.0E3 科学计数法 即 1.0*10^3 E3表示10的三次方
        Object[] params = {"hoonick",new GregorianCalendar().getTime(),1.0E3};
        
        //使用默认的本地化对象格式化字符串
        String format = MessageFormat.format(pattern1, params);
        System.out.println(format);
        
        //使用指定的本地化对象格式化字符串
        MessageFormat mf = new MessageFormat(pattern2, Locale.US);
        String format2 = mf.format(params);
        System.out.println(format2);
    }

}
```
运行结果
![988897-20181024091540835-1655861095](img\988897-20181024091540835-1655861095.png)


## StringEscapeUtils 转义字符串

常见的场景是：

- 同一字符在不同编码中表达形式不一样。
- 某些特定的字符在不同环境、不同语言中表达形式不一样。

其中org.apache.commons.lang.StringEscapeUtils已废弃，可以使用org.apache.commons.text.StringEscapeUtils替代。

```xml
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-text</artifactId>
    <version>1.6</version>
</dependency>
```

###  转义Unicode编码

```java
//转义为Unicode编码
String escape = StringEscapeUtils.escapeJava("古德猫宁");
//输出：\u53E4\u5FB7\u732B\u5B81
//反转义Unicode编码
String unescape = StringEscapeUtils.unescapeJava("\u53E4\u5FB7\u732B\u5B81");
//输出：古德猫宁
```

###  转义html脚本

```java
//转义为html脚本
String escapeHtml = StringEscapeUtils.escapeHtml4("<div>Hello World！</div>");
System.out.println(escapeHtml);
//输出：&lt;div&gt;Hello World！&lt;/div&gt;
//反转义html脚本
String unescapeHtml = StringEscapeUtils.unescapeHtml4("&lt;div&gt;Hello World！&lt;/div&gt;");
System.out.println(unescapeHtml);
//输出：<div>Hello World！</div>
```

### 转义JS脚本

```java
//转义JS脚本
String escapeJS = StringEscapeUtils.escapeEcmaScript("<script type=\"text/javascript\">alert('哈哈')<script>");
System.out.println(escapeJS);
//输出：<script type=\"text\/javascript\">alert(\'\u54C8\u54C8\')<script>
//反转义JS脚本
String unescapeJS = StringEscapeUtils.unescapeEcmaScript("<script>alert(\'哈哈\')<script>");
System.out.println(unescapeJS);
//输出：<script>alert('哈哈')<script>
```

### 转义CSV

```
String escapeCsv = StringEscapeUtils.escapeCsv("He said \"'I love you'\"");
System.out.println(escapeCsv);
//输出："He said ""'I love you'"""
String unescapeCsv = StringEscapeUtils.unescapeCsv("\"He said \"\"'I love you'\"\"\"");
System.out.println(unescapeCsv);
//输出：He said "'I love you'
```

### 转义XML

```java
//转义xml脚本
String escapeXml = StringEscapeUtils.escapeXml11("<port>8080</port>");
System.out.println(escapeXml);
//输出：&lt;port&gt;8080&lt;/port&gt;
//反转义xml脚本
String unescapeXml = StringEscapeUtils.unescapeXml("&lt;port&gt;8080&lt;/port&gt;");
System.out.println(unescapeXml);
//输出：<port>8080</port>
```

