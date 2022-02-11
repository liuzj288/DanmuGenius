@echo off
title=DanmuGenius弹幕下载器V5.1(20220210)
rem ========================================================================================
rem 环境设置区
rem ========================================================================================
rem 检查更新
call :UPDATE

:RE
rem ========================================================================================
rem 主程序区
rem ========================================================================================
rem 清理残余临时文件
if exist *.temp del *.temp && if exist *. del *.
echo ========================================================================================
echo 说明：本程序使用linux命令，Windows下使用建议安装GnuWin32环境，项目地址：https://github.com/liuzj288/DanmuGenius。
echo 模式一 视频解析下载：
echo 1. https://www.biliplus.com/video/av18284/
echo 2. https://www.biliplus.com/all/video/av88028/
echo 3. https://www.bilibili.com/video/av2249128/
echo 4. https://www.bilibili.com/video/BV17s411D7yk/
echo 模式二 番剧解析下载：
echo 5. https://www.bilibili.com/bangumi/play/ss4996/
echo 6. https://www.bilibili.com/bangumi/play/ep324583/
echo 7. https://www.bilibili.com/bangumi/media/md616/
echo 8. https://www.biliplus.com/bangumi/i/6341
echo ========================================================================================
rem 键入目标网址，自动跳转
set /p target_url=请输入目标：
echo %target_url%> target_url.temp
rem 通过匹配关键字实现番剧自动跳转
findstr /I "ss" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "ss" | sed "s#ss##g" > target_ssid.temp && set /p target_ssid=<target_ssid.temp && call :SSID2CID
findstr /I "ep" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "ep" | sed "s#ep##g" > target_epid.temp && set /p target_epid=<target_epid.temp && call :EPID2SSID
findstr /I "md" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "md" | sed "s#md##g" > target_mid.temp && set /p target_mid=<target_mid.temp && call :MID2SSID
findstr /I "https://www.biliplus.com/bangumi/i/" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "^[0-9]" > target_ssid.temp && set /p target_ssid=<target_ssid.temp && call :SSID2CID2
rem 通过匹配关键字实现视频自动跳转
findstr /I "av" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "av" | sed "s#av##g" > target_aid.temp && set /p target_aid=<target_aid.temp&& call :BILIPLUS
findstr /I "BV" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "BV" > target_BV.temp && set /p target_BV=<target_BV.temp && call :BV2AV
findstr /I "^[0-9]*$" target_url.temp >nul && call :CID2XML %target_url%





:END
cls
echo 提示：%target_title%（%target_year%）%target_av% 共%target_cidnum%P弹幕已下载完毕！
goto RE







rem ========================================================================================
rem XML下载函数定义区
rem ========================================================================================
rem 数据源1：http://comment.bilibili.com/{cid}.xml
rem 数据源2：https://api.bilibili.com/x/v1/dm/list.so?oid={cid}
:XMLGET
if not exist target_dinfo.temp goto RE
rem 创建保存文件夹
if not exist "downloads\%target_title%（%target_year%）" md "downloads\%target_title%（%target_year%）"
rem 获取弹幕数量
grep -i -c "^[0-9]" target_dinfo.temp > target_cidnum.temp && set /p target_cidnum=<target_cidnum.temp
rem 开始下载弹幕
setlocal enabledelayedexpansion
set count=10001
for /f "tokens=1,2,3,4 delims=@" %%a in (target_dinfo.temp) do (
echo 正在下载%target_title%（%target_year%） !count:~-3!/%target_cidnum% av%%c cid%%b %%a %%d
curl -L --compressed -o "downloads\%target_title%（%target_year%）\%%a[av%%c][cid%%b].xml" https://comment.bilibili.com/%%b.xml
set /a count=!count!+1
)
setlocal disabledelayedexpansion
goto :eof


rem ========================================================================================
rem 哔哩哔哩番剧下载函数定义区
rem ========================================================================================
:BILIPLUS
echo 数据源：1_https://www.biliplus.com/video/av%1（当前弹幕 自动识别BV号和ss号 默认）
echo 数据源：2_https://www.biliplus.com/all/video/av%1（历史弹幕）
rem echo 数据源：https://api.bilibili.com/x/player/pagelist?aid=%1&jsonp=jsonp
choice /c 12 /m "请选择数据源" /d 1 /t 2
if %errorlevel%==1 call :BILIPLUSAV1 %target_aid%
if %errorlevel%==2 call :BILIPLUSAV2 %target_aid%
goto :eof

