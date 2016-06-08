@echo OFF
SETLOCAL
SET TOOLSDIR=c:\tools
pushd %TOOLSDIR%
PATH=%PATH%;%CD%
CALL uru.bat ls
for /F "tokens=1" %%. in ('uru.bat ls') do @set TAG=%%.
echo TAG=%TAG%
call uru.bat %tag%
call rake spec
popd