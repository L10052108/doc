@echo OFF
color 0a
Title ����������͸����
Mode con cols=109 lines=30
:START
ECHO.
Echo                  ==========================================================================
ECHO.
Echo                                           ����������͸����(���˰�)
ECHO.
Echo                                               ����: ��   ΰ
ECHO.
ECHO.									  
Echo                  ==========================================================================
Echo.
echo.
echo.
:TUNNEL
Echo               ������Ҫ����������ǰ׺���硰aa�� �����������Ĵ�͸����Ϊ����http://aa.vaiwan.com��              
ECHO.
ECHO.
ECHO.
set /p clientid=   ����������ǰ׺��
echo.
set /p port=   ������˿ڣ�
ding -config=ding.cfg -subdomain=%clientid% %port%
PAUSE
goto TUNNEL
