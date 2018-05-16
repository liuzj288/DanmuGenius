@echo off
cd %batpath%\Plugin\danmu-tools\
set /p quantity<=quantity.temp
java -jar %batpath%\Plugin\danmu-tools\downloader.jar -u %target%
set /a quantity=!quantity!+1
echo %quantity% >quantity.temp
cd %batpath%\Plugin\danmu-tools\DanMu\ && ren "*.xml" "*." && ren "*." "*_%web%.xml"
if exist "%batpath%\Plugin\danmu-tools\DanMu\*.xml" move "%batpath%\Plugin\danmu-tools\DanMu\*.xml" "%batpath%\Download\%moviename%（%year%）\" 
