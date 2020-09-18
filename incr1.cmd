@echo OFF
REM https://qna.habr.com/q/849023
setlocal enabledelayedexpansion
set INITIAL_COUNTER=1000
if not exist example!INITIAL_COUNTER!.txt copy NUL example!INITIAL_COUNTER!.txt > NUL
REM only works until overlow: 
REM fails to sort the example10000.txt after example9999.txt
for /F %%. in ('DIR /b example*.txt ^| sort /R') do call :INCREMENT %%. && goto EOF
:INCREMENT
set COUNTER=%1
set COUNTER=!COUNTER:example=!
set COUNTER=!COUNTER:.txt=!
set /A COUNTER=!COUNTER! + 1
copy NUL example!COUNTER!.txt > NUL
echo !COUNTER!
exit /b 0
goto :EOF
:EOF
