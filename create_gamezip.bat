@echo off
set COCOS_ROOT=%QUICK_V3_ROOT%
set DIR=%~dp0
echo - config:
echo   COCOS_ROOT    = %COCOS_ROOT%
echo   DIR    = %DIR%
%COCOS_ROOT%quick\bin\compile_scripts.bat -i %DIR%src -o update.zip -e xxtea_zip -ek eckk@BoomEgg2014 -es ecss@BoomEgg2014