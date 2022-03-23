## macbook安装软件

[资料来源](https://blog.csdn.net/hyb745250618/article/details/53257294)

### 安装Homebrew

> mac os上安装软件常常需要依赖包，但对于新手来说，这是很麻烦的事情。
> 自己的安装wget的过程中，偶然间知道了Homebrew这款软件，号称是“macOS 不可或缺的套件管理器”，[Homebrew官网网站链接](http://brew.sh/index_zh-cn.html)。类似于Red hat的yum，Ubuntu的apt-get。

~~~~shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
打开终端窗口, 粘贴以上脚本。
脚本会解释它的作用，然后在您的确认下执行安装。
~~~~

如果电脑[安装失败](https://blog.csdn.net/txl910514/article/details/105880125)

可以使用国内源啦  再也不痛苦啦

`/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"`

![](https://tva1.sinaimg.cn/large/e6c9d24ely1h0jw2inrrtj20u00gsad3.jpg ":size=80%")

- 安装任意包

`$ brew install `

- 示例：安装node

`$ brew install node`

- 卸载任意包

`$ brew uninstall `

- 示例：卸载git

`$ brew uninstall git`

- 查询可用包

`$ brew search `

- 查看已安装包列表

`$ brew list`

- 查看任意包信息

`$ brew info `

- 更新Homebrew

`$ brew update`

- 查看Homebrew版本

`$ brew -v`

- Homebrew帮助信息

`$ brew -h`

- 卸载任意安装包

`$ brew uninstall `


原文链接：https://blog.csdn.net/qq_34156628/article/details/97561194

### wget安装举例

~~~~shell
使用非常简单，例如安装wget，在命令行输入以下命令、运行：
$ brew install wget
就可以了，去试一下吧。

另外据说MacPorts也有类似功能，我没有试过，有兴趣的可以看一下这篇文章[Mac OS X中MacPorts安装和使用](http://www.ccvita.com/434.html)
~~~~

