@echo off
title=DanmuGenius��Ļ������V5.1(20220210)
rem ========================================================================================
rem ����������
rem ========================================================================================
rem ������
call :UPDATE

:RE
rem ========================================================================================
rem ��������
rem ========================================================================================
rem ���������ʱ�ļ�
if exist *.temp del *.temp && if exist *. del *.
echo ========================================================================================
echo ˵����������ʹ��linux���Windows��ʹ�ý��鰲װGnuWin32��������Ŀ��ַ��https://github.com/liuzj288/DanmuGenius��
echo ģʽһ ��Ƶ�������أ�
echo 1. https://www.biliplus.com/video/av18284/
echo 2. https://www.biliplus.com/all/video/av88028/
echo 3. https://www.bilibili.com/video/av2249128/
echo 4. https://www.bilibili.com/video/BV17s411D7yk/
echo ģʽ�� ����������أ�
echo 5. https://www.bilibili.com/bangumi/play/ss4996/
echo 6. https://www.bilibili.com/bangumi/play/ep324583/
echo 7. https://www.bilibili.com/bangumi/media/md616/
echo 8. https://www.biliplus.com/bangumi/i/6341
echo ========================================================================================
rem ����Ŀ����ַ���Զ���ת
set /p target_url=������Ŀ�꣺
echo %target_url%> target_url.temp
rem ͨ��ƥ��ؼ���ʵ�ַ����Զ���ת
findstr /I "ss" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "ss" | sed "s#ss##g" > target_ssid.temp && set /p target_ssid=<target_ssid.temp && call :SSID2CID
findstr /I "ep" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "ep" | sed "s#ep##g" > target_epid.temp && set /p target_epid=<target_epid.temp && call :EPID2SSID
findstr /I "md" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "md" | sed "s#md##g" > target_mid.temp && set /p target_mid=<target_mid.temp && call :MID2SSID
findstr /I "https://www.biliplus.com/bangumi/i/" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "^[0-9]" > target_ssid.temp && set /p target_ssid=<target_ssid.temp && call :SSID2CID2
rem ͨ��ƥ��ؼ���ʵ����Ƶ�Զ���ת
findstr /I "av" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "av" | sed "s#av##g" > target_aid.temp && set /p target_aid=<target_aid.temp&& call :BILIPLUS
findstr /I "BV" target_url.temp >nul && sed -r "s#[[:punct:]]#\n#g" target_url.temp | grep -i "BV" > target_BV.temp && set /p target_BV=<target_BV.temp && call :BV2AV
findstr /I "^[0-9]*$" target_url.temp >nul && call :CID2XML %target_url%





:END
cls
echo ��ʾ��%target_title%��%target_year%��%target_av% ��%target_cidnum%P��Ļ��������ϣ�
goto RE







rem ========================================================================================
rem XML���غ���������
rem ========================================================================================
rem ����Դ1��http://comment.bilibili.com/{cid}.xml
rem ����Դ2��https://api.bilibili.com/x/v1/dm/list.so?oid={cid}
:XMLGET
if not exist target_dinfo.temp goto RE
rem ���������ļ���
if not exist "downloads\%target_title%��%target_year%��" md "downloads\%target_title%��%target_year%��"
rem ��ȡ��Ļ����
grep -i -c "^[0-9]" target_dinfo.temp > target_cidnum.temp && set /p target_cidnum=<target_cidnum.temp
rem ��ʼ���ص�Ļ
setlocal enabledelayedexpansion
set count=10001
for /f "tokens=1,2,3,4 delims=@" %%a in (target_dinfo.temp) do (
echo ��������%target_title%��%target_year%�� !count:~-3!/%target_cidnum% av%%c cid%%b %%a %%d
curl -L --compressed -o "downloads\%target_title%��%target_year%��\%%a[av%%c][cid%%b].xml" https://comment.bilibili.com/%%b.xml
set /a count=!count!+1
)
setlocal disabledelayedexpansion
goto :eof


rem ========================================================================================
rem ���������������غ���������
rem ========================================================================================
:BILIPLUS
echo ����Դ��1_https://www.biliplus.com/video/av%1����ǰ��Ļ �Զ�ʶ��BV�ź�ss�� Ĭ�ϣ�
echo ����Դ��2_https://www.biliplus.com/all/video/av%1����ʷ��Ļ��
rem echo ����Դ��https://api.bilibili.com/x/player/pagelist?aid=%1&jsonp=jsonp
choice /c 12 /m "��ѡ������Դ" /d 1 /t 2
if %errorlevel%==1 call :BILIPLUSAV1 %target_aid%
if %errorlevel%==2 call :BILIPLUSAV2 %target_aid%
goto :eof

