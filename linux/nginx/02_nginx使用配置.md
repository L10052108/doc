资料来源:<br/>
[写给前端同学的Nginx配置指南](https://juejin.cn/post/7267003603095879714)

## 前端指南

### nginx.conf配置

找到Nginx的安装目录下的`nginx.conf`文件，该文件负责Nginx的基础功能配置。

### 配置文件概述

Nginx的主配置文件(`conf/nginx.conf`)按以下结构组织：

| 配置块     | 功能描述                                           |
| ---------- | -------------------------------------------------- |
| 全局块     | 与Nginx运行相关的全局设置                          |
| events块   | 与网络连接有关的设置                               |
| http块     | 代理、缓存、日志、虚拟主机等的配置                 |
| server块   | 虚拟主机的参数设置（一个http块可包含多个server块） |
| location块 | 定义请求路由及页面处理方式                         |

![246aa426ca6a458c89a799ca1027f409~noop](img/246aa426ca6a458c89a799ca1027f409~noop.png)

### **配置文件示例**

一个比较全的配置文件示例如下。

```bash
bash复制代码# 全局段配置
# ------------------------------

# 指定运行nginx的用户或用户组，默认为nobody。
#user administrator administrators;

# 设置工作进程数，通常设置为等于CPU核心数。
#worker_processes 2;

# 指定nginx进程的PID文件存放位置。
#pid /nginx/pid/nginx.pid;

# 指定错误日志的存放路径和日志级别。
error_log log/error.log debug;

# events段配置信息
# ------------------------------
events {
    # 设置网络连接序列化，用于防止多个进程同时接受到新连接的情况，这种情况称为"惊群"。
    accept_mutex on;

    # 设置一个进程是否可以同时接受多个新连接。
    multi_accept on;

    # 设置工作进程的最大连接数。
    worker_connections  1024;
}

# http配置段，用于配置HTTP服务器的参数。
# ------------------------------
http {
    # 包含文件扩展名与MIME类型的映射。
    include       mime.types;

    # 设置默认的MIME类型。
    default_type  application/octet-stream;

    # 定义日志格式。
    log_format myFormat '$remote_addr–$remote_user [$time_local] $request $status $body_bytes_sent $http_referer $http_user_agent $http_x_forwarded_for';

    # 指定访问日志的存放路径和使用的格式。
    access_log log/access.log myFormat;

    # 允许使用sendfile方式传输文件。
    sendfile on;

    # 限制每次调用sendfile传输的数据量。
    sendfile_max_chunk 100k;

    # 设置连接的保持时间。
    keepalive_timeout 65;

    # 定义一个上游服务器组。
    upstream mysvr {   
      server 127.0.0.1:7878;
      server 192.168.10.121:3333 backup;  #此服务器为备份服务器。
    }

    # 定义错误页面的重定向地址。
    error_page 404 https://www.baidu.com;

    # 定义一个虚拟主机。
    server {
        # 设置单个连接上的最大请求次数。
        keepalive_requests 120;

        # 设置监听的端口和地址。
        listen       4545;
        server_name  127.0.0.1;

        # 定义location块，用于匹配特定的请求URI。
        location  ~*^.+$ {
           # 设置请求的根目录。
           #root path;

           # 设置默认页面。
           #index vv.txt;

           # 将请求转发到上游服务器组。
           proxy_pass  http://mysvr;

           # 定义访问控制规则。
           deny 127.0.0.1;
           allow 172.18.5.54;          
        } 
    }
}
```

### **`location` 路径映射详解**

### **格式：**

```yaml
yaml
复制代码location [ = | ~ | ~* | !~ | !~* | ^~ | @ ] uri {...}
```

#### **各标识解释：**

- `=`：精确匹配。如果匹配成功，立即停止搜索并处理此请求。
- `~`：执行正则匹配，区分大小写。
- `~*`：执行正则匹配，不区分大小写。
- `!~`：正则匹配，区分大小写不匹配。
- `!~*`：正则匹配，不区分大小写不匹配。
- `^~`：前缀匹配。如果匹配成功，不再匹配其他`location`，且不查询正则表达式。
- `@`：指定命名的`location`，主要用于内部重定向请求，如 `error_page` 和 `try_files`。
- `uri`：待匹配的请求字符串。可以是普通字符串或包含正则表达式。

#### **优先级及示例**

> 优先级顺序：无特定标识 < `^~` < `=` < 正则匹配 (`~`, `~*`, `!~`, `!~*`)

示例：

```bash
bash复制代码location = / {
    # 精确匹配 /，主机名后面不能带任何字符串
    # http://abc.com [匹配成功]
    # http://abc.com/index [匹配失败]
}

location ^~ /img/ {
    # 以 /img/ 开头的请求，都会匹配上
    # http://abc.com/img/a.jpg [匹配成功]
    # http://abc.com/img/b.mp4 [匹配成功]
}

location ~* /Example/ {
    # 忽略 uri 部分的大小写
    # http://abc.com/test/Example/ [匹配成功]
    # http://abc.com/example/ [匹配成功]
}

location /documents {
    # 如果有正则表达式可以匹配，则优先匹配正则表达式
    # http://abc.com/documentsabc [匹配成功]
}

location / {
    # http://abc.com/abc [匹配成功]
}
```

### 反向代理

> 反向代理是Nginx的核心功能之一，允许Nginx将来自客户端的请求转发到后端服务器，并将后端服务器的响应返回给客户端,使客户端感觉就像是直接与后端服务器通信一样。

![6b8454d79af742fdaa827a71a9067cfc~noop](img/6b8454d79af742fdaa827a71a9067cfc~noop.png)

#### **基本配置**

要配置Nginx作为反向代理，您需要使用`location`块中的`proxy_pass`指令：

```bash
bash复制代码location /some/path/ {
    proxy_pass http://your_backend_address;
}
```

#### **常用指令**

- `proxy_pass`：定义后端服务器的地址。
- `proxy_set_header`：修改从客户端传递到代理服务器的请求头。
- `proxy_hide_header`：隐藏从代理服务器返回的响应头。
- `proxy_redirect`：修改从代理服务器返回的响应头中的`Location`和`Refresh`头字段。

#### **示例配置**

```bash
bash复制代码server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

在此配置中，所有发送到`example.com`的请求都会被代理到`localhost:8080`。

#### **注意事项**

1. 当使用`proxy_pass`指令时，确保后端服务器是可用的，否则Nginx将返回错误。
2. 使用`proxy_set_header`确保后端服务器接收到正确的请求头。
3. 如果后端服务器和Nginx在不同的机器上，确保网络连接是稳定的。

反向代理不仅可以提高网站的性能和可靠性，还可以用于负载均衡、缓存静态内容、维护和安全等多种用途。

### **负载均衡**

> 当有多台服务器时，代理服务器根据规则将请求分发到指定的服务器上处理。

![d1f8e2c1a57e436c8b8e2e8c02a27dcc~noop](img/d1f8e2c1a57e436c8b8e2e8c02a27dcc~noop.png)

| 策略名称              | 描述                                                         | 示例                                                         |
| --------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **RR (round robin)**  | 默认的负载均衡方法，按时间顺序逐一分配到不同的后端服务器     | `upstream web_servers { server localhost:8081; server localhost:8082; }` |
| **热备**              | 当主服务器发生故障时，才将流量转发到备用服务器               | `upstream web_servers { server 127.0.0.1:7878; server 192.168.10.121:3333 backup; }` |
| **权重**              | 根据预设权重分配请求，权重越高的服务器接收的请求越多         | `upstream web_servers { server localhost:8081 weight=1; server localhost:8082 weight=2; }` |
| **ip_hash**           | 根据客户端IP地址的hash结果分配请求，确保特定客户端IP的请求总是发给同一个后端服务器 | `upstream test { ip_hash; server localhost:8080; server localhost:8081; }` |
| **fair (第三方)**     | 根据后端服务器的响应时间分配请求，响应时间短的优先分配       | `upstream backend { fair; server localhost:8080; server localhost:8081; }` |
| **url_hash (第三方)** | 根据请求的URL的hash结果分配请求，确保同一个URL的请求总是发给同一个后端服务器 | `upstream backend { hash_method crc32; hash $request_uri; server localhost:8080; server localhost:8081; }` |

这些负载均衡策略可以根据实际应用场景和需求进行选择和组合使用。

### 配置动静分离

> 动静分离是一种常见的Web服务器优化策略，主要是为了提高服务器的响应速度和减轻服务器的压力。在Nginx中，动静分离非常容易实现。

![345678](img/345678.png)

#### **动静分离的基本概念：**

动静分离是指将动态内容和静态内容分开处理。静态内容通常包括：图片、CSS、JavaScript、HTML文件等，这些内容不需要经常更改。而动态内容则是经常变化的，如：PHP、ASP、JSP、Servlet等生成的内容。

#### **Nginx配置动静分离**

1. **直接为静态内容设置一个别名或根目录**：

```bash
bash复制代码location ~* .(jpg|jpeg|png|gif|ico|css|js)$ {
    root /path/to/static/files;
    expires 30d;  # 设置缓存时间
}
```

在上述配置中，所有的静态文件都被存放在`/path/to/static/files`目录下。`expires`指令设置了静态文件的缓存时间。

1. **使用alias别名**：

如果你的静态文件不在项目的主目录下，你可以使用`alias`来指定静态文件的实际路径。

```bash
bash复制代码location /static/ {
    alias /path/to/static/files/;
}
```

在这个配置中，URL中的`/static/`会映射到文件系统的`/path/to/static/files/`。

1. **代理动态内容**：

对于动态内容，你可能需要将请求代理到后端的应用服务器，如Tomcat、uWSGI等。

```bash
bash复制代码location / {
    proxy_pass http://backend_server_address;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

#### **注意事项**：

- 确保你的静态文件路径配置正确，避免404错误。
- 使用`expires`指令为静态内容设置缓存，这可以减少服务器的负载并提高页面加载速度。
- 动静分离不仅可以提高服务器的响应速度，还可以减少后端服务器的压力，因为静态文件通常由Nginx直接处理，而不需要代理到后端服务器。

### 静态资源优化

为了提高静态资源的传输效率，Nginx提供了以下三个主要的优化指令：

- `sendfile`
- `tcp_nopush`
- `tcp_nodelay`

#### **sendfile 指令**

`sendfile` 用于开启高效的文件传输模式。它通过调用系统内核的 `sendfile` 函数来实现，从而避免了文件的多次拷贝，同时减少了用户态和内核态之间的切换，从而提高了静态文件的传输效率。

**传统的静态资源请求过程：**

1. 客户端通过网络接口向服务端发送请求。
2. 操作系统将这些请求传递给服务器端应用程序。
3. 服务器应用程序处理请求。
4. 处理完成后，操作系统将处理得到的结果通过网络适配器传递给客户端。

![343243](img/343243.png)

| 项目         | 描述                               |      |
| ------------ | ---------------------------------- | ---- |
| **语法**     | `sendfile on                       | off` |
| **默认值**   | `sendfile off`                     |      |
| **配置位置** | `http块`、`server块`、`location块` |      |

#### **tcp_nopush 和 tcp_nodelay指令**

**tcp_nopush**

当 `sendfile` 开启时，`tcp_nopush` 也可以被启用。它的主要目的是提高网络数据包的传输效率。

| 项目         | 描述                               |      |
| ------------ | ---------------------------------- | ---- |
| **语法**     | `tcp_nopush on                     | off` |
| **默认值**   | `tcp_nopush off`                   |      |
| **配置位置** | `http块`、`server块`、`location块` |      |

**tcp_nodelay**

只有在 `keep-alive` 连接开启时，`tcp_nodelay` 才能生效。它的目的是提高网络数据包的实时性。

| 项目         | 描述                               |      |
| ------------ | ---------------------------------- | ---- |
| **语法**     | `tcp_nodelay on                    | off` |
| **默认值**   | `tcp_nodelay on`                   |      |
| **配置位置** | `http块`、`server块`、`location块` |      |

`tcp_nopush` 的工作原理是设置一个缓冲区，当缓冲区满时才进行数据发送，这样可以大大减少网络开销。

### 静态资源压缩

在数据的传输过程中，为了进一步优化，Nginx引入了gzip模块，用于对传输的资源进行压缩，从而减少数据的传输体积，提高传输效率。

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3bc49f9a874f4a15895c773478e351e6~tplv-k3u1fbpfcp-jj-mark:3024:0:0:0:q75.awebp#?w=1233&h=733&s=219924&e=png&b=f6f4f4)

Nginx中的静态资源压缩可以在http块、server块、location块中配置。涉及的主要模块有：

- **ngx_http_gzip_module模块** (内置)
- **ngx_http_gzip_static_module模块**
- **ngx_http_gunzip_module模块**

#### Gzip模块配置指令

1. **gzip**：开启或关闭gzip功能。
   - 语法：`gzip on | off`
   - 默认值：`gzip off`
   - 配置位置：http块，server块，location块
2. **gzip_types**：根据响应的MIME类型选择性地开启gzip压缩。
   - 语法：`gzip_types mime-type`
   - 默认值：`gzip_types text/html`
   - 配置位置：http块，server块，location块
   - 示例：`gzip_types application/javascript`
3. **gzip_comp_level**：设置Gzip压缩的程度，级别从1-9。
   - 语法：`gzip_comp_level level`
   - 默认值：`gzip_comp_level 1`
   - 配置位置：http块，server块，location块
4. **gzip_vary**：设置是否携带"Vary:Accept-Encoding"的响应头部。
   - 语法：`gzip_vary on|off`
   - 默认值：`gzip_vary off`
   - 配置位置：http块，server块，location块
5. **gzip_buffers**：处理请求压缩的缓冲区数量和大小。
   - 语法：`gzip buffers number size`
   - 默认值：`gzip_buffer 32 4k | 16 8K`
   - 配置位置：http块，server块，location块
6. **gzip_disable**：选择性地开启和关闭gzip功能，基于客户端的浏览器标志。
   - 语法：`gzip_disable regex`
   - 默认值：`gzip_disable -`
   - 配置位置：http块，server块，location块
   - 示例：`gzip_disable "MSIE [1-6]."`
7. **gzip_http_version**：针对不同的http协议版本，选择性地开启和关闭gzip功能。
   - 语法：`gzip_http_version 1.0 | 1.1`
   - 默认值：`gzip_http_version 1.1`
   - 配置位置：http块，server块，location块
8. **gzip_min_length**：根据响应内容的大小决定是否使用gzip功能。
   - 语法：`gzip_min_length length`
   - 默认值：`gzip_min_length 20`
   - 配置位置：http块，server块, location块
9. **gzip_proxied**：设置是否对nginx服务器对后台服务器返回的结果进行gzip压缩。
   - 语法：`gzip_proxied off | expired | no-cache | no-store | private | no_last_modified | no_etag | auth | any`
   - 默认值：`gzip_proxied off`
   - 配置位置：http块，server块, location块

#### Gzip与sendfile共存问题

Gzip在应用程序中进行压缩，而sendfile可以直接通过系统的网络设备发送静态资源文件，绕过应用程序的用户进程。为了解决这两者之间的冲突，Nginx提供了`ngx_http_gzip_static_module`模块的`gzip_static`指令。

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/64c433e134804704ad9c2473f387ea4a~tplv-k3u1fbpfcp-jj-mark:3024:0:0:0:q75.awebp#?w=1138&h=678&s=209484&e=png&b=f6f4f4)

- gzip_static

  ：对静态文件进行提前压缩。

  - 语法：`gzip_static on|off|always`
  - 默认值：`gzip_static off`
  - 配置位置：http块，server块, location块

通过上述配置，Nginx可以有效地对静态资源进行压缩，提高数据传输效率，同时与sendfile功能共存，确保高效的资源传输。

### 跨域

跨域资源共享（CORS）是一种安全策略，用于控制哪些网站可以访问您的资源。当您的前端应用程序和后端API位于不同的域上时，通常会遇到跨域问题。Nginx可以通过设置响应头来帮助解决这个问题。

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2bf0e89ce8374506a12c588d4fcc56a7~tplv-k3u1fbpfcp-jj-mark:3024:0:0:0:q75.awebp#?w=850&h=550&s=63747&e=png&b=ffffff)

```bash
location / {
    # 其他配置...

    # 设置允许来自所有域名请求。如果需要指定域名，将'*'替换为您的域名。
    add_header 'Access-Control-Allow-Origin' '*';

    # 允许的请求方法。
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';

    # 允许的请求头。
    add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';

    # 允许浏览器缓存预检请求的结果，单位为秒。
    add_header 'Access-Control-Max-Age' 1728000;

    # 允许浏览器在实际请求中携带用户凭证。
    add_header 'Access-Control-Allow-Credentials' 'true';

    # 设置响应类型为JSON。
    add_header 'Content-Type' 'application/json charset=UTF-8';

    # 针对OPTIONS请求单独处理，因为预检请求使用OPTIONS方法。
    if ($request_method = 'OPTIONS') {
        return 204;
    }
}
```

**注意**：在生产环境中，出于安全考虑，建议不要使用 `'Access-Control-Allow-Origin' '*'`，而是指定确切的域名。

### 防盗链

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4e6359caa0d442a684f2e7b59e90ea6e~tplv-k3u1fbpfcp-jj-mark:3024:0:0:0:q75.awebp#?w=909&h=484&s=25125&e=png&b=e8f0f4)

> 防盗链是指防止其他网站直接链接到你的网站资源（如图片、视频等），从而消耗你的服务器带宽。Nginx提供了一个非常方便的模块——`ngx_http_referer_module`，用于实现防盗链功能。

#### **基本的防盗链配置：**

```bash
location ~ .*.(gif|jpg|jpeg|png|bmp|swf)$ {
    valid_referers none blocked www.example.com example.com *.example.net;
    
    if ($invalid_referer) {
        return 403;
    }
}
```

在上述配置中：

- `valid_referers`定义了合法的来源页面。`none`表示直接访问，`blocked`表示没有`Referer`头的访问，`www.example.com`和`example.com`是合法的来源域名，`*.example.net`表示`example.net`的所有子域名都是合法的来源。
- `$invalid_referer`变量会在来源不在`valid_referers`列表中时变为"true"。
- 如果来源不合法，服务器将返回403禁止访问的状态码。

#### **使用错误图片代替原图片：**

如果你不想显示403错误，而是想显示一个错误图片（例如：“禁止外链”的图片），你可以这样配置：

```bash
location ~ .*.(gif|jpg|jpeg|png|bmp|swf)$ {
    valid_referers none blocked www.example.com example.com *.example.net;
    
    if ($invalid_referer) {
        rewrite ^/.*$ /path/to/error/image.jpg;
    }
}
```

在上述配置中，当检测到盗链时，Nginx会重写请求的URL，将其指向一个错误图片。

#### **注意事项**：

- 防盗链配置可能会影响搜索引擎的爬虫，因此在实施防盗链策略时要小心。
- 如果你的网站使用了CDN，确保CDN的服务器也在`valid_referers`列表中，否则CDN可能无法正常工作。
- 为了确保防盗链配置正确，你应该在生产环境之前在测试环境中进行充分的测试。

### **内置变量**

nginx的配置文件中可以使用的内置变量以美元符$开始。其中，大部分预定义的变量的值由客户端发送携带。

| 变量名              | 描述                                         |
| ------------------- | -------------------------------------------- |
| `$args`             | 请求行中的参数，同`$query_string`            |
| `$content_length`   | 请求头中的Content-length字段                 |
| `$content_type`     | 请求头中的Content-Type字段                   |
| `$document_root`    | 当前请求在root指令中指定的值                 |
| `$host`             | 请求行的主机名，或请求头字段 Host 中的主机名 |
| `$http_user_agent`  | 客户端agent信息                              |
| `$http_cookie`      | 客户端cookie信息                             |
| `$limit_rate`       | 可以限制连接速率的变量                       |
| `$request_method`   | 客户端请求的动作，如GET或POST                |
| `$remote_addr`      | 客户端的IP地址                               |
| `$remote_port`      | 客户端的端口                                 |
| `$remote_user`      | 已经经过Auth Basic Module验证的用户名        |
| `$request_filename` | 当前请求的文件路径                           |
| `$scheme`           | HTTP方法（如http，https）                    |
| `$server_protocol`  | 请求使用的协议，如HTTP/1.0或HTTP/1.1         |
| `$server_addr`      | 服务器地址                                   |
| `$server_name`      | 服务器名称                                   |
| `$server_port`      | 请求到达服务器的端口号                       |
| `$request_uri`      | 包含请求参数的原始URI                        |
| `$uri`              | 不带请求参数的当前URI                        |
| `$document_uri`     | 与`$uri`相同                                 |

这些内置变量为nginx配置提供了极大的灵活性，使得nginx能够根据请求的各种属性进行决策和处理。


## nginx 配置

### nginx多文件配置

```shell
#user  nobody;
worker_processes  auto;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  65535;
	multi_accept on;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

	include /usr/local/nginx/conf/conf.d/*.conf;

}
```

在下面的这句话中。配置成多个文件

![image-20231229102138232](img/image-20231229102138232.png)

也可以指定文件

![image-20231229110124684](img/image-20231229110124684.png)



```shell
    # 配置nginx 反向代理的 80 本地服务
	include /usr/local/nginx/conf/nginx_2_80.conf;
	include /usr/local/nginx/conf/nginx_2_cash.conf;
```

 访问量过大的问题

```shell
user  nginx;
worker_processes  auto;
worker_rlimit_nofile 51200;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  65535;
        multi_accept on;
}

```

- 配置最大连接数

![image-20231229102631877](img/image-20231229102631877.png)

日志打印效果 可以增大访问量

![image-20231229102717126](img/image-20231229102717126.png)

nginx做负载均衡时其中一台服务器挂掉宕机时响应速度慢的问题解决

### nginx 负载均衡时，一台tomcat宕机时的问题 自动切换

资料来源：https://blog.csdn.net/papima/article/details/80984239

```shell
proxy_connect_timeout 1;  
proxy_read_timeout 1;  
proxy_send_timeout 1;  
```

- 配置方法

![image-20231229102925118](img/image-20231229102925118.png)

完整配置

```shell
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

     upstream localhost {
       #ip_hash;
       server 127.0.0.1:8081;
       server 127.0.0.1:8080;
     }

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

    listen 80;
    server_name localhost;
    location /{
    proxy_pass http://localhost;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_connect_timeout       1; #这里就保证了自动切换服务器
    proxy_read_timeout          1;
    proxy_send_timeout          1;
    }
        #charset koi8-r;
        #access_log  logs/host.access.log  main;
        #error_page  404              /404.html;
        # redirect server error pages to the static page /50x.html

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
```





在两台tomcat正常运行的情况下，访问http://localhost 速度非常迅速，通过测试程序也可以看出是得到的负载均衡的效果，但是我们试验性的把其中一台tomcat（server localhost:8080）关闭后，再查看[http://localhost](http://localhost/)，发现反应呈现了一半反映时间快，一半反映时间非常非常慢的情况，但是最后都能得到正确结果.

>**proxy_connect_timeout** 
>语法：proxy_connect_timeout time ； 
>该指令设置与upstream server的连接超时时间，有必要记住，这个超时不能超过75秒。说明 ：该指令设置与代理服务器的读超时时间。它决定了nginx会等待多长时间来获得请求的响应。这个时间不是获得整个response的时间，而是两次reading操作的时间。 
>**proxy_send_timeout** 
>语法 proxy_send_timeout time ； 
>默认值 60s 
>说明： 这个指定设置了发送请求给upstream服务器的超时时间。超时设置不是为了整个发送期间，而是在两次write操作期间。如果超时后，upstream没有收到新的数据，nginx会关闭连接 
>**proxy_read_timeout** 
>语法 proxy_read_timeout time ； 
>默认值 60s 
>说明： 该指令设置与代理服务器的读超时时间。它决定了nginx会等待多长时间来获得请求的响应。这个时间不是获得整个response的时间，而是两次reading操作的时间。
>
>在http模块内配置了这三个字段，再reload 一下，只启动一个项目，就会发现，就算宕机一台，我们的项目也可以接着使用，如果不放心，可以多试几次。

### 正向代理配置

**代理本地的静态资源**

代理本地的服务

可以放置 页面  图片文件

```shell
#80 port localServer
server {
	listen       80;
	server_name  localhost;
	
	location / {
		root   html;
		index  index.html index.htm;
	}

	#error_page  404              /404.html;

	# redirect server error pages to the static page /50x.html
	#
	error_page   500 502 503 504  /50x.html;
	location = /50x.html {
		root   html;
	}
}

```

root 表示文件根目录， 上文表示的配置的文件的根目录 和 配置 文件的同一级别的html 下

### 反向代理

方向代理一个网站

  实现 ip 功能传给 request

```shell
upstream nuannuan  
{   
	 server 47.100.199.19:6120  max_fails=3 fail_timeout=30s;
	#server 47.100.199.19:6121  max_fails=3 fail_timeout=30s;
	server 47.100.197.255:6120  max_fails=3 fail_timeout=30s;
	 ip_hash;
	
}  
server
{
	listen 80;
	server_name  nuannuan.junhuikeji-hz.com; 
	location / {
		proxy_pass  http://nuannuan;
	}

	proxy_set_header Host $host;
	proxy_set_header X-Real-IP $remote_addr;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	
	add_header                  Set-Cookie "HttpOnly";
	add_header                  Set-Cookie "Secure";
	add_header                  X-Frame-Options "SAMEORIGIN";
}
```



### 跳转到https 中

```
server {
    listen       80;
    server_name  tehuiwangtz.com;

    rewrite ^(.*)$  https://$host$1 permanent;
}

```

### 配置mqtt 进行负载均衡

```shell
stream {
    server {
        listen 1883;
        proxy_pass app;
    }
 
    upstream app {
        server 139.196.85.179:1883;
    }
}

```

### nginx 进行重定向304

```
############################################################
# pay
# listen    :  http://showdoc.51mylove.top
# redirect  :  http://47.100.197.200:6023;
############################################################
server
{
	listen 80;
	server_name  showdoc.51mylove.top; 
	location / {
        rewrite ^/(.*)$   https://www.baidu.com;
	}
}
```

### 配置vue

```
server {
    listen       80;
    server_name  paycosole.junhuikeji-hz.com;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

   location /api {
   	rewrite  ^.+api/?(.*)$ /$1 break;
   	include  uwsgi_params;
   	proxy_pass  http://47.100.197.255:6300/console/;
   }

	
    location / {
        root /usr/share/nginx/payconsole;
		try_files $uri $uri/ @router;
        index  index.html index.htm;
    }
	location @router {
            rewrite ^.*$ /index.html last;
    }
  
    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

}
```

### 代理页面

```
############################################################
# pay
# listen    :  paipaidai.junhuikeji-hz.com
# redirect  :  http://47.100.197.200:6023;
############################################################
server
{
	listen 80;
	server_name  paipaidai.junhuikeji-hz.com; 
	location / {
		proxy_pass  http://47.100.197.200:6023;
	}
}
```



### 配置证书

```
server {
    listen       443;
    server_name  boss.junhuikeji-hz.com;
	ssl on;
	ssl_certificate /usr/cert/2637021.pem; 
	ssl_certificate_key /usr/cert/2637021.key; 
	ssl_session_timeout 5m;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
	ssl_prefer_server_ciphers on;


    location / {
		proxy_pass  http://47.100.197.200:6023;
	}

}
server {
    listen       80;
    server_name  boss.junhuikeji-hz.com;

    rewrite ^(.*)$  https://$host$1 permanent;
	
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```

### 自定义 404 页面

配置http 的内容

1.开启nginx自定义设置，需要先在ngnix.conf 文件中添加`fastcgi_intercept_errors on;`

![image-20231229103439259](img/image-20231229103439259.png)

\2. 开启代理模式

```shell
proxy_intercept_errors on;
```

3.配置错误页面

```shell
error_page  404 /404.html;
location = /404.html {
root  /usr/share/nginx/html/zuanduoduo/;
}
```

或者采用

```shell
error_page 404 = http://gaofangtao.junhuikeji-hz.com/zuanduoduo/404.html;
```

![image-20231229103550267](img/image-20231229103550267.png)

检查配置是否正确

```shell
sudo nginx -t
```

说明配置无误

可以重启服务了

### NGINX 缓存

配置头文件

```shell
location /swagger {
		  proxy_cache cache_temp;
		  proxy_cache_valid  200 1m;
		  proxy_cache_key $scheme$request_method$host$uri$http_Authorization;
		  proxy_set_header Host $host;
		  proxy_set_header X-Real-IP $remote_addr;
		  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		  add_header Access-Control-Allow-Origin * ;
		  add_header Access-Control-Allow-Credentials true;
		  add_header Access-Control-Allow-Methods 'GET,POST,OPTIONS';
		  add_header Access-Control-Allow-Headers 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With';
		  add_header Content-Type "application/octet-stream";
		  proxy_pass http://127.0.0.1:8081;
	}

```

![image-20231229103718814](img/image-20231229103718814.png)

```shell
proxy_cache_path /usr/local/nginx/cache_temp levels=1:2 keys_zone=cache_temp:100m inactive=1m max_size=50g;
```

### nginx 配置跨域

```shell
localtion  地址。。。{
		add_header Access-Control-Allow-Origin * ;
        add_header Access-Control-Allow-Credentials true;
        add_header Access-Control-Allow-Methods 'GET,POST,OPTIONS';
        add_header Access-Control-Allow-Headers 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With';
        add_header Content-Type "application/octet-stream";
}
```

### nginx 配置域名

```shell
	server {
        listen       80;
        server_name  http://user.lovehome.xyz/;
		
		location / {

			proxy_pass http://192.168.2.145:8080;
		}
    }
```

### nginx 配置证书

- 阿里云申请免费的证书

  ![image-20231229104321030](img/image-20231229104321030.png)

![image-20231229104259425](img/image-20231229104259425.png)

配置文件举例

```shell
	server {
		listen 443;
		server_name abc.junhuikeji-zj.com;
		ssl on;
		root html;
		index index.html index.htm;
		ssl_certificate   /cert/1526597038708.pem;
		ssl_certificate_key  /cert/1526597038708.key;
		ssl_session_timeout 5m;
		ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
		ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
		ssl_prefer_server_ciphers on;
		location / {
			proxy_pass  http://47.100.199.19;
		}
	}

```

![image-20231229104509841](img/image-20231229104509841.png)

### 使用 HTTP/2 建议

nginx 开启 HTTP2 只需在相应的 HTTPS 设置后加上 `http2` 即可

```
listen [::]:443 ssl http2 ipv6only=on;
listen 443 ssl http2;
```

以下几点是 HTTP/1 和 HTTP/2 都同样适用的

### 开启压缩

配置 gzip 等可以使传输内容更小，传输速度更快

例如 nginx 可以再 http 模块中加入以下字段，其他字段和详细解释可以谷歌

```shell
    gzip  on; // 开启
    gzip_min_length 1k;
    gzip_comp_level 1; // 压缩级别
    gzip_types text/plain application/javascript application/x-javascript application/octet-stream application/json text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png font/ttf font/otf image/svg+xml; // 需要压缩的文件类型
    gzip_vary on;
    gzip_disable "MSIE [1-6]\.";
```

### 使用缓存

给静态资源设置一个缓存期是非常有必要的，关于缓存见另一篇博文 `HTTP Message`

例如 nginx 在 server 模块中添加以下字段可以设置缓存时间

```lua
  location ~* ^.+\.(ico|gif|jpg|jpeg|png|moc|mtn|mp3|mp4|mov)$ {
   access_log   off;
   expires      30d;
 }
 
 location ~* ^.+\.(css|js|txt|xml|swf|wav|json)$ {
   access_log   off;
   expires      5d;
 }
 
 location ~* ^.+\.(html|htm)$ {
   expires      24h;
 }
 
 location ~* ^.+\.(eot|ttf|otf|woff|svg)$ {
   access_log   off;
   expires 30d;
 }
```

### 减少重定向

重定向可能引入新的 DNS 查询、新的 TCP 连接以及新的 HTTP 请求，所以减少重定向也很重要。

浏览器基本都会缓存通过 301 Moved Permanently 指定的跳转，所以对于永久性跳转，可以考虑使用状态码 301。对于启用了 HTTPS 的网站，配置 HSTS 策略，也可以减少从 HTTP 到 HTTPS 的重定向

### 限制访问IP

[如何用 Nginx 代理 MySQL 连接，并限制可访问IP？](https://mp.weixin.qq.com/s/6lvKIQb4yk7uTmufr9pJ8w)

实现了对连接的代理，所有人都可以通过访问Nginx来连接MySQL服务器，解决了外网无法连接的问题。

为了更进一步的缩小访问范围，保证数据安全，我们可以限制只有公司网络的IP地址可以通过Nginx进行连接。

Nginx提供了`ngx_stream_access_module`模块，其指令非常简单，仅包含allow和deny指令。

#### allow

该指令设置指定的IP允许访问。可以和deny指令配合使用

- 作用域：stream, server
- 语法：allow address | CIDR | unix: | all;

示例：

```
 # 允许192.168.110.1访问
 allow 192.168.110.1;
 
 # 允许192.168.110.1到192.168.255.254
 allow 192.168.110.0/16;
 
 # 允许192.168.110.1到192.168.110.254
 allow 192.168.110.0/24;
 
 # 允许所有的IP访问
 allow all;
```

#### deny

该指令设置指定的IP禁止访问。可以和allow指令配合使用。

- 作用域：stream, server
- 语法：deny address | CIDR | unix: | all;

```c
# 禁止192.168.110.1访问
 deny 192.168.110.1;
 
 # 禁止192.168.110.1到192.168.255.254
 deny 192.168.110.0/16;
 
 # 禁止192.168.110.1到192.168.110.254
 deny 192.168.110.0/24;
 
 # 禁止所有的IP访问
 deny all;
```

#### 配置示例

禁止所有的IP访问，192.168.110.100除外。

```
allow 192.168.110.100;
 deny all;
```

#### 综合案例

只允许192.168.110.100通过Nginx连接MySQL服务器。

```c
stream  {
     allow 192.168.110.100;
     deny all;
     server {
         listen 3306;
         proxy_pass 192.168.110.101:3306;
     }
 }
```



