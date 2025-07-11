@echo on

rem Use all the cores when building
set CL=/MP

rem Output directory
set "dest=%cd%"

echo Checking Compiler and Build System

where /Q cmake
if %errorlevel% EQU 0 (goto skip_build_system)

rem Install CMake if not found
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-windows-x86_64.zip', './cmake.zip')" || goto :error
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "cmake.zip" -DestinationPath . || goto :error
set "PATH=%PATH%;%dest%\cmake-3.22.1-windows-x86_64\bin"
del cmake.zip

:skip_build_system

rem Tarball directory
mkdir metacall
cd metacall
set loc=%cd%

rem Install NASM for NodeJS
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-win64.zip', './nasm.zip')" || goto :error
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "nasm.zip" -DestinationPath . || goto :error
set "PATH=%PATH%;%loc%\nasm-2.15.05;%loc%\nasm-2.15.05\rdoff"
del nasm.zip

echo Downloading Dependencies

mkdir "%loc%\dependencies"
cd "%loc%\dependencies"

powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/metacall/ruby-loco/releases/download/ruby-master/ruby-mswin.7z', './ruby-mswin.7z')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe', './python_installer.exe')" || goto :error
@rem TODO: Disable C# for now until we make it work: https://github.com/metacall/distributable-windows/issues/13
@rem powershell -Command "(New-Object Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/25a8e07d-21fb-46fe-a21e-33c7972d4683/50ba527abe01a9619ace5d8cc2450b70/dotnet-sdk-7.0.101-win-x64.zip', './dotnet_sdk.zip')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nodejs.org/download/release/v20.11.0/node-v20.11.0-win-x64.zip', './node.zip')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://nodejs.org/download/release/v20.11.0/node-v20.11.0-headers.tar.gz', './node_headers.tar.gz')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/metacall/node.dll/releases/download/v0.0.6/node-shared-v20.11.0-x64.zip', './node_dll.zip')" || goto :error
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/metacall/core/66fcaac300611d1c4210023e7b260296586a42e0/cmake/NodeJSGYPPatch.py', './NodeJSGYPPatch.py')" || goto :error

echo Installing Runtimes

mkdir "%loc%\runtimes"
mkdir "%loc%\runtimes\ruby"
mkdir "%loc%\runtimes\python"
@rem TODO: Disable C# for now until we make it work: https://github.com/metacall/distributable-windows/issues/13
@rem mkdir "%loc%\runtimes\dotnet"
mkdir "%loc%\runtimes\nodejs"

cd "%loc%\dependencies"

rem Install Ruby
set PATH=%PATH%;%programfiles%\7-Zip\
7z x "%loc%\dependencies\ruby-mswin.7z" || goto :error
robocopy /move /e "%loc%\dependencies\ruby-mswin" %loc%\runtimes\ruby /NFL /NDL /NJH /NJS /NC /NS /NP
set "PATH=%PATH%;%loc%\runtimes\ruby\bin"

rem Install Python
where /Q python
if %errorlevel% EQU 0 (goto skip_uninstall_python)
rem Uninstall Python if it is already installed
python_installer.exe /uninstall || goto :error
:skip_uninstall_python
python_installer.exe /quiet TargetDir="%loc%\runtimes\python" PrependPath=1 CompileAll=1 || goto :error
set "PATH=%PATH%;%loc%\runtimes\python;%loc%\runtimes\python\Scripts"

@rem TODO: Disable C# for now until we make it work: https://github.com/metacall/distributable-windows/issues/13
@rem rem Install DotNet
@rem powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "dotnet_sdk.zip" -DestinationPath "%loc%\runtimes\dotnet" || goto :error
@rem git clone --branch v5.0.12 --depth 1 --single-branch https://github.com/dotnet/runtime.git "%loc%\runtimes\dotnet\runtime"
@rem mkdir "%loc%\runtimes\dotnet\include"
@rem robocopy /move /e "%loc%\runtimes\dotnet\runtime\src\coreclr\src\pal" "%loc%\runtimes\dotnet\include\pal" /NFL /NDL /NJH /NJS /NC /NS /NP
@rem robocopy /move /e "%loc%\runtimes\dotnet\runtime\src\coreclr\src\inc" "%loc%\runtimes\dotnet\include\inc" /NFL /NDL /NJH /NJS /NC /NS /NP
@rem rmdir /S /Q "%loc%\runtimes\dotnet\runtime"
@rem set "PATH=%PATH%;%loc%\runtimes\dotnet"

