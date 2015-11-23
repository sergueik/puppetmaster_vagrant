require_relative '../windows_spec_helper'
context 'Pending reboots' do 
  context 'Component Based Servicing' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing') do
      it{ should_not have_property('RebootPending')}
    end
  end
  context 'UAS' do
    describe command (<<-EOF
      $update_count = (Get-Item 'Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\UAS').GetValue('UpdateCount')
      if (($update_count -eq $null) -or ($update_count -eq 0)){ 
        write-output 'Success'
      } else {
        write-output 'Failure'
      }
    EOF
    ) do
      its(:stdout) { should match /Success/i }
    end
  end
  context 'Shutdown Flags' do
    describe command (<<-EOF
      $reboot_flag = 16
      $success = (((Get-Item 'Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon').GetValue('ShutdownFlags') -band $reboot_flag -bxor (65535 -bxor $reboot_flag) ) -eq 65535)
      if ($success){ 
        write-output 'Success'
      } else {
        write-output 'Failure'
      }
    EOF
    ) do
      its(:stdout) { should match /Success/i }
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
  context 'Domain join operation' do
    # TODO:
    # $snames = $WMI_Reg.EnumKey($HKLM,"SYSTEM\CurrentControlSet\Services\Netlogon").sNames
    # $PendDomJoin = ($snames -contains 'JoinDomain') -or ($snames -contains 'AvoidSpnSet')
    #
  end
  context 'Pending ComputerName vs. ActiveComputerName operation' do
    # TODO:
    # $ActCompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\","ComputerName")            
    # $CompNm = $WMI_Reg.GetStringValue($HKLM,"SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\","ComputerName")
    # If (($ActCompNm -ne $CompNm) -or $PendDomJoin) {
    #  $CompPendRen = $true
    # }
    #
  end
end 
