if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

context 'TCP Port with StopWatch' do
  port_number = 5985
  time_limit_milliseconds = 10000
  retry_delay_milliseconds = 1000
  service_name = 'Windows Remote Management' # case sensitive
  describe command (<<-EOF
    if ( -not  (get-command test-netconnection -erroraction silentlycontinue)) {
      $Host.UI.WriteErrorLine('Cannot test net connection on this system')
      exit 1
    }
    $port_number = #{port_number}
    $time_limit_milliseconds = #{time_limit_milliseconds}
    $retry_delay_milliseconds = #{retry_delay_milliseconds}
    $stop_watch = new-object -typeName 'System.Diagnostics.Stopwatch'
    $stop_watch.Start()
    # chek if TCP port is lictening
    $test_status = test-netconnection -port $port_number -computername localhost
    while ( -not ( $test_status.TcpTestSucceeded ) ) {
     start-sleep  -millisecond $retry_delay_milliseconds
     $test_status = test-netconnection -port $port_number -computername localhost
      if ($stop_watch.ElapsedMilliseconds -gt $time_limit_milliseconds) {
        $elapsed_seconds = $stop_watch.ElapsedMilliseconds / 1000
        $Host.UI.WriteErrorLine("ERROR: could not connect to TCP port ${port_number} within ${elapsed_seconds}" )
        exit 1
      }
    }
    write-output ('INFO: Successfully connected to {0}' -f $port_number)
    $stop_watch.Stop()
  EOF
  ) do
    its(:stdout) { should match /INFO: Successfully connected to #{port_number}/ }
    its(:stderr) { should_not match /ERROR: /i }
    # the STDERR is reported to not be blank
    # < CLIXML\n<Objs Version=\"1.1.0.1\" xmlns=\"http://schemas.microsoft.com/powershell/2004/04\"><Obj ...il /><PI>-1</PI><PC>100</PC><T>Completed</T><SR>0</SR><SD>1/1 completed</SD></PR></MS></Obj></Objs>
    # its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
end
