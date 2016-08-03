# origin: http://poshcode.org/6459

require_relative '../windows_spec_helper'
  context 'MAC Addresses' do
    describe command (<<EOF
        Get-WmiObject Win32_NetworkAdapterConfiguration |
        where-object {$_.MAcAddress -ne $null } | 
        select-object -first 10 | 
        select-Object -property   MacAddress,Description,ServiceName | 
        format-list -property *
    EOF
    ) do
      its(:stdout) { should match /MacAddress\s+:\s+(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2})/i }
      its(:exit_status) { should eq 0 }
    end
  end
end
