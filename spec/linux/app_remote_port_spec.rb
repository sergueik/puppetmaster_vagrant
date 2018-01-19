require 'spec_helper'
# quick command to build expectation of a certain TCP port be listen by a specific application
context 'App listening remote port' do
  remote_port = '8090'
  app_jar = 'machineagent.jar'
  describe command(<<-EOF
    netstat -anp | grep $(pgrep -a java | grep #{app_jar}|cut -f1 -d ' ')
  EOF  ) do
    let(:path) {'/bin'}
    its(:stderr) { should be_empty }
    its(:stdout) { should contain remote_port }
    its(:exit_status) {should eq 0 }
  end
end 
