资料来源：

[还原最本质的JDBC轻量级封装的工具包：Apache Common DbUtils](https://juejin.cn/post/6999242756312793119)



## DbUtils

### 介绍

  如果只使用JDBC进行开发，我们会发现冗余代码过多，为了`简化JDBC开发`，本案例我们讲采用`apache commons组件`一个成员：`Apache Commons DbUtils`。
 **Apache Commons DbUtils** 工具是一个轻量级的持久层解决方案，是个小巧的JDBC轻量级封装的工具包，其最核心的特性是在JDBC的基础上做了一层封装，让开发人员能够以一种高级API的方式使用JDBC技术完成原本复杂的CRUD操作。而且其还对结果集的封装，可以直接将查询出来的结果集封装成JavaBean。DBUtils旨在简化JDBC代码混乱与重复，因此有助于抽取出重复代码，以便开发人员只专注于与数据库相关的操作。


 对于DbUtils 有基本的了解后，就开始正式的使用吧！既然上面说过DbUtils 是操作数据库的，以mysql为例，那么让我们来看下是如何连接数据库的，见如下：



| 方法                | 说明     |
| ------------------- | -------- |
| **void close(...)** | 关闭连接 |
|**void closeQuietly(...)**|关闭连接，并忽略异常|
|**commitAndClose(Connection conn)**|在连接内提交SQL，然后关闭连接|
|**commitAndCloseQuietly(Connection conn)**|在连接内提交SQL，然后关闭连接，并忽略异常|
|**loadDriver(ClassLoader classLoader, String driverClassName)**||
|**loadDriver(String driverClassName)**|载入并注册JDBC驱动，如果成功就返回true，失败返回false。 使用该方法，无需捕捉ClassNotFoundException异常|
|**printStackTrace(SQLException e)**||
|**printStackTrace(SQLException e, PrintWriter pw)**||
|**printWarnings(Connection conn)**||
|**printWarnings(Connection conn, PrintWriter pw)**||
|**rollback(Connection conn)**|回滚操作|
|**rollbackAndClose(Connection conn)**||
|**rollbackAndCloseQuietly(Connection conn)**||

### 案例

对于DbUtils 有基本的了解后，就开始正式的使用吧！既然上面说过DbUtils 是操作数据库的，以mysql为例，那么让我们来看下是如何连接数据库的，见如下：

```java
public class CommonsDbutilsTest {
    // 数据库连接对象Connection
    private Connection connection = null;
    // DbUtils核心工具类对象
    QueryRunner queryRunner;
    // 数据库地址
    private static final String URL = "jdbc:mysql://localhost:3306/dbutils";
    // 连接数据库用的驱动
    private static final String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";
    // 数据库用户名
    private static final String USER = "test";
    // 数据库密码
    private static final String PASSWORD = "test";

    @Before
    public void before() throws SQLException {
        // Step 1: 加载数据库驱动
        DbUtils.loadDriver(JDBC_DRIVER);
        // Step 2: 获取数据库连接对象
        connection = DriverManager.getConnection(URL, USER, PASSWORD);
        // Step 3: 创建DbUtils核心工具类对象
        queryRunner = new QueryRunner();
    }

    /**
     * 关闭Connection数据库连接对象
     */
    @After
    public void after() {
        DbUtils.closeQuietly(connection);
    }
}

```

接下来开始对数据库的基本操作吧！

```java
@Test
public void insert() throws SQLException {
    String sql = "insert into users(userCode,userName,email,createTime) values(?,?,?,?)";
    Object[] params = {"dllwh", "独泪了无痕", "duleilewuhen@sina.com", new Date()};
    queryRunner.update(connection, sql, params);
    queryRunner.insert(connection, sql, new MapHandler(), params);
}

@Test
public void delete() throws SQLException {
    String sql = "delete from users where id=?";
    queryRunner.update(sql, 1);
}

@Test
public void update() throws SQLException {
    String sql = "update users set name=? where id=?";
    Object[] params = {"ddd", 5};
    queryRunner.update(connection, sql, params);
}

@Test
public void testBatch() throws SQLException {
    String sql = "insert into users(userCode,userName,email,createTime) values(?,?,?,?)";
    Object[][] params = new Object[10][];
    for (int i = 0; i < 10; i++) {
        params[i] = new Object[]{"aa" + i, "123", "aa@sina.com", new Date()};
    }
    queryRunner.batch(connection, sql, params);
}

```

### ResultSetHandler

 `ResultSetHandler`是DbUtils中的一个接口，该接口的实现类可用于将JDBC查询语句返回的结果(也就是`ResultSet`)，将数据转变并处理为任何一种形式。
 ResultSetHandler接口提供了一个单独的方法：Object handle (java.sql.ResultSet .rs)。因此任何ResultSetHandler的执行需要一个结果集（ResultSet）作为参数传入，然后才能处理这个结果集，再返回一个对象。因为返回类型是java.lang.Object，所以除了不能返回一个原始的Java类型之外，其它的返回类型并没有什么限制。
 由于ResultSetHandler接口中只有一个抽象方法，所以如果是Java 8版本的话也可以使用Lambda表达式来简化代码：

```java
/**
 * 此接口的实现将 ResultSet 转换为其他对象
 * T： 目标类型（类型参数），也就是 ResultSet 转换为的对象的类型
 */
public interface ResultSetHandler<T> {
    /**
     * 将 ResultSet 转换为一个对象
     *
     * @param rs 要转换的 ResultSet
     * 
     * @return 如果 ResultSet 包含0行，那么实现返回 null 也是合法的
     * @throws 数据库访问出错将会抛出 SQLException 异常
     */
    T handle(ResultSet rs) throws SQLException;
}

```

  DbUtils提供了一些常用的`ResultSetHandler`实现类，可以简化查询，一般情况下不需要像上面那样自己来实现`ResultSetHandler`接口。ResultSetHandler 接口的实现类：

ArrayHandler会返回一个数组，用于将结果集`第一行`数据转换为数组。

```java
@Test
public void arrayHandler() throws SQLException {
    String sql = "select * from users";
    Object[] result = queryRunner.query(connection, sql, new ArrayHandler());
    System.out.println(Arrays.asList(result));
}
```

####  ArrayListHandler

  ArrayListHandler会返回一个集合，把结果集中的`每一行`数据都转成一个对象数组，再存放到List中。

```java
public void arrayListHandler() throws SQLException {
    String sql = "select * from users";
    List<Object[]> resultList = queryRunner.query(connection, sql, new ArrayListHandler());
    resultList.forEach(object -> System.out.println(Arrays.asList(object)));
}
```

####  BeanHandler

  BeanHandler实现了将结果集`第一行`数据转换为Bean对象，即数据库查询的结果只有一条记录，在实际应用中非常方便。

```java
@Test
public void beanHandler() throws SQLException {
    String sql = "SELECT userName FROM users where id = ?";
    Object[] params = {1};
    Person person = queryRunner.query(connection, sql, new BeanHandler<Person>(Person.class), params);
    System.out.println(person);
}
```

####  BeanListHandler

  使用BeanListHandler查询对象，将结果集中的`每一行`数据都封装到一个对应的JavaBean实例中，然后将JavaBean添加到List中。

```java
@Test
public void beanListHandler() throws SQLException {
    QueryRunner queryRunner = new QueryRunner();
    String sql = "SELECT userName FROM users";
    List<Person> resultList = (List<Person>) queryRunner.query(connection, sql, new BeanListHandler(Person.class));
    resultList.forEach(person -> System.out.println(person.getUserName()));
}
```

#### BeanMapHandler

  BeanMapHandler将结果集中的`每一行`数据都封装到一个JavaBean里，再把这些JavaBean再存到一个Map里，Map中每条数据对应查询结果的一条数据，key为数据的主键或者唯一索引，value是数据通过反射机制转成的Java对象。

```java
@Test
public void beanMapHandler() throws SQLException {
    String sql = "select * from users";
    // 使用userCode列作为Map的key
    Map<String, Person> result = queryRunner.query(connection, sql, new BeanMapHandler<String, Person>(Person.class, "userCode"));
    System.out.println(result);
}
```

#### ColumnListHandler

  ColumnListHandler会返回一个集合，集合中的数据为结果集中指定列的数据，缺省值为第一列。

```java
@Test
public void columnListHandler() throws SQLException {
    String sql = "select * from users";
    List resultList = (List) queryRunner.query(connection, sql, new ColumnListHandler());
    resultList.forEach(column -> System.out.println(column));
    
    List resultList2 = (List) queryRunner.query(connection, sql, new ColumnListHandler("userCode"));
    resultList2.forEach(column -> System.out.println(column));
}
```

#### KeyedHandler

  KeyedHandler将结果集中的`每一行`数据都封装到一个MapA(key是行号,value是行数据)里，再把这些MapA再存到一个MapB(key为指定的列,value是对应里的行值即单值)里

```java
@Test
public void keyedHandler() throws SQLException {
    String sql = "select * from users";
    // Key指定为id列
    Map<Integer, Map> resultMap = (Map) queryRunner.query(connection, sql, new KeyedHandler("id"));
    for (Map.Entry<Integer, Map> me : resultMap.entrySet()) {
        int id = me.getKey();
        Map<String, Object> innermap = me.getValue();
        for (Map.Entry<String, Object> innerme : innermap.entrySet()) {
            String columnName = innerme.getKey();
            Object value = innerme.getValue();
            System.out.println(columnName + "=" + value);
        }
        System.out.println("----------------");
    }
}
```

#### MapHandler

  MapHandler会将结果集中的`第一行`数据封装到一个Map里，key是列名，value就是对应的值。

```java
@Test
public void mapHandler() throws SQLException {
    String sql = "select * from users";
    Map<String, Object> resultMap = (Map) queryRunner.query(connection, sql, new MapHandler());
    for (Map.Entry<String, Object> me : resultMap.entrySet()) {
        System.out.println(me.getKey() + "=" + me.getValue());
    }
}
```

#### MapListHandler

  MapListHandler会将结果集中的`每一行`数据都封装到一个Map里，然后再存放到List。集合中的数据为对应行转换的键值对，键为列名。

```java
@Test
public void mapListHandler() throws SQLException {
    QueryRunner queryRunner = new QueryRunner();
    String sql = "SELECT * FROM users";
    List<Map> resultList = (List) queryRunner.query(connection, sql, new MapListHandler());
    resultList.forEach(map -> System.out.println(map.get("userName")));
}
```

####ScalarHandler

  ScalarHandler会返回一个对象，用于读取结果集中第一行指定列的数据或返回一个统计函数的值，比如count(*)。`该实现类会自动推导数据库中数据的类型，注意类型的转换`

```java
@Test
public void scalarHandler() throws SQLException {
    String sql = "select count(*) from users";
    System.out.println(queryRunner.query(connection, sql, new ScalarHandler(1)));
    System.out.println(queryRunner.query(connection, sql, new ScalarHandler<Long>()));
}
```

## QueryRunner

 `org.apache.commons.dbutils.QueryRunner` 类是`DBUtils`库中的中心类。它使用可插入策略执行`SQL`查询以处理`ResultSet`，而且这个类是线程安全的。
 这个类使执行`SQL`查询简单化了，它与`ResultSetHandle`r串联在一起有效地履行着一些平常的任务，它能够大大减少你所要写的编码。`QueryRunner`类提供了两个构造器：其中一个是一个空构造器，另一个则拿一个`javax.sql.DataSource`来作为参数。因此，在你不用为一个方法提供一个数据库连接来作为参数的情况下，提供给构造器的数据源(`DataSource`)被用来获得一个新的连接并将继续进行下去。
 该类有多种构造方法，但是常用的大致可分为两种，如下所见：

| 方法                           | 说明                                                         |
| ------------------------------ | ------------------------------------------------------------ |
| **QueryRunner()**              | 创建核心类，没有提供数据源，在进行具体操作时，需要手动提供Connection |
| **QueryRunner(DataSource ds)** | 创建核心类，并提供数据源，内部自己维护Connection             |

该类中的还有几个比较常用的方法，由于其构造方法的不同，其或多或少的存在着不同，以无参构造 `new QueryRunner()` 为例说明，见如下：

| 方法                                                         | 说明                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| **batch(Connection conn,String sql,Object[][] params)**      | 批量执行INSERT、UPDATE或DELETE                               |
| **execute(Connection conn,String sql,Object... params)**     |                                                              |
| **execute(Connection conn,String sql,ResultSetHandler<T> rsh,Object... params)** |                                                              |
| **insert(Connection conn,String sql,ResultSetHandler<T> rsh)** | 执行一个插入查询语句                                         |
| i**nsert(Connection conn,String sql,ResultSetHandler<T> rsh,Object... params)** | 执行一个插入查询语句                                         |
| **insertBatch(Connection conn,String sql,ResultSetHandler<T> rsh,Object[][] params)** | 批量执行插入语句                                             |
| **query(Connection conn,String sql,ResultSetHandler<T> rsh)** | 执行一个查询操作，并将查询结果封装到对象中。 此方法会自行处理PreparedStatement和ResultSet的创建和关闭 |
| **query(Connection conn,String sql,ResultSetHandler<T> rsh,Object... params)** |                                                              |
| **update(Connection conn,String sql)**                       | 用来执行一个更新（插入、更新或删除）操作                     |
| **update(Connection conn,String sql,Object param)**          | 用来执行一个更新（插入、更新或删除）操作                     |
| **update(Connection conn,String sql,Object... params)**      | 用来执行一个更新（插入、更新或删除）操作                     |

