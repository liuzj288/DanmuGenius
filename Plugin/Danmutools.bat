@echo off
title=danmu-toolsplugin 1.0.1
if "%target%"=="" echo 请使用启动器启动! && ping /5 127.0.0.1 >nul && exit
if exist "%batpath%\Plugin\danmu-tools\DanMu\*.xml" move "%batpath%\Plugin\danmu-tools\DanMu\*.xml" "%batpath%\Download\%moviename%（%year%）\" 