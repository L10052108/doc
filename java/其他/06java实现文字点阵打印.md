资料来源：<br/>
[java 点阵打印机_输入文字，输出点阵文字](https://blog.csdn.net/weixin_29430691/article/details/114227884)


## 介绍

在做墨水屏展示汉字的时候，需要了困难。需要把汉字转成需要显示一个个点。在网上找了很多方法，比如使用嵌入式系统的方法，做一个字库。通过读取字库的内容来实现。但是找到的字库，支持GBK2312。很多生僻字、数字、字母无法显示问题。

具体的使用

### 具体的实现

#### 电脑自带字体

```java
import org.junit.Test;

import java.awt.*;
import java.awt.font.FontRenderContext;
import java.awt.font.GlyphVector;
import java.awt.geom.AffineTransform;
import java.awt.geom.RectangularShape;

public class FontDemo {

//        版权声明：本文为CSDN博主「Kelly敏」的原创文章，遵循CC4.0BY-SA版权协议，转载请附上原文出处链接及本声明。
//        原文链接：https://blog.csdn.net/weixin_29430691/article/details/114227884
    @Test
    public void test01(){
        boolean[][] view = getVeiew("黑体", Font.BOLD, 100, "劉偉");

        printView(view);
    }



    /**
     * 生成一个点阵对象
     * @param fontName 字体的名称
     * @param style
     * @param size   字体的大小
     * @return
     */
    public boolean[][] getVeiew(String fontName,int style, int size, String str) {
        Font font = new Font(fontName, style, size);
//        Font font = new Font("黑体", Font.BOLD, 26);

        AffineTransform at = new AffineTransform();
        FontRenderContext frc = new FontRenderContext(at, true, true);
        GlyphVector gv = font.createGlyphVector(frc, str);
        RectangularShape rs = gv.getVisualBounds();

        Shape shape = gv.getOutline((float) -rs.getX(), (float) -rs.getY());  //rs这个矩形的Y坐标为什么是负数？求解答
        Rectangle rect = shape.getBounds();
        int width = rect.width + rect.x;
        int height = rect.height;
        boolean[][] view = new boolean[width][height];

        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                if (shape.contains(i, j)) {
                    view[i][j] = true;

                } else {
                    view[i][j] = false;
                }
            }
        }
        return view;
    }

    /**
     * 打印一个字符
     * 渲染的规则是从上到下第一竖行，第一个渲染完成，第二个，第三个，，，
     * @param view
     */
    public void printView(boolean[][] view) {
        int height = view.length;
        int width = view[0].length;
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                if (view[j][i]) {
                    System.out.print("●");// 替换成你喜欢的图案
                } else {
                    System.out.print("○");// 全角半角和上面一致
                }
            }
            System.out.println();
        }
        System.out.println();
    }

    public void swap(boolean[][] swapArray){
        boolean[][] temp = new boolean[16][16];
        System.arraycopy(swapArray,0,temp,0,16);
        for (int row = 0; row < 16; row++) {
            for (int column = 0,newColumn=15; column < 16; column++,newColumn--) {
                swapArray[newColumn][row] = temp[row][column];
            }
        }
    }

}

```

#### GB2312字库

使用到的字库

下载:https://jinlilu.lanzoum.com/iyRCA0yiqoqj 密码:85ck

```java

public class point24 {
    //https://blog.csdn.net/llapton/article/details/108462002
// https://blog.csdn.net/llapton/article/details/108911412

    @Test
    public void printOnZi( ) throws IOException {
//        pirntOne("厸");
        pirntOne("任");
    }

    public  void pirntOne (String str) throws IOException {
//        String str = "州";

        byte[] cbuf = new byte[72];
        byte[] bytes = str.getBytes("GB2312");

        System.out.println(bytes[0]);
        //这种写法是把byte转成int的
        int segNum = bytes[0] & 0xff;
        int bitNum = bytes[1] & 0xff;

        //算出这个字在字库文件中的偏移量，注意32是表示16*16像素的字站32个字节
        /*int offset = (94 * (segNum - 0xb0) + (bitNum - 0xa1)) * 72;*/
        int offset = (94 * (segNum - 0Xaf - 1) + (bitNum - 0xa0 - 1)) * 72;
        System.out.println("offset = " + offset);

        //读取点阵字库文件，需要按需修改为你电脑上实际字库的绝对地址
//        ClassPathResource classPathResource = new ClassPathResource("HZK24H");
//        InputStream inputStream = classPathResource.getInputStream();

//        InputStream inputStream = new FileInputStream("C:\\Users\\23961\\Desktop\\jar\\HZK24H");
        //TODO 根据实际情况，进行修改
        InputStream inputStream = new FileInputStream("C:\\Users\\23961\\Desktop\\jar\\font_library\\字库\\24x24\\HZK24K");

                //跳过offset个字节，读取汉字占用的72个字节
        inputStream.skip(offset);
        inputStream.read(cbuf);

        int[][] arr = new int[24][24];
        for (int i = 0; i<24; i++) {
            for (int j = 0; j<3; j++) {
                for (int k = 0;k<8; k++) {
                    int flag = cbuf[i * 3 + j] & (0x80 >> k);
                    if ( flag>0)
                        arr[j * 8 + k][i] = 1 ;
                    else
                        arr[j * 8 + k][i] = 0 ;
                }
            }
        }

        for (int i=0;i<24;i++){
            for (int j=0;j<24;j++){
               /*System.out.print(arr[i][j]);*/
                System.out.print(arr[i][j] == 0 ? "○" : "●");
            }
            System.out.println();
        }


        //转换为行扫描的byte[]
       String[] byte_str =new String[72];
        byte[] byte_24 = new byte[72];
        for (int i=0;i<24;i++){
            for (int j=0;j<3;j++){
                String str_mid = "";
                for (int k=0;k<8;k++){
                    str_mid += arr[i][j*8+k] ;
                }
                byte_str[i*3+j] = str_mid;
            }
        }
        for (int i=0;i<72;i++){
            byte_24[i] = (byte) (Integer.parseInt(byte_str[i],2) & 0XFF);
//            System.out.println(byte_str[i]);
//            System.out.println(byte_24[i]);
        }

//        String formatHexStr = HexUtils.getFormatHexStr(byte_24);
//        System.out.println(formatHexStr.toUpperCase());
    }
}
```

#### GBK字库

```java

import com.potion.sorting.testdemo.until.HexUtils;
import lombok.extern.slf4j.Slf4j;
import org.junit.Test;

import java.io.*;

@Slf4j
public class HzDemo {

    //https://blog.csdn.net/breeze_wf/article/details/46911871?spm=1001.2101.3001.6650.4&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-4-46911871-blog-23740317.235%5Ev36%5Epc_relevant_default_base3&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-4-46911871-blog-23740317.235%5Ev36%5Epc_relevant_default_base3&utm_relevant_index=5

    @Test
    public void test01() throws Exception{
        String s = "一二";

        /*
         * 循环取得每个汉字
         * */
        for (int i = 0; i < s.length(); i++) {

            //获取汉字的信息
            byte[] aByte = getByte(i, s);
            getHex(aByte);
        }
    }



    public byte[] getByte(int i, String s) {
        byte[] b_gbk = new byte[1];
        String ss = s.substring(i, i + 1);
        log.info("hzkTest--->>>" + ss);
        try {
            b_gbk = ss.getBytes("GBK");//必须转为GBK编码
            log.info("hzkTest--->>>" + "Length=" + b_gbk.length);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return b_gbk;
    }

    private void getHex(byte[] data) throws FileNotFoundException {
        int size = 16;//字模的size
        int sum = (size * size / 8);
        byte iHigh, iLow;
        iHigh = data[1];
        iLow = data[0];
//        log.info("hzkTest--->>>", "h=" + iHigh + ",l=" + iLow);
        int IOffset;//偏移量
        IOffset = (94 * (iLow + 256 - 161) + (iHigh + 256 - 161)) * sum;//+256防止byte值为负   汉字字模在字库中的偏移地址
//        log.info("hzkTest--->>>", "IOffset=" + IOffset);

//        InputStream is = getResources().openRawResource(R.raw.hzk16);

        InputStream is = new FileInputStream("C:\\Users\\23961\\Desktop\\jar\\hzk16f");

        try {
            is.read(new byte[IOffset]);
            byte iBuff[] = new byte[size * 2];//连续读入
            is.read(iBuff);

            String formatHexStr = HexUtils.getFormatHexStr(iBuff);
            System.out.println(formatHexStr);
            getBinary(iBuff);

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /*
     * 按照共阴极逆向式列行式取码方式（OLED显示方式）重新输出排列 0 1
     * */
    private void getRowLineReverseCode(StringBuffer sb) {
        //得到前8行16列 128个
        String pre128 = sb.substring(0, 128);
        log.info("hzkTest--->>>", "pre128--->>"  + pre128);
        //取出每16列的8个数据
        for (int i = 0; i < 16; i++) {
            StringBuffer sb1 = new StringBuffer();
            for (int j = 112; j >=0; ) {
                String s = pre128.substring(i + j, i + j + 1);
                sb1.append(s);
                j -= 16;
            }
            log.info("hzkTest--->>>", "pre128--->>列行式2进制-->>"  + sb1 + ",");
            log.info("hzkTest--->>>", "pre128--->>列行式10进制-->>"  + Integer.parseInt(sb1.toString(),2) + ",");
//            log.info("hzkTest--->>>", "pre128--->>列行式16进制-->>" + binaryString2hexString(sb1.toString()) + ",");
            //直接使用十进制数据，不再转换16进制
//            buffer10.append(Integer.parseInt(sb1.toString(),2) + ",");
//            hexBuffer.append(binaryString2hexString(sb1.toString())+",");
        }

        //得到后8行16列 128个
        String las128 = sb.substring(128, 256);
        log.info("hzkTest--->>>", "las128--->>" + las128);
        //取出每16列的8个数据
        for (int i = 0; i < 16; i++) {
            StringBuffer sb2 = new StringBuffer();
            for (int j = 112; j >=0; ) {
                String s = las128.substring(i + j, i + j + 1);
                sb2.append(s);
                j -= 16;
            }
            log.info("hzkTest--->>>", "las128--->>列行式2进制-->>" + sb2 + ",");
//            log.info("hzkTest--->>>", "las128--->>列行式16进制-->>" + binaryString2hexString(sb2.toString()) + ",");
            //直接使用十进制数据，不再转换16进制
//            buffer10.append(Integer.parseInt(sb2.toString(),2) + ",");
//            hexBuffer.append(binaryString2hexString(sb2.toString())+",");
        }

//        Log.i("hzkTest--->>>","HEX--->>>>"+hexBuffer);
//        log.info("hzkTest--->>>","10---->>>>"+buffer10);
    }

    /*
     * 获取汉字的二进制数据
     * */
    private void getBinary(byte[] iBuff) {
        StringBuffer stringBuffer=new StringBuffer();
        int i, j, k;
        for (i = 0; i < 16; i++) {
            for (j = 0; j < 2; j++)
                for (k = 0; k < 8; k++) {
                    if ((iBuff[i * 2 + j] & (0x80 >> k)) >= 1) {
                        stringBuffer.append("1");
                    } else {
                        stringBuffer.append("0");
                    }
                }
        }
        log.info("hzkTest--->>>" + stringBuffer.toString());

        //把 0 1 按照共阴极逆向式列行式取码方式输出
        getRowLineReverseCode(stringBuffer);
    }
}

```

