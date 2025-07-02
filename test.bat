@echo off

rem The format of commands (i.e tests/node/commands.txt) must always contain a new line at the end

set "runtimes=%~dp0metacall\runtimes"
set "loc=%~dp0tests"

echo Package Manager Test
call metacall npm
call metacall pip

rem TODO: https://github.com/metacall/distributable-windows/issues/31
rem call metacall gem

echo NodeJS Tests
set "LOADER_SCRIPT_PATH=%loc%\node"

echo Npm Test
call metacall npm install is-number
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo Node Port Test
type "%loc%\node\commands.txt" | metacall ^> out.txt
if %errorlevel%==1 goto :test_fail
findstr "366667" out.txt || goto :test_fail_print
type out.txt
echo Successfull!!

echo Python Tests
set "LOADER_SCRIPT_PATH=%loc%\python"

echo Pip Test
call metacall pip install PyYAML
if %errorlevel%==1 goto :test_fail
echo Successfull!!

echo Python Port Test
call metacall pip install metacall
type "%loc%\python\commands.txt" | metacall ^> out.txt
if %errorlevel%==1 goto :test_fail
findstr "Hello World" out.txt || goto :test_fail_print
type out.txt
echo Successfull!!

echo Ruby Tests
set "LOADER_SCRIPT_PATH=%loc%\ruby"

rem TODO: https://github.com/metacall/distributable-windows/issues/31
rem echo Ruby gem Test
rem call metacall gem install metacall
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby bundle Test
rem call metacall bundle --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby bundler Test
rem call metacall bundler --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby erb Test
rem call metacall erb --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby irb Test
rem call metacall irb --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby racc Test
rem call metacall racc --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby rake Test
rem call metacall rake --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby rbs Test
rem call metacall rbs --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby rdbg Test
rem call metacall rdbg --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby rdoc Test
rem call metacall rdoc --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby ri Test
rem call metacall ri --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem echo Ruby typeprof Test
rem call metacall typeprof --version
rem if %errorlevel%==1 goto :test_fail
rem echo Successfull!!

rem TODO: Ruby Test
rem TODO: Ruby Port Test

echo Tests Executables
set "LOADER_SCRIPT_PATH="

echo NodeJS Executable Test
"%runtimes%\nodejs\npm.cmd" install --prefix="%loc%\node" metacall
"%runtimes%\nodejs\node.exe" "%loc%\node\test.js"
if %errorlevel%==1 goto :test_fail

echo Python Executable Test
"%runtimes%\python\python.exe" -m pip install metacall
"%runtimes%\python\python.exe" "%loc%\python\test.py"
if %errorlevel%==1 goto :test_fail

rem TODO: Ruby Executable Test

exit /b 0

:test_fail
echo Test Suite Failed!!
exit /b 1

:test_fail_print
type out.txt
echo Test Suite Failed!!
del out.txt
exit /b 1
