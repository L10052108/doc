资料来源：<br/>
[Java POI 操作Excel(读取/写入)](https://www.cnblogs.com/dzpykj/p/8417738.html)<br/>
[Java使用POI导入导出Excel](https://blog.csdn.net/weixin_39806100/article/details/86614345)<br/>

[springboot下载src/main/resources下的Excel打不开](https://blog.csdn.net/qq_35549286/article/details/127669669)



## excel 导出

### 依赖的jar

```xml
<dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi</artifactId>
            <version>3.17</version>
        </dependency>
        <dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi-scratchpad</artifactId>
            <version>3.17</version>
        </dependency>
        <dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi-ooxml</artifactId>
            <version>3.17</version>
        </dependency>
        <dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi-ooxml-schemas</artifactId>
            <version>3.17</version>
        </dependency>
        <dependency>
            <groupId>com.google.guava</groupId>
            <artifactId>guava</artifactId>
            <version>23.0</version>
        </dependency>
```

###  导出的实体类

```java

public class ExcelDataTest {
   
   private Integer column1;
   
   private String column2;
   
   private String column3;
    
    @Override
   public String toString() {
      return "ExcelDataTest [column1=" + column1 + ", column2=" + column2 + ", column3=" + column3 + "]";
   }

   public Integer getColumn1() {
      return column1;
   }

   public void setColumn1(Integer column1) {
      this.column1 = column1;
   }

   public String getColumn2() {
      return column2;
   }

   public void setColumn2(String column2) {
      this.column2 = column2;
   }

   public String getColumn3() {
      return column3;
   }

   public void setColumn3(String column3) {
      this.column3 = column3;
   }
}

```

###  excel 工具类

```java

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import cn.hutool.poi.excel.ExcelUtil;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * Excel工具类
 */
public class ExcelUtils {
    
   /**
    * 通过模板导出excel文件
    * 只支持 xlsx格式
    * 只支持 读取excle第一个sheet
    * 模板文件默认读取templates/
    * @param dataList 数据集合
    * @param dataEntityClass 数据实体类
    * @param templateName 模板名称
    * @param titleRowNum 固定标题行数
    * @return
    * @throws Exception
    */
   public static <T> ByteArrayOutputStream exportExcel(List<T> dataList, InputStream in, int titleRowNum , int sheetAt) throws Exception {
      if (dataList == null || dataList.size() == 0) {
         throw new Exception("数据为空");
      }
      XSSFWorkbook workbook = null;

      Class dataEntityClass = null;

      if(CollectionUtil.isNotEmpty(dataList)){
         dataEntityClass =  dataList.get(0).getClass();
      }


      try {
         // 读取excel模板文件
//       InputStream in = ExcelUtil.class.getClassLoader().getResourceAsStream(templateName);
//         InputStream in = new FileInputStream(templateName);
         workbook = new XSSFWorkbook(in);
         XSSFSheet sheet = workbook.getSheetAt(0);
         // 设置默认行高
         //sheet.setDefaultRowHeightInPoints(25F);
         // 获取数据实体类的所有字段
         Field[] declaredFields = dataEntityClass.getDeclaredFields();
         int declaredFieldsSize = declaredFields.length;
         // ByteArray输出字节流
         ByteArrayOutputStream baos = new ByteArrayOutputStream();

         if(dataEntityClass != null){
            // 遍历数据写入到excel
            int dataListSize = dataList.size();
            for (int i = 0; i < dataListSize; i++) {
               // 获取数据list里面的对象实例
               T instance = dataList.get(i);
               // 创建行
               Row row = sheet.createRow(i + titleRowNum);
               for(int j = 0; j < declaredFieldsSize; j++){
                  Field field = declaredFields[j];
                  field.setAccessible(true);
                  // 获取字段的值
                  Object value = field.get(instance);

                  // 创建单元格
                  Cell cell = row.createCell(j);

                  // 设置单元格样式
                  XSSFCellStyle cellStyle = workbook.createCellStyle();

                  // 设置文本对齐方式
                  cellStyle.setWrapText(true); //设置自动换行
                  cellStyle.setAlignment(HorizontalAlignment.CENTER);// 水平居中
                  cellStyle.setVerticalAlignment(VerticalAlignment.CENTER);// 垂直居中

                  // 设置边框
                  cellStyle.setBorderBottom(BorderStyle.THIN); // 下边框
                  cellStyle.setBorderLeft(BorderStyle.THIN);// 左边框
                  cellStyle.setBorderTop(BorderStyle.THIN);// 上边框
                  cellStyle.setBorderRight(BorderStyle.THIN);// 右边框

                  // 设置字体
                  XSSFFont font = workbook.createFont();
                  font.setFontName("宋体");// 设置字体名称
                  font.setFontHeightInPoints((short) 11);// 设置字号
                  font.setColor(IndexedColors.BLACK.index);// 设置字体颜色
                  cellStyle.setFont(font);

                  cell.setCellStyle(cellStyle);
                  cell.setCellValue(value != null ? value.toString() : "");
               }
            }
         }
         workbook.write(baos);
         return baos;
      } finally {
         try {
            if (workbook != null) {
               workbook.close();
            }
         } catch (Exception e) {
            e.printStackTrace();
         }
      }

   }


   /**
    * 通过模板导出excel文件
    * 只支持 xlsx格式
    * 只支持 读取excle第一个sheet
    * 模板文件默认读取templates/
    * @param dataList 数据集合
    * @param dataEntityClass 数据实体类
    * @param templateName 模板名称
    * @param titleRowNum 固定标题行数
    * @return
    * @throws Exception
    */
   public static <T> ByteArrayOutputStream exportExcel(List<T> dataList, Class<T> dataEntityClass, String templateName, int titleRowNum , int sheetAt) throws Exception {
      if (dataList == null || dataList.size() == 0) {
         throw new Exception("数据为空");
      }
      XSSFWorkbook workbook = null;
      try {
         // 读取excel模板文件
//       InputStream in = ExcelUtil.class.getClassLoader().getResourceAsStream(templateName);
         InputStream in = new FileInputStream(templateName);
         workbook = new XSSFWorkbook(in);
         XSSFSheet sheet = workbook.getSheetAt(0);
         // 设置默认行高
         //sheet.setDefaultRowHeightInPoints(25F);
         // 获取数据实体类的所有字段
         Field[] declaredFields = dataEntityClass.getDeclaredFields();
         int declaredFieldsSize = declaredFields.length;
         // ByteArray输出字节流
         ByteArrayOutputStream baos = new ByteArrayOutputStream();

         // 遍历数据写入到excel
         int dataListSize = dataList.size();
         for (int i = 0; i < dataListSize; i++) {
            // 获取数据list里面的对象实例
            T instance = dataList.get(i);
            // 创建行
            Row row = sheet.createRow(i + titleRowNum);
            for(int j = 0; j < declaredFieldsSize; j++){
               Field field = declaredFields[j];
               field.setAccessible(true);
               // 获取字段的值
               Object value = field.get(instance);

               // 创建单元格
               Cell cell = row.createCell(j);

               // 设置单元格样式
               XSSFCellStyle cellStyle = workbook.createCellStyle();

               // 设置文本对齐方式
               cellStyle.setWrapText(true); //设置自动换行
               cellStyle.setAlignment(HorizontalAlignment.CENTER);// 水平居中
               cellStyle.setVerticalAlignment(VerticalAlignment.CENTER);// 垂直居中

               // 设置边框
               cellStyle.setBorderBottom(BorderStyle.THIN); // 下边框
               cellStyle.setBorderLeft(BorderStyle.THIN);// 左边框
               cellStyle.setBorderTop(BorderStyle.THIN);// 上边框
               cellStyle.setBorderRight(BorderStyle.THIN);// 右边框

               // 设置字体
               XSSFFont font = workbook.createFont();
               font.setFontName("宋体");// 设置字体名称
               font.setFontHeightInPoints((short) 11);// 设置字号
               font.setColor(IndexedColors.BLACK.index);// 设置字体颜色
               cellStyle.setFont(font);

               cell.setCellStyle(cellStyle);
               cell.setCellValue(value != null ? value.toString() : "");
            }
         }
         workbook.write(baos);
         return baos;
      } finally {
         try {
            if (workbook != null) {
               workbook.close();
            }
         } catch (Exception e) {
            e.printStackTrace();
         }
      }

   }

   /**
    * 读取excle
    * 只支持 xlsx格式
    * 只支持 读取excle第一个sheet
    * @param excelFile excle文件
    * @param dataEntityClass 数据实体类
    * @param titleRowNum 固定标题行数
    * @return
    * @throws Exception
    */
   public static <T> List<T> importExcel(File excelFile, Class<T> dataEntityClass, int titleRowNum) throws Exception {
      if (excelFile == null) {
         throw new Exception("参数excle文件(excelFile)不能为空");
      }

      XSSFWorkbook workBook = null;
      List<T> result = new ArrayList<T>();

      DecimalFormat df = new DecimalFormat("0"); // 格式化number String字符
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd"); // 日期格式化
      try {
         // 通过excle文件构建XSSFWorkbook对象
         workBook = new XSSFWorkbook(excelFile);
         // 获取excle第一个sheet
         XSSFSheet sheet = workBook.getSheetAt(0);
         // sheet.getFirstRowNum() 获取所有有数据的第一行索引，从0开始
         // sheet.getLastRowNum() 获取所有有数据的最后一行索引，从0开始
         for(int i = sheet.getFirstRowNum() + titleRowNum ; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null) {
               continue;
            }
            T object = dataEntityClass.newInstance();
            Field[] fields = object.getClass().getDeclaredFields();
            Field.setAccessible(fields, true);

            // row.getFirstCellNum() 获取一行中有数据的列的第一列索引，从0开始
            // row.getLastCellNum() 获取一行中有数据的列的最后一列索引，从0开始
            for(int j = row.getFirstCellNum(); j < row.getLastCellNum(); j++) {
               Cell cell = row.getCell(j);
               if (cell == null) {
                  continue;
               }
               Object value = null;
               if (cell.getCellTypeEnum() == CellType.STRING) {
                  value = cell.getStringCellValue();
               } else if (cell.getCellTypeEnum() == CellType.NUMERIC) {
                  if ("General".equals(cell.getCellStyle().getDataFormatString())) {
                     value = cell.getNumericCellValue();
                  } else if ("m/d/yy".equals(cell.getCellStyle().getDataFormatString())) {
                     value = sdf.format(cell.getDateCellValue());
                  } else {
                     value = df.format(cell.getNumericCellValue());
                  }
               } else if (cell.getCellTypeEnum() == CellType.BOOLEAN) {
                  value = cell.getBooleanCellValue();
               } else if (cell.getCellTypeEnum() == CellType.BLANK) {
                  value = "";
               } else {
                  value = "";
               }
               Field field = fields[j];
               Object vObj = null;
               String vStr = value.toString();
               if (field.getType() == String.class) {
                  vObj = vStr;
               } else if (field.getType() == Integer.class) {
                  vObj = Integer.valueOf(df.format(value));
               } else if (field.getType() == Double.class) {
                  vObj = Double.valueOf(vStr);
               } else if (field.getType() == Long.class) {
                  vObj = Long.valueOf(df.format(value));
               } else if (field.getType() == Boolean.class) {
                  vObj = Boolean.valueOf(vStr);
               } else {
                  vObj = value;
               }
               field.set(object, vObj);
            }
            result.add(object);
            Field.setAccessible(fields, false);
         }
      } finally {
         try {
            if (workBook != null) {
               workBook.close();
            }
         } catch (Exception e) {
            e.printStackTrace();
         }
      }
      return result;
   }
}

```

### DownloadUtil 工具类

```java
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.URLEncoder;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

/**
 * 下载工具类
 */
public class DownloadUtil {
   
   /**
    * 通用下载设置
    * @param response
    * @param outData 输出数据 ByteArrayOutputStream
    * @param fileName 文件名
    * @throws Exception
    */
   public static void generalDownload(HttpServletResponse response, ByteArrayOutputStream outData, String fileName) throws Exception{
      response.setContentType( "application/x-msdownload");
      response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode(fileName, "UTF-8"));
      ServletOutputStream out = response.getOutputStream();
      outData.writeTo(out);
      out.flush();
      out.close();
   }
   
   /**
    * 通用下载设置
    * @param response 
    * @param outData 输出数据 InputStream
    * @param fileName 文件名
    * @throws Exception
    */
   public static void generalDownload(HttpServletResponse response, InputStream outData, String fileName) throws Exception{
      response.setContentType( "application/x-msdownload");
      response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode(fileName, "UTF-8"));
      ServletOutputStream out = response.getOutputStream();
      byte[] bffer = new byte[1024];
      int r = outData.read(bffer, 0, 1024);
      while (r != -1) {
         out.write(bffer);
         r = outData.read(bffer, 0, 1024);
      }
      out.flush();
      out.close();
   }
   
   /**
    * 通用下载设置
    * @param response 
    * @param outData 输出数据 byte[]
    * @param fileName 文件名
    * @throws Exception
    */
   public static void generalDownload(HttpServletResponse response, byte[] outData, String fileName) throws Exception{
      response.setContentType( "application/x-msdownload");
      response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode(fileName, "UTF-8"));
      ServletOutputStream out = response.getOutputStream();
      out.write(outData);
      out.flush();
      out.close();
   }
}
```

### 控制层代码

```java

    @SneakyThrows
    @GetMapping("export/{surveyId}")
    @ApiOperation(value = "导出", notes = "导出Excel文件")
    public void down(@PathVariable("surveyId") String surveyId ,
                       HttpServletResponse response,
                     ExportQuery pageQuery){
        InputStream is =  new ClassPathResource("excel" + File.separator + surveyId + ".xlsx").getInputStream();

        SurveyService surveyService = getService(surveyId);
        List<T> dataList = surveyService.query(pageQuery.getStartTime(), pageQuery.getEndTime());

        ByteArrayOutputStream baos = ExcelUtils.exportExcel(dataList, is, 2 , 0);
        DownloadUtil.generalDownload(response, baos, IdUtil.objectId() + ".xlsx");
    }
```

`springboot`下载`src/main/resources`下的Excel无法打开，

最近遇到下载导入模板的需求，我将模板`Excel`放在`src/main/resources`下，
结果下载下来后提示无法打开，

!> 原因是springboot会压缩src/main/resources下的文件，
不小心误伤了我们的模板Excel文件，

解决办法：在pom.xml加入以下内容，

```xml
	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-resources-plugin</artifactId>
				<configuration>
					<encoding>UTF-8</encoding>
					<!-- 避免src/main/resources下的Excel被压缩破坏 -->
					<nonFilteredFileExtensions>
						<nonFilteredFileExtension>xls</nonFilteredFileExtension>
						<nonFilteredFileExtension>xlsx</nonFilteredFileExtension>
					</nonFilteredFileExtensions>
				</configuration>
			</plugin>
		</plugins>
	</build>
```

然后要记得clean install之后才会生效。