rem Install NodeJS
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "node.zip" -DestinationPath "%loc%\runtimes\nodejs" || goto :error
robocopy /move /e "%loc%\runtimes\nodejs\node-v20.11.0-win-x64" "%loc%\runtimes\nodejs" /NFL /NDL /NJH /NJS /NC /NS /NP
rmdir "%loc%\runtimes\nodejs\node-v20.11.0-win-x64"
set "PATH=%PATH%;%loc%\runtimes\nodejs"

rem Install NodeJS Headers
cmake -E tar xzf node_headers.tar.gz || goto :error
cd "%loc%\dependencies\node-v20.11.0" || goto :error
mkdir %loc%\runtimes\nodejs\include
robocopy /move /e "%loc%\dependencies\node-v20.11.0\include" "%loc%\runtimes\nodejs\include" /NFL /NDL /NJH /NJS /NC /NS /NP
cd %loc%\dependencies
rmdir /S /Q "%loc%\dependencies\node-v20.11.0"

rem Install NodeJS DLL
powershell -Command "$global:ProgressPreference = 'SilentlyContinue'; Expand-Archive" -Path "node_dll.zip" -DestinationPath "%loc%\runtimes\nodejs\lib" || goto :error

echo Building MetaCall

cd %loc%

git clone --depth 1 https://github.com/metacall/core.git || goto :error

set "escaped_loc=%loc:\=/%"

rem Patch for FindRuby.cmake
echo set(Ruby_VERSION 3.5.0)> "%loc%\core\cmake\FindRuby.cmake"
echo set(Ruby_VERSION_STRING "3.5.0")>> "%loc%\core\cmake\FindRuby.cmake"
echo set(Ruby_ROOT_DIR "%escaped_loc%/runtimes/ruby")>> "%loc%\core\cmake\FindRuby.cmake"
echo set(Ruby_INCLUDE_DIRS "%escaped_loc%/runtimes/ruby/include/ruby-3.5.0+0;%escaped_loc%/runtimes/ruby/include/ruby-3.5.0+0/x64-mswin64_140")>> "%loc%\core\cmake\FindRuby.cmake"
echo set(Ruby_EXECUTABLE "%escaped_loc%/runtimes/ruby/bin/ruby.exe")>> "%loc%\core\cmake\FindRuby.cmake"
echo set(Ruby_LIBRARY "%escaped_loc%/runtimes/ruby/lib/x64-vcruntime140-ruby350.lib")>> "%loc%\core\cmake\FindRuby.cmake"
echo set(Ruby_LIBRARY_NAME "%escaped_loc%/runtimes/ruby/bin/x64-vcruntime140-ruby350.dll")>> "%loc%\core\cmake\FindRuby.cmake"
echo set(Ruby_LIBRARY_SEARCH_PATHS "%escaped_loc%/runtimes/ruby/bin/ruby_builtin_dlls")>> "%loc%\core\cmake\FindRuby.cmake"
echo include(FindPackageHandleStandardArgs)>> "%loc%\core\cmake\FindRuby.cmake"
echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(Ruby REQUIRED_VARS Ruby_EXECUTABLE Ruby_LIBRARY Ruby_INCLUDE_DIRS VERSION_VAR Ruby_VERSION)>> "%loc%\core\cmake\FindRuby.cmake"
echo mark_as_advanced(Ruby_EXECUTABLE Ruby_LIBRARY Ruby_INCLUDE_DIRS)>> "%loc%\core\cmake\FindRuby.cmake"

