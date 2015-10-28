# -*- mode: puppet -*-
# vi: set ft=puppet :
# http://stackoverflow.com/questions/28997799/how-to-create-a-run-as-administrator-shortcut-using-powershell
# http://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell
define custom_command::exechortcut(
  $shortcut_basename = $title,
  $shortcut_pathname = undef,
  $shortcut_targetpath = undef,
  $shortcut_target_arguments = undef,
  $shortcut_run_as_admin = undef,
  $version      = '0.2.0'
)   { 
  # Validate install parameters.
  validate_string($shortcut_basename )
  validate_string($shortcut_pathname )
  validate_string($shortcut_targetpath )
  validate_string($shortcut_target_arguments )
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $random = fqdn_rand(1000,$::uptime_seconds)
  $task_name = regsubst($title, "[$/\\|:, ]", '_', 'G')
  $log_dir = "c:\\temp\\${task_name}"
  $log = "${log_dir}\\${task_name}.${random}.log"

  exec {"${title} stopping service: '${service_name}'":
    command   => template('custom_command/create_admin_shortcut_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    unless    => "test-item -path ('{0}\{1}.lnk', ${shortcut_pathname}, ${shortcut_basename}  )", 

    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  } ->

  exec {"${title} deleting service: '${service_name}'":
    command   =>  template('custom_command/create_basic_shortcut_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    unless    => "test-item -path ('{0}\{1}.lnk', ${shortcut_pathname}, ${shortcut_basename}  )", 
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }  
}
