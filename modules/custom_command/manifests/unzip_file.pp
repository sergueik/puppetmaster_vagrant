# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_unzip_file(
  $zip_filename = $title, # e.g. 'C:\Windows\TEMP\filename.zip'
  $result_filename = undef, # required
  $version     = '0.1.0'
)   {
  # Validate install parameters.
  validate_string($zip_filename)
  validate_string($result_filename)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $target_path = $zip_filename # for test_path_ps1.erb
  exec {"${title} unzip file: '${zip_filename}'":
    command   =>  template('custom_command/unzip_file_ps1.erb'),
    cwd       => 'c:\windows\temp',
    logoutput => true,
    onlyif    => template('custom_command/test_path_ps1.erb'),
    creates   => $result_filename,
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
  }
}

