

## aop 租户的使用

### 1、注解

创建一个注解，需要使用租户相关的参数。只需要方这个注解

```java
import java.lang.annotation.*;

/**
 * 租户的注解，这个注解用来获取租户的值
 * 作用于方法和类上
 * 如果是没有登录的情况下，需要使用这个注解
 */
@Documented
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
public @interface Tenant {

}
```

### 2、注解切面

创建切面，在方法执行前，执行代码

```java
import cn.zhaotx.basic.vo.SysTenantVO;
import cn.zhaotx.specialist.common.utils.TenantContent;
import cn.zhaotx.specialist.common.utils.TenantHolder;
import cn.zhaotx.specialist.service.common.ITenantService;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.Assert;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@Aspect
@Component
public class TenantAspect {

    @Autowired
    private ITenantService tenantService;

    public TenantAspect() {
    }

    @Pointcut("@annotation(cn.zhaotx.specialist.common.annotation.Tenant) ")
    public void tenantAspect() {
    }

    /**
     * 执行之前的
     * @param joinPoint
     * @throws Throwable
     */
    @Before("tenantAspect()")
    public void doBefore(JoinPoint joinPoint) throws Throwable {
        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
        Assert.notNull(request, "@RepeatSubmit注解只用能于web环境.");

        // 放入到head 中
        String domainFromRequest = getDomainFromRequest(request);
        log.info("获取到的域名值是：{}",domainFromRequest);

        // 调用方法，uri 获取租户信息
        SysTenantVO tenant = tenantService.getTenantId(domainFromRequest);
        TenantContent tenantContent = TenantContent.of(tenant);
        tenantContent.setDomain(domainFromRequest);
        request.setAttribute(TenantHolder.TENANT_KEY, tenantContent);
    }

    /**
     * 获取域名的值
     * @param request
     * @return
     */
    private String getDomainFromRequest(HttpServletRequest request) {
        // 获取请求URL
        StringBuffer url = request.getRequestURL();
        // 获取域名信息
        String domain = url.toString().split("/")[2];
        return domain;
    }

}
```

### 3、获取租户信息

通过静态的方案获取租户的值

```java
/**
 * 由于用户的信息存储在了threadLocal中，不想使用太多的threadLocal，因而修改存在request中
 * 在request中的好处，会在request请求结束后消失
 */
public class TenantHolder {

    // reqeust 存储的key值
    public static final String TENANT_KEY = "tenant";

    /**
     * 获取租户对象
     * @return
     */
    public static TenantContent getTenant() {
        TenantComponent bean = SpringUtil.getBean(TenantComponent.class);
        return bean.getTenant();
    }

    /**
     * 获取租户的id
     * @return
     */
    public static String getTenantId() {
         //先从登录用户获取
//        SessionUser user = UserContextHolder.getUser();
//        if (user != null) {
//            return user.getTenantId();
//        }
//
//        // 需要配合@Tenant 注解使用
//        TenantContent tenantContent = getTenant();
//        return tenantContent == null ? null : tenantContent.getTenantId();

        return "ta834nxys7znzkzfoabd55hx6uiy5pma";  // 测试的
    }
}
```

