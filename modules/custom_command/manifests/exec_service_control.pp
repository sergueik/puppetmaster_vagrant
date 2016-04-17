# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_service_control(
  $service_name = $title, # e.g. 'aspnet_state'
  $version      = '0.2.0'
)   { 
  # Validate install parameters.
  validate_string($service_name)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $random = fqdn_rand(1000,$::uptime_seconds)
  $task_name = regsubst($title, "[$/\\|:, ]", '_', 'G')
  $log_dir = "c:\\temp\\${task_name}"
  $log = "${log_dir}\\${task_name}.${random}.log"

  exec {"${title} stopping service: '${service_name}'":
    command   => template('custom_command/stop_service_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    onlyif    => template('custom_command/query_is_running_service_ps1.erb'), 
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  } ->

  exec {"${title} deleting service: '${service_name}'":
    command   =>  template('custom_command/delete_service_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    onlyif    => template('custom_command/query_service_ps1.erb'),
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }  
}
