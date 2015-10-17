# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_template_test (
  $template = $title, # e.g. 
  $version = '0.1.0',
  $service_name = undef,
  $debug = false
)   { 
  # Validate install parameters. Uncomment the one actually used by sut
  # validate_string($service_name)
  validate_bool($debug)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
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
}

