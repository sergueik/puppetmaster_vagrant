# -*- mode: puppet -*-
# vi: set ft=puppet :

class custom_command(
  $enable  = $custom_command::params::enable,
  $config  = $custom_command::params::config,
  $title,
  $version = $custom_command::params::version
)  inherits custom_command::params { 
  # Validate install parameters.
  validate_bool($enable)
  validate_string($config)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $script_name = 'manage_scheduled_task' 
  $script_path = "c:\\temp\\${script_name}.ps1"
  $spoon_command = 'run base,spoonbrew/selenium-grid'
  $run_command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' ${spoon_command}"
  $taskname = 'Launch_selenium_grid_node'
  # Write powershell script
  # notify { 'Write powershell script':} ->
 
  file { 'launcher.ps1':
    ensure             => file,
    name               => $script_name,
    path               => $script_path,
    content            => template("custom_command/${script_name}.erb"),
    source_permissions => ignore,
 #   notify             => Exec["Execute script that will create and run scheduled task ${title}"],
  } -> 

  # notify { 'Execute script that will create and run scheduled task':} ->
  # Execute script that will create and run scheduled task
  exec { "Execute script that will create and run scheduled task ${title}": 
    path    => 'C:/Windows/System32/WindowsPowerShell/v1.0',
    command => "powershell -executionpolicy remotesigned -file ${script_path}",
    require  => File['launcher.ps1'],
#    provider => powershell,
#    refreshonly => true
  } ->

  notify { "Done ${title}.":}
  # Execute script that will create and run scheduled task
}
