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
  # Windows 2008 R2 and 2012 have cmdlets to manage jobs
  # Next requires puppet-win_facts $::operatingsystemversion fact
  if  $::operatingsystemversion {
    case $::operatingsystemversion {
      /(Windows Server 2012|Windows Server 2008 R2)/: {
        $command_script = 'scheduled_task_cmdled_wrapper_ps1.erb'
      }
      /Windows Server 2008 Standard/:{
        $command_script = 'manage_scheduled_task_ps1.erb'
      }
      default: {
        fail("Unsupported Windows version: '$::operatingsystemversion'")
      }
    }
  }
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
    content            => template('custom_command/generic_scheduled_task_xml.erb'),
    source_permissions => ignore,

  }
  # +& schtasks /Delete /F /TN InstallSpoon
  # +& schtasks /Create /TN InstallSpoon /XML $XmlFile
  # +& schtasks /Run /TN InstallSpoon

  # https://github.com/counsyl/puppet-windows
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
    content            => template('custom_command/manage_scheduled_task_ps1.erb'),
    source_permissions => ignore,
  } -> 

  exec { "Execute script that will create and run scheduled task ${name}": 
    command => "powershell -executionpolicy remotesigned -file ${script_path}",
    require  => File[ "${name} launcher script"],
    path    => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  } ->

  notify { "Done ${name}.":}
}
