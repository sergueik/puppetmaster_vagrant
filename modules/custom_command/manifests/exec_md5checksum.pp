# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_md5checksum (
  $file_path = $title,
  $file_name = undef,
  $md5_checksum   = undef,
  $version = '0.1.0',
  $debug = false
)   { 
  # Validate install parameters. Uncomment the one actually used by sut
  # validate_string($service_name)
  validate_string($target_path)
  validate_bool($debug)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  if $debug {
    exec {"${title} computes md5 checksum of ${file_path}": 
      cwd       => 'c:\windows\temp',
      logoutput => true,
      returns   => [0,1],
      path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
      provider  => 'powershell',
      command   => template('custom_command/calc_md5_ps1.erb'),
    }
  } else { 
    exec {"${title} computes md5 checksum of ${file_path}": 
      cwd       => 'c:\windows\temp',
      logoutput => true,
      path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
      provider  => 'powershell',
      command   => template('custom_command/calc_md5_ps1.erb'),
    }
  }
}
