@echo OFF
@SETLOCAL ENABLEDELAYEDEXPANSION
set FROM_DATE=%1
REM https://stackoverflow.com/questions/4192971/in-powershell-how-do-i-convert-datetime-to-unix-time
set F=%temp%\a.txt
date /t > %F%
for /F "tokens=*" %%. in ('type %F%') do (
REM  powershell.exe -executionpolicy remotesighed -noprofile -command " & { $input = '%%.' ; $date =  Get-Date($input); write-output ($date);} "
REM  powershell.exe -executionpolicy remotesighed -noprofile -command " & { $input = $args[0] ; $date =  Get-Date($input); write-output ($date);} "  "'%%.'"
  powershell.exe -executionpolicy remotesighed -noprofile -command " & { $input = $args[0] ; $date = Get-Date($input); $seconds = [Math]::Floor([decimal](Get-Date($date).AddDays(1) -uformat '%%s')); write-output $seconds} " "'%%.'"
)
del /q %F%