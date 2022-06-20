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