@echo off
title=Tucaoplugin 1.0.1 正在下载 %target%
set target=%target:http://www.tucao.tv/play/h=%
set target=%target:/=%
set target=%target: =%

curl -s -k -L -o target_utf8.temp http://www.tucao.tv/play/h%target%
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "s/\"/\n/g" target_gbk.temp
if exist *. del *.
sed "s/&/\n/g;s/**type=tudou//g;s/<\/li>/\n<\/li>/g;s/\*\*/\n/g" target_gbk.temp | egrep "^vid" | sed -r "s/vid=[0-9]*\|//g;/video_part/d" >target_ptitle.temp
egrep "m=mukio" target_gbk.temp | sed "s/a=tj/a=init/g;s/0$//g;s/&/^&/g" > xmlurl_pre.temp  
set /P xmlurl_pre=<xmlurl_pre.temp

setlocal enabledelayedexpansion
set /p quantity<=quantity.temp
set /a m=0
set /a n=1001
for /f %%i in (target_ptitle.temp) do (
echo 正在下载 P!n:~-2!_%%i
curl -# -k -L -o %batpath%\Download\%moviename%（%year%）\P!n:~-2!_%%i.xml %xmlurl_pre%!m!
set /a quantity=!quantity!+1
set /a m=!m!+1
set /a n=!n!+1
)

:END
call :save_data "%target%" "%%target_keyword%%"
echo %quantity% >quantity.temp
goto :eof


:save_data
if not exist %batpath%\AppData\movie_backup.md echo "| movie | av | ptitle | cid | addtime | note |" > %batpath%\AppData\movie_backup.md && echo "| :-: | :-: | - | :-: | :-: | - |" >> %batpath%\AppData\movie_backup.md
findstr "%1" %batpath%\AppData\movie_backup.md >nul && echo. || echo "| [%moviename%(%year%)](https://movie.douban.com/subject_search?search_text=%moviename%) <br/>[Bili+](https://www.biliplus.com/api/do.php?act=search&word=%moviename%) [磁力](http://cn.btbit.xyz/list/%moviename%.html) [字幕](http://assrt.net/sub/?searchword=%moviename%) [字幕](http://subhd.com/search0/%moviename%)</br> | [Tucao](http://www.tucao.tv/play/h%1) |  |  | %date:~0,10% | %2 |">> %batpath%\AppData\movie_backup.md
sed -i "s/\"//g" %batpath%\AppData\movie_backup.md
if exist %batpath%\AppData\*. del %batpath%\AppData\*.
if not exist %batpath%\AppData\movie_backup.temp echo "| movie | av | ptitle | cid | addtime | note |" > %batpath%\AppData\movie_backup.temp && echo "| :-: | :-: | - | :-: | :-: | - |" >> %batpath%\AppData\movie_backup.temp
sed "1,2d" %batpath%\AppData\movie_backup.md | sort | uniq >> %batpath%\AppData\movie_backup.temp && del %batpath%\AppData\movie_backup.md
cat %batpath%\AppData\movie_backup.temp > %batpath%\AppData\movie_backup.md && del %batpath%\AppData\movie_backup.temp
sed -i "s/\"//g" %batpath%\AppData\movie_backup.md
if exist %batpath%\AppData\*. del %batpath%\AppData\*.
goto :eof

