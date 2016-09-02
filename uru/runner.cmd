@echo OFF
SETLOCAL
SET TOOLSPATH=c:\uru
SET RUBYPATH=%TOOLSPATH%\ruby
set URU_INVOKER=batch
pushd %TOOLSPATH%
PATH=%PATH%;%CD%
CALL uru.bat ls
for /F "tokens=1" %%. in ('uru_rt.exe ls') do @set TAG=%%.
echo TAG=%TAG%
uru_rt.exe "%TAG%"
uru_rt.exe ruby "%RUBYPATH%\lib\ruby\gems\2.1.0\gems\rake-11.1.2\bin\rake" spec
popd