
@echo OFF
REM https://stackoverflow.com/questions/4192971/in-powershell-how-do-i-convert-datetime-to-unix-time

set F=%temp%\a.txt
date /t > %F%
for /F "tokens=*" %%. in ('type %F%') do (
REM embed argument in the script
REM powershell.exe -executionpolicy remotesigned -noprofile -command " & { $input = '%%.' ; $date =  Get-Date($input); write-output ($date);} "
REM check argument is valid
REM powershell.exe -executionpolicy remotesigned -noprofile -command " & { $input = $args[0] ; $date =  Get-Date($input); write-output ($date);} "  "'%%.'"
call set "FROM_DATE=%%."
powershell.exe -executionpolicy remotesigned -noprofile -command " & { $input = $args[0] ; $date = Get-Date($input); $seconds = [Math]::Floor([decimal](Get-Date($date) -uformat '%%s')); write-output $seconds} " "'%FROM_DATE%'"
powershell.exe -executionpolicy remotesigned -noprofile -command " & { $input = $args[0] ; $seconds = ((Get-Date($input)) - (get-date(new-object System.DateTime(1970,1,1)))).TotalSeconds; write-output $seconds} " "'%FROM_DATE%'"
)
del /q %F%
