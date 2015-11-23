require_relative '../windows_spec_helper'

context 'Pending reboots' do 
  context 'CBS' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing') do
      it{ should_not have_property('RebootPending')}
    end
  end
  context 'UAS' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\UAS') do
      it{ should have_property_value('UpdateCount', :type_dword, '0')}
    end
  end
  context 'RebootWatch' do
    describe windows_registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Reporting\RebootWatch') do
      it{ should exist}
    end
  end
  context 'WUAU' do 
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
