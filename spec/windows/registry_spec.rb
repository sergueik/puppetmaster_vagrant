
require_relative '../windows_spec_helper'

context 'Registry' do
  describe windows_registry_key('HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment') do
    it do
      should respond_to(:exists?)
      should exist
      should respond_to(:has_property?).with(2).arguments
      should respond_to(:has_property?).with(1).arguments
      should have_property('Path', :type_string)
      should respond_to(:has_value?).with(1).arguments
      should have_property_value( 'OS', :type_string_converted, 'Windows_NT' )
    end
    # for the following test to pass one needs to install modified specinfra.gem and serverspec.gem
    # on the host
    context 'Custom registry API', :if => false do
      it do
        should respond_to(:has_propertyvaluecontaining?).with(2).arguments
        should have_propertyvaluecontaining('Path', 'c:\\\\windows')
      end
    end
  end
  # NOTE: unstable
  context 'Multi-String' do
  # Run the same script before(:all) does not help
  before(:all) do
    registry_key = 'HKLM:\SYSTEM\CurrentControlSet\services\Appinfo'
    # alternative format:
    registry_key = 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Appinfo'
    Specinfra::Runner::run_command(<<-EOF
      $registry_key = '#{registry_key}'
      $property = 'DependOnService'
      (Get-Item $registry_key).GetValue($property)
      EOF
    )
  end
  processname = 'csrss'
  registry_key  = 'HKLM:\SYSTEM\CurrentControlSet\services\Appinfo'
  # NOTE newline separated values in multistring
  {
    'DependOnService' => "RpcSs\nProfSvc",
    'RequiredPrivileges' => "SeBackupPrivilege\nSeTcbPrivilege",
  }.each do |property,multiline_values|
    describe command (<<-EOF
        $registry_key = '#{registry_key}'
        $property = '#{property}'
        $values = @"
        #{multiline_values}
"@
        $status = $true
        $values -split "`r?`n" | foreach-object {
        $value = $_
        $value = $value -replace '^.*\\\\', ''
        $status = $status -band [bool] ((Get-Item $registry_key).GetValue($property) -match $value )
        }
        write-output "Evaluation status: $($([bool]$status))"
        # $exit_code  = [int](-not $status )
        if (($status -eq 1 ) -or ($status -is [Boolean] -and $status)){
          $exit_code = 0
        } else {
          $exit_code = 1
        }

        write-output "exiting with ${exit_code}"
        exit $exit_code
      EOF
    ) do
        its(:stdout) { should match /true/i }
        its(:stdout) { should match /exiting with 0/i }
        # avoid sporadically receiving the <AV>Preparing modules for first use.</AV> error
        # its(:exit_status) {should eq 0}
    end
  end
end
  # TODO:
  # 'RequiredPrivileges' => [ 'SeAssignPrimaryTokenPrivilege', 'SeIncreaseQuotaPrivilege', 'SeTcbPrivilege', 'SeBackupPrivilege', 'SeRestorePrivilege', 'SeDebugPrivilege', 'SeAuditPrivilege', 'SeChangeNotifyPrivilege', 'SeImpersonatePrivilege' ],


  # based on: https://github.com/SHIFT-ware/shift_ware/blob/master/Serverspec/spec/2-0001_Base/Advanced/2-0001-106_Registry_spec.rb  
  # NOTE: forward slashes not accepted by cmdlet:
  # Get-Item : Cannot find path
  # 'HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/services/Appinfo' because it does not exist.
  context 'cmdlets' do
    key = 'HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Services/Appinfo'
    name = 'ImagePath'
    valueType = 'ExpandString'
    value = 'C:\windows\system32\svchost.exe -k netsvcs'
    describe ("Registry Property Name #{name}") do
      describe command("(Get-Item 'Registry::#{ key.gsub('/', '\\\\') }').Property") do
        its(:stdout) { should match /(\A|\R)#{name}(\R|\Z)/}
      end
    end
    describe ("Registry Value kind of #{name}") do
      describe command("(Get-Item 'Registry::#{ key.gsub('/', '\\\\') }').GetValueKind('#{name}')" ) do
        its(:stdout) { should match valueType }
      end
    end
    describe ("Registry Value of #{name}") do
      describe command("(Get-Item 'Registry::#{ key.gsub('/', '\\\\') }').GetValue('#{name}') -replace \"\\n\", '' -replace '\\\\', '/' " ) do
        its(:stdout) { should match Regexp.new(value.gsub('\\', '/'), Regexp::IGNORECASE) }
        its(:stdout) { should match /#{value.gsub('\\', '/')}/i}
        its(:stdout) { should match /(\A|\R)#{value.gsub('\\', '/')}(\R|\Z)/i}
      end
    end
    describe ("Registry Value of #{name}") do
      describe command("(Get-Item 'Registry::#{ key.gsub('/', '\\\\') }').GetValue('#{name}') " ) do
        its(:stdout) { should match /(\A|\R)#{value.gsub('\\', '\\\\\\\\')}(\R|\Z)/i }
        its(:stdout) { should match Regexp.new(value.gsub('\\', '\\\\\\\\'), Regexp::IGNORECASE) }
      end
    end
  end
end