rem Patch for FindPython3.cmake
echo set(Python3_VERSION 3.9.7)> "%loc%\core\cmake\FindPython3.cmake"
echo set(Python3_ROOT_DIR "%escaped_loc%/runtimes/python")>> "%loc%\core\cmake\FindPython3.cmake"
echo set(Python3_EXECUTABLE "%escaped_loc%/runtimes/python/python.exe")>> "%loc%\core\cmake\FindPython3.cmake"
echo set(Python3_INCLUDE_DIRS "%escaped_loc%/runtimes/python/include")>> "%loc%\core\cmake\FindPython3.cmake"
echo set(Python3_LIBRARIES "%escaped_loc%/runtimes/python/libs/python39.lib")>> "%loc%\core\cmake\FindPython3.cmake"
echo set(Python_EXECUTABLE "%escaped_loc%/runtimes/python/python.exe")>> "%loc%\core\cmake\FindPython3.cmake"
echo set(Python_INCLUDE_DIRS "%escaped_loc%/runtimes/python/include")>> "%loc%\core\cmake\FindPython3.cmake"
echo set(Python_LIBRARIES "%escaped_loc%/runtimes/python/libs/python39.lib")>> "%loc%\core\cmake\FindPython3.cmake"
echo include(FindPackageHandleStandardArgs)>> "%loc%\core\cmake\FindPython3.cmake"
echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(Python REQUIRED_VARS Python_EXECUTABLE Python_LIBRARIES Python_INCLUDE_DIRS VERSION_VAR Python_VERSION)>> "%loc%\core\cmake\FindPython3.cmake"
echo mark_as_advanced(Python_EXECUTABLE Python_LIBRARIES Python_INCLUDE_DIRS)>> "%loc%\core\cmake\FindPython3.cmake"

@rem TODO: Disable C# for now until we make it work: https://github.com/metacall/distributable-windows/issues/13
@rem rem Patch for FindCoreCLR.cmake
@rem echo set(CoreCLR_VERSION 5.0.12)> "%loc%\core\cmake\FindCoreCLR.cmake"
@rem echo set(DOTNET_CORE_PATH "%escaped_loc%/runtimes/dotnet/shared/Microsoft.NETCore.App/5.0.12")>> "%loc%\core\cmake\FindCoreCLR.cmake"
@rem echo set(CORECLR_INCLUDE_DIR "%escaped_loc%/runtimes/dotnet/include")>> "%loc%\core\cmake\FindCoreCLR.cmake"
@rem echo include(FindPackageHandleStandardArgs)>> "%loc%\core\cmake\FindCoreCLR.cmake"
@rem echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(CoreCLR REQUIRED_VARS DOTNET_CORE_PATH CORECLR_INCLUDE_DIR VERSION_VAR CoreCLR_VERSION)>> "%loc%\core\cmake\FindCoreCLR.cmake"
@rem echo mark_as_advanced(DOTNET_CORE_PATH CORECLR_INCLUDE_DIR)>> "%loc%\core\cmake\FindCoreCLR.cmake"

@rem TODO: Disable C# for now until we make it work: https://github.com/metacall/distributable-windows/issues/13
@rem rem Patch for FindDotNET.cmake
@rem echo set(DOTNET_VERSION 5.0.12)> "%loc%\core\cmake\FindDotNET.cmake"
@rem echo set(DOTNET_MIGRATE 1)>> "%loc%\core\cmake\FindDotNET.cmake"
@rem echo set(DOTNET_COMMAND "%escaped_loc%/runtimes/dotnet/dotnet.exe")>> "%loc%\core\cmake\FindDotNET.cmake"
@rem echo include(FindPackageHandleStandardArgs)>> "%loc%\core\cmake\FindDotNET.cmake"
@rem echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(DotNET REQUIRED_VARS DOTNET_COMMAND DOTNET_MIGRATE VERSION_VAR DOTNET_VERSION)>> "%loc%\core\cmake\FindDotNET.cmake"
@rem echo mark_as_advanced(DOTNET_COMMAND DOTNET_MIGRATE DOTNET_VERSION)>> "%loc%\core\cmake\FindDotNET.cmake"

