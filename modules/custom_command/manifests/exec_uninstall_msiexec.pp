# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_uninstall_msiexec_command(
  $application_name = $title, # e.g. 'Puppet agent (64-bit)'
  $version      = '0.1.0'
)   { 
  # Validate install parameters.
  validate_string($service_name)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $random = fqdn_rand(1000,$::uptime_seconds)
  $task_name = regsubst($title, "[$/\\|:, ]", '_', 'G')
  $log_dir = "c:\\temp\\${task_name}"
  $log = "${log_dir}\\${task_name}.${random}.log"

  exec {"${title} Uninstalling application: '${application_name}'":
    command   => template('custom_command/uninstall_msiexec_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    # declare always
    onlyif    => template('custom_command/installed_products_ps1.erb'), 
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  } ->
  # run again 
  exec {"${title} Uninstalling application (2nd time): '${application_name}'":
    command   => template('custom_command/uninstall_msiexec_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    # declare always
    onlyif    => template('custom_command/installed_products_ps1.erb'), 
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }
}
