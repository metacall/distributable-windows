@echo off
setlocal
set "loc=%~dp0metacall"
rem Windows PATH
set "PATH=%SystemRoot%;%SystemRoot%\System32;%SystemRoot%\System32\Wbem"
rem MetaCall
set "PATH=%PATH%;%loc%;%loc%\lib"
rem Python
set "PYTHONHOME=%loc%\runtimes\python"
set "PIP_TARGET=%loc%\runtimes\python\Pip"
set "PATH=%PATH%;%loc%\runtimes\python;%loc%\runtimes\python\Scripts"
rem NodeJS
set "PATH=%PATH%;%loc%\lib\runtimes\nodejs;%loc%\lib\runtimes\nodejs\lib"
rem Ruby
set "PATH=%PATH%;%loc%\lib\runtimes\ruby\bin;%loc%\lib\runtimes\ruby\bin\ruby_builtin_dlls"
rem DotNet Core
set "PATH=%PATH%;%loc%\lib\runtimes\dotnet;%loc%\lib\runtimes\dotnet\host\fxr\5.0.12"

rem Check if it is running a package manager (or related binary) and execute it
if not [%1]==[] (
	where /q "%1"
	if %errorlevel% EQU 0 (
		"%1" %*
		exit /b %errorlevel%
	)
)

rem MetaCall Enviroment
set "CORE_ROOT=%loc%\runtimes\dotnet\shared\Microsoft.NETCore.App\5.0.12"
set "LOADER_LIBRARY_PATH=%loc%\lib"
set "SERIAL_LIBRARY_PATH=%loc%\lib"
set "DETOUR_LIBRARY_PATH=%loc%\lib"
set "PORT_LIBRARY_PATH=%loc%\lib"
set "CONFIGURATION_PATH=%loc%\configurations\global.json"
if not defined LOADER_SCRIPT_PATH (
	set "LOADER_SCRIPT_PATH=%cd%"
)

rem Execute MetaCall CLI
"%loc%\metacallcli.exe" %*
endlocal
