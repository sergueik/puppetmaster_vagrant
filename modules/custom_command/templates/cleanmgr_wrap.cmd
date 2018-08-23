@echo off
REM // based on http://forum.oszone.net/thread-326226.html
set REGKEY=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches

for %%. in  (
  "Recycle Bin"
  "Temporary Files"
  "Update Cleanup"
  "Active Setup Temp Folders"
  "BranchCache"
  "D3D Shader Cache"
  "Downloaded Program Files"
  "Internet Cache Files"
  "Old ChkDsk Files"
  "Previous Installations"
  "Recycle Bin""RetailDemo Offline Content"
  "Service Pack Cleanup"
  "Setup Log Files"
  "System error memory dump files"
  "System error minidump files"
  "Temporary Files"
  "Temporary Setup Files"
  "Thumbnail Cache"
  "Upgrade Discarded Files"
  "User file versions"
  "Windows Defender"
  "Windows Error Reporting Files"
  "Windows ESD installation files"
  "Windows Upgrade Log Files"
)  do call :DO %%.
CALL rem reg.exe delete "%REGKEY%\Compress old files" /f 2>NUL
CALL cleanmgr.exe /sagerun:1
goto :EOF
:DO
echo.
set REGVALUE=%*
set REGVALUE=%REGVALUE:"=%
echo call reg.exe add "%REGKEY%\%REGVALUE%" /v StateFlags0001 /t REG_DWORD /d 2 /f 1^>NUL 2^>NUL
REM see also http://www.ultimeta.ru/files/cryptopro_trusted_sites.cmd
REM call reg.exe add "HKCU\Software\Crypto Pro\CAdESplugin" /v TrustedSites /t REG_MULTI_SZ /s " " /d "!TRUSTED_SITES!" /f
goto :EOF
