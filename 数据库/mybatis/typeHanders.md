资料来源：
[MyBatis 类型处理器 typeHandlers](https://blog.csdn.net/qq_39291919/article/details/108676127?spm=1001.2101.3001.6650.2&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2.pc_relevant_default&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2.pc_relevant_default&utm_relevant_index=5)



## MyBatis 类型处理器 typeHandlers

> 官网：https://mybatis.org/mybatis-3/configuration.html#typeHandlers 
>
> Whenever MyBatis sets a parameter on a PreparedStatement or retrieves a value from a ResultSet, a TypeHandler is used to retrieve the value in a means appropriate to the Java type. 
>
> NOTE Since version 3.4.5, MyBatis supports JSR-310 (Date and Time API) by default.


>  每当 MyBatis 在 PreparedStatement 设置参数或者从 ResultSet 取值的时候，TypeHandler 都会起作用，它就是以一种适合 Java 类型的方式去取值。
>
> 而且需要注意，如果你使用的是 JDK 1.8 及以上实现了 JSR-310 的时间 API，在 MyBatis 3.4.5 及以上版本是不需要手动添加 TypeHandler 的，因为他们是默认注册的。

| Type Handler       | Java Types                 | JDBC Types             |
| :----------------- | :------------------------- | :--------------------- |
| BooleanTypeHandler | java.lang.Boolean, boolean | Any compatible BOOLEAN |
| ByteTypeHandler       | java.lang.Byte, byte       | Any compatible NUMERIC or BYTE     |
| ShortTypeHandler      | java.lang.Short, short     | Any compatible NUMERIC or SMALLINT |
| IntegerTypeHandler    | java.lang.Integer, int     |Any compatible NUMERIC or INTEGER|
|LongTypeHandler|java.lang.Long, long|Any compatible NUMERIC or BIGINT|
|FloatTypeHandler|java.lang.Float, float|Any compatible NUMERIC or FLOAT|
|DoubleTypeHandler|java.lang.Double, double|Any compatible NUMERIC or DOUBLE|
|BigDecimalTypeHandler|java.math.BigDecimal|Any compatible NUMERIC or DECIMAL|
|StringTypeHandler|java.lang.String|CHAR, VARCHAR|
|ClobReaderTypeHandler|java.io.Reader|-|
|ClobTypeHandler|java.lang.String|CLOB, LONGVARCHAR|
|NStringTypeHandler|java.lang.String|NVARCHAR, NCHAR|
|NClobTypeHandler|java.lang.String|NCLOB|
|BlobInputStreamTypeHandler|java.io.InputStream|-|
|ByteArrayTypeHandler|byte[]|Any compatible byte stream type|
|BlobTypeHandler|byte[]|BLOB, LONGVARBINARY|
|DateTypeHandler|java.util.Date|TIMESTAMP|
| DateOnlyTypeHandler        | java.util.Date             | DATE                               |
|TimeOnlyTypeHandler|java.util.Date|TIME|
|SqlTimestampTypeHandler|java.sql.Timestamp|TIMESTAMP|
|SqlDateTypeHandler|java.sql.Date|DATE|
|SqlTimeTypeHandler|java.sql.Time|TIME|
|ObjectTypeHandler|Any|OTHER, or unspecified|
|EnumTypeHandler|Enumeration Type|VARCHAR any string compatible type, as the code is stored (not index).|
|EnumOrdinalTypeHandler|Enumeration Type|Any compatible NUMERIC or DOUBLE, as the position is stored (not the code itself).|
|SqlxmlTypeHandler|java.lang.String|SQLXML|
|InstantTypeHandler|java.time.Instant|TIMESTAMP|
|LocalDateTimeTypeHandler|java.time.LocalDateTime|TIMESTAMP|
|LocalDateTypeHandler|java.time.LocalDate|DATE|
|LocalTimeTypeHandler|java.time.LocalTime|TIME|
|OffsetDateTimeTypeHandler|java.time.OffsetDateTime|TIMESTAMP|
|OffsetTimeTypeHandler|java.time.OffsetTime|TIME|
|ZonedDateTimeTypeHandler|java.time.ZonedDateTime|TIMESTAMP|
|YearTypeHandler|java.time.Year|INTEGER|
|MonthTypeHandler|java.time.Month|INTEGER|
|YearMonthTypeHandler|java.time.YearMonth|VARCHAR or LONGVARCHAR|
|JapaneseDateTypeHandler|java.time.chrono.JapaneseDate|DATE|

你可以覆盖 `TypeHandler `或者创建自己的 `TypeHandler` 来处理没有默认支持或者非标准` Class`。你可以选择实现`org.apache.ibatis.type.TypeHandler` 或者继承 ` org.apache.ibatis.type.BaseTypeHandler` 并将其映射为` JDBC `类型（可选）。

以下是自定义的` TypeHandler`，解决 mybatis 存储 blob 字段后，出现乱码的问题；同时，还有注册方式：

```java
@MappedJdbcTypes(JdbcType.BLOB)
public class ConvertBlobTypeHandler extends BaseTypeHandler<String> {// 指定字符集
	private static final String DEFAULT_CHARSET = "utf-8";

	@Override
	public void setNonNullParameter(PreparedStatement ps, int i, String parameter, JdbcType jdbcType)
			throws SQLException {
		ByteArrayInputStream bis;
		try {
			bis = new ByteArrayInputStream(parameter.getBytes(DEFAULT_CHARSET));
		} catch (UnsupportedEncodingException e) {
			throw new RuntimeException("Blob Encoding Error!");
		}
		ps.setBinaryStream(i, bis, parameter.getBytes().length);
	}
	 
	@Override
	public String getNullableResult(ResultSet rs, String columnName) throws SQLException {
		Blob blob = rs.getBlob(columnName);
		byte[] returnValue = null;
		if (null != blob) {
			returnValue = blob.getBytes(1, (int) blob.length());
			try {
				return new String(returnValue, DEFAULT_CHARSET);
			} catch (UnsupportedEncodingException e) {
				throw new RuntimeException("Blob Encoding Error!");
			}
		} else {
			return "";
		}
	 
	}
	 
	@Override
	public String getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
		Blob blob = cs.getBlob(columnIndex);
		byte[] returnValue = null;
		if (null != blob) {
			returnValue = blob.getBytes(1, (int) blob.length());
			try {
				return new String(returnValue, DEFAULT_CHARSET);
			} catch (UnsupportedEncodingException e) {
				throw new RuntimeException("Blob Encoding Error!");
			}
		} else {
			return "";
		}
	 
	}
	 
	@Override
	public String getNullableResult(ResultSet arg0, int arg1) throws SQLException {
		// TODO Auto-generated method stub
		return null;
	}
}
```
