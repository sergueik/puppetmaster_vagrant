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
  $random = fqdn_rand(1000,$::uptime_seconds)
  $taskname = regsubst($name, "[$/\\|:, ]", '_', 'G')
  $log_dir = "c:\\temp\\${taskname}"
  $script_path = "${log_dir}\\${script}.ps1"
  $xml_job_definition_path = "${log_dir}\\${script}.${random}.xml"
  $log = "${log_dir}\\${script}.${random}.log"

  exec { "purge ${log_dir}":
    cwd       => 'c:\windows\temp',
    command   => "\$target='${log_dir}' ; remove-item -recurse -force -literalpath \$target",
    logoutput => true,
    onlyif    => "\$target='${log_dir}' ; if (-not (test-path -literalpath \$target)){exit 1}",
    provider  => 'powershell',
    path    => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
  }
  ensure_resource('file', 'c:/temp' , { ensure => directory } )

  ensure_resource('file', $log_dir , {
    ensure => directory,
    require => Exec["purge ${log_dir}"],
  })
  file { "XML task for ${name}":
    ensure             => file,
    path               => $xml_job_definition_path,
    content            => template('custom_command/generic_scheduled_task.erb'),
    source_permissions => ignore,

  }
  # +& schtasks /Delete /F /TN InstallSpoon
  # +& schtasks /Create /TN InstallSpoon /XML $XmlFile
  # +& schtasks /Run /TN InstallSpoon
  $script_script_path = "${log_dir}\\remove_from_environment.ps1"
  $application_path = 'C:\Program Files\Spoon\Cmd'
  # notity {"Prune from environment ${application_path} script": }
  ensure_resource('file', $script_script_path , { 
    ensure             => file,
    path               => $script_script_path,
    content            => template('custom_command/remove_from_environment_ps1.erb'),
  } )

  # https://github.com/counsyl/puppet-windows

  exec { "Prune application path ${application_path} from environment for ${name}":
    command   => "& { ${script_script_path} }",
    logoutput => true,
    path    => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
    require   => File[$script_script_path],
  } ->

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
    command => "powershell -executionpolicy remotesigned -file ${script_path}",
    require  => File[ "${name} launcher script"],
    path    => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  } ->
exec {"$title stopping service: 'name_of_service_is_not_interpolated'":
    command   => "\$service_name='name_of_service_is_not_interpolated' ; get-service | where-object {\$_.Name -match \"\$service_name\"} | foreach-object { stop-service -name \$_.Name}",
    cwd       => 'c:\windows\temp',
    logoutput => true,
    onlyif    => "\$service_name='name_of_service_is_not_interpolated' ; get-service -name \"\$service_name\";", # correctly sets $? 
    path    => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',


}
  notify { "Done ${name}.":}
}
