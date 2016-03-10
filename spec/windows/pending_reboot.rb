require_relative '../windows_spec_helper'

context 'Pending reboots' do 
  context 'Component Based Servicing' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing') do
      it{ should_not have_property('RebootPending')}
    end
  end
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
      # TODO : verify the 0x13 
      # https://social.technet.microsoft.com/Forums/windows/en-US/aedfc165-5b2c-4f6c-ada8-144b2c7094e6/shutdownflags-registry-entry?forum=w7itprogeneral
      # https://msdn.microsoft.com/en-us/library/windows/desktop/aa376885%28v=vs.85%29.aspx
      $shutdown_detected = (((Get-Item 'Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon').GetValue('ShutdownFlags') -band $reboot_flag -bxor (65535 -bxor $reboot_flag) ) -eq 65535)                              
      if ($shutdown_detected ){ 
        write-output 'No Reboot Needed'
      } else {
        write-output 'Failure'
      }
    EOF
    ) do
      its(:stdout) { should match /No Reboot Needed/i }
    end
  end

  context 'Reboot watch' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Reporting\RebootWatch') do
      it{ should exist}
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
    $PendDomJoin = $false 
    pushd HKLM:
    $ActiveComputerName = (get-itemProperty -path 'SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ActiveComputerName' -name 'ComputerName').'ComputerName'
    $ComputerName       = (get-itemProperty -path 'SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName' -name 'ComputerName').'ComputerName'

    If (($ActiveComputerName -ne $ComputerName) -or $PendDomJoin) {

       write-output 'Reboot Pending: computer rename'
    #  $CompPendRen = $true
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
    # TODO:
    # $snames = $WMI_Reg.EnumKey($HKLM,"SYSTEM\CurrentControlSet\Services\Netlogon").sNames
    # $PendDomJoin = ($snames -contains 'JoinDomain') -or ($snames -contains 'AvoidSpnSet')
    #
  end
end 
