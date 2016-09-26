# Create HTTP POST request from an instance which has Powershell 2.0
# Powershell 2.0 does not have 'convertTo-json', 'Invoke-WebRequest'
# NOTE: no HTTP status code in this snippet
# origin:  http://technet.rapaport.com/Info/Prices/SampleCode/Full_Example.aspx
# origin: https://github.com/Infoblox-API/REST-PowerShell
# https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/

fact_name = 'rest_powershell4_test'

if Facter.value(:kernel) == 'windows'

  Facter.add(fact_name) do
    # fill in correct username and password
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
        # ignore self-signed certificates
        add-type @"
            using System.Net;
            using System.Security.Cryptography.X509Certificates;
            public class TrustAllCertsPolicy : ICertificatePolicy {
                public bool CheckValidationResult(
                    ServicePoint srvPoint, X509Certificate certificate,
                    WebRequest request, int certificateProblem) {
                    return true;
                }
            }
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        $webRequest = [System.Net.WebRequest]::Create($url)
        $webRequest.Method = 'POST'
        $webRequest.ContentType = 'application/json'
        [System.Collections.Specialized.NameValueCollection] $obj = New-Object System.Collections.Specialized.NameValueCollection
        $headers.Keys | foreach-object {
          $key = $_
          $value = $headers.Item($key)
          $obj.Add($key, $value)
        }

        # $obj.Add($auth_key, $auth_value) # custom authentication

        $webRequest.Headers.Add($obj)
        # Write-output ("The HttpHeaders are \\n{0}" -f $webRequest.Headers )
        [System.IO.Stream]$webRequestStream = $webRequest.GetRequestStream()
        [string]$postData = $Body
        [byte[]]$postArray = [System.Text.Encoding]::GetEncoding('ASCII').GetBytes($postData)
        $webRequestStream.Write($postArray, 0, $postArray.Length)
        $webRequestStream.Close()
        try {
          [System.Net.WebResponse] $response =  $req.GetResponse()
          # NOTE: no HTTP status code in this snippet
          [System.IO.StreamReader] $sr = new-object System.IO.StreamReader($response.GetResponseStream())
          [string]$Result = $sr.ReadToEnd()
          write-output ('Content: {0}' -f  $Result )
        } catch [Exception] {
	        # System.Management.Automation.ErrorRecord -> System.Net.WebException
           $exception = $_[0].Exception
           write-output ("Exception : Status: '{0}'  StatusCode: '{1}' Message: '{2}'" -f  $exception.Status,  $exception.Response.StatusCode, $exception.Message )
        }
      EOF
      )
      data_prefix = 'Content'
      data = nil
      if output = Facter::Util::Resolution.exec('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned -file "c:/windows/temp/test.ps1"')
      	# puts "output=#{output}"
        data_line = output.split("\n").grep(/#{data_prefix}/).first
        data = data_line.scan(/"[^"]+"/).first
      end
      data
    end
  end
end