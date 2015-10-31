# -*- mode: puppet -*-
# vi: set ft=puppet :
define custom_command::exec_shortcut  (
  $link_basename = $title,
  $link_pathname = '$HOME\Desktop',
  $target_path   = undef,
  $target_args   = undef,
  $run_as_admin  = undef,
  $debug         = false,
  $version       = '0.2.0'
)   {
  # Validate install parameters
  validate_string($link_basename )
  validate_string($link_pathname )
  validate_string($target_path )
  validate_string($target_args )
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $random = fqdn_rand(1000,$::uptime_seconds)
  $task_title_tag = regsubst($title, "[$/\\|:, ]", '_', 'G')
  $log_dir = "c:\\temp\\${task_title_tag}"
  $log = "${log_dir}\\${task_title_tag}.${random}.log"
  if ( $link_pathname == ''){
    $link_pathname = '$HOME\Desktop'
  }
  $expression = "test-path -path ('{0}\\{1}.lnk' -f \"${link_pathname}\", '${link_basename}')"
  # convert Powershell (True, False) to shess exit codes (0,1) 
  $path_check = "exit [int]( -not (${expression}))"
  if ($run_as_admin ) {
    $template = 'create_admin_shortcut_ps1.erb'
  } else {
    $template = 'create_simple_shortcut_ps1.erb'
  }
  exec { "${task_title_tag}_create_shortcut":
    command   => template("custom_command/${template}"),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    unless    => $path_check,
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  } 
  if $debug {
    exec { "${tasl_title_tag}_confirm_shortcut_created":
      command    => $path_check,
      cwd       => 'c:\windows\temp',
      logoutput => true,
      provider  => 'powershell',
      require   => Exec [ "${task_title_tag}_create_shortcut"],
      command   => template("custom_command/${template}"),
      cwd       => 'c:\windows\temp',
      logoutput => true,
      path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
      provider  => 'powershell',
    } 
  } 
}
