@echo off
mode con cols=80 lines=26 && set version=3.2.5
set batpath=%~dp0%
if "%batpath%" NEQ "%batpath: =%" echo ���ѹ���������ո�·���� && pause && exit
set mode=share
if not exist %batpath%\Bin\*.exe echo ������Bin������!���س�ȷ�����أ� && pause && curl -# -k -L -o %batpath%\Bin.zip https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Bin.zip
if exist %batpath%\Bin set path=%batpath%\Bin;%path%
if exist "%batpath%\AppData\music.list" for /f %%i in (%batpath%\AppData\music.list) do (start /min gplay.exe %%i)

rem �������򻷾�
if not exist %batpath%\AppData md %batpath%\AppData && echo %version% > %batpath%\AppData\version.txt  && curl -o %batpath%\AppData\download-complete.wav https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/download-complete.wav
if not exist %batpath%\Plugin md %batpath%\Plugin
if not exist %batpath%\Temp md %batpath%\Temp
if not exist %batpath%\Download md %batpath%\Download
if not exist %batpath%\Plugin\danmu-tools\downloader.jar echo ���棺δ��⵽danmu-tools��ֻ�ܽ���Bվ��Ļ�������QQȺ(495877205)��ȡ����danmu-tools! && pause

:RE0
title=DanmuGeniusPro %version%
cls
echo mode:%mode%
cd %batpath%/Temp/
echo ģʽ��S-����ģʽ;A-�Զ�ģʽ(Ĭ��);M-����ģʽ
echo ˵����R_���¿�ʼ;U_������;H_�鿴����
echo ������E_��ӱ�ǩ;C_��ձ�ǩ;
echo =======================================
if "%moviename%" NEQ "" if exist "%batpath%\Download\%moviename%��%year%��/*.xml" echo ��ʾ��%moviename%��%year%��������ϣ� ��ʱ %chronography% �룡 ���ص�Ļ %quantity%����
if "%target_keyword%" NEQ "" echo ��ע��%target_keyword%
if not exist %batpath%\Temp\moviename.temp set /p moviename=������ӰƬ��(�����ļ���)��
if exist %batpath%\Temp\moviename.temp set /P moviename=<%batpath%\Temp\moviename.temp
if exist %batpath%\Temp\moviename.temp echo ������ӰƬ��(�����ļ���)��%moviename%
if "%moviename%"=="" goto RE0
if "%moviename: =%" NEQ "%moviename%" echo ӰƬ���벻Ҫ����ո� && ping /n 3 127.0.0.1 >nul && goto RE0
if "%moviename:\=%" NEQ "%moviename%" echo ӰƬ���벻Ҫ���������ַ��� && ping /n 3 127.0.0.1 >nul && goto RE0
if "%moviename:/=%" NEQ "%moviename%" echo ӰƬ���벻Ҫ���������ַ��� && ping /n 3 127.0.0.1 >nul && goto RE0
if /i "%moviename%"=="S" set mode=smart&& goto RE0
if /i "%moviename%"=="A" set mode=auto&& goto RE0
if /i "%moviename%"=="M" set mode=share&& goto RE0
if /i "%moviename%"=="E" set /p target_keyword=�����뱸ע��&& goto RE0
if /i "%moviename%"=="C" set target_keyword=&& goto RE0
if /i "%moviename%"=="U" call :update && goto RE0
if /i "%moviename%"=="H" start https://github.com/liuzj288/DanmuGenius/blob/master/README.md && goto RE0


echo %moviename%> "%batpath%\Temp\moviename.temp"
URLEncode -e %moviename% -o keywords.temp && set /P keywords=<keywords.temp
curl -s -k -L -R --retry 5 --retry-delay 30 -o target_utf8.temp https://api.douban.com/v2/movie/search?q=%keywords%
iconv -c -f UTF-8 -t GBK target_utf8.temp > target_gbk.temp
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "/:/d;/,/d" target_gbk.temp && del *.

:RE1
echo ��ѡ��ӳʱ�䣺
egrep -A1 "year" target_gbk.temp | egrep "[[:digit:]]" | head -1 > target_year.temp && set /P year=<target_year.temp 
egrep -A1 "year" target_gbk.temp | egrep "[[:digit:]]" | xargs -n 10
if "%mode%" NEQ "smart" set /p year=��������ݣ���ǰĬ��Ϊ:%year%����|| goto RE2
if /i "%year%"=="R" del /q %batpath%\Temp\*.*  && goto RE0
if /i "%moviename%"=="S" set mode=smart&& goto RE0
if /i "%moviename%"=="A" set mode=auto&& goto RE0
if /i "%moviename%"=="M" set mode=share&& goto RE0
if /i "%moviename%"=="E" set /p target_keyword=�����뱸ע��&& goto RE0
if /i "%moviename%"=="C" set target_keyword=&& goto RE0
if /i "%moviename%"=="U" call :update && goto RE0
if /i "%moviename%"=="H" start https://github.com/liuzj288/DanmuGenius/blob/master/README.md && goto RE0
for /f "delims=0123456789" %%y in ("%year%") do if not "%%y"=="" echo ������󣺲��Ǵ����֣�&& ping /n 3 127.0.0.1 > nul && goto RE1
if %year% LEQ 1000 echo ���������������ȷ��ݣ�&& ping /n 3 127.0.0.1 > nul && goto RE1
if %year% GEQ 3000 echo ���������������ȷ��ݣ�&& ping /n 3 127.0.0.1 > nul && goto RE1

