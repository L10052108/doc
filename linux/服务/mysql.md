## 方法一

### 数据源

打开网址：https://dev.mysql.com/downloads/repo/yum/,选择对应linux版本

![img](https://img2018.cnblogs.com/blog/1730174/201907/1730174-20190723170337272-775661846.png)

点击“No thanks, just start my download.”，进行下载

![img](https://img2018.cnblogs.com/blog/1730174/201907/1730174-20190723170424636-2122131851.png)

将下载地址复制，得到rpm包的地址

![img](https://img2018.cnblogs.com/blog/1730174/201907/1730174-20190723170518429-54393470.png)



### 下载并安装mysql：

```
wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql-community-server
```

### 启动并查看状态MySQL：

```
systemctl start  mysqld.service
systemctl status mysqld.service
```

### 查看MySQL的默认密码：

```
grep "password" /var/log/mysqld.log
```

[![img](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/98b36a9b01de4cc79f3a53245296a19c~tplv-k3u1fbpfcp-zoom-1.image)](https://tva1.sinaimg.cn/large/008i3skNgy1gwg6eiwyqfj313402mgm8.jpg)

### 登录进MySQL

```
mysql -uroot -p
```

### 修改默认密码（设置密码需要有大小写符号组合—安全性)，把下面的`my passrod`替换成自己的密码

```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'my password';
```

### 开启远程访问

 (把下面的`my passrod`替换成自己的密码)

```
grant all privileges on *.* to 'root'@'%' identified by 'my password' with grant option;
flush privileges;
exit
```

### 在云服务上增加MySQL的端口

各家云服务不一样，这里不介绍

- 远程连接效果

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0ha33ov2rj20wc0u0758.jpg ':size=80%')



## 卸载MySQL

资料来源：https://blog.csdn.net/qq_41829904/article/details/92966943

~~~~sql
//rpm包安装方式卸载
查包名：rpm -qa|grep -i mysql
删除命令：rpm -e –nodeps 包名
 
//yum安装方式下载
1.查看已安装的mysql
命令：rpm -qa | grep -i mysql
2.卸载mysql
命令：yum remove mysql-community-server-5.6.36-2.el7.x86_64
查看mysql的其它依赖：rpm -qa | grep -i mysql
 
//卸载依赖
yum remove mysql-libs
yum remove mysql-server
yum remove perl-DBD-MySQL
yum remove mysql
~~~~

### 方法二



## mysql 的配置

### 修改安全策略

[在]()/etc/my.cnf文件添加validate_password_policy配置，指定密码策略

```
选择0（LOW），1（MEDIUM），2（STRONG）其中一种，选择2需要提供密码字典文件
validate_password_policy=0
```

如果不需要密码策略，添加my.cnf文件中添加如下配置禁用即可：

```
validate_password = off
```

重新启动mysql服务使配置生效：

```
systemctl restart mysqld
```
安全策略 直接 修改 成低

```
set global validate_password_policy=LOW;
```
### 配置文件的路径

- 路径列表

~~~~
配置文件：/etc/my.cnf 
日志文件：/var/log//var/log/mysqld.log 
服务启动脚本：/usr/lib/systemd/system/mysqld.service 
socket文件：/var/run/mysqld/mysqld.pid
~~~~

