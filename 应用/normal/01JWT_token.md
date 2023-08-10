资料来源：<br/>
[使用JWT生成token实现权限验证](https://blog.csdn.net/m0_59359926/article/details/123809705?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522168578457416800188583181%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=168578457416800188583181&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~top_positive~default-1-123809705-null-null.142^v88^control,239^v2^insert_chatgpt&utm_term=jwt%20token&spm=1018.2226.3001.4187)<br/>
[SpringBootJWTShiro](https://gitee.com/mrzhouy/SpringBootJWTShiro/tree/master)

## JWT

### 介绍
​        点击登录按钮，后端验证账号密码是否通过，如果通过则生成token，把token发送给前端，前端保存到cookie（前后端分离是不能使用保存session，因为每次发送ajax请求响应后都会断开服务器，就会导致session生命周期就销毁掉，然后再发送请求时再重新连接服务器，session已经不存在了），之后访问受限资源就需要取cookie拿到token，然后作为参数（放在请求头更安全）发送给后端，后端验证token。

Jwt介绍
Jwt是由三部分组成的字符串（header头部，payload载荷，signature签名）

头部：用于描述关于该 JWT 的最基本的信息，例如其类型以及签名所用的算法等。这也可以被表示成一个 JSON 对象。例如：

```
{
    "typ": "JWT",
    "alg": "HS256"
}
```

载荷：其实就是自定义的数据，一般存储用户 Id，过期时间等信息。也就是 JWT 的核心所在，因为这些数据就是使后端知道此 token 是哪个用户已经登录的凭证。而且这些数据是存在 token 里面的，由前端携带，所以后端几乎不需要保存任何数据。
例如：

```
{
    "uid": "xxxxidid", //用户id
    "exp": "12121212" //过期时间
}
```

签名：1.头部和载荷 各自base64加密后用.连接起来，然后就形成了 xxx.xx 的前两段 token。2.最后一段 token 的形成是，前两段加入一个密匙用 HS256 算法或者其他算法加密形成。3. 所以 token3 段的形成就是在签名处形成的。
将这三部分用.连接成一个完整的字符串,构成了最终的jwt

### 实现

依赖的jar 

```xml
<!--jwt token-->
			<dependency>
				<groupId>io.jsonwebtoken</groupId>
				<artifactId>jjwt</artifactId>
				<version>0.9.0</version>
			</dependency>
			<dependency>
				<groupId>com.auth0</groupId>
				<artifactId>java-jwt</artifactId>
				<version>3.5.0</version>
			</dependency>
```

**工具类**

```java

import com.yuandi.injectiondispenser.core.security.UserBean;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * 资料来源：https://juejin.cn/post/7176803095525982269
 * JwtToken生成的工具类 JWT token的格式：header.payload.signature header的格式（算法、token的类型）： {"alg":
 * "HS512","typ": "JWT"} payload的格式（用户名、创建时间、生成时间）： {"sub":"wang","created":1489079981393,"exp":1489684781}
 * signature的生成算法： HMACSHA512(base64UrlEncode(header) + "." +base64UrlEncode(payload),secret)
 */
@Slf4j
@Component
public class JwtTokenUtil {

    private String CLAIM_KEY_CREATED = "";


    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    @Value("${jwt.tokenHead}")
    private String tokenHead;

    /**
     * 根据负责生成JWT的token
     */
    private String generateToken(Map<String, Object> claims) {
        return tokenHead+ " " + Jwts.builder()
                .setClaims(claims)
                .setExpiration(generateExpirationDate())
                .signWith(SignatureAlgorithm.HS512, secret)
                .compact();
    }

    /**
     * 从token中获取JWT中的负载
     */
    private Claims getClaimsFromToken(String token) {
        String tokenBody = token.split(" ")[1];
        Claims claims = null;
        try {
            claims = Jwts.parser()
                    .setSigningKey(secret)
                    .parseClaimsJws(tokenBody)
                    .getBody();
        } catch (Exception e) {
            log.info("JWT格式验证失败:{}", tokenBody);
        }
        return claims;
    }


    /**
     * 生成token的过期时间
     */
    private Date generateExpirationDate() {
        return new Date(System.currentTimeMillis() + expiration * 1000);
    }

    /**
     * 从token中获取登录用户名
     */
    public UserBean getUser(String token) {
        try {
            Claims claims = getClaimsFromToken(token);
            Long id = claims.get("id",Long.class);
            String username = claims.get("userName",String.class);

            UserBean userBean = new UserBean();
            userBean.setId(id);
            userBean.setUserName(username);
            return userBean;
        } catch (Exception e) {
            e.printStackTrace();
        }
       return null;
    }

    /**
     * 验证token是否还有效
     *
     * @param token       客户端传入的token
     * @param -userDetails 从数据库中查询出来的用户信息
     */
//    public boolean validateToken(String token, UserDetails userDetails) {
//        String username = getUserNameFromToken(token);
//        return username.equals(userDetails.getUsername()) && !isTokenExpired(token);
//    }
    public boolean validateToken(String token) {
        return isTokenExpired(token);
    }

    /**
     * 判断token是否已经失效
     */
    private boolean isTokenExpired(String token) {
        Date expiredDate = getExpiredDateFromToken(token);
        return expiredDate.after(new Date());
    }

    /**
     * 从token中获取过期时间
     */
    private Date getExpiredDateFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims.getExpiration();
    }

    /**
     * 根据用户信息生成token
     */
    public String generateToken(Long id, String userName) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("id", id);
        claims.put("userName", userName);
        return generateToken(claims);
    }

    /**
     * 当原来的token没过期时是可以刷新的
     *
     * @param oldToken 带tokenHead的token
     */
    public String refreshHeadToken(String oldToken) {
//    if (StrUtil.isEmpty(oldToken)) {
//      return null;
//    }
        if (StringUtils.isBlank(oldToken)) {
            return null;
        }
        String token = oldToken.substring(tokenHead.length());
//    if (StrUtil.isEmpty(token)) {
//      return null;
//    }
        if (StringUtils.isBlank(token)) {
            return null;
        }
        //token校验不通过
        Claims claims = getClaimsFromToken(token);
        if (Objects.isNull(claims)) {
            return null;
        }
        //如果token已经过期，不支持刷新
        if (isTokenExpired(token)) {
            return null;
        }
        //如果token在30分钟之内刚刷新过，返回原token
        if (tokenRefreshJustBefore(token, 30 * 60)) {
            return token;
        } else {
            claims.put(CLAIM_KEY_CREATED, new Date());
            return generateToken(claims);
        }
    }

    /**
     * 判断token在指定时间内是否刚刚刷新过
     *
     * @param token 原token
     * @param time  指定时间（秒）
     */
    private boolean tokenRefreshJustBefore(String token, int time) {
        Claims claims = getClaimsFromToken(token);
        Date created = claims.get(CLAIM_KEY_CREATED, Date.class);
        Date refreshDate = new Date();
        //刷新时间在创建时间的指定时间内
        if (refreshDate.after(created) && refreshDate.before(cn.hutool.core.date.DateUtil.offsetSecond(created, time))) {
            return true;
        }
        return false;
    }
}
```

**登录接口**

```java

import com.yuandi.injectiondispenser.core.security.PasswordUtils;
import com.yuandi.injectiondispenser.core.web.ErrorCode;
import com.yuandi.injectiondispenser.core.web.Result;
import com.yuandi.injectiondispenser.system.domain.model.system.SysUser;
import com.yuandi.injectiondispenser.system.security.JwtTokenUtil;
import com.yuandi.injectiondispenser.system.sys.data.request.LogResquest;
import com.yuandi.injectiondispenser.system.sys.data.response.LoginResponse;
import com.yuandi.injectiondispenser.system.sys.service.LoginService;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;

@Slf4j
@RestController
public class LoginController {

    @Autowired
    private LoginService loginService;

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    /**
     * 登录接口
     * @param logParam
     * @param response
     * @return
     */
    @SneakyThrows
    @PostMapping("/login")
    public Result login(@RequestParam("username") String username,
                          @RequestParam("password") String psd, HttpServletResponse response) {
        log.info("收到的数据是：{}" + logParam);
        response.setCharacterEncoding("utf-8");
        response.setContentType("application/json");
      
        SysUser user = loginService.findUser(username);
        if (user == null) {
            return Result.failure(ErrorCode.USER_CREDENTIALS_USERNAME_OR_PASSWORD_INVALID);
        } else {

            Long id = user.getId();
            String userName = user.getUserName();
            String password = user.getPassword();
            boolean matches = PasswordUtils.matches(psd, password);
            // 密码正确
            if (matches) {
                String token = jwtTokenUtil.generateToken(id, userName);
                response.setHeader("token", token);

                LoginResponse res = new LoginResponse();
                res.setUsername(username);
                res.setId(id);
                res.setToken(token);

                return Result.success(res);
            } else {
                return Result.failure(ErrorCode.USER_PASSWORD_WRONG);
            }
        }
    }

}
```

密码工具类

```java
package com.yuandi.injectiondispenser.core.security;


/**
 * 密码工具类
 * 
 * @author gaigeshen
 */
public final class PasswordUtils {
  
  private PasswordUtils() { }

  /**
   * 密码编码器
   */
  private static final PasswordEncoder ENCODER = new BCryptPasswordEncoder(4);

  /**
   * 
   * 返回预定义的编码器
   * 
   * @return 编码器
   */
  public static PasswordEncoder encoder() {
    return ENCODER;
  }

  /**
   * 编码明文
   * 
   * @param plainText
   *          明文字符串内容
   * @return 编码后的密文
   */
  public static String encode(String plainText) {
    return encoder().encode(plainText);
  }

  /**
   * 比较明文和密文
   * 
   * @param plainText
   *          明文字符串内容
   * @param encodedText
   *          密文字符串内容
   * @return 是否匹配
   */
  public static boolean matches(String plainText, String encodedText) {
    return encoder().matches(plainText, encodedText);
  }
}

```

加密工具类

```java
public interface PasswordEncoder {
    String encode(CharSequence var1);

    boolean matches(CharSequence var1, String var2);

    default boolean upgradeEncoding(String encodedPassword) {
        return false;
    }
}
```

实现类

```java
package com.yuandi.injectiondispenser.core.security;

import cn.hutool.crypto.digest.BCrypt;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.security.SecureRandom;
import java.util.regex.Pattern;

public class BCryptPasswordEncoder implements PasswordEncoder {
    private Pattern BCRYPT_PATTERN;
    private final Log logger;
    private final int strength;
    private final SecureRandom random;

    public BCryptPasswordEncoder() {
        this(-1);
    }

    public BCryptPasswordEncoder(int strength) {
        this(strength, (SecureRandom)null);
    }

    public BCryptPasswordEncoder(int strength, SecureRandom random) {
        this.BCRYPT_PATTERN = Pattern.compile("\\A\\$2a?\\$\\d\\d\\$[./0-9A-Za-z]{53}");
        this.logger = LogFactory.getLog(this.getClass());
        if (strength == -1 || strength >= 4 && strength <= 31) {
            this.strength = strength;
            this.random = random;
        } else {
            throw new IllegalArgumentException("Bad strength");
        }
    }

    public String encode(CharSequence rawPassword) {
        String salt;
        if (this.strength > 0) {
            if (this.random != null) {
                salt = BCrypt.gensalt(this.strength, this.random);
            } else {
                salt = BCrypt.gensalt(this.strength);
            }
        } else {
            salt = BCrypt.gensalt();
        }

        return BCrypt.hashpw(rawPassword.toString(), salt);
    }

    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        if (encodedPassword != null && encodedPassword.length() != 0) {
            if (!this.BCRYPT_PATTERN.matcher(encodedPassword).matches()) {
                this.logger.warn("Encoded password does not look like BCrypt");
                return false;
            } else {
                return BCrypt.checkpw(rawPassword.toString(), encodedPassword);
            }
        } else {
            this.logger.warn("Empty encoded password");
            return false;
        }
    }
}
```

过滤拦截

```java
import com.alibaba.fastjson2.JSON;
import com.yuandi.injectiondispenser.core.security.UserBean;
import com.yuandi.injectiondispenser.core.web.Result;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.UnsupportedJwtException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;


@Component
public class CheckTokenInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        //关于浏览器的请求预检.在跨域的情况下，非简单请求会先发起一次空body的OPTIONS请求，称为"预检"请求，用于向服务器请求权限信息，等预检请求被成功响应后，才发起真正的http请求。
        String method = request.getMethod();
        if("OPTIONS".equalsIgnoreCase(method)){
            return true;
        }
//        String token = request.getParameter("token");放入params才能用这个，放hearder用getHearder
        String token = request.getHeader("token");
        if(token == null){

            Result<Object> fail = Result.fail("需要先进行登录处理");
            doResponse(response,fail);
        }else{
            try {
//                JwtParser parser = Jwts.parser();
//                parser.setSigningKey("ycj123456"); //解析token的SigningKey必须和生成token时设置密码一致
                //如果token检验通过（密码正确，有效期内）则正常执行，否则抛出异常
//                Jws<Claims> claimsJws = parser.parseClaimsJws(token);
                boolean validateToken = jwtTokenUtil.validateToken(token);
                UserBean user = jwtTokenUtil.getUser(token);
                request.setAttribute("currentUser", user); //把当前的用户信息放到request中

                return validateToken;//true就是验证通过，放行
            }catch (ExpiredJwtException e){
//                ResultVO resultVO = new ResultVO(ResStatus.LOGIN_FAIL_OVERDUE, "登录过期，请重新登录！", null);
//                doResponse(response,resultVO);
            }catch (UnsupportedJwtException e){
//                ResultVO resultVO = new ResultVO(ResStatus.LOGIN_FAIL_NOT, "Token不合法，请自重！", null);
//                doResponse(response,resultVO);
            }catch (Exception e){
//                ResultVO resultVO = new ResultVO(ResStatus.LOGIN_FAIL_NOT, "请先登录！", null);
//                doResponse(response,resultVO);
            }
        }
        return false;
    }


    //没带token或者检验失败响应给前端
    private void doResponse(HttpServletResponse response, Result result) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("utf-8");
        PrintWriter out = response.getWriter();
//        String s = new ObjectMapper().writeValueAsString(resultVO);
        String s = JSON.toJSON(result).toString();

        out.print(s);
        out.flush();
        out.close();
    }

}
```

拦截配置

```java

import com.yuandi.injectiondispenser.core.security.CurrentUserMethodArgumentResolver;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;

import java.util.List;

@Configuration
public class InterceptorConfig  extends WebMvcConfigurerAdapter {
 
    @Autowired
    private CheckTokenInterceptor  checkTokenInterceptor;
 
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(checkTokenInterceptor)
//                .addPathPatterns("/demo/**")
                .addPathPatterns("/menu/**");
    }

    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> argumentResolvers) {
        argumentResolvers.add(currentUserMethodArgumentResolver());
        super.addArgumentResolvers(argumentResolvers);
    }

    @Bean
    public CurrentUserMethodArgumentResolver currentUserMethodArgumentResolver() {
        return new CurrentUserMethodArgumentResolver();
    }
}
```

使用的注解

```java
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 在Controller的方法参数中使用此注解，该方法在映射时会注入当前登录的User对象
 */
@Target(ElementType.PARAMETER)          // 可用在方法的参数上
@Retention(RetentionPolicy.RUNTIME)     // 运行时有效
public @interface CurrentUser {
}
```

获取用户信息方式

只需要在`control`的方法中加上`@CurrentUse`注解就可以获取

```java
    @GetMapping("/user-menus")
    public Result userMenus(@CurrentUser UserBean user){

        System.out.println(user);
        List<MenuStruct> menuStructs = menuService.userMenus(user);
        return Result.success(menuStructs);
    }
```

