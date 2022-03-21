## 安装redis

### 安装依赖

~~~~shell
yum -y install gcc automake autoconf libtool make 
yum -y install gcc-c++
~~~~

### 下载

`wget http://download.redis.io/releases/redis-3.2.11.tar.gz`

可以查看其他版本信息，网址 ` http://download.redis.io/releases`

- 效果如图

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0hbz6y3fzj20ug0sawki.jpg ':size=60%')

下载安装包

`http://download.redis.io/releases/redis-6.2.6.tar.gz`

### 解压

解压文件； 上传的文件在root。

~~~~shell
mkdir /redis

解压文件； 上传的文件在root。
cd ~
tar -zxvf redis-3.0.0.tar.gz -C /usr/local
mv redis-6.2.6/ redis
~~~~

### 编译

- src 是源代码，编译后会产生.rb 结尾的文件
- makefile ，才能执行make命令

执行编译

`make`

### 安装

执行安装目录

`make install PREFIX=/usr/local/redis/6379`

>  后面的/usr/local/redis/6379指的是安装目录，是自定义的

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0hcpjjm0gj20s00h6q5q.jpg)

生成一个6379文件夹

### 修改配置

> 拷贝一份配置文件

~~~~shell
 cp redis.conf 6379
 cd 6379
~~~~

修改配置文件redis.conf



### 前台启动

> 前台启动关闭窗口后，服务停止

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0hcuob39ij21b40nugod.jpg)

启动命令

`./bin/redis-server redis.conf `

### 配置服务

- 修改成后台启动

`daemonize yes`

- 修改允许远程访问

`bind 0.0.0.0`

> 默认值bind 127.0.0.1 -::1 表示只能本地访问

### 客户端连接

`/bin/redis-cli -h ip -p port -a password`

> -h 服务器的IP地址
>
> -p 端口号
>
> -a 或者 -u密码

### 设置密码：

- 没有设置密码，可以连接后设置一次性密码（重启后失效）


`redis 127.0.0.1:6379> config set requirepass foobared`

- 设置启动密码

> 修改redis.conf文件中（默认是注释掉的），重启后有效

`requirepass foobared`





