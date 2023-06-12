资料来源：<br/>
[MessageFormat的用法,java动态替换String字符串中的占位符](https://www.cnblogs.com/hoonick/p/9841649.html)

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