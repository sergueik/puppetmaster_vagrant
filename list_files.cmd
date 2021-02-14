@echo OFF
call :TEST1
call :TEST2
goto :EOF

:TEST1
set FILES=
for /F "tokens=*" %%. in ('dir /b "*.cmd"') do (
call set "FILE=%%."
call set "FILE=%%FILE:.cmd=%%
call set "FILES=%%FILES%% %%FILE%%"
)
call set "FILES=%%FILES:~1%%"
echo %FILES%
goto :EOF
:TEST2

set /a "CNT=0"
for %%. in ("*.cmd") do (
  call set /a "CNT+=1"
  call set "ITEM%%CNT%%=%%~n."
)
set ITEM

goto :EOF
