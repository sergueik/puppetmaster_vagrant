@echo OFF
setlocal

REM No environment variable named URU_HOME can be used
REM After set, it is automatically exported.
REM This leads to an error: -- No rubies registered with uru

set SCRIPT_HOME=c:\uru

set URU_INVOKER=batch
pushd %SCRIPT_HOME%
PATH=%PATH%;%CD%
call uru.bat ls

for /F "tokens=1" %%. in ('uru_rt.exe ls') do @set RUBY_TAG=%%.
echo RUBY_TAG=%RUBY_TAG%
uru_rt.exe "%RUBY_TAG%"
uru_rt.exe ruby "%SCRIPT_HOME%\ruby\lib\ruby\gems\2.1.0\gems\rake-11.1.2\bin\rake" spec
popd
