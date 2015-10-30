# -*- mode: puppet -*-
# vi: set ft=puppet :
define custom_command::exec_shortcut  (
  $shortcut_basename = $title,
  $shortcut_pathname = '$HOME\Desktop',
  $shortcut_targetpath = undef,
  $shortcut_target_arguments = undef,
  $shortcut_run_as_admin = undef,
  $version      = '0.1.0'
)   {
  # Validate install parameters.
  validate_string($shortcut_basename )
  validate_string($shortcut_pathname )
  validate_string($shortcut_targetpath )
  validate_string($shortcut_target_arguments )
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')


# http://stackoverflow.com/questions/28997799/how-to-create-a-run-as-administrator-shortcut-using-powershell
# http://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell
# NOTE: https://forge.puppetlabs.com/puppetlabs/win_desktop_shortcut is not doing what it says it is doing.
  $random = fqdn_rand(1000,$::uptime_seconds)
  $task_name = regsubst($title, "[$/\\|:, ]", '_', 'G')
  $log_dir = "c:\\temp\\${task_name}"
  $log = "${log_dir}\\${task_name}.${random}.log"
  if ( $shortcut_pathname == ''){
    $shortcut_pathname = '$HOME\Desktop'
  }
  $path_check = "exit [int]( -not (test-path -path ('{0}\\{1}.lnk' -f ${shortcut_pathname}, ${shortcut_basename})))"
  exec { "${title} performing post-run check for '${shortcut_basename}(admin).lnk'":
    command    => "exit [int]( -not (test-path -path ('{0}\\{1}(admin).lnk' -f '${shortcut_pathname}', '${shortcut_basename}')))",
    cwd       => 'c:\windows\temp',
    logoutput => true,
    provider  => 'powershell',
  }  ->
  exec {"${title} creating basic shortcut: '${service_name}'":
    command   =>  template('custom_command/create_simple_shortcut_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    unless    => "exit [int]( -not (test-path -path ('{0}\\{1}(admin).lnk' -f '${shortcut_pathname}', '${shortcut_basename}')))",
    provider  => 'powershell',
  } ->
  # cannot create shortcut with the same name
  exec {"${title} creating admin shortcut: '${shortcut_basename}' for '${shortcut_target}'":
    command   => template('custom_command/create_admin_shortcut_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    unless    => $path_check,

    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  } ->
 notify { 'Done': }
}
