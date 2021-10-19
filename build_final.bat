@echo off

mkdir Metacall
cd Metacall

set loc=%cd%
echo Installing w64devkit
echo %loc%a
powershell -Command "invoke-WebRequest https://github.com/skeeto/w64devkit/releases/download/v1.10.0/w64devkit-1.10.0.zip -Outfile w64devkit_comp.zip"
powershell -Command expand-Archive -Path "w64devkit_comp.zip" -DestinationPath .
set PATH=%loc%\w64devkit\bin

This line onwards will be added to the build.batch and source directory will be %loc% we need to come out and chaneg dir to 'installers'
mkdir installers
cd installers
echo Make sure you are connected to a network 
pause
echo Downlaoding Ruby 3.0.2-1 ...
powershell -Command "invoke-WebRequest https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.0.2-1/rubyinstaller-devkit-3.0.2-1-x64.exe -Outfile ruby_installer.exe"
echo Ruby Downloaded
pause

Downloading PYTHON
echo Downlaoding python 3.9.7 ...
powershell -Command "invoke-WebRequest https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe -Outfile python_installer.exe"
echo Python Downloaded
pause

Downloading DOTNET
echo Downlaoding .NET 5.0 Runtime...
powershell -Command "invoke-WebRequest https://download.visualstudio.microsoft.com/download/pr/5d8afe47-8a54-4ca0-b34d-57120fa66d23/114044f7cfa4d581a49cefc47f3a8717/dotnet-runtime-5.0.11-win-x86.exe -Outfile dotnet_installer.exe"
echo DOTNET Downloaded
pause

Downloading NODE
echo Downlaoding NOde.js...
powershell -Command "invoke-WebRequest https://nodejs.org/dist/v14.18.0/node-v14.18.0-x64.msi -Outfile node_installer.msi"
echo DOTNET Downloaded
pause

::come out of intallations and create and go to dep
cd..
mkdir dep
cd dep
mkdir Ruby
mkdir Python
mkdir Dotnet
mkdir nodejs
cd..
cd installers

::Installation for Ruby
echo Going to install all dependencies via GUI, don't close this window.
echo Installing Ruby...

::we can also add verysilent- for no UI and Silent-for lest UI 

ruby_installer.exe /dir="%loc%\dep\Ruby" /VERYSILENT
echo Ruby Installed
set PATH=%PATH%;%loc%\dep\Ruby\bin
pause

::For Python
echo Installing python...
python_installer.exe/passive TargetDir="%cd%\dep\Python" PrependPath=1
echo Python installed
pause

echo Installing dotnet..
::can be quite or passive
dotnet_installer.exe/s /v" INSTALLDIR=%loc%\dep\Dotnet"
set PATH=%PATH%;%loc%\dep\Dotnet\bin
echo dotnet installed

:: needs admin controls
echo Installing Nodejs..
mkdir Dotnet
::can be quite or passive
msiexec.exe /i node_installer.msi /INSTALLDIR="%loc%\dep\Nodejs" /quiete
set PATH=%PATH%;%loc%\dep\Nodejs\bin
echo dotnet installed

echo All Dependencies Installed

cd..

git clone https://github.com/metacall/core.git

mkdir bin
cd core
mkdir Build

cd Build

::CMAKE must be installed in the system
cmake -Wno-dev -DCMAKE_BUILD_TYPE=Release -DOPTION_BUILD_SECURITY=OFF -DOPTION_FORK_SAFE=Off -DOPTION_BUILD_LOADERS_PY=ON -DPython_ROOT_DIR=%loc%/dep/Python -DOPTION_BUILD_LOADERS_NODE=ON -DOPTION_BUILD_LOADERS_CS=ON -DOPTION_BUILD_LOADERS_RB=ON -DOPTION_BUILD_LOADERS_TS=ON -DCMAKE_INSTALL_PREFIX="%loc%/bin" -G "MinGW Makefiles" ..
cmake --build .

::Setting up vcpkg
::git clone https://github.com/Microsoft/vcpkg.git
::building vcpkg and using disableMetrics to avoid data share
::.\vcpkg\bootstrap-vcpkg.bat -disableMetrics  

echo Your things are ready 
pause >nul
