资料来源：<br/>
[使用 Glances 一目了然监控远程 Linux 系统](https://www.lxlinux.net/15095.html)<br/>
[Linux pip错误分析](https://blog.csdn.net/weixin_67503304/article/details/125397132)<br/>
[Centos7.4系统Python2.7升级Python3.6(编译安装)](https://blog.csdn.net/qq_28513801/article/details/128952672)<br/>
[如何使用 Glances 命令监控](https://blog.csdn.net/Linuxprobe18/article/details/119184540)<br/>



## Glances监控工具

### 简介

Glances监控工具是功能强大简单易用的在线监控工具。Glances支持gpm图形模式和Glances文本模式，几乎可以在任何终端和工作站上使用，占用资源很少。Glances具有展示监控的高级特性，运行方式支持独立模式，C/S模式，WEB服务模式。 Glances监控内容包括但不限于以下内容：

- CPU监控
- 内存监控
- 负载监控
- 磁盘I/O监控
- 文件系统监控
- 网络监控
- 进程信息监控

### 安装

 本文选择Glances3.1.0安装

  Requirements

- python 2.7,>=3.4
- psutil>=5.3.0
- bottle (for Web server mode)