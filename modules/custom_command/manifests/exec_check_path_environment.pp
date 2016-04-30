# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_check_path_environment(
  $application_path = $title, # e.g. 'c:\windows\system32'
  $version = '0.1.0',
  $debug = false
)   { 
  # Validate install parameters.
  validate_absolute_path($application_path)
  validate_bool($debug)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $template = 'check_path_environment'
  if $debug {
    # validate the script behaves as intended before putting it as onlyif / unless condition
    exec {"${template}( ${title})": 
      cwd       => 'c:\windows\temp',
      logoutput => true,
      returns   => [0,1],
      path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
      provider  => 'powershell',
      command   => template("custom_command/${template}_ps1.erb"),
    }
  }
  exec {"Run onlyif '${application_path}' is in System Environment (${title})":
    command   => 'write-output "executing custom onlyif command"',
    cwd       => 'c:\windows\temp',
    logoutput => true,
    onlyif    => template("custom_command/${template}_ps1.erb"),
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }
  exec {"Run unless'${application_path}' is in System Environment (${title}":
    command   => 'write-output "executing custom unless command"',
    cwd       => 'c:\windows\temp',
    logoutput => true,
    unless    => template("custom_command/${template}_ps1.erb"),
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }

# inline
#  exec {"Run onlyif(inline) \$host.Version.Major < '${application_path}'":
#    command   => 'write-output "`$host.Version.Major = $($host.Version.Major)"',
#    cwd       => 'c:\windows\temp',
#    logoutput => true,
#    onlyif    => "\$application_path = [int](${application_path});exit [int]( -not ($host.Version.Major -lt \${application_path} ))",
#    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
#    provider  => 'powershell',
#  }
#  exec {"Run unless(inline) \$host.Version.Major < '${application_path}'":
#    command   => 'write-output "`$host.Version.Major = $($host.Version.Major)"',
#    cwd       => 'c:\windows\temp',
#    logoutput => true,
#    unless    => "\$application_path = [int](${application_path});exit [int]( -not ($host.Version.Major -lt \${application_path} ))",
#    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
#    provider  => 'powershell',
#  }
}

