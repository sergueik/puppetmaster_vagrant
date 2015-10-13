# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_remove_registry_key(
  $target_path = $title, # e.g. 'C:\Program Files\Spoon\Cmd'
  $version     = '0.2.0'
)   { 
  # Validate install parameters.
  validate_string($target_path)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  exec {"${title} recycle directory: '${target_path}'":
    command   =>  template('custom_command/remove_item_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    onlyif    => template('custom_command/test_path_ps1.erb'),
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }  
}

