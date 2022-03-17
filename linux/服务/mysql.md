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



### 方法二

