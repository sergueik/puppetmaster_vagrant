# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_powershell_execution_syntax_error(
  $version     = '0.1.0'
)   { 
  # Validate install parameters.
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $template = 'exec_powershell_execution_syntax_error'
  # demonstrate  syntax error
  exec {"${template2}( ${title})": 
    cwd       => 'c:\windows\temp',
    logoutput => true,
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
    command    => template("custom_command/${template}_ps1.erb"),
  }
}

