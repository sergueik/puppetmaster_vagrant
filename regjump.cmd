@echo OFF

REM based on http://www.cyberforum.ru/powershell/thread2562174.html
REM conversion of Powershell snippet which itself is a JS conversion suggested
REM to cmd
REM Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit' -Name Lastkey -Value 'Computer\HKEY_CURRENT_USER\Software'
REM Start-Process regedit.exe

REM reg.exe add HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit /v LastKey /d Computer\HKEY_LOCAL_MACHINE\HARDWARE\ACPI /f
reg.exe add HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit /v LastKey /d Computer\HKEY_CURRENT_USER\Software /f
start regedit.exe

