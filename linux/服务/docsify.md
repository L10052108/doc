# docsify 使用教程

资料来源：

[docsify的配置+全插件列表](https://xhhdd.cc/index.php/archives/80/comment-page-1)
[北山湖臭皮匠](https://github.com/taoGod/extraordinarywen/tree/master/docs)

## 背景

经常在网上看到一些排版非常漂亮的技术手册，左边有目录栏，右边是[Markdown](https://so.csdn.net/so/search?q=Markdown&spm=1001.2101.3001.7020)格式的文档，整个配色都十分舒服，就像一本书一样，一看就很让人喜欢。就比如[Markdown Preview Enhanced的文档](https://shd101wyy.github.io/markdown-preview-enhanced/#/zh-cn/).目前网上我了解的有两种工具可以实现这样的效果，一种叫做docsify，另一种叫做Gitbook。因为MPE文档用的是docsify，而且据docsify自己的宣传，说是

> 不同于 GitBook、Hexo 的地方是它不会生成将 .md 转成 .html 文件，所有转换工作都是在运行时进行。
> 这将非常实用，如果只是需要快速的搭建一个小型的文档网站，或者不想因为生成的一堆 .html 文件“污染” commit 记录，只需要创建一个 index.html 就可以开始写文档而且直接部署在 GitHub Pages。

所以我也就用它来做吧。这里先放上我的成品：<https://aopstudio.github.io/docs>

以上资料资料来源：https://blog.csdn.net/weixin_30399055/article/details/97598957 

- 很多官方文档也采用这个软件

  [apollo官网](https://www.apolloconfig.com/#/zh/)

  [hutool工具类](https://hutool.cn/docs/#/)


## 安装

###  安装环境

- 需要安装npm环境

参考 [node](linux/node.md)

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

文件的结构：

![02801](pic/02801.png ':size=50%')

### 创建启动脚本

- 在doc 文件夹下创建启动脚本

`nohup /usr/local/node/node-v14.18.2-linux-x64/bin/docsify serve ./doc &`

- 增加执行权限

`chmod +X start.sh`

- 启动程序

`./start.sh`

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

> 后面采用Jenkins 自动化部署，通过Jenkins拉去代码，然后把文件拷贝到服务的目录

具体的部署过程可以参看[Jenkins](linux/Jenkins.md)

## 主页的配置

很多功能需要配置文件来实现

![1647248480834](pic/1647248480834.jpg ':size=40%')

### 配置左侧栏

[资料来源](https://cpury.com/1408.html)

docsify官方并不支持侧边栏折叠，目前只能通过第三方插件实现或者自己DIY。

docsify的目录功能也可简单实现折叠，一般够用。

最终实现的展示效果：

![docsify-sidebar-collapse](pic/docsify-sidebar-collapse.gif)



index.html配置

~~~~
<script>
  window.$docsify = {
    loadSidebar: true,
    alias: {
      '/.*/_sidebar.md': '/_sidebar.md',
    },
    subMaxLevel: 3,
    ...
    sidebarDisplayLevel: 1, // set sidebar display level
  }
</script>
<script src="//cdn.jsdelivr.net/npm/docsify/lib/docsify.min.js"></script>

<!-- plugins -->
<script src="//cdn.jsdelivr.net/npm/docsify-sidebar-collapse/dist/docsify-sidebar-collapse.min.js"></script>
~~~~

 _sidebar.md demo

~~~~
- [数据结构与算法](/general/algorithm/README.md)
  - 数据结构
    - [stack](/general/algorithm/data-structures/stack/README.zh-CN.md)
    - [queue](/general/algorithm/data-structures/queue/README.zh-CN.md)
    - list
      - [linked-list](/general/algorithm/data-structures/linked-list/README.zh-CN.md)
      - [doubly-linked-list](/general/algorithm/data-structures/doubly-linked-list/README.zh-CN.md)
    - [tree](/general/algorithm/data-structures/tree/README.zh-CN.md)
      - [binary search tree](/general/algorithm/data-structures/tree/binary-search-tree/README.md)
      - [red black tree](/general/algorithm/data-structures/tree/red-black-tree/README.md)
    - [heap](/general/algorithm/data-structures/heap/README.zh-CN.md)
    - [hash-table](/general/algorithm/data-structures/hash-table/README.md)
    - [graph](/general/algorithm/data-structures/graph/README.zh-CN.md)
  - 算法
    - [排序算法](/general/algorithm/algorithms/sorting.md)
- [设计模式](/general/design-pattern/README.md)
- 网络
  - [协议模型](/general/network/protocol-model.md)
  - [TCP/IP](/general/network/tcp-ip.md)
~~~~



## 插件

### 官方插件

[可以参考](help/docsify/定制化插件.md)


