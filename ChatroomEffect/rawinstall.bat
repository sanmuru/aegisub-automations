@echo off

set "reg=HKCR\Applications\aegisub32.exe"
for /f "tokens=2*" %%a in ('reg query %reg% /v FriendlyAppName 2^>nul') do set "a=%%b"

for /f "tokens=1 delims=," %%i in ("%a:~1%") do set "a=%%~di%%~pi"
echo 扫描到Aegisub安装路径："%a:~0,-1%"
echo.

set /p var=是否卸载已安装的文件 [Y(默认)^|N]：
echo.
if /i "%var%"=="N" goto START_INSTALL

echo 正在卸载……
::在这里写卸载代码
if exist "%a%"automation\autoload\ChatroomEffect-generate.lua del "%a%"automation\autoload\ChatroomEffect-generate.lua
if exist "%a%"automation\include\ChatroomEffect (
	del /s /q "%a%"automation\include\ChatroomEffect
	rd /s /q "%a%"automation\include\ChatroomEffect
)
echo.

:START_INSTALL

echo 正在安装……
::在这里写安装代码
copy /y ChatroomEffect-generate.lua "%a%"automation\autoload\
if not exist "%a%"automation\include\ChatroomEffect md "%a%"automation\include\ChatroomEffect
for /f "delims=" %%i in ('dir /a /b "*.lua"') do (
	if exist "%%~ni%%~xi" if /i not "%%~ni%%~xi"=="ChatroomEffect-generate.lua" copy /y "%%~ni%%~xi" "%a%"automation\include\ChatroomEffect\
)
xcopy /e /y animations "%a%"automation\include\ChatroomEffect\animations\
xcopy /e /y logics "%a%"automation\include\ChatroomEffect\logics\
xcopy /e /y shapes "%a%"automation\include\ChatroomEffect\shapes\

set outputdir="bin\Debug"
if not exist "%a%"automation\include\ChatroomEffect\tools md "%a%"automation\include\ChatroomEffect\tools
for /f "delims=" %%i in ('dir /ad /b "tools\cre-tools"') do (
	if exist "tools\cre-tools"\"%%~ni"\"%outputdir%" xcopy /e /y "tools\cre-tools"\"%%~ni"\"%outputdir%" "%a%"automation\include\ChatroomEffect\tools\
)
echo.

echo 安装成功！
pause>nul