:BILIPLUSAV1
rem echo 数据源：https://www.biliplus.com/video/av%1/
curl -s -L "https://www.biliplus.com/video/av%1/" | iconv.exe -c -f UTF-8 -t GBK > target_avinfo.temp
findstr /I "cid" target_avinfo.temp >nul || echo 当前数据源未找到弹幕数据，已自动切换数据源2 && call :BILIPLUSAV2 %1
grep "cid" target_avinfo.temp | sed "s#v2_app_api#\nv2_app_api#g" | grep -v "v2_app_api" | sed "s#,#,\n#g" | sed "s#{#\n{\n#g" | sed "s#}#\n}\n#g" > target_info.temp
rem grep "cid" target_avinfo.temp | sed "s#v2_app_api#\nv2_app_api#g" | grep "v2_app_api" | sed "s#,#,\n#g" | sed "s#{#\n{\n#g" | sed "s#}#\n}\n#g" > target_info.temp
rem 获取番剧标题和上映年份
grep "title" target_info.temp | sed "s#:#\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/title/d" > target_title.temp &&  set /p target_title=<target_title.temp
echo 已检测到标题名 %target_title%
set /p target_title=请输入番名，如地狱少女：
echo %target_title%> target_title.temp
start https://search.douban.com/movie/subject_search?search_text=%target_title%
set /p target_year=请输入发行年份，如2005：
echo ========================================================================================
rem 获取分集av号，cid号，分集标题
grep "cid" target_info.temp | sed "s#:#\n#g" | sed "s#,$##g" | sed "/cid/d" > target_pcid.temp
if exist target_paid.temp del target_paid.temp
for /f %%a in ( target_pcid.temp ) do ( cat target_aid.temp>> target_paid.temp )
grep "page" target_info.temp | grep -v "pages" | sed "s#:#\n#g" | sed "s#,$##g" | sed "/page/d" | sed -r "s#^[0-9]$#00&#g" | sed -r "s#^[0-9][0-9]$#0&#g" > target_pindex.temp
grep "part" target_info.temp | grep -v "parts" | sed "s#:#\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/part/d" > target_ptitle.temp
grep "title" target_info.temp | sed "s#:#\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/title/d"  | sed "s/[[:punct:]]//g"> target_ptitle.temp
rem 合并文件，准备下载
paste -d@ target_pindex.temp target_pcid.temp target_paid.temp target_ptitle.temp > target_dinfo.temp
call :XMLGET
goto :eof

:BILIPLUSAV2
rem echo 数据源：https://www.biliplus.com/all/video/av%1/
curl -s -L "https://www.biliplus.com/all/video/av%1/" | iconv.exe -c -f UTF-8 -t GBK  | sed "s#/api/view_all#\nhttps://www.biliplus.com&#g" | sed "s#,#\n#g" | grep "view_all" | sed "s#.$##g" > target_allapiurl.temp
for /f %%a in (target_allapiurl.temp) do ( curl -s -L %%a | jq-win32 -s "." | iconv.exe -c -f UTF-8 -t GBK > target_info.temp )
rem 获取番剧标题和上映年份
grep "title" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/title/d" > target_title.temp &&  set /p target_title=<target_title.temp
echo 已检测到标题名 %target_title%
set /p target_title=请输入番名，如地狱少女：
start https://search.douban.com/movie/subject_search?search_text=%target_title%
set /p target_year=请输入上映年份，如2005：
echo ========================================================================================
rem 获取分集av号，cid号，分集标题
grep "cid" target_info.temp | grep -v "cid_count" | sed "s#: #\n#g" | sed "s#,$##g" | sed "/cid/d" > target_pcid.temp
if exist target_paid.temp del target_paid.temp
for /f %%a in (target_pcid.temp) do ( cat target_aid.temp>> target_paid.temp )
grep "page" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/page/d" | sed -r "s#^[0-9]$#00&#g" | sed -r "s#^[0-9][0-9]$#0&#g" > target_pindex.temp
grep "part" target_info.temp | grep -v "parts" | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/part/d" > target_ptitle.temp
grep "title" target_info.temp | sed "s#:#\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/title/d" > target_ptitle.temp
rem 合并文件，准备下载
paste -d@ target_pindex.temp target_pcid.temp target_paid.temp target_ptitle.temp > target_dinfo.temp
call :XMLGET
goto :eof

