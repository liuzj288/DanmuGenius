@echo off
set version=3.5.0
title=DanmuGeniusPro(稳定版) %version%
mode con cols=90 lines=30
set batpath=%~dp0%
echo %version%>"%batpath%\AppData\version.ini"
call :environmentcheck

:RE0
cls
echo 模式:%pattern%
cd %batpath%\Temp\
echo 操作：A-自动模式;S-分享模式;T_添加标签;C_清空标签
echo 说明：F_在线查询;Q_重新开始;U_检查更新;H_查看帮助
echo ================================================================================
if "%moviename%" NEQ "" if exist "%dpath%\%moviename%(%year%)\*.xml" echo 提示：%moviename%%target_tag%(%year%)下载完毕！用时 %chronography% 秒！
if "%target_tag%" NEQ "" echo 标签：%target_tag%
set /p moviename=请输入影片名：
if "%moviename%" NEQ "%moviename: =%" echo 影片名请不要输入空格！&& ping -n 3 127.0.0.1 >nul && goto RE0
echo %moviename%| findstr /r "[\/]" && echo 影片名请不要输入特殊字符！&&set moviename=&& ping /n 3 127.0.0.1 >nul && goto RE0
call :option %moviename% RE0
call :doubansearch %moviename%

:RE1
set /p year=请输入年份(当前默认为:%year%)：
call :option %year% RE1
for /f "delims=0123456789" %%y in ("%year%") do if not "%%y"=="" echo 输入错误：不是纯数字！&& ping /n 3 127.0.0.1 > nul && goto RE1
if %year% LEQ 1000 echo 输入错误：请输入正确年份！&& ping /n 3 127.0.0.1 > nul && goto RE1
if %year% GEQ 3000 echo 输入错误：请输入正确年份！&& ping /n 3 127.0.0.1 > nul && goto RE1
call :jijisearch %moviename%%year%

:RE2
echo 模式:%pattern%
cls
echo 准备下载：%target_tag% %moviename%(%year%)
echo ================================================================================
echo 操作：A-自动模式;S-分享模式;T_添加标签;C_清空标签
echo 操作：E_编辑列表;C_清空列表;F_查找弹幕;Q_返回上层
echo ================================================================================
echo 任务列表：
if not exist target_URL.temp echo. 2>target_URL.temp
cat target_URL.temp |sed "s/av/\nav/g;s/[[:blank:]]//g;" |sort /r |uniq > target_URL.txt && cat -b target_URL.txt |xargs -n 2
echo.
echo ================================================================================
set target_URL=G
set /p target_URL=请粘贴URL、AV号或CID号(按回车开始下载)：
call :option %target_URL% RE2
set target_URL=%target_URL:http://www.bilibili.com/video/=%&& set target_URL=%target_URL:https://www.bilibili.com/video/=%&& set target_URL=%target_URL:http://www.jijidown.com/video/=%&& set target_URL=%target_URL:https://www.biliplus.com/all/video/=%
if "%target_URL: =%" NEQ "%target_URL%" echo 警告：请不要输入空格！ && ping /n 3 127.0.0.1 >nul && goto RE2
findstr "%target_URL%" target_URL.temp >nul && echo 警告：重复任务！ && ping /n 3 127.0.0.1 >nul && goto RE2
findstr "%target_URL%" "%batpath%\AppData\movie_backup.md" >nul && echo 警告：已下载！ && ping /n 2 127.0.0.1 >nul && goto RE2 || echo %target_URL% |sed "s/ //g">>target_URL.temp && goto RE2

:main
echo %time%| sed "s/://g;s/\.//g;s/ /0/g" > "%batpath%\Temp\time.temp" && set /P timestart=<"%batpath%\Temp\time.temp"
set /a secondstart=%timestart:~4,2%&& set /a minutestart=%timestart:~2,2%&& set /a hourstart=%timestart:~0,2%

