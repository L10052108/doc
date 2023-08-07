资料来源：<br/>
[SpringBoot 快速实现 IP 地址解析](https://mp.weixin.qq.com/s/G-u1IgFAmIumAZ990og9vA)<br/>
[准确率 99.9% 的离线IP地址定位库](https://mp.weixin.qq.com/s/m0Pxbi3QMekxRrz8KvpDcQ)

## 介绍

Ip2region 是一个离线 IP 地址定位库，准确率高达 99.9%，搜索性能为 0.0x 毫秒。DB 文件只有几兆字节，其中存储了所有 IP 地址。支持 Java、PHP、C、Python、Nodejs、Golang、C#、lua 等查询绑定。查询算法使用二叉树、B树和内存搜索算法。

**查询准确率高达99.9%**

数据来源于一些知名的 IP 查询提供商，经测试比纯 IP 定位更准确一些。

- \>80% ，淘宝IP地址库：http://ip.taobao.com
- ≈10% ，GeoIP：https://geoip.com
- ≈2% ，纯真IP库：http://www.cz88.net

**文件体积小**

数据库文件 ip2region.db 只有几 MB 大小，最小的版本不超过 1.5MB，最大的不超过 8MB。

**标准数据格式**

每条 ip 数据段都固定了格式，目前只有国内的数据可以精确到城市级别，其他国家只有部分可以定位到国家，其余无法确认的数据默认值为 0 。

**查询速度快**

所有客户端单次查询都在0.x毫秒级别，内置了三种查询算法：

- memory算法：整个数据库全部载入内存，单次查询都在0.1x毫秒内，C语言的客户端单次查询在0.00x毫秒级别。
- binary算法：基于二分查找，基于 ip2region.db文件，不需要载入内存，单次查询在0.x毫秒级别。
- b-tree算法：基于btree算法，基于 ip2region.db文件，不需要载入内存，单词查询在0.x毫秒级别，比 binary 算法更快。

**多种查询客户端的支持**

客户端已经集成 java、C#、php、c、python、nodejs、php 扩展(php5和php7)、golang、rust、lua、lua_c、nginx。

## ip查询

进行ip查询

```java
/**
 * ip查询
 */
@Slf4j
public class IPUtil {

    private static final String UNKNOWN = "unknown";

    protected IPUtil(){ }

    /**
     * 获取 IP地址
     * 使用 Nginx等反向代理软件， 则不能通过 request.getRemoteAddr()获取 IP地址
     * 如果使用了多级反向代理的话，X-Forwarded-For的值并不止一个，而是一串IP地址，
     * X-Forwarded-For中第一个非 unknown的有效IP字符串，则为真实IP地址
     */
    public static String getIpAddr(HttpServletRequest request) {
        String ip = request.getHeader("x-forwarded-for");
        if (ip == null || ip.length() == 0 || UNKNOWN.equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || UNKNOWN.equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || UNKNOWN.equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return "0:0:0:0:0:0:0:1".equals(ip) ? "127.0.0.1" : ip;
    }

    public static  String getAddr(String ip){
        String dbPath = "src/main/resources/ip2region/ip2region.xdb";
        // 1、从 dbPath 加载整个 xdb 到内存。
        byte[] cBuff;
        try {
            cBuff = Searcher.loadContentFromFile(dbPath);
        } catch (Exception e) {
            log.info("failed to load content from %s: %s\n", dbPath, e);
            return null;
        }

        // 2、使用上述的 cBuff 创建一个完全基于内存的查询对象。
        Searcher searcher;
        try {
            searcher = Searcher.newWithBuffer(cBuff);
        } catch (Exception e) {
           log.info("failed to create content cached searcher: %s\n", e);
            return null;
        }
        // 3、查询
        try {
            String region = searcher.searchByStr(ip);
            return region;
        } catch (Exception e) {
            log.info("failed to search(%s): %s\n", ip, e);
        }
        return null;
    }

```

这里我们将ip 解析封装成一个工具类，包含获取IP和ip 地址解析两个方法，ip 的解析可以在请求中获取。获取到ip后，需要根据ip ，在xdb 中查找对应的IP地址的解析，由于是本地数据库可能存在一定的缺失，部分ip 存在无法解析的情况。

#### 在线解析:

如果想要获取更加全面的ip 地址信息，可使用在线数据库，这里提供的是 whois.pconline.com 的IP解析，该IP解析在我的使用过程中表现非常流畅，而且只有少数的ip 存在无法解析的情况。

```java
@Slf4j
public class AddressUtils {
    // IP地址查询
    public static final String IP_URL = "http://whois.pconline.com.cn/ipJson.jsp";

    // 未知地址
    public static final String UNKNOWN = "XX XX";

    public static String getRealAddressByIP(String ip) {
        String address = UNKNOWN;
        // 内网不查询
        if (IpUtils.internalIp(ip)) {
            return "内网IP";
        }
        if (true) {
            try {
                String rspStr = sendGet(IP_URL, "ip=" + ip + "&json=true" ,"GBK");
                if (StrUtil.isEmpty(rspStr)) {
                    log.error("获取地理位置异常 {}" , ip);
                    return UNKNOWN;
                }
                JSONObject obj = JSONObject.parseObject(rspStr);
                String region = obj.getString("pro");
                String city = obj.getString("city");
                return String.format("%s %s" , region, city);
            } catch (Exception e) {
                log.error("获取地理位置异常 {}" , ip);
            }
        }
        return address;
    }

    public static String sendGet(String url, String param, String contentType) {
        StringBuilder result = new StringBuilder();
        BufferedReader in = null;
        try {
            String urlNameString = url + "?" + param;
            log.info("sendGet - {}" , urlNameString);
            URL realUrl = new URL(urlNameString);
            URLConnection connection = realUrl.openConnection();
            connection.setRequestProperty("accept" , "*/*");
            connection.setRequestProperty("connection" , "Keep-Alive");
            connection.setRequestProperty("user-agent" , "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)");
            connection.connect();
            in = new BufferedReader(new InputStreamReader(connection.getInputStream(), contentType));
            String line;
            while ((line = in.readLine()) != null) {
                result.append(line);
            }
            log.info("recv - {}" , result);
        } catch (ConnectException e) {
            log.error("调用HttpUtils.sendGet ConnectException, url=" + url + ",param=" + param, e);
        } catch (SocketTimeoutException e) {
            log.error("调用HttpUtils.sendGet SocketTimeoutException, url=" + url + ",param=" + param, e);
        } catch (IOException e) {
            log.error("调用HttpUtils.sendGet IOException, url=" + url + ",param=" + param, e);
        } catch (Exception e) {
            log.error("调用HttpsUtil.sendGet Exception, url=" + url + ",param=" + param, e);
        } finally {
            try {
                if (in != null) {
                    in.close();
                }
            } catch (Exception ex) {
                log.error("调用in.close Exception, url=" + url + ",param=" + param, ex);
            }
        }
        return result.toString();
    }
}
```

#### 场景：

那么在开发的什么流程获取ip 地址是比较合适的，这里就要用到我们的拦截器了。拦截进入服务的每个请求，进行前置操作，在进入时就完成请求头的解析，ip 获取以及ip 地址解析，这样在后续流程的全环节，都可以复用ip 地址等信息。

```java
/**
 * 对ip 进行限制，防止IP大量请求
 */
@Slf4j
@Configuration
public class IpUrlLimitInterceptor implements HandlerInterceptor{

    @Override
    public boolean preHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o) {

        //更新全局变量
        Constant.IP = IPUtil.getIpAddr(httpServletRequest);
        Constant.IP_ADDR = AddressUtils.getRealAddressByIP(Constant.IP);
        Constant.URL = httpServletRequest.getRequestURI();
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, ModelAndView modelAndView) {
        //通过本地获取
//        获得ip
//        String ip = IPUtil.getIpAddr(httpServletRequest);
        //解析具体地址
//        String addr = IPUtil.getAddr(ip);

        //通过在线库获取
//        String ip = IpUtils.getIpAddr(httpServletRequest);
//        String ipaddr = AddressUtils.getRealAddressByIP(ipAddr);
//        log.info("IP >> {},Address >> {}",ip,ipaddr);
    }

    @Override
    public void afterCompletion(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, Object o, Exception e) {

    }
}
```

如果想要执行我们的ip 解析拦截器，需要在spring boot的视图层进行拦截才会触发我们的拦截器。

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Autowired
    IpUrlLimitInterceptor ipUrlLimitInterceptor;
 
     //执行ip拦截器
    @Override
    public void addInterceptors(InterceptorRegistry registry){
        registry.addInterceptor(ipUrlLimitInterceptor)
                // 拦截所有请求
                .addPathPatterns("/**");
    }
}
```

通过这样的一套流程下来，我们就能实现对每一个请求进行ip 获取、ip解析，为每个请求带上具体ip地址的小尾巴。

## 使用

### maven 仓库：

```xml
<dependency>
    <groupId>org.lionsoul</groupId>
    <artifactId>ip2region</artifactId>
    <version>2.7.0</version>
</dependency>
```

### 完全基于文件的查询

```
import org.lionsoul.ip2region.xdb.Searcher;
import java.io.*;
import java.util.concurrent.TimeUnit;

public class SearcherTest {
    public static void main(String[] args) {
        // 1、创建 searcher 对象
        String dbPath = "ip2region.xdb file path";
        Searcher searcher = null;
        try {
            searcher = Searcher.newWithFileOnly(dbPath);
        } catch (IOException e) {
            System.out.printf("failed to create searcher with `%s`: %s\n", dbPath, e);
            return;
        }

        // 2、查询
        try {
            String ip = "1.2.3.4";
            long sTime = System.nanoTime();
            String region = searcher.search(ip);
            long cost = TimeUnit.NANOSECONDS.toMicros((long) (System.nanoTime() - sTime));
            System.out.printf("{region: %s, ioCount: %d, took: %d μs}\n", region, searcher.getIOCount(), cost);
        } catch (Exception e) {
            System.out.printf("failed to search(%s): %s\n", ip, e);
        }

        // 3、关闭资源
        searcher.close();
        
        // 备注：并发使用，每个线程需要创建一个独立的 searcher 对象单独使用。
    }
}
```



### 缓存 `VectorIndex` 索引

我们可以提前从 `xdb` 文件中加载出来 `VectorIndex` 数据，然后全局缓存，每次创建 Searcher 对象的时候使用全局的 VectorIndex 缓存可以减少一次固定的 IO 操作，从而加速查询，减少 IO 压力。

```
import org.lionsoul.ip2region.xdb.Searcher;
import java.io.*;
import java.util.concurrent.TimeUnit;

public class SearcherTest {
    public static void main(String[] args) {
        String dbPath = "ip2region.xdb file path";

        // 1、从 dbPath 中预先加载 VectorIndex 缓存，并且把这个得到的数据作为全局变量，后续反复使用。
        byte[] vIndex;
        try {
            vIndex = Searcher.loadVectorIndexFromFile(dbPath);
        } catch (Exception e) {
            System.out.printf("failed to load vector index from `%s`: %s\n", dbPath, e);
            return;
        }

        // 2、使用全局的 vIndex 创建带 VectorIndex 缓存的查询对象。
        Searcher searcher;
        try {
            searcher = Searcher.newWithVectorIndex(dbPath, vIndex);
        } catch (Exception e) {
            System.out.printf("failed to create vectorIndex cached searcher with `%s`: %s\n", dbPath, e);
            return;
        }

        // 3、查询
        try {
            String ip = "1.2.3.4";
            long sTime = System.nanoTime();
            String region = searcher.search(ip);
            long cost = TimeUnit.NANOSECONDS.toMicros((long) (System.nanoTime() - sTime));
            System.out.printf("{region: %s, ioCount: %d, took: %d μs}\n", region, searcher.getIOCount(), cost);
        } catch (Exception e) {
            System.out.printf("failed to search(%s): %s\n", ip, e);
        }
        
        // 4、关闭资源
        searcher.close();

        // 备注：每个线程需要单独创建一个独立的 Searcher 对象，但是都共享全局的制度 vIndex 缓存。
    }
}
```



### 缓存整个 `xdb` 数据

我们也可以预先加载整个 ip2region.xdb 的数据到内存，然后基于这个数据创建查询对象来实现完全基于文件的查询，类似之前的 memory search。

```
import org.lionsoul.ip2region.xdb.Searcher;
import java.io.*;
import java.util.concurrent.TimeUnit;

public class SearcherTest {
    public static void main(String[] args) {
        String dbPath = "ip2region.xdb file path";

        // 1、从 dbPath 加载整个 xdb 到内存。
        byte[] cBuff;
        try {
            cBuff = Searcher.loadContentFromFile(dbPath);
        } catch (Exception e) {
            System.out.printf("failed to load content from `%s`: %s\n", dbPath, e);
            return;
        }

        // 2、使用上述的 cBuff 创建一个完全基于内存的查询对象。
        Searcher searcher;
        try {
            searcher = Searcher.newWithBuffer(cBuff);
        } catch (Exception e) {
            System.out.printf("failed to create content cached searcher: %s\n", e);
            return;
        }

        // 3、查询
        try {
            String ip = "1.2.3.4";
            long sTime = System.nanoTime();
            String region = searcher.search(ip);
            long cost = TimeUnit.NANOSECONDS.toMicros((long) (System.nanoTime() - sTime));
            System.out.printf("{region: %s, ioCount: %d, took: %d μs}\n", region, searcher.getIOCount(), cost);
        } catch (Exception e) {
            System.out.printf("failed to search(%s): %s\n", ip, e);
        }
        
        // 4、关闭资源 - 该 searcher 对象可以安全用于并发，等整个服务关闭的时候再关闭 searcher
        // searcher.close();

        // 备注：并发使用，用整个 xdb 数据缓存创建的查询对象可以安全的用于并发，也就是你可以把这个 searcher 对象做成全局对象去跨线程访问。
    }
}
```



### 编译测试程序

通过 maven 来编译测试程序。

```
# cd 到 java binding 的根目录
cd binding/java/
mvn compile package
```



然后会在当前目录的 target 目录下得到一个 ip2region-{version}.jar 的打包文件。

### 查询测试

可以通过 `java -jar ip2region-{version}.jar search` 命令来测试查询：

```
➜  java git:(v2.0_xdb) ✗ java -jar target/ip2region-2.6.0.jar search
java -jar ip2region-{version}.jar search [command options]
options:
 --db string              ip2region binary xdb file path
 --cache-policy string    cache policy: file/vectorIndex/content
```



例如：使用默认的 data/ip2region.xdb 文件进行查询测试：

```
➜  java git:(v2.0_xdb) ✗ java -jar target/ip2region-2.6.0.jar search --db=../../data/ip2region.xdb
ip2region xdb searcher test program, cachePolicy: vectorIndex
type 'quit' to exit
ip2region>> 1.2.3.4
{region: 美国|0|华盛顿|0|谷歌, ioCount: 7, took: 82 μs}
ip2region>>
```



输入 ip 即可进行查询测试，也可以分别设置 `cache-policy` 为 file/vectorIndex/content 来测试三种不同缓存实现的查询效果。

### bench 测试

可以通过 `java -jar ip2region-{version}.jar bench` 命令来进行 bench 测试，一方面确保 `xdb` 文件没有错误，一方面可以评估查询性能：

```
➜  java git:(v2.0_xdb) ✗ java -jar target/ip2region-2.6.0.jar bench
java -jar ip2region-{version}.jar bench [command options]
options:
 --db string              ip2region binary xdb file path
 --src string             source ip text file path
 --cache-policy string    cache policy: file/vectorIndex/content
```

例如：通过默认的 data/ip2region.xdb 和 data/ip.merge.txt 文件进行 bench 测试：

```
➜  java git:(v2.0_xdb) ✗ java -jar target/ip2region-2.6.0.jar bench --db=../../data/ip2region.xdb --src=../../data/ip.merge.txt
Bench finished, {cachePolicy: vectorIndex, total: 3417955, took: 8s, cost: 2 μs/op}
```

可以通过分别设置 `cache-policy` 为 file/vectorIndex/content 来测试三种不同缓存实现的效果。 @Note: 注意 bench 使用的 src 文件要是生成对应 xdb 文件相同的源文件。