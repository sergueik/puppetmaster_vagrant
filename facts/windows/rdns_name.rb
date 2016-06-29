#!/usr/bin/env ruby

require 'facter'

# Create HTTP POST request from an instance which has Powershell 3 + 
# origin:  http://stackoverflow.com/questions/27951561/use-invoke-webrequest-with-a-username-and-password-for-basic-authentication-on-t
# http://www.jokecamp.com/blog/invoke-restmethod-powershell-examples/
# https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/

fact_name = 'rest_powershell3_test'

if Facter.value(:kernel) == 'windows'
  Facter.add(fact_name) do
  
   instance_hostname = Facter.value(:hostname) 
   instance_ipaddress = Facter.value(:ipaddress) 
    data_prefix = 'rdnsname: '
    setcode do
      File.write('c:/windows/temp/test.ps1', <<-EOF
      EOF
Param( 
  [string]$instance_ipaddress = '#{instance_ipaddress}',
  [string]$instance_hostname = '#{instance_hostname}         
  ) 

try { 
  $result = [System.Net.Dns]::GetHostEntry($instance_ipaddress).HostName} 
catch [Exception]{
  $result = $instance_hostname.ToLower() + '.' +  (Get-WmiObject Win32_ComputerSystem).domain 
} 

write-output ('{0} "{1}" -f $data_prefix,  $result) 
      
      ) 
      data = nil 
      if output = Facter::Util::Resolution.exec('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"')
        data_line = output.split("\n").grep(/#{data_prefix}/).first       
        data = data_line.scan(/"[^"]+"/).first
      end
      data
    end 
  end
end


