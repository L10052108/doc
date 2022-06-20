资料来源：

[使用Zerotier实现免费内网穿透](https://coffeemilk.blog.csdn.net/article/details/119360712?spm=1001.2101.3001.6650.4&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-4-119360712-blog-123423221.pc_relevant_paycolumn_v3&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-4-119360712-blog-123423221.pc_relevant_paycolumn_v3&utm_relevant_index=6)

[在centos7上部署ZeroTier实现内网穿透](https://blog.csdn.net/qq_33887096/article/details/114532957?spm=1001.2101.3001.6650.3&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-3-114532957-blog-121034648.pc_relevant_paycolumn_v3&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-3-114532957-blog-121034648.pc_relevant_paycolumn_v3&utm_relevant_index=6)



## Zerotier实现免费内网穿透

### 实现效果

![](large/e6c9d24ely1h3ek9kmx4yj210r0ozwgb.jpg ':size=50%')

### 实现原理

①使用[ZeroTier](https://www.zerotier.com/download/)将需要操作的设备组在一个虚拟的局域网里面，实现该[虚拟局域网](https://so.csdn.net/so/search?q=%E8%99%9A%E6%8B%9F%E5%B1%80%E5%9F%9F%E7%BD%91&spm=1001.2101.3001.7020)里面的设备可以相互通讯连接。

![](large/e6c9d24ely1h3ekagwuyrj21ec0qudie.jpg ':size=50%')



## 注册和使用

​	注册过程省略

### 创建网络

①登陆成功后选择【Networks--->Create A Network】创建虚拟局域网

![](large/e6c9d24ely1h3ekbsh6f3j21qk0cv3zx.jpg ':size=50%')

![](large/e6c9d24ely1h3ekby2f2sj21yu0kbq5m.jpg ':size=50%')


 ②选中新建出来的虚拟局域网，点击鼠标进如设置界面进行设置

![](large/e6c9d24ely1h3ekcl3av7j21y30qgdkc.jpg ':size=50%')


![](large/e6c9d24ely1h3ekcuhdclj21i50u00wh.jpg ':size=50%')



![](large/e6c9d24ely1h3ekcyua4lj20zl0nfq5c.jpg ':size=50%')

### 添加设备到虚拟局域网络中

①进入ZeroTier虚拟网络VPN的下载界面 

![](large/e6c9d24ely1h3ekdwpohsj21q90dr761.jpg ':size=50%')

### windows版本

 ②下载电脑版的ZeroTier虚拟网络VPN（这里以Windows系统电脑为例说明）

![](large/e6c9d24ely1h3ekeb18hkj219t0u0n1a.jpg ':size=50%')



③ 安装完成ZeroTier One后打开加入刚才创建的虚拟局域网ID标识符

![](large/e6c9d24ely1h3ekepoockj20s20h7tae.jpg ':size=50%')

### mac 版本

![](large/e6c9d24ely1h3ekhic4afj20jq0bst9p.jpg ':size=50%')

### Linux版本

修改repo地址

`vi /etc/yum.repos.d/zerotier.repo`

地址内容

~~~~properties
[zerotier]
name=ZeroTier, Inc. RPM Release Repository
baseurl=http://download.zerotier.com/redhat/el/$releasever
enabled=1
gpgcheck=0
~~~~

清除老的镜像，执行安装操作

~~~~shell
yum clean all
yum make cache
yum install zerotier-one
~~~~

安装完成，进行启动服务
`zerotier-one -d`

加入网络

`zerotier-cli join 网络ID`

如果network设置为privite再在zerotier网站将主机id加入

执行命令，将云服务器加入到自己创建好的虚拟网络，将命令中的 xxxxxxxx 替换成实际的虚拟网络 ID。

    $ sudo zerotier-cli join xxxxxxxx


### 刷新网络

 ④刷新ZeroTier虚拟局域网管理网页查看设备且授权

![](large/e6c9d24ely1h3ekftlb5ij21880u00wl.jpg ':size=50%')

 ⑤验证电脑添加虚拟局域网是否成功

略



