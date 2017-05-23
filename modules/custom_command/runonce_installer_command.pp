# This is a fragment useful for situations when the product instaled by Puppet is sensitive to identity of the parent process
# calling the installer, and fails when  provisioned by Puppet agent while successfully run in interactive user session.

file { 'installer_wrapper.ps1':
  ensure             => 'file',
  path               => "${$package_setup_staging_path}\\installer_wrapper.ps1",
  content            => template("${module_name}/windows/installer_wrapper_ps1.erb"),
  source_permissions => 'ignore',
  before             => Exec["trigger ${product_name} install"],
}
# Example of install wrapper:
# $log = 'a.log'
# pushd '<%= @package_setup_staging_path -%>'
# write-output 'starting install' | out-file $log -encoding ascii
# $package_setup_exe_filename = '<%= @package_setup_exe_filename -%>'
# dir $package_setup_exe_filename | out-file $log -append -encoding ascii
# $process = Start-Process $package_setup_exe_filename -argumentlist @('--mode', 'unattended', '--debugtrace', "${pwd}\debug.log", '--fortify_license_path', '<%= @staging_path -%>\license.lic',  '--optionfile', '<%= @package_setup_options_filename -%>' , '--debuglevel', '4') -Wait -PassThru;
# Write-output $process.ExitCode;
# Write-output $process.ExitCode | out-file $log -append -encoding ascii;
# $process | format-list
# $process | format-list | out-file $log -append -encoding ascii;
# if ( $process.ExitCode -eq 0 ) {
#   Write-output 'Install successful' | out-file $log -append -encoding ascii;
# } else {
#   Write-output 'Install failed' | out-file $log -append -encoding ascii;
#  }
# exit $process.ExitCode

# Example of Registry key of a product which presence remains unknown to ARP and win32_product WMI provider
$reg_key = "HKLM:\\SOFTWARE\\Wow6432Node\\${vendor}\\${product_name} ${product_version}"
# To query product in the ARP Uninstall subkeys
# Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize
# To query  WMI win32_product
# Get-WmiObject Win32_Product | Sort-Object Name | Format-Table Name, Version, Vendor
# NOTE: WMI call is quite time consuming

registry_key { 'HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce':
  ensure => present,
} ->

registry_value { 'HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce\Install_Product':
  ensure => present,
  type   => string,
  data   => "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe $package_setup_staging_path\\installer_wrapper.ps1",
} ->

exec { "Trigger reboot  and ${product_name} install":
  command   => "\$data = get-itemproperty -path \"${reg_key}\" -erroraction silentlycontinue | select-object -expandproperty 'version'; [bool]\$status = (\$data -ne \$null) ;  \$exitcode = [int]( -not ( \$status )); if (\$exitcode -ne 0 ) {  write-output \"Registry check  has exit with \${exitcode}\" ;write-output 'Trigger reboot and install of ${product_name}'; } ",
  logoutput => true,
  cwd       => $package_setup_staging_path,
  creates   => $installdir,
  require   => [File[$package_setup_exe],File['installer_wrapper.ps1']],
  provider  => 'Powershell',
  notify    => Reboot['reboot to perform Runonce'],
  unless    => "\$data = get-itemproperty -path \"${reg_key}\" | select-object -expandproperty 'version'; [bool]\$status = (\$data -ne \$null) ; \$exitcode = [int]( -not ( \$status )); write-output \"will exit with \${exitcode}\" ; exit \$exitcode",
}

reboot { ['reboot to perform Runonce']:
  apply => 'immediately',
  when  => 'refreshed',
}
