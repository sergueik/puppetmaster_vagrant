# Create HTTP POST request from an instance with Powershell host 2.0 installed
# Powershell 2.0 does not have 'convertTo-json', 'Invoke-WebRequest'
# NOTE: no HTTP status code in this snippet
# origin:  http://technet.rapaport.com/Info/Prices/SampleCode/Full_Example.aspx
# https://blogs.technet.microsoft.com/bshukla/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webclient/
# see also
# https://github.com/voxpupuli/puppet-download_file/blob/master/templates/download.ps1.erb
# https://www.datacore.com/RESTSupport-Webhelp/using_windows_powershell_as_a_rest_client.htm

fact_name = 'rest_powershell2_test'

if Facter.value(:kernel) == 'windows'

  Facter.add(fact_name) do
    # fill in correct username and password
    username = 'username'
    password = 'password'
    auth_key = 'auth_key'
    auth_value = 'auth_value'
    proxy_address = ''
    proxy_user = ''
    proxy_password = ''
    is_password_secure = false
    cookie_string = ''
    url = 'https://api.github.com/user'
    script_filepath = 'c:/windows/temp/test.ps1'

    setcode do
      File.write(script_filepath, <<-EOF

        param(
          [string]$username = '#{username}',
          [string]$password = '#{password}',
          [string]$auth_key = '#{auth_key}',
          [string]$auth_value = '#{auth_value}',
          [string]$proxyAddress = '#{proxy_address}',
          [string]$proxyUser = '#{proxy_user}',
          [string]$proxyPassword = '#{proxy_password}',
          [bool]$is_password_secure = is_password_secure,
          [string]$cookie_string = '#{cookie_string}',
          [string]$url = '#{url}'
        )

        $headers = @{ 'Authorization' =
          ('Basic {0}' -f ([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f ${username},${password})))))
        }

        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

        $webRequest = [System.Net.WebRequest]::Create($url)

        if ($proxyAddress -ne '') {
          if (!($proxyAddress.StartsWith('http://') -or $proxyAddress.StartsWith('https://'))) {
            $proxyAddress = 'http://' + $proxyAddress
          }

          $proxy = New-Object System.Net.WebProxy
          $proxy.Address = $proxyAddress
          if (($proxyPassword -ne '') -and ($proxyUser -ne '')) {

            if ($is_password_secure) {
              $password = ConvertTo-SecureString -string $proxyPassword
            } else {
              $password = ConvertTo-SecureString "$proxyPassword" -AsPlainText -Force
            }

            $proxy.Credentials = New-Object System.Management.Automation.PSCredential($proxyUser,$password)
            $webRequest.UseDefaultCredentials = $true
          }
          $webRequest.proxy = $proxy
        }

        $webRequest.Method = 'POST'
        $webRequest.ContentType = 'application/json'

        if ($cookie_string -ne ''){
          $webRequest.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie_string)
        }

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
          [System.Net.WebResponse] $response =  $webRequest.GetResponse()
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
      powershell_exec = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
      powershell_flags = '-executionpolicy remotesigned'
      if output = Facter::Util::Resolution.exec("#{powershell_exec} #{powershell_flags} -file \"#{script_filepath}\"")
      	# puts "output=#{output}"
        data_line = output.split("\n").grep(/#{data_prefix}/).first
        data = data_line.scan(/"[^"]+"/).first
      end
      data
    end
  end
end