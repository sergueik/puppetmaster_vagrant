require_relative '../windows_spec_helper'

context 'Default Site' do
  describe file('C:\\inetpub\\wwwroot') do
    it { should be_present }
  end 
  describe port(80) do
    it { should be_listening }
  end
end
context 'World Wide Web Publishing Service' do
  describe service('W3SVC') do
    it { should be_running }
  end
end
context 'Windows Process Activation Service' do
  describe service('WAS') do
    it { should be_running }
  end
end 