:BILIPLUSAV1
rem echo ����Դ��https://www.biliplus.com/video/av%1/
curl -s -L "https://www.biliplus.com/video/av%1/" | iconv.exe -c -f UTF-8 -t GBK > target_avinfo.temp
findstr /I "cid" target_avinfo.temp >nul || echo ��ǰ����Դδ�ҵ���Ļ���ݣ����Զ��л�����Դ2 && call :BILIPLUSAV2 %1
grep "cid" target_avinfo.temp | sed "s#v2_app_api#\nv2_app_api#g" | grep -v "v2_app_api" | sed "s#,#,\n#g" | sed "s#{#\n{\n#g" | sed "s#}#\n}\n#g" > target_info.temp
rem grep "cid" target_avinfo.temp | sed "s#v2_app_api#\nv2_app_api#g" | grep "v2_app_api" | sed "s#,#,\n#g" | sed "s#{#\n{\n#g" | sed "s#}#\n}\n#g" > target_info.temp
rem ��ȡ����������ӳ���
grep "title" target_info.temp | sed "s#:#\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/title/d" > target_title.temp &&  set /p target_title=<target_title.temp
echo �Ѽ�⵽������ %target_title%
set /p target_title=�����뷬�����������Ů��
echo %target_title%> target_title.temp
start https://search.douban.com/movie/subject_search?search_text=%target_title%
set /p target_year=�����뷢����ݣ���2005��
echo ========================================================================================
rem ��ȡ�ּ�av�ţ�cid�ţ��ּ�����
grep "cid" target_info.temp | sed "s#:#\n#g" | sed "s#,$##g" | sed "/cid/d" > target_pcid.temp
if exist target_paid.temp del target_paid.temp
for /f %%a in ( target_pcid.temp ) do ( cat target_aid.temp>> target_paid.temp )
grep "page" target_info.temp | grep -v "pages" | sed "s#:#\n#g" | sed "s#,$##g" | sed "/page/d" | sed -r "s#^[0-9]$#00&#g" | sed -r "s#^[0-9][0-9]$#0&#g" > target_pindex.temp
grep "part" target_info.temp | grep -v "parts" | sed "s#:#\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/part/d" > target_ptitle.temp
grep "title" target_info.temp | sed "s#:#\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/title/d"  | sed "s/[[:punct:]]//g"> target_ptitle.temp
rem �ϲ��ļ���׼������
paste -d@ target_pindex.temp target_pcid.temp target_paid.temp target_ptitle.temp > target_dinfo.temp
call :XMLGET
goto :eof

:BILIPLUSAV2
rem echo ����Դ��https://www.biliplus.com/all/video/av%1/
curl -s -L "https://www.biliplus.com/all/video/av%1/" | iconv.exe -c -f UTF-8 -t GBK  | sed "s#/api/view_all#\nhttps://www.biliplus.com&#g" | sed "s#,#\n#g" | grep "view_all" | sed "s#.$##g" > target_allapiurl.temp
for /f %%a in (target_allapiurl.temp) do ( curl -s -L %%a | jq-win32 -s "." | iconv.exe -c -f UTF-8 -t GBK > target_info.temp )
rem ��ȡ����������ӳ���
grep "title" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/title/d" > target_title.temp &&  set /p target_title=<target_title.temp
echo �Ѽ�⵽������ %target_title%
set /p target_title=�����뷬�����������Ů��
start https://search.douban.com/movie/subject_search?search_text=%target_title%
set /p target_year=��������ӳ��ݣ���2005��
echo ========================================================================================
rem ��ȡ�ּ�av�ţ�cid�ţ��ּ�����
grep "cid" target_info.temp | grep -v "cid_count" | sed "s#: #\n#g" | sed "s#,$##g" | sed "/cid/d" > target_pcid.temp
if exist target_paid.temp del target_paid.temp
for /f %%a in (target_pcid.temp) do ( cat target_aid.temp>> target_paid.temp )
grep "page" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/page/d" | sed -r "s#^[0-9]$#00&#g" | sed -r "s#^[0-9][0-9]$#0&#g" > target_pindex.temp
grep "part" target_info.temp | grep -v "parts" | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/part/d" > target_ptitle.temp
grep "title" target_info.temp | sed "s#:#\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/title/d" > target_ptitle.temp
rem �ϲ��ļ���׼������
paste -d@ target_pindex.temp target_pcid.temp target_paid.temp target_ptitle.temp > target_dinfo.temp
call :XMLGET
goto :eof

