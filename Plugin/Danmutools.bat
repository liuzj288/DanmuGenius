@echo off
cd %batpath%\Plugin\danmu-tools\
java -jar %batpath%\Plugin\danmu-tools\downloader.jar -u %target%

cd %batpath%\Plugin\danmu-tools\DanMu\ && ren "*.xml" "*." && ren "*." "*_%web%.xml"
if exist "%batpath%\Plugin\danmu-tools\DanMu\*.xml" move "%batpath%\Plugin\danmu-tools\DanMu\*.xml" "%batpath%\Download\%moviename%£¨%year%£©\" 