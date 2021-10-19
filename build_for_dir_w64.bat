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
pause