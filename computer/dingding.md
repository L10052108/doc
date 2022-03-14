

# 内网穿透

## 内网穿透介绍



xxxxxx



## 下载工具





## 启动脚本

### mac启动脚本

参考资料：[mac双击文件就执行脚本的步骤](mac双击文件就执行脚本的步骤)









### Windows启动脚本

~~~~
@echo OFF
color 0a
Title 钉钉内网穿透工具
Mode con cols=109 lines=30
:START
ECHO.
Echo                  ==========================================================================
ECHO.
Echo                                           钉钉内网穿透工具(个人版)
ECHO.
Echo                                               作者: 刘   伟
ECHO.
ECHO.									  
Echo                  ==========================================================================
Echo.
echo.
echo.
:TUNNEL
Echo               输入需要启动的域名前缀，如“aa” ，即分配给你的穿透域名为：“http://aa.vaiwan.com”              
ECHO.
ECHO.
ECHO.
set /p clientid=   请输入域名前缀：
echo.
set /p port=   请输入端口：
ding -config=ding.cfg -subdomain=%clientid% %port%
PAUSE
goto TUNNEL

~~~~



## 参考资料

参考资料：

[mac双击文件就执行脚本的步骤](https://www.hangge.com/blog/cache/detail_2598.html)

