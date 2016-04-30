$app_pool_name = 'my-test-app'
$app_pool_dotnet_version = 'v4.0'
$iis_app_name = 'my-test-app.test'
$directory_path = 'D:\SomeFolder'
$create_script = 'c:/windows/temp/create_iis_site_app_pool.ps1'
$check_exists_script = 'c:/windows/temp/check_iis_app_pool_exists.ps1'

file { $create_script :
  ensure             => file,
  content            => template('appdynamics/create_iis_site_app_pool_ps1.erb'),
  source_permissions => ignore,
  mode               => '0755',
}
->

file { $check_exists_script :
  ensure             => file,
  content            => template('appdynamics/check_iis_app_pool_exists_ps1.erb'),
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
