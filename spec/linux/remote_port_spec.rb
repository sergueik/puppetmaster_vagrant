  # test that application (e.g. AppDynamics jar) listens to a known tcp port of its server 
  context 'Remote port' do
    jar = 'machineagent.jar'
    port = '8080'
    describe command("netstat -anp | grep \$(pgrep -a java | grep -i '#{jar}' | cut -f 1 -d ' ')") do
      let(:path) {'/bin'}
      its(:stderr) { should be_empty }
      its(:stdout) { should contain port }
      its(:exit_status) {should eq 0 }
    end
  end
