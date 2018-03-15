require 'spec_helper'

# test that application (e.g. AppDynamics jar) listens to a known tcp port of its server 
  context 'Remote TCP port check' do
    jar = 'javaagent.jar'
    port = '4444'
    describe command("netstat -anp | grep \$(pgrep -a java | grep -i '#{jar}' | cut -f 1 -d ' ')") do
      let(:path) {'/bin'}
      its(:stderr) { should be_empty }
      its(:stdout) { should contain port }
      its(:exit_status) {should eq 0 }
    end
  end

context 'Remote TCP port check 2' do
  # pgrep not available on downlevel OSes
  port = '4444'  
  cmdline_match = '[j]avaagent.jar'  
  port_check_command = "netstat -anp | grep  #{port} | grep $(ps -ef | grep '#{cmdline_match}' | awk '{ print $2 }') | head -1"  
  describe command(port_check_command) do
    let(:path) {'/bin'}
    its(:stderr) { should be_empty }
    its(:stdout) { should contain port }
    its(:exit_status) {should eq 0 }
  end
  context 'Command Output'  do
    port = '4444'
    cmdline_match = '[j]avaagent.jar'
    # provide explicitly path in the commands
    port_check_command = "/bin/netstat -anp | /bin/grep  #{port} | /bin/grep $(/bin/ps -ef | /bin/grep '#{cmdline_match}' | /bin/awk '{ print $2 }') | /bin/head -1"
    # port_check_command = '/bin/netstat -anp | /bin/grep  #{port} | /bin/grep $(/bin/ps -ef | /bin/grep \'#{cmdline_match}\' | /bin/awk \'{ print $2 }\') | /bin/head -1'
    command_output = nil
    begin
      command_output = Specinfra.backend.run_command(port_check_command).stdout
      $stderr.puts command_output
      # port grep and head are optional
      # but they reduce the number of lines in the content to just one
      #
      # without them the output would look like
      # tcp6       0      0 :::46411                :::*                    LISTEN      1041/java
      # tcp6       0      0 :::1389                 :::*                    LISTEN      1041/java
      # tcp6       0      0 :::1689                 :::*                    LISTEN      1041/java
      # tcp6       0      0 :::4444                 :::*                    LISTEN      1041/java
      # unix  2      [ ]         STREAM     CONNECTED     16180    1041/java
      # unix  2      [ ]         STREAM     CONNECTED     18772    1041/java
      # with the extra grep and head it will only
      # tcp6       0      0 :::4444                 :::*                    LISTEN      1041/java
    rescue => e
      $stderr.puts 'Exception: ' + e.to_s
    end
    subject { command_output } 
    it { should match port }
    end
  end
