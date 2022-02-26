# docsify 使用教程

## 背景

经常在网上看到一些排版非常漂亮的技术手册，左边有目录栏，右边是[Markdown](https://so.csdn.net/so/search?q=Markdown&spm=1001.2101.3001.7020)格式的文档，整个配色都十分舒服，就像一本书一样，一看就很让人喜欢。就比如[Markdown Preview Enhanced的文档](https://shd101wyy.github.io/markdown-preview-enhanced/#/zh-cn/).目前网上我了解的有两种工具可以实现这样的效果，一种叫做docsify，另一种叫做Gitbook。因为MPE文档用的是docsify，而且据docsify自己的宣传，说是

> 不同于 GitBook、Hexo 的地方是它不会生成将 .md 转成 .html 文件，所有转换工作都是在运行时进行。
> 这将非常实用，如果只是需要快速的搭建一个小型的文档网站，或者不想因为生成的一堆 .html 文件“污染” commit 记录，只需要创建一个 index.html 就可以开始写文档而且直接部署在 GitHub Pages。

所以我也就用它来做吧。这里先放上我的成品：<https://aopstudio.github.io/docs>

以上资料资料来源：https://blog.csdn.net/weixin_30399055/article/details/97598957 

## 安装

###  安装环境

````
###### 安装npm（实际上，部署不需要安装npm...） ######
# 淘宝镜像，下载node，解压
wget https://npm.taobao.org/mirrors/node/latest-v14.x/node-v14.15.3-linux-x64.tar.gz
tar -zxvf node-v14.15.3-linux-x64.tar.gz
# 添加软链接
ln -s /usr/local/node/node-v14.15.3-linux-x64/bin/npm /usr/local/bin/npm
ln -s /usr/local/node/node-v14.15.3-linux-x64/bin/node /usr/local/bin/node
# 安装成功，查看版本
npm -v
````

### 安装软件

安装 docsify-cli 工具

推荐全局安装 docsify-cli 工具，可以方便地创建及在本地预览生成的文档。

`npm i docsify-cli -g`

初始化项目

````Java
# 初始化目录
docsify init docs
# 启动一个本地服务器，可以方便地实时预览效果。默认访问地址 http://localhost:3000
docsify serve docs
````

初始化成功后，可以看到 ./docs 目录下创建的几个文件

- index.html 入口文件

- README.md 会做为主页内容渲染

- .nojekyll 用于阻止 GitHub Pages 忽略掉下划线开头的文件


原文链接：https://blog.csdn.net/sinat_42483341/article/details/111934332

### 创建启动脚本

在doc 文件夹下创建启动脚本

`nohup /usr/local/node/node-v14.18.2-linux-x64/bin/docsify serve ./doc &`

### 部署

文档代码放到Git服务器上，每次更新代码。只需要从Git拉去代码即可
````Java
# 加入索引
git add .
# 确认
git commit -m 'xxxx'
# 提交
git push
````

服务器拉取代码

`git pull`

这样就完成代码的更新

