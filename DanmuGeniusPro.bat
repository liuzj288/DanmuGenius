@echo off
mode con cols=80 lines=25 && set version=3.1.6
title=DanmuGeniusPro %version%
set batpath=%~dp0%
if "%batpath%" NEQ "%batpath: =%" echo ���ѹ���������ո�·���� && pause && exit
set mode=auto
if not exist %batpath%\Bin\*.exe echo ������Bin������!���س�ȷ�����أ� && pause && curl -# -k -L -o %batpath%\Bin.zip https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Bin.zip
if exist %batpath%\Bin set path=%batpath%\Bin;%path%
if exist "%batpath%\AppData\music.list" for /f %%i in (%batpath%\AppData\music.list) do (start /min gplay.exe %%i)

rem �������򻷾�
if not exist %batpath%\AppData md %batpath%\AppData && echo %version% > %batpath%\AppData\version.txt  && curl -o %batpath%\AppData\download-complete.wav https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/AppData/download-complete.wav
if not exist %batpath%\Plugin md %batpath%\Plugin
if not exist %batpath%\Temp md %batpath%\Temp
if not exist %batpath%\Download md %batpath%\Download
if not exist %batpath%\Plugin\danmu-tools echo ���棺δ��⵽danmu-tools��ֻ�ܽ���Bվ��Ļ�� && pause

:RE0
cls
echo mode:%mode%
cd %batpath%/Temp/
echo ģʽ��S-����ģʽ;A-�Զ�ģʽ(Ĭ��);M-�ֶ�ģʽ
echo ������E_��ӱ�ǩ;C_��ձ�ǩ;U_������;H_�鿴����
echo =======================================
if "%moviename%" NEQ "" if exist "%batpath%\Download\%moviename%��%year%��/*.xml" echo ��ʾ��%moviename%��%year%����������ϣ�����ʱ %chronography% �룡
if "%target_keyword%" NEQ "" echo ��ע��%target_keyword%
set /p moviename=������ӰƬ��(�����ļ���)��
if "%moviename%"=="" goto RE0
if /i "%moviename%"=="S" set mode=smart&& goto RE0
if /i "%moviename%"=="A" set mode=auto&& goto RE0
if /i "%moviename%"=="M" set mode=manual&& goto RE0
if /i "%moviename%"=="E" set /p target_keyword=�����뱸ע��&& goto RE0
if /i "%moviename%"=="C" set target_keyword=&& goto RE0
if /i "%moviename%"=="U" call :update && goto RE0
if /i "%moviename%"=="H" start https://github.com/liuzj288/DanmuGenius/blob/master/README.md && goto RE0

URLEncode -e %moviename% -o keywords.temp && set /P keywords=<keywords.temp
curl -s -k -L -R --retry 5 --retry-delay 10 -o target_utf8.temp https://api.douban.com/v2/movie/search?q=%keywords%
iconv -c -f UTF-8 -t GBK target_utf8.temp > target_gbk.temp
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "/:/d;/,/d" target_gbk.temp && del *.
echo ��ѡ��ӳʱ�䣺
egrep -A1 "year" target_gbk.temp | egrep "[[:digit:]]" | head -1 > target_year.temp && set /P year=<target_year.temp 
egrep -A1 "year" target_gbk.temp | egrep "[[:digit:]]" | xargs -n 10
:RE1
if "%mode%" NEQ "smart" set /p year=��������ݣ���ǰĬ��Ϊ:%year%����|| goto RE2


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
curl -s -R --retry 5 --retry-delay 10 -o target_utf8.temp %%p
iconv -c -f UTF-8 -t GBK  target_utf8.temp > target_gbk.temp
sed -i "/����/d;/Ƭ��/d;/Ԥ��/d;/�A��/d;/���/d;/����/d;/�Լ�/d;/Ƭ��/d;/����/d;/����/d;/Ļ��/d;/�Ȱ�Ī/d" target_gbk.temp && del *.
sed -i "s#\"#\n#g" target_gbk.temp
sed -i "s#'/video/#\n#g;s#'#\n#g" target_gbk.temp && del *.
if "%mode%" NEQ "manual" egrep "^av" target_gbk.temp >> target_URL.temp || start https://www.bilibili.com/sp/%keywords% && start https://www.biliplus.com/api/do.php?act=search^&word=%keywords%^&o=danmaku^&n=30^&p=1^&source=biliplus
)
for /f %%z in (target_URL.temp) do (
findstr "%%z" "%batpath%\AppData\movie_backup.md" >nul || echo %%z >> target_URL.txt
)

