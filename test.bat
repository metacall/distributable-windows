@echo off

rem The format of commands (i.e tests/node/commands) must always contain a new line at the end

set "loc=%~dp0tests"

echo NodeJS test
set "LOADER_SCRIPT_PATH=%loc%\node"
type "%loc%\node\commands" | metacall | findstr "366667" || goto :test_fail

echo Python test
set "LOADER_SCRIPT_PATH=%loc%\python"
type "%loc%\python\commands" | metacall | findstr "Hello World" || goto :test_fail

exit /b 0

:test_fail
echo Test suite failed
exit /b 1
