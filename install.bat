@echo off
set batpath=%~dp0%
if not exist DanmuGeniusPro.bat echo ���棺���ѹ��DanmuGeniusPro.bat�����ļ��У�����7 && pause
if not exist %batpath%Bin\ echo �����ػ����������� && pause

setx PATH "%path%;%batpath%Bin\"
echo ��װ��ϣ���ӭʹ�ã�
pause