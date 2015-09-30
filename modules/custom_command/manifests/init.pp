# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command(
  $wait        = true,
  $command     = 'notepad.exe',
  $script      = 'manage_scheduled_task',
  $version     = '0.2.0'
)   { 
  # Validate install parameters.
  validate_bool($wait)
  validate_string($script)
  validate_string($command)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $script_path = "c:\\temp\\${script}.ps1"
  $random = fqdn_rand(1000,$::uptime_seconds)
  $xml_job_definition_path = "c:\\temp\\${script}.${random}.xml"
  $taskname = regsubst($name, " +", '_', 'G') # 'Launch_selenium_grid_node'

  file { "XML task for ${name}":
    ensure             => file,
    path               => $xml_job_definition_path,
    content            => template('custom_command/generic_scheduled_task.erb'),
    source_permissions => ignore,

  }
  # +& schtasks /Delete /F /TN InstallSpoon
  # +& schtasks /Create /TN InstallSpoon /XML $XmlFile
  # +& schtasks /Run /TN InstallSpoon
  $log = "c:\\temp\\${script}.${random}.log"
  notify { "Write powershell launcher script for ${name}":} ->
  file { "${name} launcher log":
    name               => "${script}${random}.log",
    path               => $log,
    ensure             => absent,
    source_permissions => ignore,
  } -> 
 
  file { "${name} launcher script":
    ensure             => file,
    path               => $script_path,
    content            => template('custom_command/manage_scheduled_task.erb'),
    source_permissions => ignore,
  } -> 

  exec { "Execute script that will create and run scheduled task ${name}": 
    path    => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    command => "powershell -executionpolicy remotesigned -file ${script_path}",
    require  => File[ "${name} launcher script"],
  } ->

  notify { "Done ${name}.":}
}
