@echo off

rem The format of commands (i.e tests/node/commands.txt) must always contain a new line at the end

set "loc=%~dp0tests"

echo NodeJS test
set "LOADER_SCRIPT_PATH=%loc%\node"
type "%loc%\node\commands.txt" | metacall.bat | findstr "366667" || goto :test_fail

echo Python test
set "LOADER_SCRIPT_PATH=%loc%\python"
metacall.bat pip3 install metacall
type "%loc%\python\commands.txt" | metacall.bat | findstr "Hello World" || goto :test_fail

exit /b 0

:test_fail
echo Test suite failed
exit /b 1
