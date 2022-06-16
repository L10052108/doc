资料来源：

[HTTP2 详解](https://blog.csdn.net/z69183787/article/details/106643647/)



## nginx 配置



### 使用 HTTP/2 建议

nginx 开启 HTTP2 只需在相应的 HTTPS 设置后加上 `http2` 即可

```
listen [::]:443 ssl http2 ipv6only=on;
listen 443 ssl http2;
```

以下几点是 HTTP/1 和 HTTP/2 都同样适用的

1、开启压缩

配置 gzip 等可以使传输内容更小，传输速度更快

例如 nginx 可以再 http 模块中加入以下字段，其他字段和详细解释可以谷歌

```
    gzip  on; // 开启
    gzip_min_length 1k;
    gzip_comp_level 1; // 压缩级别
    gzip_types text/plain application/javascript application/x-javascript application/octet-stream application/json text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png font/ttf font/otf image/svg+xml; // 需要压缩的文件类型
    gzip_vary on;
    gzip_disable "MSIE [1-6]\.";
```

2、使用缓存

给静态资源设置一个缓存期是非常有必要的，关于缓存见另一篇博文 `HTTP Message`

例如 nginx 在 server 模块中添加以下字段可以设置缓存时间

```
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

3、CDN 加速

CDN 的好处是就近访问，延迟低，访问快

4、减少 DNS 查询

每个域名都需要 DNS 查询，一般需要几毫秒到几百毫秒，移动环境下会更慢。DNS 解析完成之前，请求会被阻塞。减少 DNS 查询也是优化项之一

浏览器的 [DNS Prefetching](https://en.wikipedia.org/wiki/Link_prefetching) 技术也是一种优化手段

5、减少重定向

重定向可能引入新的 DNS 查询、新的 TCP 连接以及新的 HTTP 请求，所以减少重定向也很重要。

浏览器基本都会缓存通过 301 Moved Permanently 指定的跳转，所以对于永久性跳转，可以考虑使用状态码 301。对于启用了 HTTPS 的网站，配置 HSTS 策略，也可以减少从 HTTP 到 HTTPS 的重定向





