@echo OFF
set version=1.0.1
title=Bangumiplugin %version%：正在下载 %target%

:curl_target
curl -s -k -L -o target_utf8.temp %target%
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "s#\"##g" target_gbk.temp
sed -i "s#,#\n#g;s#:#\n#g;s#>#>\n#g;s#><#>\n<#g" target_gbk.temp && del *.
egrep -A1 "^ep_id" target_gbk.temp |egrep "^[0-9]" |sed "s#^#https://www.bilibili.com/bangumi/play/ep#g" |uniq > target_epid.temp
for /f "delims=" %%p in ('sed -n "$=" target_epid.temp') do set /a epid_num=%%p

:main
SETLOCAL ENABLEDELAYEDEXPANSION
set /a m=1001
set /a n=1
for /f %%z in (target_epid.temp) do (
cls
curl -s -k -L -o target_utf8.temp %%z
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "s#\"##g" target_gbk.temp
sed -i "s#,#\n#g;s#:#\n#g;s#>#>\n#g;s#><#>\n<#g" target_gbk.temp && del *.
egrep "www.bilibili.com/video/av" target_gbk.temp | sed "s#/#\n#g" |egrep "^av" |sed "s#av##g"> target_av.temp && set /P target_av=<target_av.temp
egrep "</h1>" target_gbk.temp | sed "s#</h1>##g;s#%moviename%：##g"  > target_ptitle.temp && set /P target_ptitle=<target_ptitle.temp
egrep -A1 "^cid" target_gbk.temp |egrep "^[0-9]" |head -1 > target_pcid.temp && set /P target_pcid=<target_pcid.temp

echo 正在下载 !n!/%epid_num%：av!target_av!_cid!target_pcid!
call :get_xml !target_pcid!
for %%i in ( %batpath%\temp\cid!target_pcid!.xml )do if %%~zi lss 51200 ( del "%%i" ) else (
move %batpath%\temp\cid!target_pcid!.xml  "%batpath%\Download\%moviename%（%year%）\av!target_av: =!_P!m:~-2!_%target_title%_!target_ptitle!_cid!target_pcid!.xml" >nul
call :save_data "!target_pcid: =!" "!target_av: =!" "P!m:~-2! !target_ptitle!" " %target_keyword% "
)
set /a n=!n!+1
set /a m=!m!+1
)
SETLOCAL DISABLEDELAYEDEXPANSION

:end
goto :eof



::===========================
::函数部分开始
::===========================

:get_xml
curl -k -L -# --compressed -o "%1_new.xml" http://comment.bilibili.com/%1.xml -o "target_rolldate.temp" http://comment.bilibili.com/rolldate,%1
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
findstr "cid%1" %batpath%\AppData\movie_backup.md >nul && echo. || echo "| [%moviename%(%year%)](https://movie.douban.com/subject_search?search_text=%moviename%) <br/>[Bili+](https://www.biliplus.com/api/do.php?act=search&word=%moviename%) [字幕](http://assrt.net/sub/?searchword=%moviename%) [字幕](http://subhd.com/search0/%moviename%)</br> | [av%2](http://www.bilibili.com/video/av%2) <br/>[唧唧](http://www.jijidown.com/video/av%2) [Bili+](https://www.biliplus.com/all/video/av%2)</br> | %3 | [cid%1](http://comment.bilibili.tv/%1.xml) <br/>[全弹幕](https://www.biliplus.com/open/moepus.powered.full-danmaku.php#%1)</br> | %date:~0,10% | %4 |" >> %batpath%\AppData\movie_backup.md
sed -i "s/\"//g" %batpath%\AppData\movie_backup.md
if exist %batpath%\AppData\*. del %batpath%\AppData\*.
if not exist %batpath%\AppData\movie_backup.temp echo "| movie | av | ptitle | cid | addtime | note |" > %batpath%\AppData\movie_backup.temp && echo "| :-: | :-: | - | :-: | :-: | - |" >> %batpath%\AppData\movie_backup.temp
sed "1,2d" %batpath%\AppData\movie_backup.md | sort | uniq >> %batpath%\AppData\movie_backup.temp && del %batpath%\AppData\movie_backup.md
cat %batpath%\AppData\movie_backup.temp > %batpath%\AppData\movie_backup.md && del %batpath%\AppData\movie_backup.temp
sed -i "s/\"//g" %batpath%\AppData\movie_backup.md
if exist %batpath%\AppData\*. del %batpath%\AppData\*.
goto :eof