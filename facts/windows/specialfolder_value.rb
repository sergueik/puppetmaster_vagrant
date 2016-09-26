# origin: https://msdn.microsoft.com/en-us/library/system.environment.specialfolder(v=vs.110).asp

fact_name = 'specialfolder_value'

if Facter.value(:kernel) == 'windows'

  Facter.add(fact_name) do

    setcode do
      File.write('c:/windows/temp/test.ps1', <<-EOF
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
      if output = Facter::Util::Resolution.exec('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"')
        data_line = output.split("\n").grep(/#{data_prefix}/).first
        data = data_line.scan(/"[^"]+"/).first
      end
      data
    end
  end
end
