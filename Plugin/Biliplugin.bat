@echo Off
set version=1.0.5
title=Biliplugin %version%：正在下载 %target%
if "%target%"=="" echo 请使用启动器启动 && ping /5 127.0.0.1 >nul && exit

:main
echo %target%| findstr /r "[aA][vV]" >nul && echo %target%|sed -r "s#[aA][vV]##g;s#/##g;s# ##g">target_av.temp
set /P target_av=<target_av.temp
call :av2cid %target_av: =%

:get_cid
setlocal enabledelayedexpansion
set /p quantity=<quantity.temp
set /a m=1001
set /a n=1
for /f %%z in (target_pcid.temp) do (
set target_pcid=%%z
sed -n "!n!p" target_ptitle.temp | sed "s/[mid]/%%t/g" > target_pntitle.temp && set /P target_pntitle=<target_pntitle.temp
if "!target_pntitle!"=="%target_title%" set target_pntitle=
cls
echo 正在下载 !n!/%pcid_num%：av!target_av!_cid!target_pcid!
call :get_xml !target_pcid!

for %%i in ( %batpath%\temp\cid!target_pcid!.xml )do if %%~zi lss 100 ( del "%%i" ) else (
move %batpath%\temp\cid!target_pcid!.xml "%batpath%\Download\%moviename%[%year%]\av!target_av: =!_P!m:~-2!_!target_pntitle!_cid!target_pcid!.xml" >nul
call :save_data "!target_pcid: =!" "!target_av: =!" "P!m:~-2! !target_pntitle!" "!target_title! %target_keyword%"

)
set /a n=!n!+1
set /a m=!m!+1
)

:end
echo %quantity% >quantity.temp
set category=%category:B站:=%
set category=%category%B站
goto :eof


::===========================================================================
::函数部分开始
::===========================================================================
:av2cid
curl -s -o target_av2cidutf8.temp http://www.jijidown.com/Api/AvToCid/%1/0
iconv -c -f UTF-8 -t GBK target_av2cidutf8.temp > target_av2cidgbk.temp
sed -i "s/\"//g" target_av2cidgbk.temp
sed -i "s/},{/\n/g;s/title/\ntitle/g;s/,time/\n,time/g;s/AV/\nAV/g;s/://g;s/?//g" target_av2cidgbk.temp
sed -i "/^$/d;/,CID0,/d;1d;3d" target_av2cidgbk.temp
if exist *. del *.
egrep "title" target_av2cidgbk.temp |sed "s/title//g;s/%1//g;s/哔哩哔哩弹幕视频网_____゜__゜_つロ__乾杯_____bilibili_______________________________________//g;s/该视频已被B站删除//g">target_title.temp  && set target_title=&& set /P target_title=<target_title.temp
sed "s/,/\n/g" target_av2cidgbk.temp| egrep "CID" |sed "s/CID//g;/^0$/d"|uniq > target_pcid.temp
for /f "delims=" %%p in ('sed -n "$=" target_pcid.temp') do set /a pcid_num=%%p
egrep "Title" target_av2cidgbk.temp | sed -r "s/AV[0-9]*,//g;s/,CID[0-9]*,//g;s/Title/ /g" | sed "s/}]}//g">target_ptitle.temp
goto :eof


:get_xml
@echo off
echo 正在下载当前弹幕……
curl -k -L -# --compressed -o "%1_new.temp" http://comment.bilibili.com/%1.xml
if exist *. del *.
iconv -c -f UTF-8 -t GBK  %1_new.temp |sort /rec 65535 |uniq > %1_new.xml && del *.
sed -i "1d;$d" "%1_new.xml"
echo 正在获取历史弹幕……
curl -k -L -s --compressed -o "target_rolldate.temp" http://comment.bilibili.com/rolldate,%1
sed -i "s/\"/\n/g" target_rolldate.temp 
sed -i "/new/,+3d;/[[:punct:]]/d;/timestamp/d" target_rolldate.temp && del *.
for /f "delims=" %%r in ('sed -n "$=" target_rolldate.temp') do set /a target_interval=%%r/5
sed -n "1~%target_interval%p" target_rolldate.temp > target_timestamp.temp
for /f %%t in (target_timestamp.temp) do (
curl -# -k -L --compressed -o %1_%%t.temp http://comment.bilibili.com/dmroll,%%t,%1
if exist *. del *.
iconv -c -f UTF-8 -t GBK  %1_%%t.temp> %1_%%t.xml && del *. 
sed "1d;$d" %1_%%t.xml>> %1_new.xml
del %1_%%t.temp
del %1_%%t.xml
)

echo 正在清洗合并弹幕……
cat %1_new.xml |sort /rec 65535 |uniq >%1.temp
sed -i "1i <?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?><i><chatserver>chat.bilibili.com</chatserver><chatid>%1</chatid><mission>0</mission><maxlimit>8000</maxlimit><state>0</state><realname>%2</realname><source>e-r</source>" %1.temp
sed -i "$a </i>" %1.temp && del *.
iconv -c -f GBK -t UTF-8 %1.temp > cid%1.xml && del %1.temp
goto :eof

:save_data
if not exist %batpath%\AppData\movie_backup.md echo "| movie | av | ptitle | cid | addtime | note |" > %batpath%\AppData\movie_backup.md && echo "| :-: | :-: | - | :-: | :-: | - |">> %batpath%\AppData\movie_backup.md
findstr "cid%1" %batpath%\AppData\movie_backup.md >nul && echo. || echo "| [%moviename%(%year%)](https://movie.douban.com/subject_search?search_text=%moviename%) <br/>[Bili+](https://www.biliplus.com/api/do.php?act=search&word=%moviename%) [磁力](http://cn.btbit.xyz/list/%moviename%.html) [字幕](http://assrt.net/sub/?searchword=%moviename%) [字幕](http://subhd.com/search0/%moviename%)</br> | [av%2](http://www.bilibili.com/video/av%2) <br/>[Bili+](https://www.biliplus.com/all/video/av%2) [唧唧](http://www.jijidown.com/video/av%2)</br>  | %3 | [cid%1](http://comment.bilibili.tv/%1.xml) <br/>[全弹幕](https://www.biliplus.com/open/moepus.powered.full-danmaku.php#%1)</br> | %date:~0,10% | %4 |">> %batpath%\AppData\movie_backup.md
sed -i "s/\"//g" %batpath%\AppData\movie_backup.md
if exist %batpath%\AppData\*. del %batpath%\AppData\*.
if not exist %batpath%\AppData\movie_backup.temp echo "| movie | av | ptitle | cid | addtime | note |" > %batpath%\AppData\movie_backup.temp && echo "| :-: | :-: | - | :-: | :-: | - |" >> %batpath%\AppData\movie_backup.temp
sed "1,2d" %batpath%\AppData\movie_backup.md | sort /rec 65535 | uniq >> %batpath%\AppData\movie_backup.temp && del %batpath%\AppData\movie_backup.md
cat %batpath%\AppData\movie_backup.temp > %batpath%\AppData\movie_backup.md && del %batpath%\AppData\movie_backup.temp
sed -i "s/\"//g" %batpath%\AppData\movie_backup.md
if exist %batpath%\AppData\*. del %batpath%\AppData\*.
goto :eof