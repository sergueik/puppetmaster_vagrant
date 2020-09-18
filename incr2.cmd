@echo OFF

REM https://qna.habr.com/q/849023


if exist example.txt (
  set /a COUNTER=1
  goto :LOOP
)
copy NUL example.txt > NUL
goto :EOF

:LOOP
if exist example%COUNTER%.txt (
  set /a COUNTER += 1
  goto :LOOP
)
copy NUL example%COUNTER%.txt > NUL
echo %COUNTER%

:EOF