if not exist "%batpath%\Download\%moviename%%target_tag%[%year%]" md "%batpath%\Download\%moviename%%target_tag%[%year%]"
setlocal enabledelayedexpansion
for /f %%z in (target_URL.txt) do (
set target=%%z
echo !target! | findstr "https://www.bilibili.com/bangumi/" >nul && call "%batpath%\Plugin\Bangumiplugin.bat"
echo !target! | findstr /r "[aA][vV]" >nul && call "%batpath%\Plugin\Biliplugin.bat"
echo !target! | findstr "tucao" >nul && call "%batpath%\Plugin\Tucaoplugin.bat"
echo !target! | findstr "iqiyi" >nul && set web=iqiyi&& cls && call "%batpath%\Plugin\danmutools.bat"
echo !target! | findstr "youku" >nul && set web=youku&& cls && call "%batpath%\Plugin\danmutools.bat"
echo !target! | findstr "diyidan" >nul && set web=diyidan&& cls && call "%batpath%\Plugin\danmutools.bat"
echo !target! | findstr "qq" >nul && set web=tencent&& cls && call "%batpath%\Plugin\danmutools.bat"
echo !target! | findstr "acfun" >nul && set web=acfun&& cls && call "%batpath%\Plugin\danmutools.bat"
)
setlocal disabledelayedexpansion
if not exist "%batpath%\Download\%moviename%(%year%)\*.xml" rd "%batpath%\Download\%moviename%(%year%)"
if "%pattern%"=="share" call :share

:end
gplay.exe %batpath%\AppData\download-complete.wav > nul
if exist %batpath%\Temp\*.* del /q %batpath%\Temp\*.*
echo %time%|sed "s/://g;s/\.//g;s/ /0/g">%batpath%\Temp\time.temp && set /P timeend=<%batpath%\Temp\time.temp
set /a secondend=%timeend:~4,2%&& set /a minuteend=%timeend:~2,2%&& set /a hourend=%timeend:~0,2%
set /a chronography=(%hourend%-%hourstart%)*3600+(%minuteend%-%minutestart%)*60+(%secondend%-%secondstart%)
cd %batpath%
ping /n 2 127.0.0.1 >nul
goto RE0











::================================================================================
::函数部分开始
::================================================================================
:environmentcheck
:: 环境配置
if "%batpath%" NEQ "%batpath: =%" echo 提示：请解压到不包含空格路径！ && ping /n 3 127.0.0.1>nul && exit
rem if not exist "%batpath%\Bin\*.exe" echo 请下载Bin环境包!按回车确认下载！ && ping /n 3 127.0.0.1>nul && start https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Bin.zip && echo 请解压到:"%batpath%Bin\"! || set path=%batpath%\Bin;%path%
if not exist "%batpath%\AppData" md "%batpath%\AppData"
if not exist "%batpath%\Temp" md "%batpath%\Temp"
if not exist "%batpath%AppData\download-complete.wav" curl -s -k -L -o "%batpath%AppData\download-complete.wav" https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/download-complete.wav
if not exist "%batpath%AppData\setting.ini" curl -s -k -L -o "%batpath%AppData\setting.ini" https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/setting.ini
:: 读取默认设置
if exist "%batpath%\AppData\setting.ini" for /f "delims=" %%m in ('egrep "pattern" "%batpath%\AppData\setting.ini"^|sed "s/pattern://g;s/ //g"') do set pattern=%%m
if exist "%batpath%\AppData\setting.ini" for /f "delims=" %%u in ('egrep "autoupdate" "%batpath%\AppData\setting.ini"^|sed "s/autoupdate://g;s/ //g"') do set autoupdate=%%u
if exist "%batpath%\AppData\setting.ini" for /f "delims=" %%d in ('egrep "dpath" "%batpath%\AppData\setting.ini"^|sed "s/dpath://g;s/ //g"') do set dpath=%%d
if not exist "%dpath%" md "%dpath%"
:: 下载插件
rem if not exist "%batpath%\Plugin" md "%batpath%\Plugin"
rem if not exist "%batpath%\Plugin\Bangumiplugin.bat" curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Bangumiplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Bangumiplugin.bat
rem if not exist "%batpath%\Plugin\Biliplugin.bat" curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Biliplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Biliplugin.bat
rem if not exist "%batpath%\Plugin\Tucaoplugin.bat" curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Tucaoplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Tucaoplugin.bat
rem if not exist "%batpath%\Plugin\Danmutools.bat" curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Danmutools.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Danmutools.bat
rem if not exist "%batpath%\Plugin\DanmuGeniusPro.bat" curl -# -k -L -R --retry 5 --retry-delay 40 -o %batpath%\DanmuGeniusPro.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/DanmuGeniusPro.bat
goto :eof

