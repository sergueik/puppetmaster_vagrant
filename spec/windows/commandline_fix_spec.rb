require_relative '../windows_spec_helper'


context 'CommandLine Property' do

  # The specinfra does not support more then one process with a name.
  # https://github.com/mizzy/specinfra/blob/master/lib/specinfra/command/windows/base/process.rb
  # This snippet fixes that brute-force
  describe command(<<-EOF
    # D:\apps\Java8-jre\bin\javaw.exe -Dcom.urbancode.air.mw.common.Monitor.port=49263 -Xrs -Xmx256m -Dfile.encoding=UTF-8 -Dconsole.encoding=UTF-8 -Djava.security.properties=d:\apps\udeploy-6.2.1.2\conf\agent\java.security -Djava.io.tmpdir=d:\apps\udeploy-6.2.1.2/var/temp -jar d:\apps\udeploy-6.2.1.2\monitor\air-worker.jar d:\apps\udeploy-6.2.1.2\bin\classpath.conf 5000 com.urbancode.air.agent.AgentWorker
    # D:\apps\Java8-jre\bin\javaw.exe -Dcom.urbancode.monitorworker.Monitor.port=49269 -Xrs -Xmx256m -Djava.security.properties=d:\apps\ah3agent\conf\agent\java.security -jar d:\apps\ah3agent\monitor\agent-workerlauncher.jar d:\apps\ah3agent\bin\classpath.conf 5000 com.urbancode.anthill3.agent.AgentWorker

    $results = New-Object -typename 'System.Collections.ArrayList'
    $expected_result = 'com.urbancode.anthill3.agent.AgentWorker   zzz'
    $process_name = 'javaw.exe'
    $property = 'commandline'
    # suppress printing the return value  ArrayList index at which the value has been added.
    get-wmiobject win32_process -Filter "name = '${process_name}'" |
    select-object -ExpandProperty ${property} |
    foreach-object { [void]$results.add($_) }
      if ($results.count -eq 1) {
        if ($results[0] -match $expected_result ) {
          $status = $true
        } else {
          $status = $false
        }
      } else {
        # TODO: Powershell callback
        # if ($results.BinarySearch('') -ge 0 ) { echo OK }

        foreach ($result in $results.GetEnumerator()) {
          if ($result -match $expected_result) {
            $status = $true
          }
        }
      }    
    # TODO:  debug the difference in behavior under RSpec
    $exit_code = [int](-not ($status))
    write-output "status = ${status}"
    write-output "exit_code = ${exit_code}"

    exit $exit_code
  EOF
  ) do
    its(:stdout) { should match /#{file_checksum}/ }
    its(:stdout) { should match /[tT]rue/ }
    its(:exit_status) { should eq 0 }
  end
end
