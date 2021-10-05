@echo off

set /p loc=Enter your desired full location to set up the things: 
cd %loc%

::building w64devkit without docker
powershell -Command "invoke-WebRequest https://github.com/skeeto/w64devkit/releases/download/v1.10.0/w64devkit-1.10.0.zip -Outfile w64devkit_comp.zip"
powershell -Command expand-Archive -Path "w64devkit_comp.zip" -DestinationPath .
::set PATH=%loc%\w64devkit\bin

::Cloning Metacall
git clone https://github.com/metacall/core.git

::set PATH=%loc%\w64devkit\bin

cd core
mkdir Build

cd Build


cmake -Wno-dev -DCMAKE_BUILD_TYPE=Release -DOPTION_BUILD_SECURITY=OFF -DOPTION_FORK_SAFE=Off -G "MinGW Makefiles" ..
cmake --build . 

::Setting up vcpkg
::git clone https://github.com/Microsoft/vcpkg.git
::building vcpkg and using disableMetrics to avoid data share
::.\vcpkg\bootstrap-vcpkg.bat -disableMetrics  

echo Your things are ready 
pause >nul