:option
:: 参数1——变量;参数2——跳转点
if /i "%1"=="A" set pattern=auto&& goto %2
if /i "%1"=="S" set pattern=share&& goto %2
if /i "%1"=="T" set /p target_tag=请输入备注：&& echo target_tag:%target_tag%>>"%batpath%\Temp\task.temp" && goto %2
if /i "%2"=="RE0" if /i "%1"=="C" set target_tag=&& goto %2
if /i "%2"=="RE2" if /i "%1"=="C" echo. 2>target_URL.temp && echo. 2>target_URL.txt goto %2
if /i "%1"=="Q" del "%batpath%\Temp\task.temp" && goto RE0
if /i "%1"=="U" call :update && goto %2
if /i "%1"=="H" start https://github.com/liuzj288/DanmuGenius/blob/master/README.md && goto %2
if /i "%2"=="RE1" if /i "%1"=="F" start https://movie.douban.com/subject_search?search_text=%moviename% && goto %2
if /i "%2"=="RE2" if /i "%1"=="F" start https://movie.douban.com/subject_search?search_text=%moviename% && start https://www.biliplus.com/api/do.php?act=search^&word=%moviename%^&p=1^&o=default^&n=30^&source=biliplus && start https://www.biliplus.com/api/do.php?act=search^&word=%moviename%^&p=1^&o=default^&n=30^&source=bilibili && start https://www.bilibili.com/sp/%moviename% && start https://www.baidu.com/s?wd=%moviename%%target_tag%弹幕 && start http://so.iqiyi.com/so/q_%moviename% && start http://www.soku.com/search_video/q_%moviename% && start http://v.qq.com/x/search/?q=%moviename% && goto %2
if /i "%2"=="RE2" if /i "%1"=="E" start /wait notepad.exe target_URL.temp && cat target_URL.temp |sort |uniq>target_URL.txt && goto %2
if /i "%2"=="RE2" if /i "%1"=="G" goto main
goto :eof

:doubansearch
:: 参数1——影片名
URLEncode -e %1 -o URLEncode.temp && set /P keywords=<URLEncode.temp
curl -s -k -L -R --retry 5 --retry-delay 30 -o target_utf8.temp https://api.douban.com/v2/movie/search?q=%keywords%
iconv -c -f UTF-8 -t GBK target_utf8.temp > target_gbk.temp
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "/:/d;/,/d" target_gbk.temp && del *.
echo 请选择公映时间：
egrep -A1 "year" target_gbk.temp | egrep "[[:digit:]]" | head -1 > target_year.temp && set /P year=<target_year.temp
egrep -A1 "year" target_gbk.temp | egrep "[[:digit:]]" | xargs -n 10
goto :eof

