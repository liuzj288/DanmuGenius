@echo off
set version=2.0.1
title=��Ļ����DanmuGeniusPro %version%
mode con cols=80 lines=25
set batpath=%~dp0%&& set mode=smart
echo ���ڳ�ʼ������
if not exist %batpath%\AppData md %batpath%\AppData && curl -k -L -o %batpath%\AppData\movie_backup.md  https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/movie_backup.md && curl -k -L -o "%batpath%\AppData\download-complete.wav" https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/download-complete.wav
if not exist %batpath%\Download md %batpath%\Download
if not exist %batpath%\Plugin md %batpath%\Plugin
if not exist %batpath%\Temp md %batpath%\Temp

echo ���ڼ����¡���
curl -k -L -s -o %batpath%\AppData\versionnew.temp https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/version.txt && set /P versionnew=<%batpath%\AppData\versionnew.temp
if "%version%" NEQ "%versionnew%" (echo ��ǰ�汾%version% ���°汾 %versionnew% �뼰ʱ���£�) else (echo ������ʹ�����°汾��)

echo %batpath%%mode%

pause