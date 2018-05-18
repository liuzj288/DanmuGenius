@echo off
set batpath=%~dp0%
if not exist DanmuGeniusPro.bat echo 警告：请解压至DanmuGeniusPro.bat所在文件夹！！！7 && pause
if not exist %batpath%Bin\ echo 请下载环境包！！！ && pause

setx PATH "%path%;%batpath%Bin\"
echo 安装完毕！欢迎使用！
pause