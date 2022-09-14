@echo off

rem The format of commands (i.e tests/node/commands.txt) must always contain a new line at the end

set "loc=%~dp0tests"

echo NodeJS tests
set "LOADER_SCRIPT_PATH=%loc%\node"
echo Npm Test
start /wait metacall.bat npm install metacall ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo Node metacall test
type "%loc%\node\commands.txt" | metacall.bat | findstr "366667" || goto :test_fail
echo Successfull!!

echo Python tests
set "LOADER_SCRIPT_PATH=%loc%\python"
echo Pip Test
start /wait metacall.bat pip install metacall ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo Python metacall test
type "%loc%\python\commands.txt" | call metacall.bat | findstr "Hello World" || goto :test_fail
echo Successfull!!

echo Ruby tests
set "LOADER_SCRIPT_PATH=%loc%\ruby"
echo Gem test
start /wait metacall.bat gem install metacall ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo bundle test
start /wait metacall.bat bundle --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo bundler test
start /wait metacall.bat bundler --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo erb test
start /wait metacall.bat erb --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo irb test
start /wait metacall.bat irb --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo racc test
start /wait metacall.bat racc --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo rake test
start /wait metacall.bat rake --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo rbs test
start /wait metacall.bat rbs --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo rdbg test
start /wait metacall.bat rdbg --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo rdoc test
start /wait metacall.bat rdoc --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo ri test
start /wait metacall.bat ri --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!
echo typeprof test
start /wait metacall.bat typeprof --version ^> out.txt
type out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

DEL out.txt
exit /b 0

:test_fail
echo Test suite failed
DEL out.txt
exit /b 1
