@echo off

REM port-create step required for
REM Windows vagrant boxes  hosted on http://aka.ms/
REM links are also searchable from http://www.vagrantbox.es/ 
REM This has to be done interactively on the guest.

REM Origin: https://gist.github.com/andreptb/57e388df5e881937e62a
REM "Setting modern.ie vagrant boxes to be controlled by Vagrant"


REM %SYSTEMROOT%\System32\winrm.cmd
call winrm.cmd quickconfig -q
call winrm.cmd set winrm/config/winrs @{MaxMemoryPerShellMB="300"}
call winrm.cmd set winrm/config @{MaxTimeoutms="1800000"}
call winrm.cmd set winrm/config/client/auth @{Basic="true"}
call winrm.cmd set winrm/config/service @{AllowUnencrypted="true"}
call winrm.cmd set winrm/config/service/auth @{Basic="true"}
REM Alternative commands:

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value True; Set-Item WSMan:\localhost\Service\Auth\Basic -Value True"
sc.exe triggerinfo winrm start/networkon stop/networkoff
goto :EOF

REM for Windows 10 
REM uninitialized constant WinRM::FS::Core::CommandExecutor::WinRMUploadError
REM see https://github.com/mitchellh/vagrant/issues/6060
REM need to update the winrmm-fs vagrant plugin to version 0.2.3 or later