rem BV��תAV��
:BV2AV
curl -L --compressed "https://api.bilibili.com/x/web-interface/archive/stat?bvid=%target_BV%" | jq-win32 -s "." | sed "s#,$##g" | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
grep -i "aid" target_info.temp | sed "s#: #\n#g" | grep "^[0-9]*[0-9]$" > target_aid.temp && set /p target_aid=<target_aid.temp
call :BILIPLUS %target_aid%
goto :eof


rem ========================================================================================
rem ���������������غ���������
rem ========================================================================================
:SSID2CID
rem ���÷��������
set /p target_title=�����뷬�����������Ů��
set /p target_year=�����뷢����ݣ���2005��
echo ========================================================================================
rem ����Դ��https://api.bilibili.com/pgc/web/season/section?season_id=%target_ssid%
curl -s -L "https://api.bilibili.com/pgc/web/season/section?season_id=%target_ssid%" | jq-win32 -s "." | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
rem ��ȡϵ�б��⡢���ȱ��⡢��ӳ���
grep "id" target_info.temp | egrep -v "(a|c|v)id" | sed "s#: #\n#g" | sed "s#,$##g" | sed "/id/d" | sed "1!d" > target_epid.temp && set /p target_epid=<target_epid.temp
rem ��ȡ�ּ�av�ţ�cid�ţ��ּ�����
grep "aid" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/aid/d" > target_paid.temp
grep "cid" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/cid/d" > target_pcid.temp
grep "title" target_info.temp | grep -v "long_title" | sed "s#: #\n#g" | sed "s#,$##g" | sed "/title/d" | sed "s#^.##g" | sed "s#.$##g"  | sed "/��Ƭ/d"  > target_pindex.temp
grep "long_title" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/long_title/d" > target_ptitle.temp
rem �ϲ��ļ���׼������
paste -d@ target_pindex.temp target_pcid.temp target_paid.temp target_ptitle.temp | sed -r "/(^[0-9]|^��)/!d" | sort > target_dinfo.temp
call :XMLGET
goto :eof

:SSID2CID2
rem ���÷��������
set /p target_title=�����뷬�����������Ů��
set /p target_year=�����뷢����ݣ���2005��
echo ========================================================================================
echo ����Դ��https://www.biliplus.com/api/bangumi?season=%target_ssid%
curl -s -L "https://www.biliplus.com/api/bangumi?season=%target_ssid%" | jq-win32 -s "." | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
rem ��ȡ�ּ�av�ţ�cid�ţ��ּ�����
grep "av_id" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/av_id/d" > target_paid.temp
grep "danmaku" target_info.temp | grep -v "danmaku_count" | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/danmaku/d" > target_pcid.temp
grep "index" target_info.temp | grep -v "index_" | grep -v "_index" | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/index/d" > target_pindex.temp
grep "index_title" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed -r "s#(^.|.$)##g" | sed "/index_title/d" > target_ptitle.temp
rem �ϲ��ļ���׼������
paste -d@ target_pindex.temp target_pcid.temp target_paid.temp target_ptitle.temp | sed -r "/^[0-9]/!d" | sort > target_dinfo.temp
call :XMLGET
goto :eof

:EPID2SSID
rem ����Դhttp://api.bilibili.com/pgc/view/web/season?ep_id=%target_epid%
curl -s -L --compressed "http://api.bilibili.com/pgc/view/web/season?ep_id=%target_epid%" | jq-win32 -s "."  | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
grep "season_id" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/season_id/d" | sed "1!d" > target_ssid.temp && set /p target_ssid=<target_ssid.temp
call :SSID2CID %target_ssid%
goto :eof

:MID2SSID
rem ����Դhttps://api.bilibili.com/pgc/review/user?media_id=%target_mid%
curl -s -L --compressed "https://api.bilibili.com/pgc/review/user?media_id=%target_mid%" | jq-win32 -s "." | iconv.exe -c -f UTF-8 -t GBK > target_info.temp
grep "season_id" target_info.temp | sed "s#: #\n#g" | sed "s#,$##g" | sed "/season_id/d" | sed "1!d" > target_ssid.temp && set /p target_ssid=<target_ssid.temp
call :SSID2CID %target_ssid%
goto :eof

:UPDATE
echo ���ڼ����¡���
curl -s -L --retry 3 -o version.temp https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/version.txt
set /p version=<version.txt && set /p version_latest=<version.temp
if %version%==%version_latest% echo ��ǰû�п��ø��� || echo DanmuGenius�Ѹ�����%version_new%���뼰ʱ���ظ��� && start https://github.com/liuzj288/DanmuGenius
goto :eof
