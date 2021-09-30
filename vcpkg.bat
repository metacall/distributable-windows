@echo off
set /p loc=Enter your desired full location to set up the things: 
cd %loc%
::This line onwards will be added to the build.batch and source directory will be %loc% we need to come out and chaneg dir to 'installers'
mkdir installers
cd installers
echo Make sure you are connected to a network 
pause
echo Downlaoding Ruby 3.0.2-1 ...
powershell -Command "invoke-WebRequest https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.0.2-1/rubyinstaller-devkit-3.0.2-1-x64.exe -Outfile ruby_installer.exe"
echo Ruby Downloaded
pause

::Downloading PYTHON
echo Downlaoding python 3.9.7 ...
powershell -Command "invoke-WebRequest https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe -Outfile python_installer.exe"
echo Python Downloaded
pause

::Downloading DOTNET
echo Downlaoding .NET 5.0 Runtime...
powershell -Command "invoke-WebRequest https://dotnet.microsoft.com/download/dotnet/thank-you/runtime-5.0.10-windows-x64-installer -Outfile dotnet_installer.exe"
echo DOTNET Downloaded
pause

::Downloading NODE
echo Downlaoding NOde.js...
powershell -Command "invoke-WebRequest https://nodejs.org/dist/v14.18.0/node-v14.18.0-x64.msi -Outfile node_installer.msi"
echo DOTNET Downloaded
pause

::come out of intallations and create and go to dep
cd..
mkdir dep
cd installers

::Installation for Ruby
echo Going to install all dependencies via GUI, don't close this window.
echo Installing Ruby...
mkdir Ruby
::we can also add verysilent- for no UI and Silent-for lest UI 
ruby_installer/DIR="%loc%\dep\Ruby" /SILENT
echo Ruby Installed
::not sure about adding path
setx PATH="%loc%\dep\Ruby\bin";%PATH%
pause

::For Python
echo Installing python...
mkdir Python
python_installer.exe/passive TargetDir="%loc%\dep\Python" PrependPath=1
echo Python installed
pause

::for DOTNET - still pending ui and targetdir
echo Installing dotnet..
mkdir Dotnet
dotnet_installer.exe
echo dotnet installed

::for Node.js - still pending is targetdir
echo Installing dotnet..
mkdir Dotnet
::can be quite or passive
msiexec.exe /i node_installer.msi INSTALLDIR="%loc%\dep\Dotnet" /passive
echo dotnet installed

echo All Dependencies Installed
pause
