@echo OFF
@SETLOCAL ENABLEDELAYEDEXPANSION
set FROM_DATE=%~1
REM https://stackoverflow.com/questions/4192971/in-powershell-how-do-i-convert-datetime-to-unix-time
set F1=%temp%\a.txt
if "%FROM_DATE%"=="" GOTO :NOARG
echo FROM_DATE=%FROM_DATE%
powershell.exe -executionpolicy remotesighed -noprofile -command " & { $input = $args[0] ; $date = Get-Date($input); $seconds = [Math]::Floor([decimal](Get-Date($date).AddDays(1) -uformat '%%s')); write-output $seconds} " "'%From_date%'" > %F1%
GOTO :RESULT
:NOARG
set F2=%temp%\a.txt
date /t > %F2%
for /F "tokens=*" %%. in ('type %F2%') do (
REM inline
REM  powershell.exe -executionpolicy remotesighed -noprofile -command " & { $input = '%%.' ; $date =  Get-Date($input); write-output ($date);} "
REM argument check
REM  powershell.exe -executionpolicy remotesighed -noprofile -command " & { $input = $args[0] ; $date =  Get-Date($input); write-output ($date);} "  "'%%.'"
powershell.exe -executionpolicy remotesighed -noprofile -command " & { $input = $args[0] ; $date = Get-Date($input); $seconds = [Math]::Floor([decimal](Get-Date($date).AddDays(1) -uformat '%%s')); write-output $seconds} " "'%%.'" > %F1%
)
rem del /q %F2%
:RESULT

REM echo F1=%F1%

for /F "tokens=*" %%. in ('type "%F1%"') do set RESULT=%%.
rem del /q %F1%
echo %RESULT%
GOTO :EOF