rem BV号转AV号
:BV2AV
curl -L --compressed "https://api.bilibili.com/x/web-interface/archive/stat?bvid=%target_BV%" | jq-win32 -s "." | sed "s#,$##g" | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
grep -i "aid" target_info.temp | sed "s#: #\n#g" | grep "^[0-9]*[0-9]$" > target_aid.temp && set /p target_aid=<target_aid.temp
call :BILIPLUS %target_aid%
goto :eof


rem ========================================================================================
rem 哔哩哔哩番剧下载函数定义区
rem ========================================================================================
:SSID2CID
rem 设置番名和年份
set /p target_title=请输入番名，如地狱少女：
set /p target_year=请输入发行年份，如2005：
echo ========================================================================================
rem 数据源：https://api.bilibili.com/pgc/web/season/section?season_id=%target_ssid%
curl -s -L "https://api.bilibili.com/pgc/web/season/section?season_id=%target_ssid%" | jq-win32 -s "." | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
rem 获取系列标题、季度标题、上映年份
grep "id" target_info.temp | egrep -v "(a|c|v)id" | sed "s#: #\n#g" | sed "s#,$##g" | sed "/id/d" | sed "1!d" > target_epid.temp && set /p target_epid=<target_epid.temp
rem 获取分集av号，cid号，分集标题
grep "aid" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/aid/d" > target_paid.temp
grep "cid" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/cid/d" > target_pcid.temp
grep "title" target_info.temp | grep -v "long_title" | sed "s#: #\n#g" | sed "s#,$##g" | sed "/title/d" | sed "s#^.##g" | sed "s#.$##g"  | sed "/正片/d"  > target_pindex.temp
grep "long_title" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/long_title/d" > target_ptitle.temp
rem 合并文件，准备下载
paste -d@ target_pindex.temp target_pcid.temp target_paid.temp target_ptitle.temp | sed -r "/(^[0-9]|^第)/!d" | sort > target_dinfo.temp
call :XMLGET
goto :eof

:SSID2CID2
rem 设置番名和年份
set /p target_title=请输入番名，如地狱少女：
set /p target_year=请输入发行年份，如2005：
echo ========================================================================================
echo 数据源：https://www.biliplus.com/api/bangumi?season=%target_ssid%
curl -s -L "https://www.biliplus.com/api/bangumi?season=%target_ssid%" | jq-win32 -s "." | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
rem 获取分集av号，cid号，分集标题
grep "av_id" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/av_id/d" > target_paid.temp
grep "danmaku" target_info.temp | grep -v "danmaku_count" | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/danmaku/d" > target_pcid.temp
grep "index" target_info.temp | grep -v "index_" | grep -v "_index" | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/index/d" > target_pindex.temp
grep "index_title" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/index_title/d" > target_ptitle.temp
rem 合并文件，准备下载
paste -d@ target_pindex.temp target_pcid.temp target_paid.temp target_ptitle.temp | sed -r "/^[0-9]/!d" | sort > target_dinfo.temp
call :XMLGET
goto :eof

:EPID2SSID
rem 数据源http://api.bilibili.com/pgc/view/web/season?ep_id=%target_epid%
curl -s -L --compressed "http://api.bilibili.com/pgc/view/web/season?ep_id=%target_epid%" | jq-win32 -s "."  | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
grep "season_id" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/season_id/d" | sed "1!d" > target_ssid.temp && set /p target_ssid=<target_ssid.temp
call :SSID2CID %target_ssid%
goto :eof

:MID2SSID
rem 数据源https://api.bilibili.com/pgc/review/user?media_id=%target_mid%
curl -s -L --compressed "https://api.bilibili.com/pgc/review/user?media_id=%target_mid%" | jq-win32 -s "." | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
grep "season_id" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/season_id/d" | sed "1!d" > target_ssid.temp && set /p target_ssid=<target_ssid.temp
call :SSID2CID %target_ssid%
goto :eof

:UPDATE
echo 正在检查更新……
curl -s -L --retry 3 -o version.temp https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/version.txt
set /p version=<version.txt && set /p version_latest=<version.temp
if %version%==%version_latest% echo 当前没有可用更新 || echo DanmuGenius已更新至%version_new%，请及时下载更新 && start https://github.com/liuzj288/DanmuGenius
goto :eof
