# -*- mode: puppet -*-
# vi: set ft=puppet :

define exec_path_environment(
  $application_path = $title, # e.g. 'C:\Program Files\Spoon\Cmd'
  $version      = '0.1.0'
)   { 
  # Validate install parameters.
  validate_string($application_path)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $random = fqdn_rand(1000,$::uptime_seconds)
  $task_name = regsubst($title, "[\$/\\\\|:, ]", '_', 'G')
  $log_dir = "c:\\windows\\temp\\${task_name}"
  $log = "${log_dir}\\${task_name}.${random}.log"
  $temp_script = "${log_dir}\\remove_from_environment.ps1"

  ensure_resource('file', $log_dir , {
    ensure  => directory,
    require => Exec["purge ${log_dir}"],
  }) 

  exec { "purge ${log_dir}":
    command   => "\$target='${log_dir}' ; remove-item -recurse -force -literalpath \$target",
    cwd       => 'c:\windows\temp',
    logoutput => true,
    onlyif    => "\$target='${log_dir}' ; if (-not (test-path -literalpath \$target)){exit 1}",
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  } 



  ensure_resource('file', $temp_script, { 
    content => template('exec_path_environment/remove_from_environment_ps1.erb'),
    ensure  => file,
    path    => $temp_script,
    # require => File[$log_dir],
  } )

  exec { "${title} prune application path ${application_path} from environment":
    command   => "& { ${temp_script} }",
    logoutput => true,
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
    require   => File[$temp_script],
  }
}
