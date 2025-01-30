@echo off

rem The format of commands (i.e tests/node/commands.txt) must always contain a new line at the end

set "loc=%~dp0tests"

echo Package Manager Test
setlocal
call metacall npm install is-number
call metacall npm
call metacall pip
endlocal

echo NodeJS tests
set "LOADER_SCRIPT_PATH=%loc%\node"

echo Npm Test
setlocal
call metacall npm install is-number ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo Node metacall test
setlocal
type "%loc%\node\commands.txt" | metacall ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
findstr "366667" out.txt || goto :test_fail 
echo Successfull!!

echo Python tests
set "LOADER_SCRIPT_PATH=%loc%\python"
set "PYTHONHOME=%~dp0metacall\runtimes\python"
set "PIP_TARGET=%~dp0metacall\runtimes\python\Lib\site-packages"
set "PATH=%~dp0metacall\runtimes\python;%~dp0metacall\runtimes\python\Scripts;%~dp0metacall\runtimes\python\Lib\site-packages\bin"

echo Pip Test
setlocal
call metacall pip install PyYAML ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo Python metacall test
setlocal
type "%loc%\python\commands.txt" | metacall ^> out.txt 
if %errorlevel%==1 goto :test_fail
endlocal
findstr "Hello World" out.txt || goto :test_fail 
echo Successfull!!

echo Ruby tests
set "LOADER_SCRIPT_PATH=%loc%\ruby"

echo Gem test
setlocal
call metacall gem install metacall ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo bundle test
setlocal
call metacall bundle --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo bundler test
setlocal
call metacall bundler --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo erb test
setlocal
call metacall erb --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo irb test
setlocal
call metacall irb --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo racc test
setlocal
call metacall racc --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo rake test
setlocal
call metacall rake --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo rbs test
setlocal
call metacall rbs --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo rdbg test
setlocal
call metacall rdbg --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo rdoc test
setlocal
call metacall rdoc --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo ri test
setlocal
call metacall ri --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

echo typeprof test
setlocal
call metacall typeprof --version ^> out.txt
if %errorlevel%==1 goto :test_fail
endlocal
echo Successfull!!

DEL out.txt
exit /b 0

:test_fail
echo Test Suite Failed!!
type out.txt
DEL out.txt
exit /b 1
