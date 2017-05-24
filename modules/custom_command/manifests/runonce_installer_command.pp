# -*- mode: puppet -*-
# vi: set ft=puppet :


# useful for situations when the vendor installer is sensitive to identity of the parent process 
# calling the installer, 
# and cannot be successfully installed when provisioned by Puppet agent 
# while being successful when run in interactive user session.
define custom_command::runonce_insaller_command (
  $debug          = false,
  $verbose        = false,
  $version        = '0.3.0'
) {

  # TODO:  create install staging directory, copy the vendor executable there, write answer file, license file etc.

  file { 'installer_wrapper.ps1':
    ensure             => 'file',
    path               => "${$package_setup_staging_path}\\installer_wrapper.ps1",
    content            => template("${module_name}/bitrock_installer_wrapper_ps1.erb"),
    source_permissions => 'ignore',
    before             => Exec['Trigger reboot'],
  }

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

  # TODO :update the logic to only write the registry value this when actually about to install  
  # IT may be easiest is to remove when not necessary. 
  # it appears harmless to just leave hanging around
 
  registry_value { 'HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce\Install_Product':
    ensure => present,
    type   => string,
    data   => "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe $package_setup_staging_path\\installer_wrapper.ps1",
  } ->

  exec { 'Trigger reboot':
    command   => regsubst(template("${module_name}/trigger_runonce_reboot_message_command_ps1.erb"), "\r?\n", ";"),
    logoutput => true,
    cwd       => $package_setup_staging_path,
    creates   => $installdir,
    require   => [File[$package_setup_exe],File['installer_wrapper.ps1']],
    provider  => 'powershell',
    notify    => Reboot['Runonce'],
    # This will only run the exec if all conditions in the array return false
    unless    => [ 
      regsubst(template("${module_name}/detect_vendor_registry_key_ps1.erb"), "\r?\n", ";"),   
      regsubst(template("${module_name}/detect_flagfile_ps1.erb"), "\r?\n", ";")
    ],
    # NOTE: to prevent race condition between the installer RunOnce command and Puppet agent itself after the instance is rebooted,
    # one need to take care to suppress the trigger if already run.
    # Simplest is to generate a flag file and check ifit is present. 
    # Alternative is to detect if the vendor install process is running
  }

  reboot { ['Runonce']:
    apply => 'immediately',
    when  => 'refreshed',
  }
}