rem Patch for FindNodeJS.cmake
echo set(NodeJS_VERSION 20.11.0)> "%loc%\core\cmake\FindNodeJS.cmake"
echo set(NodeJS_INCLUDE_DIRS "%escaped_loc%/runtimes/nodejs/include/node")>> "%loc%\core\cmake\FindNodeJS.cmake"
echo set(NodeJS_LIBRARY "%escaped_loc%/runtimes/nodejs/lib/libnode.lib")>> "%loc%\core\cmake\FindNodeJS.cmake"
echo set(NodeJS_EXECUTABLE "%escaped_loc%/runtimes/nodejs/node.exe")>> "%loc%\core\cmake\FindNodeJS.cmake"
echo set(NodeJS_LIBRARY_NAME_PATH "%escaped_loc%/runtimes/nodejs/lib/libnode.dll")>> "%loc%\core\cmake\FindNodeJS.cmake"
echo set(NodeJS_LIBRARY_NAME "libnode.dll")>> "%loc%\core\cmake\FindNodeJS.cmake"
echo include(FindPackageHandleStandardArgs)>> "%loc%\core\cmake\FindNodeJS.cmake"
echo FIND_PACKAGE_HANDLE_STANDARD_ARGS(NodeJS REQUIRED_VARS NodeJS_INCLUDE_DIRS NodeJS_LIBRARY NodeJS_EXECUTABLE VERSION_VAR NodeJS_VERSION)>> "%loc%\core\cmake\FindNodeJS.cmake"
echo mark_as_advanced(NodeJS_VERSION NodeJS_INCLUDE_DIRS NodeJS_LIBRARY NodeJS_EXECUTABLE)>> "%loc%\core\cmake\FindNodeJS.cmake"

mkdir "%loc%\core\build"
cd "%loc%\core\build"

rem Build MetaCall
cmake -Wno-dev ^
	-DCMAKE_BUILD_TYPE=RelWithDebInfo ^
	-DOPTION_BUILD_PLUGINS_BACKTRACE=ON ^
	-DOPTION_BUILD_SECURITY=OFF ^
	-DOPTION_FORK_SAFE=OFF ^
	-DOPTION_BUILD_SCRIPTS=OFF ^
	-DOPTION_BUILD_TESTS=OFF ^
	-DOPTION_BUILD_EXAMPLES=OFF ^
	-DOPTION_BUILD_LOADERS_PY=ON ^
	-DOPTION_BUILD_LOADERS_NODE=ON ^
	-DNPM_ROOT="%escaped_loc%/runtimes/nodejs" ^
	-DOPTION_BUILD_LOADERS_CS=OFF ^
	-DOPTION_BUILD_LOADERS_RB=ON ^
	-DOPTION_BUILD_LOADERS_TS=ON ^
	-DOPTION_BUILD_PORTS=ON ^
	-DOPTION_BUILD_PORTS_PY=ON ^
	-DOPTION_BUILD_PORTS_NODE=ON ^
	-DCMAKE_INSTALL_PREFIX="%loc%" ^
	-G "NMake Makefiles" .. || goto :error
cmake --build . --target install || goto :error

echo MetaCall Built Successfully

rem Patch for fixing install phase of py_port (https://gitlab.kitware.com/cmake/cmake/-/issues/25835#note_1502642)
set "PYTHONHOME=%loc%\runtimes\python"
set "PIP_TARGET=%loc%\runtimes\python\Lib\site-packages"
set "PATH=%PATH%;%loc%\runtimes\python;%loc%\runtimes\python\Scripts;%loc%\runtimes\python\Lib\site-packages\bin"

"%loc%\runtimes\python\python.exe" -m pip install "%loc%\core\source\ports\py_port"
if %errorlevel%==1 exit /b 1

rem Delete unnecesary data from tarball directory
cd %loc%
rmdir /S /Q "%loc%\core"
rmdir /S /Q "%loc%\dependencies"
rmdir /S /Q "%loc%\nasm-2.15.05"
rmdir /S /Q "%loc%\runtimes\dotnet\include"
rmdir /S /Q "%loc%\runtimes\python\Lib\test"

rem Patch the C# Loader configuration
echo { }> "%loc%\configurations\cs_loader.json"

rem Make the paths of configurations relative
powershell -ExecutionPolicy Bypass -File "%dest%\config.ps1" -loc "%loc%"
if %errorlevel%==1 exit /b 1

echo Compressing the Tarball
cd %dest%
cmake -E tar "cf" "%dest%\metacall-tarball-win-x64.zip" --format=zip "%loc%" "%dest%\metacall.bat"

echo Tarball Compressed Successfully
exit 0

rem Handle error
:error
echo Failed with error #%errorlevel%
exit /b %errorlevel%
