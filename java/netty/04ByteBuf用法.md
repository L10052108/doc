资料来源：<br/>
[ByteBuf用法详解](https://blog.csdn.net/smith789/article/details/104410317?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-104410317-blog-123698827.235%5Ev33%5Epc_relevant_increate_t0_download_v2_base&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-104410317-blog-123698827.235%5Ev33%5Epc_relevant_increate_t0_download_v2_base&utm_relevant_index=2)



## ByteBuf使用

### ByteBuf 介绍

ByteBuf from Netty比ByteBuffer from java nio更强大，比如可以进行池化，不需要flip切换读写模式。
ByteBuf内部结构如图所示：
ByteBuf本质上是一个字节数组，分为了4个部分。

![20200220152808398](img\20200220152808398.png ':size=60%')

readerIndex是读指针，每读取一个字节，readerIndex就会+1。一旦readerIndex = writerIndex，不可再读了。
writerIndex是写指针，每写入一个字节，writerIndex就会+1.一旦writerIndex = readerIndex，不可再写了。
capacity表示ByteBuf容量，它的值 = 废弃的字节数 + 可读的字节数 + 可写的字节数。
读取之后，0~readerIndex就被视为废弃的，调用discardReadBytes方法，可以释放这部分空间。
maxCapacity是ByteBuf可以扩容的最大容量。扩容超过maxCapacity就会报错。
使用示例

```java
@Test
public void test1(){
    ByteBuf b = ByteBufAllocator.DEFAULT.buffer(1,10);
    System.out.println("可读字节数：" + b.readableBytes() + ",可写字节数：" + b.writableBytes());
    System.out.println("分配了初始容量是9，最大容量10个字节的缓冲区" + b);
    b.writeBytes(new byte[]{1,2});
    System.out.println("写入了2个字节" + b);
    System.out.println("可读字节数：" + b.readableBytes() + ",可写字节数：" + b.writableBytes());
    getByteBuf(b);
    System.out.println("可读字节数：" + b.readableBytes() + ",可写字节数：" + b.writableBytes());
    System.out.println(b);
    readByteBuf(b);
    System.out.println("可读字节数：" + b.readableBytes() + ",可写字节数：" + b.writableBytes());
    System.out.println(b);
    getByteBuf(b);
    System.out.println("可读字节数：" + b.readableBytes() + ",可写字节数：" + b.writableBytes());
    System.out.println(b);
}

private void readByteBuf(ByteBuf buffer){
    System.out.println("开始读取，改变了buffer内部指针,buffer内容如下：");
    while(buffer.isReadable()){
        System.out.print(buffer.readByte() + ",");
    }
    System.out.println();
}

/**
 * 读取字节，不改变指针
 * @param buffer
 */
private void getByteBuf(ByteBuf buffer){
    System.out.println("开始读取，不改变buffer内部指针，buffer内容如下：");
    for (int i = 0; i < buffer.readableBytes(); i++) {
        System.out.print(buffer.getByte(i) + ",");
    }
    System.out.println();
}
```

运行结果

```
可读字节数：0,可写字节数：1
分配了初始容量是9，最大容量10个字节的缓冲区PooledUnsafeDirectByteBuf(ridx: 0, widx: 0, cap: 1/10)
写入了2个字节PooledUnsafeDirectByteBuf(ridx: 0, widx: 2, cap: 10/10)
可读字节数：2,可写字节数：8
开始读取，不改变buffer内部指针，buffer内容如下：
1,2,
可读字节数：2,可写字节数：8
PooledUnsafeDirectByteBuf(ridx: 0, widx: 2, cap: 10/10)
开始读取，改变了buffer内部指针,buffer内容如下：
1,2,
可读字节数：0,可写字节数：8
PooledUnsafeDirectByteBuf(ridx: 2, widx: 2, cap: 10/10)
开始读取，不改变buffer内部指针，buffer内容如下：

可读字节数：0,可写字节数：8
PooledUnsafeDirectByteBuf(ridx: 2, widx: 2, cap: 10/10)
```

工具类

用到的jar包

```xml
            <!-- 工具类 -->
            <dependency>
                <groupId>cn.hutool</groupId>
                <artifactId>hutool-all</artifactId>
                <version>5.8.5</version>
            </dependency>
```

字符串数组转化

```java
import cn.hutool.core.util.HexUtil;
import io.netty.buffer.ByteBuf;

public class ByteBufUtils {

    /**
     * 获取其中的字节数组
     *
     * @param byteBuf 数据
     * @return 字节数组
     */
    public static byte[] byteArray(ByteBuf byteBuf) {
        byte[] bytes = new byte[byteBuf.readableBytes()];
        byteBuf.getBytes(0, bytes);
        return bytes;
    }


    /**
     * 字符串解析数组
     * @param str
     * @return
     */
    public static byte[] decodeHex(String str){
        return HexUtil.decodeHex(str);
    }


    /**
     * 将数据转为十六进制字符串，字节之间保留空格
     *
     * @param byteBuf 数据
     * @return 十六进制字符串
     */
    public static String toHex(ByteBuf byteBuf) {
        byte[] bytes = byteArray(byteBuf);
        return getFormatHexStr(bytes);
    }

    /**
     * 字符串进行格式化
     * @param bytes 原先字符串
     * @return
     */
    public static String getFormatHexStr(byte[] bytes){
        String encodeHexStr = HexUtil.encodeHexStr(bytes);
        return HexUtil.format(encodeHexStr);
    }

    /**
     * 把二进制字符串转化成byte数组
     * @param str 二进制字符串
     * @return
     */
    public static byte[] strToByte(String str){
        return HexUtil.decodeHex(str);
    }
    
    /**
     * 把Long类型的数字转成byte数组
     * @param l 需要转化的数字
     * @return
     */
    public static byte[] getLongByte(Long l){
        ByteBuffer bb = ByteBuffer.allocate(8);
        bb.putLong(0, 25);

        return bb.array();
    }

}
```

补充：

byte数组和数字类型之间的转化

```java
    @Test
    public void test01(){
//        int i = ByteUtil.byteToUnsignedInt(100);
        byte[] b = ByteUtil.numberToBytes(100L);
        String formatHexStr = HexUtils.getFormatHexStr(b);
        System.out.println(formatHexStr);
    }

    @Test
    public void test02(){
        String str = "64 00 00 00 00 00 00 00";
        byte[] bytes = HexUtils.decodeHex(str);
        long l = ByteUtil.bytesToLong(bytes);
        System.out.println(l);
    }
```

