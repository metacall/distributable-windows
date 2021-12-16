@echo off
setlocal
set loc=%~dp0metacall
rem Windows PATH
set "PATH=%loc%;%loc%\lib"
rem Python
set "PYTHONHOME=%loc%\runtimes\python"
set "PATH=%PATH%;%loc%\runtimes\python"
rem NodeJS
set "PATH=%PATH%;%loc%\lib\runtimes\nodejs\lib"
rem Ruby
set "PATH=%PATH%;%loc%\lib\runtimes\ruby\bin;%loc%\lib\runtimes\ruby\bin\ruby_builtin_dlls"
rem DotNet Core
set "PATH=%PATH%;%loc%\lib\runtimes\nodejs\lib"
rem set "escaped_loc=%loc:\=\\%"
rem echo { "dotnet_root":"%escaped_loc%\\runtimes\\dotnet\\shared\\Microsoft.NETCore.App\\5.0.12", "dotnet_loader_assembly_path":"%escaped_loc%\\lib\\CSLoader.dll" }> "%loc%\configurations\cs_loader.json"
echo { }> "%loc%\configurations\cs_loader.json"
set "CORE_ROOT=%loc%\runtimes\dotnet\shared\Microsoft.NETCore.App\5.0.12"
rem MetaCall Enviroment
set "LOADER_LIBRARY_PATH=%loc%\lib"
set "SERIAL_LIBRARY_PATH=%loc%\lib"
set "DETOUR_LIBRARY_PATH=%loc%\lib"
set "PORT_LIBRARY_PATH=%loc%\lib"
set "CONFIGURATION_PATH=%loc%\configurations\global.json"
if not defined LOADER_SCRIPT_PATH (
	set "LOADER_SCRIPT_PATH=%cd%"
)
%loc%\metacallcli.exe
endlocal
