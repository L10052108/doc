## 安装node环境

```
###### 安装npm（实际上，部署不需要安装npm...） ######
#创建目录
mkdir -p /usr/local/node/
cd /usr/local/node/
###### 安装npm（实际上，部署不需要安装npm...） ######
# 淘宝镜像，下载node，解压
wget https://npm.taobao.org/mirrors/node/latest-v14.x/node-v14.15.3-linux-x64.tar.gz
tar -zxvf node-v14.15.3-linux-x64.tar.gz
# 添加软链接
ln -s /usr/local/node/node-v14.15.3-linux-x64/bin/npm /usr/local/bin/npm
ln -s /usr/local/node/node-v14.15.3-linux-x64/bin/node /usr/local/bin/node
# 安装成功，查看版本
npm -v
————————————————
版权声明：本文为CSDN博主「寒泉Hq」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/sinat_42483341/article/details/111934332
```

- 注意： 版本可能更新，需要进行访问最新环境，更改版本信息