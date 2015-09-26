# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'windows7' {
  include wait_for
  $_name = 'test application'
  # $my_file_arg = 'c:/temp/cleanup.cmd'
  # include 'mywebsite'
  # TODO: expand the zip
  $_name_alias = regsubst($_name, ' ', '_')

  exec {"Removing old Autorun installer command for ${_name}":
    command => "C:/Windows/System32/reg.exe DELETE HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run /v ${_name_alias} /f",
    returns => [0,1],
  } ->
  notify {"Creating Autorun installer command for ${_name}":} ->

  # write the autorun registry keys
  registry::value { "Autorun command for installing ${_name}":
    # TODO write to HKCU, RunOnce
    key   => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
    value => $_name_alias,
    type  => string,
    data  => 'C:\Windows\system32\cmd.exe /c echo foobar 123> C:\TEMP\a.txt',
  } ->
  reboot { "after ${_name}":
    subscribe => Registry::Value["Autorun command for installing ${_name}"],
  } ->
    # registry_value {"HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\${_name_alias}":
      # TODO: support random value to ensure it is written every time
      # data   => 'C:\Windows\system32\cmd.exe /c echo 123> C:\TEMP\a.txt',
      # ensure => present,
      # notify => Reboot["after ${_name}"],
    # } ->

  notify { "wait for install of ${_name} to be finished": 
    subscribe => Registry::Value["Autorun command for installing ${_name}"],
   } ->

  wait_for { "wait for install of ${_name} to be finished":
     query             => 'cmd.exe /c type c:\temp\a.txt',
     regex             => 'foobar',
     exit_code         => 0,
     polling_frequency => 60,
     max_retries       => 10,
  } -> 


  # Cannot use either registry_value resource or Registry::Value class:
  #  Munging failed for value "..." - 
  exec {"Removing Autorun installer command for ${_name}":
    command  => "C:/Windows/System32/reg.exe DELETE HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Run /v ${_name_alias} /f",
    subscribe => Wait_for["wait for install of ${_name} to be finished"],
  }
}
