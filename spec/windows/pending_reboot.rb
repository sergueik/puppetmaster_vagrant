require_relative '../windows_spec_helper'

context 'Pending reboots' do 
  context 'Component Based Servicing' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing') do
      it{ should_not have_property('RebootPending')}
    end
  end
# TODO:
# 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'
# 'AcceleratedInstallRequired' 
  context 'UAS' do
    describe command (<<-EOF
      $update_count = (Get-Item 'Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\UAS').GetValue('UpdateCount')
      if (($update_count -eq $null) -or ($update_count -eq 0)){ 
        write-output 'No Reboot Needed'
      } else {
        write-output 'Failure'
      }
    EOF
    ) do
      its(:stdout) { should match /No Reboot Needed/i }
    end
  end
  context 'Shutdown Flags' do
    describe command (<<-EOF
      $reboot_flag = 16
      # Pending reboot: 0x13 
      # After accepting pending reboot: 0x09
      # https://social.technet.microsoft.com/Forums/windows/en-US/aedfc165-5b2c-4f6c-ada8-144b2c7094e6/shutdownflags-registry-entry?forum=w7itprogeneral
      # https://msdn.microsoft.com/en-us/library/windows/desktop/aa376885%28v=vs.85%29.aspx
      $shutdown_detected = (((Get-Item 'Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon').GetValue('ShutdownFlags') -band $reboot_flag -bxor (65535 -bxor $reboot_flag) ) -eq 65535) 
      if ($shutdown_detected ){ 
        write-output 'Pending Reboot detected'
      } else {
        write-output 'No Reboot Needed'
      }
    EOF
    ) do
      its(:stdout) { should match /No Reboot Needed/i }
    end
  end
  # NOTE: unstable fails in first run, passes in subsequent runs
  context 'Reboot watch' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate') do
      it{ should exist}
    end
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Reporting\RebootWatch') do
      it{ should exist}
    end
    describe command(<<-EOF
    $status = 0
    pushd HKLM:
    if (test-path -path 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Reporting\\RebootWatch') {
      write-output 'Found RebootWatch key'
    }
    EOF
    ) do
      its(:exit_status) { should be 0 }
      its(:stdout) { should match /Found RebootWatch key/i }
    end
  end
  context 'WindowsUpdate Auto Update' do 
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update') do
      it{ should_not have_property('RebootRequired')}
    end
  end
  context 'PendingFileRenameOperations' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager') do
      it{ should_not have_property('PendingFileRenameOperations')}
    end
  end
  context 'UpdateExeVolatile' do
    
    describe command(<<-EOF
    $status = 0
    pushd HKLM:
    if (test-path -path 'SOFTWARE\\Microsoft\\Updates\\UpdateExeVolatile') {
      $flags = (get-itemProperty -path 'SOFTWARE\\Microsoft\\Updates\\UpdateExeVolatile' -name 'Flags').'Flags'
      if (($UpdateExeVolatileFlags -eq '1' ) -or ($flags -eq '2' ) ) {  
        write-output 'Reboot Pending'
        write-output ('Flags = {0}' -f $flags )
      }
    }
    write-output 'No Reboot Needed'
    EOF
    ) do
      its(:exit_status) { should be 0 }
      its(:stdout) { should match /No Reboot Needed/i }
    end
  end
  context 'Pending ComputerName vs. ActiveComputerName operation' do
    
    describe command(<<-EOF
    pushd HKLM:
    $ActiveComputerName = (get-itemProperty -path 'SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ActiveComputerName' -name 'ComputerName').'ComputerName'
    $ComputerName       = (get-itemProperty -path 'SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName' -name 'ComputerName').'ComputerName'

    if ( $ActiveComputerName -ne $ComputerName ) {
       write-output 'Reboot Pending: computer rename'
    } else {
      write-output 'No Reboot Needed'
    }
    EOF
    ) do
      its(:exit_status) { should be 0 }
      its(:stdout) { should match /No Reboot Needed/i }
    end
    
  end
  
  context 'Domain join operation' do
    # Review commit #https://github.com/sergueik/puppetmaster_vagrant/commit/30ab64bab7b02e2f29cc7ec47b2d7311c484a456 
    describe command(<<-EOF
    $registry_key = 'SYSTEM\\CurrentControlSet\\Services\\Netlogon'
    $subkey_names = (Get-item  -path "HKLM:${registry_key}").GetSubKeyNames()
    if (($subkeys.snames -contains 'JoinDomain') -or ($subkeys.snames -contains 'AvoidSpnSet')){
       write-output 'Reboot Pending: Join Domain'
    } else {
      write-output 'No Reboot Needed'
    }
    $subkeys_full_names = Get-childitem -path "HKLM:${registry_key}" | select-object -expandproperty Name 
    $subkey_names = $subkeys_full_names | foreach-object { return  ($_ -replace '^.*\\\\', '') }
    if (($subkeys.snames -contains 'JoinDomain') -or ($subkeys.snames -contains 'AvoidSpnSet')){
       write-output 'Reboot Pending: Join Domain'
    } else {
      write-output 'No Reboot Needed'
    }
    EOF
    ) do
      its(:exit_status) { should be 0 }
      its(:stdout) { should match /No Reboot Needed/i }
    end
  end
  
  context 'Domain join operation Unused' do
    describe command(<<-EOF  
    $HKLM = 2147483650
    $key = 'SYSTEM\\CurrentControlSet\\Services\\Netlogon'
    # System.Management.ManagementClass#ROOT\\default\\StdRegProv
    # NOTE: use forward slashes here 
    $WMI_Reg = [WMIClass]'\\\\.\\root\\default:StdRegprov'
    $subkeys = $WMI_Reg.EnumKey($HKLM, $key)
    if (($subkeys.snames -contains 'JoinDomain') -or ($subkeys.snames -contains 'AvoidSpnSet')){
       write-output 'Reboot Pending: Join Domain'
    } else {
      write-output 'No Reboot Needed'
    }
    $subkey_names = (Get-item  -path 'HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Netlogon').GetSubKeyNames()
    $subkeys_full_names = Get-childitem  -path 'HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Netlogon' | select-object -expandproperty Name 
    $subkey_names = $subkeys_full_names | foreach-object { return  ($_ -replace '^.*\\\\', '') }

    # NOTE: 
    # if a 'property' used instead of 'expandproperty' in the following 
    $subkeys_full_names = Get-childitem  -path 'HKLM:\\SYSTEM\\CurrentControlSet\\Services\\Netlogon' | select-object -property Name 
    # there appears a bogus curly bracket added by -replace  
    # $subkeys_full_names | foreach-object  { return ($_ -replace '^.*\\\\', '') }
    # 
    # Name
    # ----
    # HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Parameters
    # 'Parameters}'
    # HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Private
    # 'Private}'

    # HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Parameters
    # HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\Netlogon\\Private

    EOF
    ) do
      its(:exit_status) { should be 0 }
      its(:stdout) { should match /No Reboot Needed/i }
    end
  end
end 
