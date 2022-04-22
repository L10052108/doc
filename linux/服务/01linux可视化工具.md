资料来源

[官方标配！吊炸天的Linux可视化管理工具，必须推荐给你](https://www.toutiao.com/article/7067569199320744482/?app=news_article&timestamp=1650380630&use_new_style=1&req_id=202204192303500101580310440513B0C8&group_id=7067569199320744482&wxshare_count=1&tt_from=weixin&utm_source=weixin&utm_medium=toutiao_android&utm_campaign=client_share&share_token=28858b91-92b4-4b88-b8ca-6fc124edb795)

## linux可视化工具

###  Cockpit简介

Cockpit是CentOS 8内置的一款基于Web的可视化管理工具，对一些常见的命令行管理操作都有界面支持，比如用户管理、防火墙管理、服务器资源监控等，使用非常方便，号称人人可用的Linux管理工具。

下面是Cockpit的管理界面，看起来还是挺炫酷的！

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h1if4hubczj21v10u0jvv.jpg)



### 安装&使用

安装

~~~~shell
# 安装
yum install cockpit
# 配置cockpit服务开机自启
systemctl enable --now cockpit.socket
# 启动cockpit服务
systemctl start cockpit
~~~~

- 安装完成后即可通过浏览器访问Cockpit，使用Linux用户即可登录（比如root用户），访问地址：https://ip:9090/ 默认端口号9090。

证书安全问题[mac谷歌浏览器使用](computer/mac/02mac配置.md)

