# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_add_registry_value(
  $target_script = undef,
  $version = '0.1.0'
)   {
  # Validate parameters.
  validate_string($target_script)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $title_tag = regsubst($title, '[\\\\:]', '_', 'G')
  $registry_hive = 'HKLM:'
  $registry_path = 'Software\Microsoft\Windows\CurrentVersion\RunOnce'
  $property_name = $title_tag
  $property_value = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe ${target_script}"
  exec {"${title_tag} creating RunOnce command":
    command   =>  template('custom_command/add_value_with_check_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    # onlyif  => template('custom_command/test_application_is_not_installed_ps1.erb'),
    # unless  => template('custom_command/test_application_is_installed_ps1.erb'),
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }
}
