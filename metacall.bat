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

rem Package Managers Paths
set "pip_path=%loc%\runtimes\python\Pip\bin\pip.exe"
set "pip3_path=%loc%\runtimes\python\Pip\bin\pip3.exe"
set "npm_path=%loc%\runtimes\nodejs\npm.cmd"
set "npx_path=%loc%\runtimes\nodejs\npx.cmd"
set "bundle_path=%loc%\runtimes\ruby\bundle.bat"
set "bundler_path=%loc%\runtimes\ruby\bundler.bat"
set "erb_path=%loc%\runtimes\ruby\erb.bat"
set "gem_path=%loc%\runtimes\ruby\gem.bat"
set "irb_path=%loc%\runtimes\ruby\irb.bat"
set "racc_path=%loc%\runtimes\ruby\racc.bat"
set "rake_path=%loc%\runtimes\ruby\rake.bat"
set "rbs_path=%loc%\runtimes\ruby\rbs.bat"
set "rdbg_path=%loc%\runtimes\ruby\rdbg.bat"
set "rdoc_path=%loc%\runtimes\ruby\rdoc.bat"
set "ri_path=%loc%\runtimes\ruby\ri.bat"
set "typeprof_path=%loc%\runtimes\ruby\typeprof.bat"
rem TODO: set "nuget_path=%loc%\runtimes\dotnet\nuget.exe"

rem Check if it is running a package manager (or related binary) and execute it
for /f "tokens=1,* delims= " %%a in ("%*") do set SUBPROGRAM_PARAMETERS=%%b
setlocal ENABLEDELAYEDEXPANSION
set package_manager=^^^!%1_path^^^!
if not [%package_manager%]==[] (
	"%package_manager%" %SUBPROGRAM_PARAMETERS%
)
endlocal

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
