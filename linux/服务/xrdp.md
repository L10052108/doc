资料来源：https://www.toutiao.com/article/7086361473961804327/?app=news_article&timestamp=1650065865&use_new_style=1&req_id=202204160737450101580242261F27DF0D&group_id=7086361473961804327&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=df1fcb8b-d473-41b1-93c7-83b38a2bfc4e

## linux远程桌面管理工具xrdp

### 概述

我们知道，我们日常通过vnc来远程管理linux图形界面，今天分享一工具Xrdp，它是一个开源工具，允许用户通过Windows RDP访问Linux远程桌面。 除了Windows RDP之外，xrdp工具还接受来自其他RDP客户端的连接，如FreeRDP，rdesktop和NeutrinoRDP。

**实验环境说明：**

- Linux操作系统：centos7.9
- Windows客户端操作系统：win10
- xrdp软件版本：xrdp-0.9.19-1.el7.x86_64

### 安装过程

**安装GNOME默认桌面环境**

```Shell
yum groupinstall "X Window System" -y
yum group install "GNOME" -y
```

**安装Xrdp**

```Shell
yum install xrdp -y
```

**启动Xrdp服务，并设置开机启动 **

```Shell
systemctl enable xrdp --now
```

**查看Xrdp的启动状态**

```Shell
systemctl status xrdp
```
**重启Xrdp服务**

```Shell
sudo systemctl restart xrdp
```
显示成功

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1bi4q4lvbj21440bs41j.jpg)

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1bi51915vj20u80fz0vx.jpg)

###  配置Xrdp

设置Xrdp使用GNONE，编辑配置文件，添加如下行

```Shell
sudo vim /etc/xrdp/xrdp.ini
exec gnome-session
```

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1bi7fzq1yj20p609q75j.jpg)
重启Xrdp服务**

```Shell
sudo systemctl restart xrdp
```



###  配置防火墙

**配置防火墙（如果启用了防火墙的话），放行3389端口**

默认情况下，Xrdp监听3389端口，如果使用的是云服务器（如阿里云、华为云），可以通过安全组规则放行3389端口。

### 测试验证

使用windows自带的远程桌面客户端进行连接

![linux远程桌面管理工具xrdp](https://p3.toutiaoimg.com/origin/tos-cn-i-qvj2lq49k0/4726e231ae62470cb637436f1bf90a12?from=pc)

输入用户名和密码等信息

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1bi9zybqjj20pj0m0jrx.jpg)

登录成功

![linux远程桌面管理工具xrdp](https://p3.toutiaoimg.com/origin/tos-cn-i-qvj2lq49k0/e3ce007cdca34f7298c53eaaed3ee3a3?from=pc)