URLEncode -e %moviename%%year% -o keywords.temp 
sed -i "s#%%#%%7C#g;s#[a-z]#\u&#g" keywords.temp && set /P keywords=<keywords.temp
curl -s -R --retry 5 --retry-delay 10 -o target_utf8.temp http://www.jijidown.com/Search/%keywords%
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "/����/d;/Ƭ��/d;/Ԥ��/d;/�A��/d;/���/d;/����/d;/�Լ�/d;/Ƭ��/d;/����/d;/����/d;/Ļ��/d;/�Ȱ�Ī/d" target_gbk.temp && del *.
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "s#'/video/#\n#g;s#'#\n#g" target_gbk.temp && del *.
egrep "^av" target_gbk.temp > target_URL.temp
egrep "/J/default/"  target_gbk.temp | sed "s#^#http://www.jijidown.com#g" |sort |uniq > target_pages.temp
for /f %%p in (target_pages.temp) do (
curl -s -R --retry 5 --retry-delay 30 -o target_utf8.temp %%p
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "/����/d;/Ƭ��/d;/Ԥ��/d;/�A��/d;/���/d;/����/d;/�Լ�/d;/Ƭ��/d;/����/d;/����/d;/Ļ��/d;/�Ȱ�Ī/d" target_gbk.temp && del *.
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "s#'/video/#\n#g;s#'#\n#g" target_gbk.temp && del *.
egrep "^av" target_gbk.temp >> target_URL.temp
)
for /f %%z in (target_URL.temp) do (
findstr "%%z" "%batpath%\AppData\movie_backup.md" >nul || echo %%z >> target_URL.txt
)

:RE2
cls
echo ׼�����أ�%target_keyword% %moviename%(%year%)
echo =======================================
echo �����б�
if not exist target_URL.txt echo. 2>target_URL.txt
if exist target_URL.txt cat -b target_URL.txt
echo.
echo =======================================
echo ������E_�༭�б�;C_����б�F_���ҵ�Ļ
echo ˵����S_��ʼ����;Q_�����ϲ�
echo =======================================
set /p target_URL=��ճ��URL��AV�Ż�CID�ţ�
set target_URL=%target_URL:http://www.bilibili.com/video/=%
set target_URL=%target_URL:https://www.bilibili.com/video/=%
set target_URL=%target_URL:http://www.jijidown.com/video/=%
set target_URL=%target_URL:https://www.biliplus.com/all/video/=%
if "%target_URL: =%" NEQ "%target_URL%" echo ��������벻Ҫ����ո� && ping /n 3 127.0.0.1 >nul && goto RE2
if /i "%target_URL%"=="S" goto main
if /i %target_URL%==E start /wait target_URL.txt && goto RE2
if /i %target_URL%==C echo. 2>target_URL.txt && goto RE2
if /i %target_URL%==F start https://www.biliplus.com/api/do.php?act=search^&word=%moviename%^&p=1^&o=default^&n=30 && start https://www.bilibili.com/sp/%moviename% && start http://so.iqiyi.com/so/q_%moviename% && start http://www.soku.com/search_video/q_%moviename% && start http://v.qq.com/x/search/?q=%moviename% && goto RE2
if /i %target_URL%==Q goto RE0
findstr "%target_URL%" target_URL.txt >nul && echo ���棺�ظ����� && ping -n 2 127.0.0.1 >nul && goto RE2
findstr "%target_URL%" %batpath%\AppData\movie_backup.md >nul && echo ���棺�����أ� && ping -n 2 127.0.0.1 >nul && goto RE2 || echo %target_URL%>>target_URL.txt && goto RE2


