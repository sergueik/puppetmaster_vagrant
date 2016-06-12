#!/usr/bin/env ruby

require 'facter'

# Name of this fact.

fact_name = 'powershell_script_output'

if Facter.value(:kernel) == 'windows'

  Facter.add(fact_name) do
    setcode do 
      File.write('c:/windows/temp/test.ps1', <<-EOF
        # Powershell script
        write-output 'test 123'
      EOF
      ) 
      prefix = 'test'
      data = nil 
      # command =  'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"'
      # puts "command=#{command}"
      if output = Facter::Util::Resolution.exec('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"')
      	# puts "output=#{output}"
        data_line = output.split("\n").grep(/#{prefix}/).first       
        data = data_line.scan(/[\d\.]+/).first
      end
      data
    end 
  end
end
