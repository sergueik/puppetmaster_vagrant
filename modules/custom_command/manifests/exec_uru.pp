# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_uru(
  $toolspath   = 'c:\tools',
  $version     = '0.2.0'
)   { 
  validate_string($toolspath)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $random = fqdn_rand(1000,$::uptime_seconds)
  $taskname = regsubst($name, "[$/\\|:, ]", '_', 'G')
  $report_dir = "c:\\temp\\${taskname}"
  $script_path = "${report_dir}\\uru_launcher.ps1"
  $report_log = "${log_dir}\\${script}.${random}.log"
   
  exec { "purge ${report_dir}":
    cwd       => 'c:\windows\temp',
    command   => "\$target='${report_dir}' ; remove-item -recurse -force -literalpath \$target",
    logoutput => true,
    onlyif    => "\$target='${report_dir}' ; if (-not (test-path -literalpath \$target)){exit 1}",
    provider  => 'powershell',
    path    => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
  }
  ensure_resource('file', 'c:/temp' , { ensure => directory } )

  ensure_resource('file', $report_dir , {
    ensure => directory,
    require => Exec["purge ${report_dir}"],
  })
  
  # TODO : generate Rakefile, spec and sample serverspec file
 
  file { "${name} launcher script":
    ensure             => file,
    path               => $script_path,
    content            => template('custom_command/uru_runner_ps1.erb'),
    source_permissions => ignore,
  } -> 
  
  file { "${name} Rakefile":
    ensure             => file,
    path               => "${toolspath}\\Rakefile",
    content            => template('custom_command/Rakefile_serverspec.erb'),
    source_permissions => ignore,
  } ->

  file { "${toolspath}\\\spec":
    ensure             => directory,
    source_permissions => ignore,
  } ->
  
  file { "${toolspath}\\\spec\\${name}":
    ensure             => directory,
    source_permissions => ignore,
  } ->

  file { "${name} windows_spec_helper.rb":
    ensure             => file,
    path               => "${toolspath}\\spec\\windows_spec_helper.rb",
    content            => template('custom_command/windows_spec_helper_rb.erb'),
    source_permissions => ignore,
  } ->

  exec { "Execute uru ${name}": 
    command   => "powershell.exe -executionpolicy remotesigned -file ${script_path}",
    require   => File[ "${name} launcher script"],
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
    logoutput => true,
  } ->

  exec { "Add serverspec log to console ${name}": 
    command   => "type ${toolspath}\\reports\\report_.json",
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
    logoutput => true,
  } ->

  notify { "Done ${name}.":}
}