:main
echo 00%time%| sed "s/://g;s/\.//g">%batpath%\Temp\time.temp && set /P timestart=<%batpath%\Temp\time.temp
set /a secondstart=%timestart:~-4,2% && set /a minutestart=%timestart:~-6,2% && set /a hourstart=%timestart:~-8,2%
set quantity=0 && echo %quantity% 1>quantity.temp
if not exist %batpath%\Download\%moviename%��%year%�� md %batpath%\Download\%moviename%��%year%��
setlocal enabledelayedexpansion
for /f %%z in (target_URL.txt) do (
set target=%%z
echo !target! | findstr "https://www.bilibili.com/bangumi/" >nul && call %batpath%\Plugin\Bangumiplugin.bat
echo !target! | findstr /r "[aA][vV]" >nul && call %batpath%\Plugin\Biliplugin.bat
echo !target! | findstr /r "tucao" >nul && call %batpath%\Plugin\Tucaoplugin.bat
echo !target! | findstr "iqiyi" >nul && set web=iqiyi&& cls && call %batpath%\Plugin\danmutools.bat
echo !target! | findstr "youku" >nul && set web=youku&& cls && call %batpath%\Plugin\danmutools.bat
echo !target! | findstr "diyidan" >nul && set web=diyidan&& cls && call %batpath%\Plugin\danmutools.bat
echo !target! | findstr "qq" >nul && set web=tencent&& cls && call %batpath%\Plugin\danmutools.bat
echo !target! | findstr "acfun" >nul && set web=acfun&& cls && call %batpath%\Plugin\danmutools.bat
)
setlocal disabledelayedexpansion
if not exist %batpath%\Download\%moviename%��%year%��\*.xml rd %batpath%\Download\%moviename%��%year%��
if exist quantity.temp set/P quantity=<quantity.temp 
if "%mode%"=="share" call :share

:end
gplay.exe %batpath%\AppData\download-complete.wav > nul
echo 00%time%| sed "s/://g;s/\.//g">%batpath%\Temp\time.temp && set /P timeend=<%batpath%\Temp\time.temp
set /a secondend=%timeend:~-4,2% && set /a minuteend=%timeend:~-6,2% && set /a hourend=%timeend:~-8,2%
if exist %batpath%\Temp\*.* del /q %batpath%\Temp\*.*
set /a chronography=(%hourend%-%hourstart%)*60*60+(%minuteend%-%minutestart%)*60+(%secondend%-%secondstart%)
cd %batpath%
ping /n 2 127.0.0.1 >nul
pause
goto RE0



::=========================
::�������ֿ�ʼ
::=========================

:update
cls
echo ���ڼ����¡���
curl -k -L -s -o %batpath%\AppData\versionnew.temp https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/version.txt && set /P versionnew=<%batpath%\AppData\versionnew.temp && del %batpath%\AppData\versionnew.temp
if "%version%" NEQ "%versionnew%" (
echo ��ǰ�汾%version% ���°汾 %versionnew% �뼰ʱ���£� && ping /n 3 127.0.0.1 >nul
echo ���ڸ���Bangumiplugin����
curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Bangumiplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Bangumiplugin.bat
echo ���ڸ���Biliplugin����
curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Biliplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Biliplugin.bat
echo ���ڸ���Tucaoplugin����
curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Tucaoplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Tucaoplugin.bat
echo ���ڸ���Danmutools����
curl -# -k -L -R --retry 5 --retry-delay 30 -o %batpath%\Plugin\Danmutools.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Danmutools.bat
echo ���ڸ��������򡭡�
curl -# -k -L -R --retry 5 --retry-delay 40 -o %batpath%\DanmuGeniusPro.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/DanmuGeniusPro.bat
echo ���³ɹ��������ʹ�ã� && ping /n 5 127.0.0.1 >nul && start %batpath%\DanmuGeniusPro.bat && exit
) else (echo ������ʹ�����°汾��������£�&& ping /n 5 127.0.0.1 >nul)
goto :eof

:share
@echo off
set dateadd=%date:/=%
set dateadd=%dateadd:~0,8%
echo ����Ļ��[Danmugenius%version%](https://github.com/liuzj288/DanmuGenius)���ز�����!> "%batpath%\Temp\info.md"
if exist %batpath%\Download\%moviename%��%year%��\*_youku.xml set category=%category%�ſ�
if exist %batpath%\Download\%moviename%��%year%��\*_iqiyi.xml set category=%category%������
if exist %batpath%\Download\%moviename%��%year%��\*_tencent.xml set category=%category%��Ѷ
if exist %batpath%\Download\%moviename%��%year%��\*_diyidan.xml set category=%category%��һ��
if exist %batpath%\Download\%moviename%��%year%��\*_tucao.xml set category=%category%tucao
if exist %batpath%\Download\%moviename%��%year%��\*_acfun.xml set category=%category%acfun
if exist %batpath%\Download\%moviename%��%year%��\*.xml cat %batpath%\Temp\target_URL.txt>> "%batpath%\Download\%moviename%��%year%��\ԭʼ��Դ.txt"
if exist %batpath%\Download\%moviename%��%year%��\*.xml winrar a -y -ep1 -ibck "%batpath%\Share\%moviename%[%year%][%category%][%dateadd%].7z" "%batpath%\Download\%moviename%��%year%��" "%batpath%\Temp\info.md" && explorer.exe /select,%batpath%Share\%moviename%[%year%][%category%][%dateadd%].7z
goto :eof