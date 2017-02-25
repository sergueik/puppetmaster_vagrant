require_relative '../windows_spec_helper'

context 'CommandLine Property' do

  # The specinfra does not support more then one process with a name.
  # https://github.com/mizzy/specinfra/blob/master/lib/specinfra/command/windows/base/process.rb
  # This snippet fixes that brute-force
  expected_result = 'com.urbancode.anthill3.agent.AgentWorker'
  process_name = 'javaw.exe'
  describe command(<<-EOF
    $status = $false
    $debug = $false
    $expected_result = '#{expected_result}'
    $process_name = '#{process_name}'
    $results = New-Object -typename 'System.Collections.ArrayList'
    $property = 'commandline'
    # suppress printing the return value  ArrayList index at which the value has been added.
    get-wmiobject win32_process -Filter "name = '${process_name}'" |
    select-object -ExpandProperty ${property} |
    foreach-object { [void]$results.add($_) }
      if ($results.count -eq 1) {
        if($debug) {
            write-output ('Inspecting {0}' -f $results[0])
        }
        if ($results[0] -match $expected_result ) {
          write-output ('Found "{0}"' -f $expected_result )
          $status = $true
        } else {
          $status = $false
        }
      } else {
        # TODO: Powershell callback
        function Comparer {
          param([Object] $x, [Object] $y)
          return $false
        }
        try {
                 if ([Array]::BinarySearch($results, { param([System.Object] $x, [System.Object] $y)
         return 0; }) -ge 0 ) { echo OK }
        } catch [Exception] {
        # Exception calling "BinarySearch" with "2" argument(s): "Failed to compare two elements in the array."
        }

        foreach ($result in $results.GetEnumerator()) {
          if($debug) {
            write-output ('Inspecting {0}' -f $result)
          }
          if ($result -match $expected_result) {
            write-output ('Found "{0}"' -f $expected_result )
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
    its(:stdout) { should match /found "#{expected_result}"/ }
    its(:stdout) { should match /[tT]rue/ }
    its(:exit_status) { should eq 0 }
  end
end
