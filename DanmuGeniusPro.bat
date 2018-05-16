@echo off
mode con cols=80 lines=25 && set version=3.1.6
title=DanmuGeniusPro %version%
set batpath=%~dp0%
if "%batpath%" NEQ "%batpath: =%" echo 请解压到不包含空格路径！ && pause && exit
set mode=auto
if not exist %batpath%\Bin\*.exe echo 请下载Bin环境包!按回车确认下载！ && pause && curl -# -k -L -o %batpath%\Bin.zip https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Bin.zip
if exist %batpath%\Bin set path=%batpath%\Bin;%path%
if exist "%batpath%\AppData\music.list" for /f %%i in (%batpath%\AppData\music.list) do (start /min gplay.exe %%i)

rem 制作程序环境
if not exist %batpath%\AppData md %batpath%\AppData && echo %version% > %batpath%\AppData\version.txt  && curl -o %batpath%\AppData\download-complete.wav https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/download-complete.wav
if not exist %batpath%\Plugin md %batpath%\Plugin
if not exist %batpath%\Temp md %batpath%\Temp
if not exist %batpath%\Download md %batpath%\Download
if not exist %batpath%\Plugin\danmu-tools echo 警告：未检测到danmu-tools！只能解析B站弹幕！ && pause

:RE0
cls
echo mode:%mode%
cd %batpath%/Temp/
echo 模式：S-智能模式;A-自动模式(默认);M-手动模式
echo 操作：E_添加标签;C_清空标签;U_检查更新;H_查看帮助
echo =======================================
if "%moviename%" NEQ "" if exist "%batpath%\Download\%moviename%（%year%）/*.xml" echo 提示：%moviename%（%year%）已下载完毕，共用时 %chronography% 秒！
if "%target_keyword%" NEQ "" echo 备注：%target_keyword%
set /p moviename=请输入影片名(保存文件夹)：
if "%moviename%"=="" goto RE0
if /i "%moviename%"=="S" set mode=smart&& goto RE0
if /i "%moviename%"=="A" set mode=auto&& goto RE0
if /i "%moviename%"=="M" set mode=manual&& goto RE0
if /i "%moviename%"=="E" set /p target_keyword=请输入备注：&& goto RE0
if /i "%moviename%"=="C" set target_keyword=&& goto RE0
if /i "%moviename%"=="U" call :update && goto RE0
if /i "%moviename%"=="H" start https://github.com/liuzj288/DanmuGenius/blob/master/README.md && goto RE0

URLEncode -e %moviename% -o keywords.temp && set /P keywords=<keywords.temp
curl -s -k -L -R --retry 5 --retry-delay 10 -o target_utf8.temp https://api.douban.com/v2/movie/search?q=%keywords%
iconv -c -f UTF-8 -t GBK target_utf8.temp > target_gbk.temp
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "/:/d;/,/d" target_gbk.temp && del *.
echo 请选择公映时间：
egrep -A1 "year" target_gbk.temp | egrep "[[:digit:]]" | head -1 > target_year.temp && set /P year=<target_year.temp 
egrep -A1 "year" target_gbk.temp | egrep "[[:digit:]]" | xargs -n 10
:RE1
if "%mode%" NEQ "smart" set /p year=请输入年份（当前默认为:%year%）：|| goto RE2


URLEncode -e %moviename%%year% -o keywords.temp 
sed -i "s#%%#%%7C#g;s#[a-z]#\u&#g" keywords.temp && set /P keywords=<keywords.temp
curl -s -R --retry 5 --retry-delay 10 -o target_utf8.temp http://www.jijidown.com/Search/%keywords%
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "/剪辑/d;/片段/d;/预告/d;/預告/d;/混剪/d;/自制/d;/自剪/d;/片段/d;/插曲/d;/配乐/d;/幕后/d;/谷阿莫/d" target_gbk.temp && del *.
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "s#'/video/#\n#g;s#'#\n#g" target_gbk.temp && del *.
egrep "^av" target_gbk.temp > target_URL.temp
egrep "/J/default/"  target_gbk.temp | sed "s#^#http://www.jijidown.com#g" |sort |uniq > target_pages.temp
for /f %%p in (target_pages.temp) do (
curl -s -R --retry 5 --retry-delay 10 -o target_utf8.temp %%p
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "/剪辑/d;/片段/d;/预告/d;/預告/d;/混剪/d;/自制/d;/自剪/d;/片段/d;/插曲/d;/配乐/d;/幕后/d;/谷阿莫/d" target_gbk.temp && del *.
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "s#'/video/#\n#g;s#'#\n#g" target_gbk.temp && del *.
if "%mode%" NEQ "manual" egrep "^av" target_gbk.temp >> target_URL.temp || start https://www.bilibili.com/sp/%keywords% && start https://www.biliplus.com/api/do.php?act=search^&word=%keywords%^&o=danmaku^&n=30^&p=1^&source=biliplus
)
for /f %%z in (target_URL.temp) do (
findstr "%%z" "%batpath%\AppData\movie_backup.md" >nul || echo %%z >> target_URL.txt
)

