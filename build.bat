@echo on

rem Use all the cores when building
set CL=/MP

mkdir metacall
cd metacall
set loc=%cd%

echo Checking Compiler and Build System

where /Q cmake
if %ERRORLEVEL% EQU 0 (goto skip_build_system)

rem Install CMake if not found
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-windows-x86_64.zip', './cmake.zip')" || goto :error
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "cmake.zip" -DestinationPath . || goto :error
set PATH=%PATH%;%loc%\cmake-3.22.1-windows-x86_64\bin
del cmake.zip

:skip_build_system

echo Downloading Dependencies

mkdir %loc%\dependencies
cd %loc%\dependencies

powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/MSP-Greg/ruby-loco/releases/download/ruby-master/ruby-mswin.7z', './ruby-mswin.7z')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe', './python_installer.exe')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/d1ca6dbf-d054-46ba-86d1-36eb2e455ba2/e950d4503116142d9c2129ed65084a15/dotnet-sdk-5.0.403-win-x64.zip', './dotnet_sdk.zip')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nodejs.org/download/release/v14.18.2/node-v14.18.2-win-x64.zip', './node.zip')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nodejs.org/download/release/v14.18.2/node-v14.18.2-headers.tar.gz', './node_headers.tar.gz')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nodejs.org/download/release/v14.18.2/node-v14.18.2.tar.gz', './node_src.tar.gz')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/metacall/core/66fcaac300611d1c4210023e7b260296586a42e0/cmake/NodeJSGYPPatch.py', './NodeJSGYPPatch.py')" || goto :error

echo Installing Runtimes

mkdir %loc%\runtimes
mkdir %loc%\runtimes\ruby
mkdir %loc%\runtimes\python
mkdir %loc%\runtimes\dotnet
mkdir %loc%\runtimes\nodejs

cd %loc%\dependencies

rem Install Ruby
set PATH=%PATH%;%programfiles%\7-Zip\
7z x %loc%\dependencies\ruby-mswin.7z || goto :error
robocopy /move /e %loc%\dependencies\ruby-mswin %loc%\runtimes\ruby /NFL /NDL /NJH /NJS /NC /NS /NP
set PATH=%PATH%;%loc%\runtimes\ruby\bin

rem Install Python
where /Q python
if %ERRORLEVEL% EQU 0 (goto skip_uninstall_python)

rem Uninstall Python if it is already installed
python_installer.exe /uninstall || goto :error

:skip_uninstall_python

python_installer.exe /quiet TargetDir="%loc%\runtimes\python" PrependPath=1 CompileAll=1 || goto :error
set PATH=%PATH%;%loc%\runtimes\python

rem Install DotNet
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "dotnet_sdk.zip" -DestinationPath %loc%\runtimes\dotnet || goto :error
git clone --branch v5.0.12 --depth 1 --single-branch https://github.com/dotnet/runtime.git %loc%\runtimes\dotnet\runtime
mkdir %loc%\runtimes\dotnet\include
robocopy /move /e %loc%\runtimes\dotnet\runtime\src\coreclr\src\pal %loc%\runtimes\dotnet\include\pal /NFL /NDL /NJH /NJS /NC /NS /NP
robocopy /move /e %loc%\runtimes\dotnet\runtime\src\coreclr\src\inc %loc%\runtimes\dotnet\include\inc /NFL /NDL /NJH /NJS /NC /NS /NP
rmdir /S /Q %loc%\runtimes\dotnet\runtime
set PATH=%PATH%;%loc%\runtimes\dotnet

rem Install NodeJS
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "node.zip" -DestinationPath %loc%\runtimes\nodejs || goto :error
robocopy /move /e %loc%\runtimes\nodejs\node-v14.18.2-win-x64 %loc%\runtimes\nodejs /NFL /NDL /NJH /NJS /NC /NS /NP || goto :error
rmdir %loc%\runtimes\nodejs\node-v14.18.2-win-x64
set PATH=%PATH%;%loc%\runtimes\nodejs\bin

