@echo OFF

@SETLOCAL ENABLEDELAYEDEXPANSION
set START_TAG=%~1
set END_TAG=%~2

if "%START_TAG%"==""  goto :NOARG
if "%END_TAG%"==""  goto :NOARG

if %START_TAG% GEQ %END_TAG% goto :BADARG

set STEP=1
for /L %%. in (%START_TAG%,%STEP%,%END_TAG%) do (
  call set "TAG=%%."
  echo TAG=!TAG!
  echo https://www.google.com/?q=!TAG!
)
goto :EOF
:NOARG
echo Missing range argument(s)
goto :EOF
:BADARG
echo Bad range
goto :EOF

