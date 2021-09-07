@echo off

set /p loc=Enter your desired full location to set up the things: 
cd %loc%
git clone https://github.com/skeeto/w64devkit
cd w64devkit
echo Make sure you have started DOCKER on your system and then press any key to continue...
pause >nul
docker build -t w64devkit .
docker run --rm w64devkit >w64devkit.zip

cd..
mkdir w64devkit
powershell -Command expand-Archive -Path "w64devkit.zip" -DestinationPath "w64devkit_expanded"

git clone https://github.com/metacall/core.git

::set PATH=%loc%\w64devkit\bin

cd core
mkdir Build

cd Build


cmake -Wno-dev -DCMAKE_BUILD_TYPE=Release -DOPTION_BUILD_SECURITY=OFF -G "MinGW Makefiles" ..
cmake --build . 

::Setting up vcpkg
::git clone https://github.com/Microsoft/vcpkg.git
::building vcpkg and using disableMetrics to avoid data share
::.\vcpkg\bootstrap-vcpkg.bat -disableMetrics  

echo Your things are ready 
pause >nul