rem Install NodeJS Headers
cmake -E tar xzf node_headers.tar.gz || goto :error
cd %loc%\dependencies\node-v14.18.2 || goto :error
mkdir %loc%\runtimes\nodejs\include
robocopy /move /e %loc%\dependencies\node-v14.18.2\include %loc%\runtimes\nodejs\include /NFL /NDL /NJH /NJS /NC /NS /NP
cd %loc%\dependencies
rmdir /S /Q %loc%\dependencies\node-v14.18.2

rem Build NodeJS (DLL)
cmake -E tar xzf node_src.tar.gz || goto :error
cd %loc%\dependencies\node-v14.18.2 || goto :error
.\vcbuild.bat || goto :error
python %loc%\dependencies\NodeJSGYPPatch.py %loc%\dependencies\node-v14.18.2\node.gyp || goto :error
.\vcbuild.bat dll rem This command will fail but it will produce a valid node.dll
mkdir %loc%\runtimes\nodejs\lib || goto :error
move %loc%\dependencies\node-v14.18.2\out\Release\libnode.lib %loc%\runtimes\nodejs\lib\libnode.lib || goto :error
move %loc%\dependencies\node-v14.18.2\out\Release\libnode.dll %loc%\runtimes\nodejs\lib\libnode.dll || goto :error
cd %loc%\dependencies
rmdir /S /Q %loc%\dependencies\node-v14.18.2

echo Building MetaCall

cd %loc%

git clone --depth 1 https://github.com/metacall/core.git || goto :error

set "escaped_loc=%loc:\=/%"

rem Patch for FindRuby.cmake
echo set(Ruby_VERSION 3.1.0)>> %loc%\core\cmake\FindRuby.cmake
echo set(Ruby_ROOT_DIR "%escaped_loc%/runtimes/ruby")>> %loc%\core\cmake\FindRuby.cmake
echo set(Ruby_EXECUTABLE "%escaped_loc%/runtimes/ruby/bin/ruby.exe")>> %loc%\core\cmake\FindRuby.cmake
echo set(Ruby_INCLUDE_DIRS "%escaped_loc%/runtimes/ruby/include/ruby-3.1.0;%escaped_loc%/runtimes/ruby/include/ruby-3.1.0/x64-mswin64_140")>> %loc%\core\cmake\FindRuby.cmake
echo set(Ruby_LIBRARY "%escaped_loc%/runtimes/ruby/lib/x64-vcruntime140-ruby310.lib")>> %loc%\core\cmake\FindRuby.cmake
echo include(FindPackageHandleStandardArgs)>> %loc%\core\cmake\FindRuby.cmake
echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(Ruby REQUIRED_VARS Ruby_EXECUTABLE Ruby_LIBRARY Ruby_INCLUDE_DIRS VERSION_VAR Ruby_VERSION)>> %loc%\core\cmake\FindRuby.cmake
echo mark_as_advanced(Ruby_EXECUTABLE Ruby_LIBRARY Ruby_INCLUDE_DIRS)>> %loc%\core\cmake\FindRuby.cmake

rem Patch for FindPython.cmake
echo set(Python_VERSION 3.9.7)>> %loc%\core\cmake\FindPython.cmake
echo set(Python_ROOT_DIR "%escaped_loc%/runtimes/python")>> %loc%\core\cmake\FindPython.cmake
echo set(Python_EXECUTABLE "%escaped_loc%/runtimes/python/python.exe")>> %loc%\core\cmake\FindPython.cmake
echo set(Python_INCLUDE_DIRS "%escaped_loc%/runtimes/python/include")>> %loc%\core\cmake\FindPython.cmake
echo set(Python_LIBRARIES "%escaped_loc%/runtimes/python/libs/python39.lib")>> %loc%\core\cmake\FindPython.cmake
echo include(FindPackageHandleStandardArgs)>> %loc%\core\cmake\FindPython.cmake
echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(Python REQUIRED_VARS Python_EXECUTABLE Python_LIBRARIES Python_INCLUDE_DIRS VERSION_VAR Python_VERSION)>> %loc%\core\cmake\FindPython.cmake
echo mark_as_advanced(Python_EXECUTABLE Python_LIBRARIES Python_INCLUDE_DIRS)>> %loc%\core\cmake\FindPython.cmake

