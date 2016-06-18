#!/usr/bin/env ruby

require 'facter'

# Create HTTP POST request from an instance which has Powershell 3 + 
# origin:  http://stackoverflow.com/questions/27951561/use-invoke-webrequest-with-a-username-and-password-for-basic-authentication-on-t
# http://www.jokecamp.com/blog/invoke-restmethod-powershell-examples/
# https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/

fact_name = 'rest_powershell3_test'

if Facter.value(:kernel) == 'windows'
  Facter.add(fact_name) do
  
    username = 'username'
    password = 'password'
    auth_key = 'auth_key'
    auth_value = 'auth_value'
    url = 'https://api.github.com/user'
    
    setcode do 
      File.write('c:/windows/temp/test.ps1', <<-EOF
        param(
          [string]$username = '#{username}',
          [string]$password = '#{password}',
          [string]$auth_key = '#{auth_key}',
          [string]$auth_value = '#{auth_value}',
          [string]$url = '#{url}'
        )

        $headers = @{ 'Authorization' =
          ('Basic {0}' -f ([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f ${username},${password})))))
        }

        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        Invoke-WebRequest -uri $url -Headers $headers
        # $Body = @{'data_key' = 'data_value'} | convertTo-Json
        # Invoke-WebRequest -uri $url -Headers $headers -Method POST -body $Body -ContentType 'application/json' -UseBasicParsing
        
      EOF
      ) 
      status_prefix = 'StatusCode'
      data_prefix = 'Content'
      data = nil 
      if output = Facter::Util::Resolution.exec('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"')
        status_line = output.split("\n").grep(/#{status_prefix}/).first       
        status = status_line.scan(/[\d\.]+/).first
        if status =~ /200/ 
          data_line = output.split("\n").grep(/#{data_prefix}/).first       
          data = data_line.scan(/"[^"]+"/).first
        end
      end
      data
    end 
  end
end