:jijisearch
URLEncode -e %1 -o keywords.temp
sed -i "s#%%#%%7C#g;s#[a-z]#\u&#g" keywords.temp && set /P keywords=<keywords.temp
curl -s -R --retry 5 --retry-delay 10 -o target_utf8.temp http://www.jijidown.com/Search/%keywords%
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "/剪辑/d;/片段/d;/预告/d;/預告/d;/混剪/d;/自制/d;/自剪/d;/片段/d;/插曲/d;/配乐/d;/幕后/d;/谷阿莫/d" target_gbk.temp && del *.
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "s#'/video/#\n#g;s#'#\n#g" target_gbk.temp && del *.
egrep "^av" target_gbk.temp > target_URL.temp
egrep "/J/default/"  target_gbk.temp | sed "s#^#http://www.jijidown.com#g" |sort |uniq > target_pages.temp
for /f %%p in (target_pages.temp) do (
curl -s -R --retry 5 --retry-delay 30 -o target_utf8.temp %%p
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "/剪辑/d;/片段/d;/预告/d;/預告/d;/混剪/d;/自制/d;/自剪/d;/片段/d;/插曲/d;/配乐/d;/幕后/d;/谷阿莫/d" target_gbk.temp && del *.
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "s#'/video/#\n#g;s#'#\n#g" target_gbk.temp && del *.
egrep "^av" target_gbk.temp | sed "s/ //g" >> target_av.temp
)
if exist target_av.temp for /f %%z in (target_av.temp) do (
findstr "%%z" "%batpath%\AppData\movie_backup.md" >nul || echo %%z >> target_URL.temp
)
goto :eof

:update
cls
echo 正在检查更新……
curl -k -L -s -o "%batpath%\Temp\versionnew.temp" https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/version.txt && set /P versionnew=<"%batpath%\Temp\versionnew.temp" && del "%batpath%\Temp\versionnew.temp"
if "%version%" NEQ "%versionnew%" (
echo 当前版本%version% 最新版本 %versionnew% 请及时更新！ && ping /n 3 127.0.0.1 >nul
echo 正在更新Bangumiplugin……
curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Bangumiplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Bangumiplugin.bat
echo 正在更新Biliplugin……
curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Biliplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Biliplugin.bat
echo 正在更新Tucaoplugin……
curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Tucaoplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Tucaoplugin.bat
echo 正在更新Danmutools……
curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Danmutools.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Danmutools.bat
echo 正在更新setting……
curl -# -k -L -R --retry 5 --retry-delay 30 -o "%batpath%AppData\setting.ini" https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/setting.ini
echo 正在更新主程序……
curl -# -k -L -R --retry 5 --retry-delay 40 -o %batpath%\DanmuGeniusPro.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/DanmuGeniusPro.bat
curl -# -k -L -R --retry 5 --retry-delay 40 -o %batpath%\install.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/install.bat
echo 更新成功！请继续使用！ && ping /n 5 127.0.0.1 >nul && start %batpath%\DanmuGeniusPro.bat && exit
) else (echo 你正在使用最新版本！无需更新！&& ping /n 5 127.0.0.1 >nul)
goto :eof

:share
@echo off
set dateadd=%date:/=%
set dateadd=[%dateadd:~0,8%]
echo 本弹幕由[Danmugenius%version%](https://github.com/liuzj288/DanmuGenius)下载并分享!> "%batpath%\Temp\info.md"
set category=
if exist %batpath%\Download\%moviename%(%year%)\av*.xml set category=%category%B站
if exist %batpath%\Download\%moviename%(%year%)\*_youku.xml set category=%category%优酷
if exist %batpath%\Download\%moviename%(%year%)\*_iqiyi.xml set category=%category%爱奇艺
if exist %batpath%\Download\%moviename%(%year%)\*_tencent.xml set category=%category%腾讯
if exist %batpath%\Download\%moviename%(%year%)\*_diyidan.xml set category=%category%第一弹
if exist %batpath%\Download\%moviename%(%year%)\*_tucao.xml set category=%category%tucao
if exist %batpath%\Download\%moviename%(%year%)\*_acfun.xml set category=%category%acfun
if "%target_tag%" NEQ "" set target_tag=[%target_tag%]
if exist %batpath%\Download\%moviename%(%year%)\*.xml cat %batpath%\Temp\target_URL.txt>> "%batpath%\Download\%moviename%(%year%)\原始资源.txt"
if exist %batpath%\Download\%moviename%(%year%)\*.xml winrar a -y -ep1 -ibck -o+ "%batpath%\Share\%moviename%%target_tag%[%year%]%dateadd%.7z" "%batpath%\Download\%moviename%%target_tag%(%year%)" "%batpath%\Temp\info.md" && explorer.exe /select,%batpath%Share\%moviename%%target_tag%[%year%]%dateadd%.7z
goto :eof