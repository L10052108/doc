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

### 安装wget

~~~~shell
使用非常简单，例如安装wget，在命令行输入以下命令、运行：
$ brew install wget
就可以了，去试一下吧。

另外据说MacPorts也有类似功能，我没有试过，有兴趣的可以看一下这篇文章[Mac OS X中MacPorts安装和使用](http://www.ccvita.com/434.html)
~~~~

