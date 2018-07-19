fact_name = 'environment_value'

if Facter.value(:kernel) == 'windows'

  Facter.add(fact_name) do

    setcode do
      script_filepath = 'c:/windows/temp/test.ps1'
      # NOTE some Windows variables are actually special folders
      # https://msdn.microsoft.com/en-us/library/system.environment.specialfolder(v=vs.110).asp
      File.write(script_filepath, <<-EOF
      $Result = [environment]::GetEnvironmentVariable('LOCALAPPDATA',[System.EnvironmentVariableTarget]::User)
        write-output ('Content: "{0}"' -f  $Result )
      EOF
      )
      data_prefix = 'Content'
      data = nil
      powershell_exec = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
      powershell_flags = '-executionpolicy remotesigned'
      if output = Facter::Util::Resolution.exec("#{powershell_exec} #{powershell_flags} -file \"#{script_filepath}\"")
        data_line = output.split("\n").grep(/#{data_prefix}/).first
        data = data_line.scan(/"[^"]+"/).first
      end
      data
    end
  end
end
