@echo OFF
SETLOCAL ENABLEDELAYEDEXPANSION
REM https://stackoverflow.com/questions/4192971/in-powershell-how-do-i-convert-datetime-to-unix-time

set F=%temp%\a.txt

set ARGC=0
for %%. in (%*) do Set /A ARGC+=1
IF "%ARGC%"=="0" goto :NOARG
IF "%ARGC%"=="1" goto :SINGLEARG
set FROM_DATE=%1 %2
GOTO :START
:SINGLEARG
set FROM_DATE=%~1
GOTO :START
:NOARG
date /t > %F%
for /F "tokens=*" %%. in ('type %F%') do set FROM_DATE=%%.
del /q %F%
set FROM_DATE=!FROM_DATE:~0,14!
:START
echo FROM_DATE="!FROM_DATE!"
REM powershell.exe -executionpolicy remotesighed -noprofile -command " & { $input = $args[0] ; $date =  Get-Date($input); write-output ($date);} " "'!FROM_DATE!'"
powershell.exe -executionpolicy remotesighed -noprofile -command " & { $input = $args[0] ; $date = Get-Date($input); $seconds = [Math]::Floor([decimal](Get-Date($date).AddDays(1) -uformat '%%s')); write-output $seconds} " "'!FROM_DATE!'" > %F%
for /F "tokens=*" %%. in ('type "%F%"') do set RESULT=%%.
REM type %F%
del /q %F%
echo %RESULT%
GOTO :EOF
				
