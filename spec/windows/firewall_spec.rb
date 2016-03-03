require_relative '../windows_spec_helper'

context 'Firewall Rule' do
  [
  'Windows Remote Management (HTTP-In)'
  ].each do |rule_name|
    describe command ("& netsh advfirewall firewall show rule name='#{rule_name}'") do
      its(:stdout) { should match /Enabled: +Yes/i }
      its(:stdout) { should match /Action: +Allow/i }
      its(:stdout) { should match /Profiles: +Public/i }
      its(:stdout) { should match /Direction: +In/i }
      its(:stdout) { should match /LocalPort: +5985/i }
      its(:stdout) { should match /RemoteIP: +Any/i }
      its(:stderr) { should be_empty }
      its(:exit_status) { should eq 0 }
    end
  end
end


