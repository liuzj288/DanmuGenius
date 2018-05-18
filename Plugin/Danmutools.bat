@echo off
set /p quantity=<%batpath%\Temp\quantity.temp
if "%target%"=="" echo 请使用启动器启动 && ping /5 127.0.0.1 >nul && exit
title=danmu-toolplugin1.0.2
cd %batpath%\Plugin\danmu-tools\
java -jar %batpath%\Plugin\danmu-tools\downloader.jar -u %target%

cd %batpath%\Plugin\danmu-tools\DanMu\ 
if exist "*.xml" ren "*.xml" "*." && ren "*." "*_%web%.xml"
ls -l |grep "^-"|wc -l>%batpath%\Temp\quantitynew.temp
set /p quantitynew=<%batpath%\Temp\quantitynew.temp
if exist "%batpath%\Plugin\danmu-tools\DanMu\*.xml" move "%batpath%\Plugin\danmu-tools\DanMu\*.xml" "%batpath%\Download\%moviename%[%year%]\" >nul

set /a quantity=%quantity%+%quantitynew%
echo %quantity%> %batpath%\Temp\quantity.temp