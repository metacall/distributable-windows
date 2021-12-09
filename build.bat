@echo off

rem Use all the cores when building
set CL=/MP

mkdir metacall
cd metacall
set loc=%cd%

echo Checking Compiler and Build System

rem Devkit is also required for building Ruby
powershell -Command "invoke-WebRequest https://github.com/skeeto/w64devkit/releases/download/v1.10.0/w64devkit-1.10.0.zip -Outfile w64devkit.zip"
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "w64devkit.zip" -DestinationPath .
set PATH=%PATH%;%loc%\w64devkit\bin
del w64devkit.zip

where /Q cmake
if %ERRORLEVEL% EQU 0 (goto skip_build_system)

rem Install CMake if not found
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-windows-x86_64.zip', './cmake.zip')"
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "cmake.zip" -DestinationPath .
set PATH=%PATH%;%loc%\cmake-3.22.1-windows-x86_64\bin
del cmake.zip

:skip_build_system

echo Downloading Dependencies

mkdir dependencies
cd dependencies
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.5-1/rubyinstaller-2.7.5-1-x64.exe', './ruby_installer.exe')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe', './python_installer.exe')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/d1ca6dbf-d054-46ba-86d1-36eb2e455ba2/e950d4503116142d9c2129ed65084a15/dotnet-sdk-5.0.403-win-x64.zip', './dotnet_sdk.zip')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nodejs.org/download/release/v14.18.2/node-v14.18.2-win-x64.zip', './node.zip')"

echo Installing Runtimes

cd ..
mkdir runtimes
cd runtimes
mkdir ruby
mkdir python
mkdir dotnet
mkdir nodejs

cd ..
cd dependencies

rem Install Ruby with DevKit
ruby_installer.exe /dir="%loc%\runtimes\ruby_mingw" /VERYSILENT

set OLDPATH=%PATH%
set PATH=%PATH%;%loc%\runtimes\ruby_mingw\bin

rem Build Ruby with MSVC
git clone --depth 1 --branch v2_7_5 https://github.com/ruby/ruby.git %loc%\runtimes\ruby_msvc
cd %loc%\runtimes\ruby
chcp 1252
win32\configure --prefix="%loc%\runtimes\ruby" --target=x64-mswin64
nmake
nmake check
nmake install
cd %loc%\dependencies
del %loc%\runtimes\ruby_msvc
set PATH=%OLDPATH%;%loc%\runtimes\ruby\bin

rem Install Python
python_installer.exe /quiet TargetDir="%loc%\runtimes\python" PrependPath=1 CompileAll=1
set PATH=%PATH%;%loc%\runtimes\python\bin

rem Install DotNet
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "dotnet_sdk.zip" -DestinationPath %loc%\runtimes\dotnet
set PATH=%PATH%;%loc%\runtimes\dotnet\bin

rem Install NodeJS
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "node.zip" -DestinationPath %loc%\runtimes\nodejs
robocopy /move /e %loc%\runtimes\nodejs\node-v14.18.2-win-x64 %loc%\runtimes\nodejs /NFL /NDL /NJH /NJS /NC /NS /NP
rmdir %loc%\runtimes\nodejs\node-v14.18.2-win-x64
set PATH=%PATH%;%loc%\runtimes\nodejs\bin

echo Building MetaCall

cd ..

git clone --depth 1 https://github.com/metacall/core.git

rem Patch for FindRuby.cmake
set "escaped_loc=%loc:\=/%"

rem TODO: Not working with MSVC, we have to rebuild Ruby with MSVC
echo set(Ruby_VERSION 2.7.0)>> %loc%\core\cmake\FindRuby.cmake
echo set(Ruby_ROOT_DIR "%escaped_loc%/runtimes/ruby")>> %loc%\core\cmake\FindRuby.cmake
echo set(Ruby_EXECUTABLE "%escaped_loc%/runtimes/ruby/bin/ruby.exe")>> %loc%\core\cmake\FindRuby.cmake
echo set(Ruby_INCLUDE_DIRS "%escaped_loc%/runtimes/ruby/include/ruby-2.7.0;%escaped_loc%/runtimes/ruby/include/ruby-2.7.0/x64-mingw32")>> %loc%\core\cmake\FindRuby.cmake
echo set(Ruby_LIBRARY "%escaped_loc%/runtimes/ruby/lib/libx64-msvcrt-ruby270.dll.a")>> %loc%\core\cmake\FindRuby.cmake
echo include(FindPackageHandleStandardArgs)>> %loc%\core\cmake\FindRuby.cmake
echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(Ruby REQUIRED_VARS Ruby_EXECUTABLE Ruby_LIBRARY Ruby_INCLUDE_DIRS VERSION_VAR Ruby_VERSION)>> %loc%\core\cmake\FindRuby.cmake
echo mark_as_advanced(Ruby_EXECUTABLE Ruby_LIBRARY Ruby_INCLUDE_DIRS)>> %loc%\core\cmake\FindRuby.cmake

mkdir core\build
cd core\build

rem TODO: NODE, CS, RB, TS
cmake -Wno-dev ^
	-DCMAKE_BUILD_TYPE=Release ^
	-DOPTION_BUILD_SECURITY=OFF ^
	-DOPTION_FORK_SAFE=OFF ^
	-DOPTION_BUILD_SCRIPTS=OFF ^
	-DOPTION_BUILD_TESTS=OFF ^
	-DOPTION_BUILD_EXAMPLES=OFF ^
	-DOPTION_BUILD_LOADERS_PY=ON ^
	-DPython_ROOT_DIR="%loc%\runtimes\python" ^
	-DOPTION_BUILD_LOADERS_NODE=OFF ^
	-DOPTION_BUILD_LOADERS_CS=OFF ^
	-DOPTION_BUILD_LOADERS_RB=OFF ^
	-DOPTION_BUILD_LOADERS_TS=OFF ^
	-DCMAKE_INSTALL_PREFIX="%loc%" ^
	-G "NMake Makefiles" ..
cmake --build . --target install
cd ..\..

rem Delete unnecesary data
rmdir /S /Q %loc%\core
rmdir /S /Q %loc%\dependencies
rmdir /S /Q %loc%\cmake-3.22.1-windows-x86_64
rmdir /S /Q %loc%\w64devkit

echo MetaCall Built Successfully
