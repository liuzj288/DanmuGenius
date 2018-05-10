@echo off
set version=2.0.1
title=弹幕精灵DanmuGeniusPro %version%
mode con cols=80 lines=25
set batpath=%~dp0%&& set mode=smart
echo 正在初始化……
if not exist %batpath%\AppData md %batpath%\AppData && curl -k -L -o %batpath%\AppData\movie_backup.md  https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/movie_backup.md && curl -k -L -o "%batpath%\AppData\download-complete.wav" https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/download-complete.wav
if not exist %batpath%\Download md %batpath%\Download
if not exist %batpath%\Plugin md %batpath%\Plugin
if not exist %batpath%\Temp md %batpath%\Temp

echo 正在检查更新……
curl -k -L -s -o %batpath%\AppData\versionnew.temp https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/version.txt && set /P versionnew=<%batpath%\AppData\versionnew.temp
if "%version%" NEQ "%versionnew%" (echo 当前版本%version% 最新版本 %versionnew% 请及时更新！) else (echo 你正在使用最新版本！)

echo %batpath%%mode%

pause