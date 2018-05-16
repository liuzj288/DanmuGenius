@echo off
if "%target%"=="" echo 请使用启动器启动 && ping /5 127.0.0.1 >nul && exit
title=danmu-toolplugin1.0.2
cd %batpath%\Plugin\danmu-tools\
set /p quantity<=%batpath%\Temp\quantity.temp
java -jar %batpath%\Plugin\danmu-tools\downloader.jar -u %target%
set /a quantity=!quantity!+1
echo %quantity% >%batpath%\Temp\quantity.temp
cd %batpath%\Plugin\danmu-tools\DanMu\ && ren "*.xml" "*." && ren "*." "*_%web%.xml"
if exist "%batpath%\Plugin\danmu-tools\DanMu\*.xml" move "%batpath%\Plugin\danmu-tools\DanMu\*.xml" "%batpath%\Download\%moviename%（%year%）\" 
