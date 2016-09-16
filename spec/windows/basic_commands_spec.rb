require_relative '../windows_spec_helper'

context 'Basic Commands' do
  processname = 'csrss'
  describe command("(get-process -name '#{processname}').Responding") do
    let (:pre_command) { 'get-item -path "c:\windows"' }
    its(:stdout) { should match /[tT]rue/ }
    its(:exit_status) { should eq 0 }
  end
  dns_hostname = 'windows7'
  describe command ('(get-CIMInstance "Win32_ComputerSystem" -Property "DNSHostName").DNSHostName') do
    its(:stdout) { should match /\b#{dns_hostname}\b/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
end
