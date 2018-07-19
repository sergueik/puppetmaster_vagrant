# origin: https://msdn.microsoft.com/en-us/library/system.environment.specialfolder(v=vs.110).asp

fact_name = 'specialfolder_value'

if Facter.value(:kernel) == 'windows'

  Facter.add(fact_name) do

    script_filepath = 'c:/windows/temp/test.ps1'

    setcode do
      File.write(script_filepath, <<-EOF
      try {

        $Result = [environment]::GetFolderPath([System.Environment.SpecialFolder]::ProgramFiles)
        # NOTE: naive conversion does not work -
      } catch [Exception]{
      }
      $Result = [Environment]::GetFolderPath('LocalApplicationData')
      # [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])
      # LocalApplicationData
      # UserProfile
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
