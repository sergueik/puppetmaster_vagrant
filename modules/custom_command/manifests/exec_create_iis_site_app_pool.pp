# -*- mode: puppet -*-
# vi: set ft=puppet :

define custom_command::exec_create_iis_site_app_pool(
  $app_pool_name = $title, # e.g. 'my-test-app'
  $app_pool_dotnet_version = undef, # e.g. 'v4.0'
  $iis_app_name = undef, # e.g. 'my-test-app.test'
  $directory_path = undef, # e.g. 'D:\SomeFolder'
  $port = undef, # e.g. 80
  $version = '0.1.0',
  $debug = false
)   { 
  # Validate install parameters.
  validate_string($app_pool_name)
  validate_re($dotnet_version, '^v\d+\.\d+(\.\d+)*$') 
  validate_string($iis_app_name)
  validate_absolute_path($directory_path)
  validate_integer($port)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  validate_bool($debug)
 
  $create_script = 'c:/windows/temp/create_iis_site_app_pool.ps1'
  $check_exists_script = 'c:/windows/temp/check_iis_app_pool_exists.ps1'

  file { $create_script :
    ensure             => file,
    content            => template("${name}/create_iis_site_app_pool_ps1.erb"),
    source_permissions => ignore,
    mode               => '0755',
  }
  ->

  file { $check_exists_script :
    ensure             => file,
    content            => template("${name}/check_iis_app_pool_exists_ps1.erb"),
    source_permissions => ignore,
    mode               => '0755',
  }
  ->
  exec { 'create iis site and app pool':
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    command   => "powershell -executionpolicy remotesigned -file ${create_script}",
    provider  => 'powershell',
    logoutput => true,
    unless    => "powershell -executionpolicy remotesigned -file ${check_exists_script}",
  }

}