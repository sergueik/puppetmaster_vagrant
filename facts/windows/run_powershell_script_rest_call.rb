#!/usr/bin/env ruby

require 'facter'

# Name of this fact.

fact_name = 'powershell_script_rest_call_response'

# code of the fact to follow

if Facter.value(:kernel) == 'windows'
  # origin:  http://stackoverflow.com/questions/27951561/use-invoke-webrequest-with-a-username-and-password-for-basic-authentication-on-t
  # http://www.jokecamp.com/blog/invoke-restmethod-powershell-examples/
  # https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/
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

        # override validation
        # The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        Invoke-WebRequest -uri $url -Headers $headers
#        Invoke-WebRequest -uri $url -Headers $headers -Method POST -body $body -ContentType 'application/json' -UseBasicParsing
        
        
        # override validation
        # The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        
        # Powershell 2.0 does not have 'Invoke-WebRequest' either..
        # http://technet.rapaport.com/Info/Prices/SampleCode/Full_Example.aspx
        $req = [System.Net.WebRequest]::Create($url) 
        $req.Method = 'POST'
        [System.Collections.Specialized.NameValueCollection]$o = new-object System.Collections.Specialized.NameValueCollection
        $o.Add($auth_key , $auth_value )
              
        $req.ContentType = 'application/json'
        # [System.Net.WebHeaderCollection]
        $req.Headers.Add($o)
        # Write-output ("The HttpHeaders are \n{0}" -f $req.Headers )
        [System.IO.Stream]$reqStream = $req.GetRequestStream()
        [string] $postData = $Body
        [byte[]] $postArray = [System.Text.Encoding]::GetEncoding('ASCII').GetBytes($postData)
        $reqStream.Write($postArray, 0, $postArray.Length)
        $reqStream.Close()
        try { 
          [System.Net.WebResponse] $response =  $req.GetResponse()
          # NOTE: no HTTP status code in this snippet
          [System.IO.StreamReader] $sr = new-object System.IO.StreamReader($response.GetResponseStream())
          [string]$Result = $sr.ReadToEnd()
          write-output ('Content: {0}' -f  $Result ) 
        } catch [Exception] {
           write-output 'exception : ' , $_
        }

      EOF
      ) 
      status_prefix = 'StatusCode'
      data_prefix = 'Content'
      data = nil 
      # command =  'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"'
      # puts "command=#{command}"
      if output = Facter::Util::Resolution.exec('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"')
      	# puts "output=#{output}"
        status_line = output.split("\n").grep(/#{status_prefix}/).first       
        status = status_line.scan(/[\d\.]+/).first
        if status =~ /200/ 
          data_line = output.split("\n").grep(/#{data_prefix}/).first       
          data = data_line.scan(/"[^"]+"/).first
        end
      end
      data
      # 'powershell_script_rest_call_response' = '200'
    end 
  end
end

