资料来源：
[OpenFeign添加认证Token](https://juejin.cn/post/6914951568383016973)

### opneFeign调用

- 使用配置属性进行配置

~~~~yaml
# 配置token
feign:
  client:
    config:
      feignName:
        requestInterceptors: xyz.guqing.erueka.config.FeignRequestInterceptor
~~~~

- 使用`@Component`注入Bean, 见代码示例

~~~~~java

import feign.RequestInterceptor;
import feign.RequestTemplate;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.util.Iterator;
import java.util.Optional;

@Slf4j
@Component //注入Bean，也可使用配置属性进行配置
public class FeignRequestInterceptor implements RequestInterceptor {

    @Override
    public void apply(RequestTemplate template) {
        log.info("Feign 调用, url: {} ", template.request().url());

        // 从请求中获取head,然后放到head中
        HttpServletRequest request = Optional.ofNullable(RequestContextHolder.getRequestAttributes()).map(it -> ((ServletRequestAttributes) it).getRequest()).orElse(null);
        if (request == null) {
            return;
        }
        Iterator<String> headerIterator = CollectionUtils.toIterator(request.getHeaderNames());
        while (headerIterator.hasNext()) {
            String name = headerIterator.next();
            log.info("add header, url: {} , path: {}", name, request.getHeader(name));
            // 只写入 Authorization
            if ("authorization".equals(name)) {
                template.header(name, request.getHeader(name));
            }
        }
    }
}

~~~~~

拦截器，从请求头中找到authorization。从请求头中获取，作为http请求的头中的参数

![](large/e6c9d24ely1h239px1dlyj21ts0swthr.jpg ':size=70%')

