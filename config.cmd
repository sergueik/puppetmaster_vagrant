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
REM further tweaks:
REM for Windows 10 
REM uninitialized constant WinRM::FS::Core::CommandExecutor::WinRMUploadError
REM see https://github.com/mitchellh/vagrant/issues/6060
REM need to update the winrmm-fs vagrant plugin to version 0.2.3 or later

REM Finally to unblock creation of local resources on the guest 
REM Directory of c:\vagrant-chef\465fb3b29b23535e31953e1920ccd88e
REM
REM 01/01/2016  11:30 AM    ^<DIR^>          .
REM 01/01/2016  11:30 AM    ^<DIR^>          ..
REM 01/01/2016  11:30 AM    ^<SYMLINKD^>     cookbooks [\\vboxsrv\v-csc-e48252ec5]
REM apply configurarion described in https://github.com/mwrock/boxstarter/blob/master/Boxstarter.WinConfig
REM and https://gist.github.com/novascreen/10d5d891fc04ecfd758b
REM It can be done remotely through Vagrant shell provisioner, which will work.
REM Without this change, chef-solo and Puppet will fail with
REM Shared folders that Chef requires are missing on the virtual machine.
