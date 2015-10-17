# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_show_powershell_version(
  $expected_version = $title, # e.g. 4
  $version     = '0.1.0'
)   { 
  # Validate install parameters.
  validate_re($expected_version, '^\d$')
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $template = 'exec_show_powershell_version'
  # validate the script behaves as intended before putting it as onlyif / unless condition
  exec {"${template}( ${title})": 
    cwd       => 'c:\windows\temp',
    logoutput => true,
    returns   => [0,1],
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
    command    => template('custom_command/exec_check_powershell_version_ps1.erb'),
}
#  exec {"${title} show_powershell version if >= '${expected_version}'":
#
#    command   =>  '$host.Version.Major',
#    cwd       => 'c:\windows\temp',
#    logoutput => true,
#    onlyif    => template('custom_command/exec_check_powershell_version_ps1.erb'),
#    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
#    provider  => 'powershell',
#  }   
#  exec {"${title} show_powershell version unless >= '${expected_version}'":
#
#    command   =>  '$host.Version.Major',
#    cwd       => 'c:\windows\temp',
#    logoutput => true,
#    unless    => template('custom_command/exec_check_powershell_version_ps1.erb'),
#    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
#    provider  => 'powershell',
#  }  
}

