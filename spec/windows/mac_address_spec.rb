require_relative '../windows_spec_helper'

# origin: http://poshcode.org/6459
context 'Mac Addresses' do
  describe command (<<-EOF
    get-wmiobject Win32_NetworkAdapterConfiguration |
      where-object {$_.MacAddress -ne $null } |
      select-Object -property MacAddress,Description,ServiceName |
      format-list -property *
  EOF
  ) do
    its(:stdout) { should match /MacAddress\s+:\s+(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2})/i }
    its(:exit_status) { should eq 0 }
  end
  describe command (<<-EOF
    $obj = get-wmiobject Win32_NetworkAdapterConfiguration |
             where-object {$_.MacAddress -ne $null } |
             select-Object -property MacAddress,Description,serviceName;
    write-output $obj[0].'MacAddress'
  EOF
  ) do
    its(:stdout) { should match /(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2}):(?:[A-F0-9]{2})/ }
    its(:exit_status) { should eq 0 }
  end
end
