#!/usr/bin/env ruby

require 'facter'

# Name of this fact.

fact_name = 'powershell_script_rest_call_response'

# code of the fact to follow

if Facter.value(:kernel) == 'windows'
  # origin:  http://stackoverflow.com/questions/27951561/use-invoke-webrequest-with-a-username-and-password-for-basic-authentication-on-t
  # http://www.jokecamp.com/blog/invoke-restmethod-powershell-examples/
  Facter.add(fact_name) do
    username = 'sergueik'
    password = 'xxxxx'
    setcode do 
      File.write('c:/windows/temp/test.ps1', <<-EOF
        # Powershell script
        param(
          [string]$username = '#{username}',
          [string]$password = '#{password}',
          [string]$url = 'https://api.github.com/user'
        )
        $headers = @{ Authorization = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f ${username},${password}))))" }

        Invoke-WebRequest -uri $url -Headers $headers
      EOF
      ) 
      prefix = 'StatusCode'
      data = nil 
      # command =  'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"'
      # puts "command=#{command}"
      if output = Facter::Util::Resolution.exec('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"')
      	# puts "output=#{output}"
        data_line = output.split("\n").grep(/#{prefix}/).first       
        data = data_line.scan(/[\d\.]+/).first
      end
      data
      # 'powershell_script_rest_call_response' = '200'
    end 
  end
end