rem Patch for FindCoreCLR.cmake
echo set(CoreCLR_VERSION 5.0.12)>> %loc%\core\cmake\FindCoreCLR.cmake
echo set(DOTNET_CORE_PATH "%escaped_loc%/runtimes/dotnet/shared/Microsoft.NETCore.App/5.0.12")>> %loc%\core\cmake\FindCoreCLR.cmake
echo set(CORECLR_INCLUDE_DIR "%escaped_loc%/runtimes/dotnet/include")>> %loc%\core\cmake\FindCoreCLR.cmake
echo include(FindPackageHandleStandardArgs)>> %loc%\core\cmake\FindCoreCLR.cmake
echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(CoreCLR REQUIRED_VARS DOTNET_CORE_PATH CORECLR_INCLUDE_DIR VERSION_VAR CoreCLR_VERSION)>> %loc%\core\cmake\FindCoreCLR.cmake
echo mark_as_advanced(DOTNET_CORE_PATH CORECLR_INCLUDE_DIR)>> %loc%\core\cmake\FindCoreCLR.cmake

rem Patch for FindDotNET.cmake
echo set(DOTNET_VERSION 5.0.12)>> %loc%\core\cmake\FindDotNET.cmake
echo set(DOTNET_MIGRATE 1)>> %loc%\core\cmake\FindDotNET.cmake
echo set(DOTNET_COMMAND "%escaped_loc%/runtimes/dotnet/dotnet.exe")>> %loc%\core\cmake\FindDotNET.cmake
echo include(FindPackageHandleStandardArgs)>> %loc%\core\cmake\FindDotNET.cmake
echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(DotNET REQUIRED_VARS DOTNET_COMMAND DOTNET_MIGRATE VERSION_VAR DOTNET_VERSION)>> %loc%\core\cmake\FindDotNET.cmake
echo mark_as_advanced(DOTNET_COMMAND DOTNET_MIGRATE DOTNET_VERSION)>> %loc%\core\cmake\FindDotNET.cmake

rem TODO: Patch for FindNodeJS.cmake

mkdir %loc%\core\build
cd %loc%\core\build

rem Build MetaCall
cmake -Wno-dev ^
	-DCMAKE_BUILD_TYPE=Release ^
	-DOPTION_BUILD_SECURITY=OFF ^
	-DOPTION_FORK_SAFE=OFF ^
	-DOPTION_BUILD_SCRIPTS=OFF ^
	-DOPTION_BUILD_TESTS=OFF ^
	-DOPTION_BUILD_EXAMPLES=OFF ^
	-DOPTION_BUILD_LOADERS_PY=ON ^
	-DOPTION_BUILD_LOADERS_NODE=ON ^
	-DOPTION_BUILD_LOADERS_CS=ON ^
	-DOPTION_BUILD_LOADERS_RB=ON ^
	-DOPTION_BUILD_LOADERS_TS=ON ^
	-DOPTION_BUILD_PORTS=ON ^
	-DOPTION_BUILD_PORTS_PY=ON ^
	-DOPTION_BUILD_PORTS_NODE=ON ^
	-DCMAKE_INSTALL_PREFIX="%loc%" ^
	-G "NMake Makefiles" .. || goto :error
cmake --build . --target install || goto :error

rem Delete unnecesary data
rmdir /S /Q %loc%\core
rmdir /S /Q %loc%\dependencies
rmdir /S /Q %loc%\cmake-3.22.1-windows-x86_64
rmdir /S /Q %loc%\runtimes\dotnet\include

echo MetaCall Built Successfully
dir /b /s /a %loc%

echo Compressing the Tarball
cd ../..
powershell -Command "Compress-Archive" -Path %loc% -DestinationPath metacall.zip

exit 0

rem Handle error
:error
echo Failed with error #%errorlevel%
exit /b %errorlevel%
