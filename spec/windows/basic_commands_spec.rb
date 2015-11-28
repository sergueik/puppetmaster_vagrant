require_relative '../windows_spec_helper'

context 'Commands' do
  context 'basic' do
    processname = 'csrss'
    describe command("(get-process -name '#{processname}').Responding") do
      let (:pre_command) { 'get-item -path "c:\windows"' }
      its(:stdout) { should match /[tT]rue/ }
      its(:exit_status) { should eq 0 }
    end
    describe command ('ipconfig ') do
      its(:stdout) { should match /^Windows IP Configuration/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
    describe command ('& "ipconfig" ') do
      its(:stdout) { should match /^Windows IP Configuration/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
    describe command ('(get-CIMInstance "Win32_ComputerSystem" -Property "DNSHostName").DNSHostName') do
      its(:stdout) { should match /\bwindows7\b/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end
