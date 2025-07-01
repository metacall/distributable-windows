@echo off

rem The format of commands (i.e tests/node/commands.txt) must always contain a new line at the end

set "loc=%~dp0tests"

echo Package Manager Test
call metacall npm
call metacall pip
call metacall gem

echo NodeJS tests
set "LOADER_SCRIPT_PATH=%loc%\node"

echo Npm Test
call metacall npm install is-number
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo Node metacall test
type "%loc%\node\commands.txt" | metacall ^> out.txt
if %errorlevel%==1 goto :test_fail
findstr "366667" out.txt || goto :test_fail_print
type out.txt
echo Successfull!!

echo Python tests
set "LOADER_SCRIPT_PATH=%loc%\python"

echo Pip Test
call metacall pip install PyYAML
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo Python metacall test
type "%loc%\python\commands.txt" | metacall ^> out.txt
if %errorlevel%==1 goto :test_fail
findstr "Hello World" out.txt || goto :test_fail_print
type out.txt
echo Successfull!!

echo Ruby tests
set "LOADER_SCRIPT_PATH=%loc%\ruby"

rem TODO: https://github.com/metacall/distributable-windows/issues/31
rem echo Gem test
rem call metacall gem install metacall
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo bundle test
rem call metacall bundle --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo bundler test
rem call metacall bundler --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo erb test
rem call metacall erb --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo irb test
rem call metacall irb --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo racc test
rem call metacall racc --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo rake test
rem call metacall rake --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo rbs test
rem call metacall rbs --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo rdbg test
rem call metacall rdbg --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo rdoc test
rem call metacall rdoc --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo ri test
rem call metacall ri --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo typeprof test
rem call metacall typeprof --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem TODO: Tests of executables

exit /b 0

:test_fail
echo Test Suite Failed!!
exit /b 1

:test_fail_print
type out.txt
echo Test Suite Failed!!
del out.txt
exit /b 1
