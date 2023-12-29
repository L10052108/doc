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



## 跳转到https 中

```
server {
    listen       80;
    server_name  tehuiwangtz.com;

    rewrite ^(.*)$  https://$host$1 permanent;
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



