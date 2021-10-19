@echo off

set /p loc=Enter your desired full location to set up the things: 
cd %loc%
powershell -Command "invoke-WebRequest https://github.com/skeeto/w64devkit/releases/download/v1.10.0/w64devkit-1.10.0.zip -Outfile w64devkit_comp.zip"
::git clone https://github.com/skeeto/w64devkit
::cd w64devkit
::echo Make sure you have started DOCKER on your system and then press any key to continue...
::pause >nul
::docker build -t w64devkit .
::docker run --rm w64devkit >w64devkit.zip

powershell -Command expand-Archive -Path "w64devkit_comp.zip" -DestinationPath .

git clone https://github.com/metacall/core.git

::set PATH=%loc%\w64devkit\bin

cd core
mkdir Build

cd Build

::CMAKE must be installed in the system
cmake -Wno-dev -DCMAKE_BUILD_TYPE=Release -DOPTION_BUILD_SECURITY=OFF -DOPTION_FORK_SAFE=Off -DOPTION_BUILD_LOADERS_PY=ON -DPython_ROOT_DIR=%loc%/dep/Python -DOPTION_BUILD_LOADERS_NODE=ON -DOPTION_BUILD_LOADERS_CS=ON -DOPTION_BUILD_LOADERS_RB=ON -DOPTION_BUILD_LOADERS_TS=ON -G "MinGW Makefiles" ..
cmake --build .

::Setting up vcpkg
::git clone https://github.com/Microsoft/vcpkg.git
::building vcpkg and using disableMetrics to avoid data share
::.\vcpkg\bootstrap-vcpkg.bat -disableMetrics  

echo Your things are ready 
pause >nul
