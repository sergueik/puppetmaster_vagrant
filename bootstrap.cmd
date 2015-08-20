@echo OFF 

REM This updates the settings instead  of forcing to
REM instead of writing a custom ExecutionPolicy parameter into every call
set TARGET_EXECUTIONPOLICY=Unrestricted

PATH=%PATH%;C:\Windows\System32\WindowsPowerShell\v1.0
echo Changing Powershell Script execution Policy 
powershell.exe -ExecutionPolicy %TARGET_EXECUTIONPOLICY% "&{Param([string] $targetExecutionPolicy) Set-ExecutionPolicy $TargetExecutionPolicy; write-output (get-ExecutionPolicy -list )}" -targetExecutionPolicy %TARGET_EXECUTIONPOLICY%

echo Enabling Powershell Remoting 
powershell.exe -ExecutionPolicy %TARGET_EXECUTIONPOLICY% "&{Enable-PSRemoting -Force }"

echo 'Install .NET 4.0'
@powershell -NoProfile -File "c:\vagrant\install_net4.ps1"

echo 'Install Chocolatey'
@powershell -NoProfile -File "c:\vagrant\install_chocolatey.ps1"

goto :EOF
