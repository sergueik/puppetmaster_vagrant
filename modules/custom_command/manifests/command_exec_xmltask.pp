# -*- mode: puppet -*-
# vi: set ft=puppet :

define windows_xmltask(
  $program = undef,
  $arguments = undef,
  $description = $title,
  $domain = '.',
  $job_definition = undef,
  $timeout = 300,
  $username = 'vagrant',
  $version = '0.2.0',
  $wait = true,
  $create = false,
  $workdir = 'c:/windows/temp'
)   {
  # validate install parameters
  validate_bool($wait)
  validate_string($timeout)
  validate_string($program)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $random = fqdn_rand(1000,  $taskname)

  case $::osfamily {
    Windows: {
      $supported = true
    }
    default: {
      fail("The ${module_name} module is not supported on ${::osfamily} system")
    }
  }
  $taskname = regsubst($title, "[$/\\|:, ]", '_', 'G')
  # log file will be passed to the script template
  $logfile = "c:\\windows\\temp\\${taskname}.${random}.log"
  $script = "c:\\windows\\temp\\${taskname}.ps1"
  if $create {
    $job_definition = "c:\\windows\\temp$\\${taskname}.xml"
    windows_xmltask::job_definition  { $taskname:
      program => $program,
      arguments => $arguments,
      description => $description,
      domain => $domain,
      username> = $username,
      workdir => $workdir,
    }
  } else {
    validate_string($job_definition)
  }
  # https://github.com/counsyl/puppet-windows/blob/master/templates/refresh_environment.ps1.erb
  file { $logfile:
    ensure             => absent,
    source_permissions => ignore,
  } ->

  file { $script:
    ensure             => file,
    content            => template('windows_xmltask/run_task_ps1.erb'),
    source_permissions => ignore,
  } ->

  exec { "${taskname}_execute":
    command   => "powershell -executionpolicy remotesigned -file ${script}",
    logoutout => true,
    require   => File[$script],
    path      => ['C:\Windows\System32\WindowsPowerShell\v1.0',
                  'C:\Windows\System32'],
    provider  => 'powershell',
  }
# TODO: support Windows 8.1 case - utilize Scheduled Task cmdlets
#    exec { "Importing task $taskname":
#      command => "
#        Try{
#          if((Get-ScheduledTask '$taskname') -eq $null){
#            Register-ScheduledTask -Xml (get-content 'C:\Users\Public\\$temp_filename.xml' | out-string) -TaskName '$taskname' $is_force
#          }
#          Remove-Item 'c:\Users\Public\\$temp_filename.xml'
#        }
#        Catch{
#          exit 0
#        }
#      ",
#      provider  => powershell,
#    }
}
