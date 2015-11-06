require_relative '../windows_spec_helper'

context 'Registry' do
  describe windows_registry_key("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment") do
    it { should respond_to(:exists?) }
    it { should exist }
    it { should respond_to(:has_property?).with(2).arguments }
    it { should respond_to(:has_property?).with(1).arguments }
    it { should have_property('Path', :type_string) }
    it { should respond_to(:has_value?).with(1).arguments }
    it { should have_property_value( 'OS', :type_string_converted, 'Windows_NT' ) }
     # for the next tests to pass
     # need to install modified specinfra.gem and serverspec.gem 
     # on the host
     it { should respond_to(:has_propertyvaluecontaining?).with(2).arguments }
     it { should have_propertyvaluecontaining('Path', 'c:\\\\windows') }
  end

context 'multistring' do
# run the same script before(:all) does not help
before(:all) do
  Specinfra::Runner::run_command(<<-END_COMMAND
$registry_key  = 'HKLM:\\SYSTEM\\CurrentControlSet\\services\\Appinfo' 
$property = 'DependOnService'
(Get-Item $registry_key).GetValue($property)
END_COMMAND
  ) 
  end
  processname = 'csrss'
  registry_key  = 'HKLM:\SYSTEM\CurrentControlSet\services\Appinfo' 
  testdata  = {
      'DependOnService' => "RpcSs\nProfSvc",
      'RequiredPrivileges' => "SeBackupPrivilege\nSeTcbPrivilege",
    }
  testdata.each do |property,values|
    describe command (<<-END_COMMAND
$registry_key = '#{registry_key}'
$property = '#{property}'
$values = @"
#{values}
"@
$status = $true
$values -split "`r?`n" | foreach-object {
$value = $_ 
$value = $value -replace '^.*\\\\', ''
$status = $status -band [bool] ((Get-Item $registry_key).GetValue($property) -match $value )
}
write-output "Evaluation status: $($([bool]$status))"
if (($status -eq 1 ) -or ($status -is [Boolean] -and $status)){ 
  $exit_code = 0 
} else { 
  $exit_code = 1 
} 

write-output "exiting with ${exit_code}"
exit $exit_code
# $exit_code  = [int](-not $status )
END_COMMAND
    ) do
        its(:stdout) { should match /true/i }
        its(:stdout) { should match /exiting with 0/i }
        # avoid sporadically collecting the <AV>Preparing modules for first use.</AV> error
        # its(:exit_status) {should eq 0} 
    end
  end
end
# TODO:
#    'RequiredPrivileges' => [ 'SeAssignPrimaryTokenPrivilege', 'SeIncreaseQuotaPrivilege', 'SeTcbPrivilege', 'SeBackupPrivilege', 'SeRestorePrivilege', 'SeDebugPrivilege', 'SeAuditPrivilege', 'SeChangeNotifyPrivilege', 'SeImpersonatePrivilege' ], 

end

