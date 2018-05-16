@echo OFF
set version=1.0.3
title=Biliplugin %version%：正在下载 %target%
if "%target%"=="" echo 请使用启动器启动 && ping /5 127.0.0.1 >nul && exit

:main
echo %target%| findstr /r "[aA][vV]" >nul && echo %target%| sed -r "s#http://www.jijidown.com/video/[aA][vV]##g;s#[aA][vV]##g;s#/##g"> target_av.temp && goto av2cid

:av2cid
rem 使用唧唧接口获取对应信息
set /P target_av=<target_av.temp
curl -s -o target_av2cidutf8.temp http://www.jijidown.com/Api/AvToCid/%target_av%/0
iconv -c -f UTF-8 -t GBK target_av2cidutf8.temp > target_av2cidgbk.temp
sed -i "s#:#\n#g;s#,#\n#g;s#/##g;s#}##g;s#哔哩哔哩 (゜-゜)つロ 干杯~#%moviename%##g;s#视频去哪了呢？#%moviename%#g;s#YPE html>##g;s#]##g" target_av2cidgbk.temp
sed -i "s/\"//g" target_av2cidgbk.temp
if exist *. del *.
egrep -A1 "^title" target_av2cidgbk.temp | sed "/title/d;/--/d;/^$/d" | sed -r "s/[[:blank:][:punct:]]/_/g;s/%target_av: =%//g;s/哔哩哔哩弹幕视频网_____゜__゜_つロ__乾杯_____bilibili_______________________________________//g;s/该视频已被B站删除//g" > target_title.temp && set target_title=&& set /P target_title=<target_title.temp
egrep -A1 "^CID" target_av2cidgbk.temp | sed -r "s/[[:blank:][:punct:]]//g" | sed -r "/^CID/d;/^$/d;/^0$/d" |uniq > target_pcid.temp
for /f "delims=" %%p in ('sed -n "$=" target_pcid.temp') do set /a pcid_num=%%p
egrep -A1 "^Title" target_av2cidgbk.temp | sed "/Title/d;/--/d" | sed "s#[[:blank:]][[:blank:]]*#_#g;s#[[:blank:]()>!.]#_#g;s#/##g;s#]##g;s#%moviename%##g" | sed "/^$/d;/哔哩哔哩弹幕视频网/d;/bilibili/d" > target_ptitle.temp && seq -f"P%%02g"  1 1 99 >> target_ptitle.temp

:get_cid
setlocal enabledelayedexpansion
set /p quantity<=quantity.temp
set /a m=1001
set /a n=1
for /f %%z in (target_pcid.temp) do (
set target_pcid=%%z
sed -n "!n!p" target_ptitle.temp | sed "s/[mid]/%%t/g" > target_pntitle.temp && set /P target_pntitle=<target_pntitle.temp
if "!target_pntitle!"=="%target_title%" set target_pntitle=
cls
echo 正在下载 !n!/%pcid_num%：av!target_av!_cid!target_pcid!
call :get_xml !target_pcid!

for %%i in ( %batpath%\temp\cid!target_pcid!.xml )do if %%~zi lss 51200 ( del "%%i" ) else (
move %batpath%\temp\cid!target_pcid!.xml "%batpath%\Download\%moviename%（%year%）\av!target_av: =!_P!m:~-2!_!target_pntitle!_cid!target_pcid!.xml" >nul
call :save_data "!target_pcid: =!" "!target_av: =!" "P!m:~-2! !target_pntitle!" "!target_title! %target_keyword%"
set /a quantity=!quantity!+1

)
set /a n=!n!+1
set /a m=!m!+1
)

:end
echo %quantity% >quantity.temp
goto :eof


::=========================
::函数部分开始
::=========================
:get_xml
curl -k -L -# --compressed -o "%1_new.xml" http://comment.bilibili.com/%1.xml 
curl -k -L -s --compressed -o "target_rolldate.temp" http://comment.bilibili.com/rolldate,%1
sed -i "s/\"/\n/g" target_rolldate.temp 
sed -i "/new/,+3d;/[[:punct:]]/d;/timestamp/d" target_rolldate.temp && del *.
for /f "delims=" %%r in ('sed -n "$=" target_rolldate.temp') do set /a target_interval=%%r/5
sed -n "1~%target_interval%p" target_rolldate.temp > target_timestamp.temp
cat target_timestamp.temp | xargs -n 1 -P 15 -I {} curl -s -k -L --compressed -o %1_{}.xml http://comment.bilibili.com/dmroll,{},%1
sed -ir "s/><d/>\n<d/g;1d;$d;/[我卧沃广][操槽日靠电]/d" %1_*.xml && del *.

copy %1_new.xml + %1_*.xml >nul
iconv -c -f UTF-8 -t GBK  %1_new.xml |sort |uniq > %1.temp && del %1_*.* 
sed -i "1i <?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?><i><chatserver>chat.bilibili.com</chatserver><chatid>%1</chatid><mission>0</mission><maxlimit>8000</maxlimit><state>0</state><realname>%2</realname><source>e-r</source>" %1.temp
sed -i "$a </li>" %1.temp && del *.
iconv -c -f GBK -t UTF-8 %1.temp > cid%1.xml && del %1.temp
goto :eof

:save_data
if not exist %batpath%\AppData\movie_backup.md echo "| movie | av | ptitle | cid | addtime | note |" > %batpath%\AppData\movie_backup.md && echo "| :-: | :-: | - | :-: | :-: | - |" >> %batpath%\AppData\movie_backup.md
findstr "cid%1" %batpath%\AppData\movie_backup.md >nul && echo. || echo "| [%moviename%(%year%)](https://movie.douban.com/subject_search?search_text=%moviename%) <br/>[Bili+](https://www.biliplus.com/api/do.php?act=search&word=%moviename%) [磁力](http://cn.btbit.xyz/list/%moviename%.html) [字幕](http://assrt.net/sub/?searchword=%moviename%) [字幕](http://subhd.com/search0/%moviename%)</br> | [av%2](http://www.bilibili.com/video/av%2) <br/>[Bili+](https://www.biliplus.com/all/video/av%2) [唧唧](http://www.jijidown.com/video/av%2)</br>  | %3 | [cid%1](http://comment.bilibili.tv/%1.xml) <br/>[全弹幕](https://www.biliplus.com/open/moepus.powered.full-danmaku.php#%1)</br> | %date:~0,10% | %4 |" >> %batpath%\AppData\movie_backup.md
sed -i "s/\"//g" %batpath%\AppData\movie_backup.md
if exist %batpath%\AppData\*. del %batpath%\AppData\*.
if not exist %batpath%\AppData\movie_backup.temp echo "| movie | av | ptitle | cid | addtime | note |" > %batpath%\AppData\movie_backup.temp && echo "| :-: | :-: | - | :-: | :-: | - |" >> %batpath%\AppData\movie_backup.temp
sed "1,2d" %batpath%\AppData\movie_backup.md | sort | uniq >> %batpath%\AppData\movie_backup.temp && del %batpath%\AppData\movie_backup.md
cat %batpath%\AppData\movie_backup.temp > %batpath%\AppData\movie_backup.md && del %batpath%\AppData\movie_backup.temp
sed -i "s/\"//g" %batpath%\AppData\movie_backup.md
if exist %batpath%\AppData\*. del %batpath%\AppData\*.
goto :eof