:RE2
cls
echo ׼�����أ�%target_keyword% %moviename%(%year%)
echo =======================================
echo �����б�
if exist target_URL.txt cat -b target_URL.txt
echo.
echo =======================================
echo ������E_�༭�б�;C_����б�F_���ҵ�Ļ
echo ˵����S_��ʼ����;Q_�����ϲ�
echo =======================================
set /p target_URL=��ճ��URL��AV�Ż�CID�ţ�
set target_URL=%target_URL:http://www.bilibili.com/video/=% && set target_URL=%target_URL:https://www.bilibili.com/video/=% && set target_URL=%target_URL:http://www.jijidown.com/video/=% && set target_URL=%target_URL:https://www.biliplus.com/all/video/=%
if /i "%target_URL%"=="S" goto main
if /i %target_URL%==E start /wait target_URL.txt && goto RE2
if /i %target_URL%==C echo. 2>target_URL.txt && goto RE2
if /i %target_URL%==F start https://www.biliplus.com/api/do.php?act=search^&word=%moviename% && start https://www.bilibili.com/sp/%moviename% && goto RE2
if /i %target_URL%==Q goto RE0
findstr "%target_URL%" target_URL.txt >nul && echo ���棺�ظ����� && ping -n 2 127.0.0.1 >nul && goto RE2
findstr "%target_URL%" %batpath%\AppData\movie_backup.md >nul && echo ���棺�����أ� && ping -n 2 127.0.0.1 >nul && goto RE2 || echo %target_URL%>> target_URL.txt && goto RE2


:main
set timestart=0%time%
set /a secondstart=%timestart:~-5,2% && set /a minutestart=%timestart:~-8,2% && set /a hourstart=%timestart:~-11,2%
if not exist %batpath%\Download\%moviename%��%year%�� md %batpath%\Download\%moviename%��%year%��
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
if not exist %batpath%\Download\%moviename%��%year%��\*.xml rd %batpath%\Download\%moviename%��%year%��
if exist %batpath%\Temp\*.* del /q %batpath%\Temp\*.*

:end
cd %batpath%
gplay.exe %batpath%\AppData\download-complete.wav > nul
set timeend=0%time%
set /a secondend=%timeend:~-5,2% && set /a minuteend=%timeend:~-8,2% && set /a hourend=%timeend:~-11,2%
set /a chronography=(%hourend%-%hourstart%)*60*60+(%minuteend%-%minutestart%)*60+(%secondend%-%secondstart%)
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
curl -# -k -L -R --retry 5 --retry-delay 10 -o %batpath%\Plugin\Bangumiplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Bangumiplugin.bat
echo ���ڸ���Biliplugin����
curl -# -k -L -R --retry 5 --retry-delay 10 -o %batpath%\Plugin\Biliplugin.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/Biliplugin.bat
echo ���ڸ���Danmutools����
curl -# -k -L -R --retry 5 --retry-delay 10 -o %batpath%\Plugin\Danmutools.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/Plugin/danmutools.bat
echo ���ڸ��������򡭡�
curl -# -k -L -R --retry 5 --retry-delay 10 -o %batpath%\DanmuGeniusPro.bat https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/DanmuGeniusPro.bat
echo ���³ɹ��������ʹ�ã� && ping /n 5 127.0.0.1 >nul && start %batpath%\DanmuGeniusPro.bat && exit
) else (echo ������ʹ�����°汾��������£�&& ping /n 5 127.0.0.1 >nul)
goto :eof