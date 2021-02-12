@echo Off
REM cls
REM based on http://forum.oszone.net/thread-347942.html
REM  the next line contains invisible space on the right hand side
set ACC= 
set BADACC=
FOR /L  %%. in (1,1,5) do (
  REM this will not work as intended
  if "%BADACC%"=="" ( set BADACC=%%. ) else ( 
    call set "BADACC=%%BADACC%% %%."
  )
  rem This will have accumulate but will need one leading space to be stripped
  call set "ACC=%%ACC%% %%."
  set "LOOP=%%."
)
REM in this place 'call' is optional
call set "ACC=%%ACC:~1%%"
set ACC=%ACC:~1%
echo BADACC=%BADACC%
echo ACC=%ACC%
echo LOOP=%LOOP%
goto :EOF
