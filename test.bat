@echo off

rem The format of commands (i.e tests/node/commands.txt) must always contain a new line at the end

set "loc=%~dp0tests"

echo Package Manager Test
call metacall npm install is-number
call metacall npm
call metacall pip

echo NodeJS tests
set "LOADER_SCRIPT_PATH=%loc%\node"

echo Npm Test
call metacall npm install is-number ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo Node metacall test
type "%loc%\node\commands.txt" | metacall.bat ^> out.txt
if %errorlevel%==1 goto :test_fail
findstr "366667" out.txt || goto :test_fail 
echo Successfull!!

echo Python tests
set "LOADER_SCRIPT_PATH=%loc%\python"
set "PYTHONHOME=%~dp0metacall\runtimes\python"
set "PIP_TARGET=%~dp0metacall\runtimes\python\Lib\site-packages"
set "PATH=%~dp0metacall\runtimes\python;%~dp0metacall\runtimes\python\Scripts;%~dp0metacall\runtimes\python\Lib\site-packages\bin"

echo Pip Test
call metacall pip install PyYAML ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo Python metacall test
type "%loc%\python\commands.txt" | metacall.bat ^> out.txt 
if %errorlevel%==1 goto :test_fail
findstr "Hello World" out.txt || goto :test_fail 
echo Successfull!!

echo Ruby tests
set "LOADER_SCRIPT_PATH=%loc%\ruby"

echo Gem test
call metacall gem install metacall ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo bundle test
call metacall bundle --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo bundler test
call metacall bundler --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo erb test
call metacall erb --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo irb test
call metacall irb --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo racc test
call metacall racc --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo rake test
call metacall rake --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo rbs test
call metacall rbs --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo rdbg test
call metacall rdbg --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo rdoc test
call metacall rdoc --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo ri test
call metacall ri --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo typeprof test
call metacall typeprof --version ^> out.txt
if %errorlevel%==1 goto :test_fail
echo Successfull!!

DEL out.txt
exit /b 0

:test_fail
echo Test Suite Failed!!
type out.txt
DEL out.txt
exit /b 1
