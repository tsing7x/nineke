@echo off
set DIR=%~dp0
set NDK_DEBUG=1
call %DIR%build_native_release.bat

:copy
echo copy libs
xcopy /s /q "%APP_ROOT%\proj.android.lib.xinge\xingelibs\armeabi\*.*" "%APP_ANDROID_ROOT%\libs\armeabi\"

echo override copy res_th
xcopy /s /q /y "%APP_ROOT%\res_th\*.*" "%APP_ANDROID_ROOT%assets\res\"

echo override copy src.th
xcopy /s /q /y "%APP_ROOT%\src.th\*.*" "%APP_ANDROID_ROOT%assets\src"

echo - copy assets
xcopy /s /q "%APP_ROOT%frameworks\runtime-src\assets\*.*" "%APP_ANDROID_ROOT%assets\"

:end
exit /b %retVal%