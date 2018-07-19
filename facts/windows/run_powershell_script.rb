fact_name = 'powershell_script_output'

if Facter.value(:kernel) == 'windows'

  Facter.add(fact_name) do
    prefix = 'answer'
    script_filepath = 'c:/windows/temp/test.ps1'

    setcode do
      File.write(script_filepath, <<-EOF
        # Powershell script
        write-output '#{prefix} 42'
      EOF
      )
      data = nil
      powershell_exec = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
      powershell_flags = '-executionpolicy remotesigned'
      command =  "#{powershell_exec} #{powershell_flags} -file \"#{script_filepath}\""
      # puts "command=#{command}"
      if output = Facter::Util::Resolution.exec(command)
      	# puts "output=#{output}"
        data_line = output.split("\n").grep(/#{prefix}/).first
        data = data_line.scan(/[\d\.]+/).first
      end
      data
    end
  end
end