#!/usr/bin/env ruby

require 'facter'

# Name of this fact.
fact_name = 'environment_value'

if Facter.value(:kernel) == 'windows'

  Facter.add(fact_name) do

    setcode do
      File.write('c:/windows/temp/test.ps1', <<-EOF
      $Result = $env:LOCALAPPDATA
      # 'user' will not work 
      $Result = [environment]::GetEnvironmentVariable('LOCALAPPDATA')
      # This is sparsely populated 
      $Result = [environment]::GetEnvironmentVariable('LOCALAPPDATA',[System.EnvironmentVariableTarget]::User)
        write-output ('Content: "{0}"' -f  $Result ) 
      EOF
      )
      data_prefix = 'Content'
      data = nil
      if output = Facter::Util::Resolution.exec('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"')
        data_line = output.split("\n").grep(/#{data_prefix}/).first
        data = data_line.scan(/"[^"]+"/).first
      end
      data
    end
  end
end