:RE2
cls
echo 准备下载：%target_keyword% %moviename%(%year%)
echo =======================================
echo 任务列表：
if exist target_URL.txt cat -b target_URL.txt
echo.
echo =======================================
echo 操作：E_编辑列表;C_清空列表；F_查找弹幕
echo 说明：S_开始下载;Q_返回上层
echo =======================================
set /p target_URL=请粘贴URL、AV号或CID号：
set target_URL=%target_URL:http://www.bilibili.com/video/=% && set target_URL=%target_URL:https://www.bilibili.com/video/=% && set target_URL=%target_URL:http://www.jijidown.com/video/=% && set target_URL=%target_URL:https://www.biliplus.com/all/video/=%
if /i "%target_URL%"=="S" goto main
if /i %target_URL%==E start /wait target_URL.txt && goto RE2
if /i %target_URL%==C echo. 2>target_URL.txt && goto RE2
if /i %target_URL%==F start https://www.biliplus.com/api/do.php?act=search^&word=%moviename% && start https://www.bilibili.com/sp/%moviename% && goto RE2
if /i %target_URL%==Q goto RE0
findstr "%target_URL%" target_URL.txt >nul && echo 警告：重复任务！ && ping -n 2 127.0.0.1 >nul && goto RE2
findstr "%target_URL%" %batpath%\AppData\movie_backup.md >nul && echo 警告：已下载！ && ping -n 2 127.0.0.1 >nul && goto RE2 || echo %target_URL%>> target_URL.txt && goto RE2


:main
set timestart=0%time%
set /a secondstart=%timestart:~-5,2% && set /a minutestart=%timestart:~-8,2% && set /a hourstart=%timestart:~-11,2%
if not exist %batpath%\Download\%moviename%（%year%） md %batpath%\Download\%moviename%（%year%）
setlocal enabledelayedexpansion
for /f %%z in (target_URL.txt) do (
set target=%%z
echo !target! | findstr "https://www.bilibili.com/bangumi/" >nul && call %batpath%\Plugin\Bangumiplugin.bat
echo !target! | findstr /r "[aA][vV]" >nul && call %batpath%\Plugin\Biliplugin.bat
echo !target! | findstr "tucao" >nul && call %batpath%\Plugin\Tucaoplugin.bat
echo !target! | findstr "iqiyi" >nul && cd %batpath%\Plugin\danmu-tools\ && set web=iqiyi && cls && java -jar %batpath%\Plugin\danmu-tools\downloader.jar -u !target! && cd %batpath%\Plugin\danmu-tools\DanMu\ && ren *.xml *. && ren *. *_iqiyi.xml && call %batpath%\Plugin\danmutools.bat
echo !target! | findstr "youku" >nul && cd %batpath%\Plugin\danmu-tools\ && set web=youku && cls && java -jar %batpath%\Plugin\danmu-tools\downloader.jar -u !target! && cd %batpath%\Plugin\danmu-tools\DanMu\ && ren *.xml *. && ren *. *_youku.xml && call %batpath%\Plugin\danmutools.bat
echo !target! | findstr "diyidan" >nul && cd %batpath%\Plugin\danmu-tools\ && set web=iqiyi && cls && java -jar %batpath%\Plugin\danmu-tools\downloader.jar -u !target! && cd %batpath%\Plugin\danmu-tools\DanMu\ && ren *.xml *. && ren *. *_diyidan.xml && call %batpath%\Plugin\danmutools.bat
echo !target! | findstr "qq.com" >nul && cd %batpath%\Plugin\danmu-tools\ set web=tencent && cls && java -jar %batpath%\Plugin\danmu-tools\downloader.jar -u !target! && cd %batpath%\Plugin\danmu-tools\DanMu\ && ren *.xml *. && ren *. *_tencent.xml && call %batpath%\Plugin\danmutools.bat
echo !target! | findstr "acfun" >nul && cd %batpath%\Plugin\danmu-tools\ && set web=acfun && cls && java -jar %batpath%\Plugin\danmu-tools\downloader.jar -u !target! && cd %batpath%\Plugin\danmu-tools\DanMu\ && ren *.xml *. && ren *. *_acfun.xml && call %batpath%\Plugin\danmutools.bat
)
if not exist %batpath%\Download\%moviename%（%year%）\*.xml rd %batpath%\Download\%moviename%（%year%）
if exist %batpath%\Temp\*.* del /q %batpath%\Temp\*.*

:end
cd %batpath%
gplay.exe %batpath%\AppData\download-complete.wav > nul
set timeend=0%time%
set /a secondend=%timeend:~-5,2% && set /a minuteend=%timeend:~-8,2% && set /a hourend=%timeend:~-11,2%
set /a chronography=(%hourend%-%hourstart%)*60*60+(%minuteend%-%minutestart%)*60+(%secondend%-%secondstart%)
goto RE0



::=========================
::函数部分开始
::=========================

:update
cls
echo 正在检查更新……
curl -k -L -s -o %batpath%\AppData\versionnew.temp https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/version.txt && set /P versionnew=<%batpath%\AppData\versionnew.temp && del %batpath%\AppData\versionnew.temp
if "%version%" NEQ "%versionnew%" (
echo 当前版本%version% 最新版本 %versionnew% 请及时更新！ && ping /n 3 127.0.0.1 >nul
echo 正在更新Bangumiplugin……
curl -# -k -L -R --retry 5 --retry-delay 10 -o %batpath%\Plugin\Bangumiplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Bangumiplugin.bat
echo 正在更新Biliplugin……
curl -# -k -L -R --retry 5 --retry-delay 10 -o %batpath%\Plugin\Biliplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Biliplugin.bat
echo 正在更新Danmutools……
curl -# -k -L -R --retry 5 --retry-delay 10 -o %batpath%\Plugin\Danmutools.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/danmutools.bat
echo 正在更新主程序……
curl -# -k -L -R --retry 5 --retry-delay 10 -o %batpath%\DanmuGeniusPro.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/DanmuGeniusPro.bat
echo 更新成功！请继续使用！ && ping /n 5 127.0.0.1 >nul && start %batpath%\DanmuGeniusPro.bat && exit
) else (echo 你正在使用最新版本！无需更新！&& ping /n 5 127.0.0.1 >nul)
goto :eof