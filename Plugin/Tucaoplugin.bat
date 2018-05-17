@echo off
echo 插件
pause
if "%target%"=="" echo 请使用启动器启动 && ping /5 127.0.0.1 >nul && exit
title=Tucaoplugin 1.0.1 正在下载 %target%
set target=%target:http://www.tucao.tv/play/h=%
set target=%target:/=%
set target=%target: =%
echo %target%

curl -s -k -L --retry 5 --retry-delay 40 -o target_utf8.temp http://www.tucao.tv/play/h%target%
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "s/\"/\n/g" target_gbk.temp
if exist *. del *.
sed "s/&/\n/g;s/**type=tudou//g;s/<\/li>/\n<\/li>/g;s/\*\*/\n/g" target_gbk.temp | egrep "^vid" | sed -r "s/vid=[0-9]*\|//g;/video_part/d" >target_ptitle.temp
for /f "delims=" %%r in ('sed -n "$=" target_ptitle.temp') do set /a target_pnum=%%r
egrep "m=mukio" target_gbk.temp | sed "s/a=tj/a=init/g;s/0$//g;s/&/^&/g" > xmlurl_pre.temp  
set /P xmlurl_pre=<xmlurl_pre.temp

setlocal enabledelayedexpansion
set /P quantity=<%batpath%\Temp\quantity.temp
set /a m=0
set /a n=1001
for /f %%i in (target_ptitle.temp) do (
cls
echo 正在下载 P!n:~-2!/%target_pnum%：%%i
curl -# -k -L --retry 5 --retry-delay 40 -o "%batpath%\Download\%moviename%（%year%）\P!n:~-2!_%%i_tucao.xml" %xmlurl_pre%!m!
set /a quantity=!quantity: =!+1
set /a m=!m!+1
set /a n=!n!+1
)

:END

echo %quantity%> quantity.temp
goto :eof

