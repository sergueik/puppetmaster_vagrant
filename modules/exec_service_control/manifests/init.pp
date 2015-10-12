# -*- mode: puppet -*-
# vi: set ft=puppet :

define exec_service_control(
  $service_name = $title, # e.g. 'aspnet_state'
  $version      = '0.1.0'
)   { 
  # Validate install parameters.
  validate_string($service_name)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $random = fqdn_rand(1000,$::uptime_seconds)
  $task_name = regsubst($title, "[$/\\|:, ]", '_', 'G')
  $log_dir = "c:\\temp\\${task_name}"
  $log = "${log_dir}\\${task_name}.${random}.log"

  exec {"${title} stopping service: '${service_name}'":
    command   => template('exec_service_control/stop_service_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    onlyif    => template("exec_service_control/query_service_ps1.erb"), 
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  } ->

  exec {"${title} deleting service: '${service_name}'":
    command   =>  template('exec_service_control/delete_service_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    onlyif    => template("exec_service_control/query_service_ps1.erb"),
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }  
}
