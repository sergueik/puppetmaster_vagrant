@echo OFF
REM https://stackoverflow.com/questions/4192971/in-powershell-how-do-i-convert-datetime-to-unix-time

set F=%temp%\a.txt

set FROM_DATE=%~1
if "%FROM_DATE%"=="" GOTO :NOARG
GOTO :START
:NOARG
date /t > %F%
for /F "tokens=*" %%. in ('type %F%') do call set "FROM_DATE=%%."
del /q %F%
call set "FROM_DATE=%%FROM_DATE:~0,14%%"
:START
echo FROM_DATE="%FROM_DATE%"
REM powershell.exe -executionpolicy remotesigned -noprofile -command " & { $input = $args[0] ; $date =  Get-Date($input); write-output ($date);} " "'!FROM_DATE!'"
REM powershell.exe -executionpolicy remotesigned -noprofile -command " & { $input = $args[0] ; $date = Get-Date($input); $seconds = [Math]::Floor([decimal](Get-Date($date) -uformat '%%s')); write-output $seconds} " "'%FROM_DATE%'" > %F%
powershell.exe -executionpolicy remotesigned -noprofile -command " & { $input = $args[0] ; $seconds = ((Get-Date($input)) - (get-date(new-object System.DateTime(1970,1,1)))).TotalSeconds; write-output $seconds} " "'%FROM_DATE%'" > %F%

for /F "tokens=*" %%. in ('type "%F%"') do call set "RESULT=%%."
REM type %F%
del /q %F%
echo %RESULT%
GOTO :EOF
