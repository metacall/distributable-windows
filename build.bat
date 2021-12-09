@echo off

mkdir metacall
cd metacall

echo Downloading Compiler and Build System

set loc=%cd%
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/skeeto/w64devkit/releases/download/v1.10.0/w64devkit-1.10.0.zip', './w64devkit_comp.zip')"
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "w64devkit_comp.zip" -DestinationPath .
set PATH=%PATH%;%loc%\w64devkit\bin
del w64devkit_comp.zip

powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-windows-x86_64.zip', './cmake.zip')"
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "cmake.zip" -DestinationPath .
set PATH=%PATH%;%loc%\cmake-3.22.1-windows-x86_64\bin
del cmake.zip

echo Downloading Dependencies

mkdir installers
cd installers
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.0.2-1/rubyinstaller-devkit-3.0.2-1-x64.exe', './ruby_installer.exe')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe', './python_installer.exe')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/5d8afe47-8a54-4ca0-b34d-57120fa66d23/114044f7cfa4d581a49cefc47f3a8717/dotnet-runtime-5.0.11-win-x86.exe', './dotnet_installer.exe')"
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nodejs.org/dist/v14.18.0/node-v14.18.0-x64.msi', './node_installer.msi')"

echo Installing Runtimes

cd ..
mkdir runtimes
cd runtimes
mkdir ruby
mkdir python
mkdir dotnet
mkdir nodejs

cd ..
cd installers

ruby_installer.exe /dir="%loc%\runtimes\ruby" /VERYSILENT
set PATH=%PATH%;%loc%\runtimes\ruby\bin

python_installer.exe /quiet TargetDir="%loc%\runtimes\python" PrependPath=1
set PATH=%PATH%;%loc%\runtimes\python\bin

dotnet_installer.exe /passive /installdir=%loc%\runtimes\dotnet
set PATH=%PATH%;%loc%\runtimes\dotnet\bin

msiexec.exe /i node_installer.msi /INSTALLDIR="%loc%\runtimes\nodejs" /quiet
set PATH=%PATH%;%loc%\runtimes\nodejs\bin

echo Building MetaCall

cd ..

rem TODO
rem rmdir installers

git clone --depth 1 https://github.com/metacall/core.git
mkdir core\build
cd core\build

rem TODO
rem NODE, TS, CS, SCRIPTS, TESTS
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
	-DOPTION_BUILD_LOADERS_RB=ON ^
	-DOPTION_BUILD_LOADERS_TS=OFF ^
	-DCMAKE_INSTALL_PREFIX="%loc%" ^
	-G "MinGW Makefiles" ..
cmake --build . --target install
cd ..\..
rmdir core\build

rem TODO
rem rmdir cmake-3.22.1-windows-x86_64
rem rmdir w64devkit

echo MetaCall Built Successfully
pause >nul
