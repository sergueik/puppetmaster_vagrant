@echo OFF 
set VERBOSE=%1
if NOT "%VERBOSE%" equ "" set VERBOSE=true
REM set VERBOSE=true
set TARGET_EXECUTIONPOLICY=Unrestricted

PATH=%PATH%;C:\Windows\System32\WindowsPowerShell\v1.0

if NOT "%VERBOSE%" equ "true" call :SILENT
if "%VERBOSE%" equ "true" call :VERBOSE
goto :DONE
:SILENT
 
echo Changing Powershell Script execution Policy 
powershell.exe -ExecutionPolicy %TARGET_EXECUTIONPOLICY% "&{Param([string] $new_value) Set-ExecutionPolicy $new_value}" -new_value %TARGET_EXECUTIONPOLICY%
 
echo Enabling Powershell Remoting 
powershell.exe -ExecutionPolicy %TARGET_EXECUTIONPOLICY% "&{Enable-PSRemoting -Force |out-null}"
 
goto :EOF
:VERBOSE
 
echo Changing Powershell Script execution Policy 
powershell.exe -ExecutionPolicy %TARGET_EXECUTIONPOLICY% "&{Param([string] $new_value) Set-ExecutionPolicy $new_value; write-output (get-ExecutionPolicy -list |convertto-json)}" -new_value %TARGET_EXECUTIONPOLICY%
 
echo Enabling Powershell Remoting 
powershell.exe -ExecutionPolicy %TARGET_EXECUTIONPOLICY% "&{Enable-PSRemoting -Force }"
 
goto :EOF
:DONE

echo 'Install .NET 4.0'
@powershell -NoProfile -File "c:\vagrant\install_net4.ps1"

echo 'Install Chocolatey'
@powershell -NoProfile -File "c:\vagrant\install_chocolatey.ps1"

exit 0
