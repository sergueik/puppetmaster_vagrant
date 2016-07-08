# http://stackoverflow.com/questions/29368414/need-script-to-find-server-activation-status

require_relative '../windows_spec_helper'
context 'LicenseStatus' do
  describe command (<<-EOF
# Terse form
Get-CimInstance -ClassName SoftwareLicensingProduct |where PartialProductKey |select PScomputername,LicenseStatus| format-list
# Longer form presumably will work with Powershell 2.0
Get-CimInstance -ClassName SoftwareLicensingProduct | where-object { $_.PartialProductKey -match '\\S' } |select-object -property PScomputername,LicenseStatus | format-list
  
  EOF
  ) do
    its(:stdout) { should contain 'LicenseStatus  : 1' }
  end
end
