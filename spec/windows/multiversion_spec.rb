require_relative '../windows_spec_helper'

context 'Multiple Product Versions Acceptable' do
  latest_version = '2'
  latest_build = '00'
  previous_version = '1'
  previous_build = '00'
  context 'Package' do
    describe package(actual_package_name) do
      it { should be_installed  }
      # cannot expect - e.g. region differences
      xit { should be_installed.with_version("#{latest_version}.#{latest_build}") }
    end
    product_version = 'product_version'
    # NOTE: Redirection to 'NUL' failed: FileStream will not open Win32 devices such as disk partitions and tape drives. Avoid use of "\\.\" in the path.
    describe command(<<-EOF
    $product_version = '#{product_version}'
    $data =  & "C:\\Program Files\\Puppet Labs\\Puppet\\bin\\facter.bat" --puppet "${product_version}" 2> 1
    write-output $data
    EOF
    ) do
      its(:stdout) { should match /(#{previous_version}.#{previous_build}|#{latest_version}.#{latest_build})/ }
    end
  end
  
  
    describe command(<<-EOF
function FindInstalledApplicationWithVersionsArray {
  param($appName = '',$appVersionsArray = @())
  $DebugPreference = 'Continue'
  Write-Debug ('appName: "{0}", appVersions: @({1})' -f $appName,($appVersionsArray -join ', '))
  $appNameRegex = New-Object Regex (($appName -replace '\\[','\\[' -replace '\\]','\\]'))

  if ((Get-WmiObject win32_operatingsystem).OSArchitecture -notmatch '64')
  {
    $keys = (Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*')
    $possible_path = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
    if (Test-Path $possible_path)
    {
      $keys += (Get-ItemProperty $possible_path)
    }
  }
  else
  {
    $keys = (Get-ItemProperty 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*','HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*')
    $possible_path = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
    if (Test-Path $possible_path)
    {
      $keys += (Get-ItemProperty $possible_path)
    }
    $possible_path = 'HKCU:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
    if (Test-Path $possible_path)
    {
      $keys += (Get-ItemProperty $possible_path)
    }
  }

  if ($appVersionsArray.Length -eq 0) {
    $result = @( $keys | Where-Object { $appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName) })
    Write-Debug ('applications found:' + $result)
    Write-Output ([boolean]($result.Length -gt 0))
  }
  else {
    $result = @( $keys | Where-Object { $appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName) } | Where-Object { $appVersionsArray.Contains($_.DisplayVersion) })
    Write-Debug ('applications found:' + $result)
    Write-Output ([boolean]($result.Length -gt 0))
  }
}

$exitCode = 1
$success = $false
$ProgressPreference = 'SilentlyContinue'
$appVersionsArray = @( '2.19','2.20')
try {
  $success = ((FindInstalledApplicationWithVersionsArray -appName 'Defraggler' -appVersionsArray $appVersionsArray) -eq $true)
  if ($success -is [boolean] -and $success) {
    $exitCode = 0 }
} catch {
  Write-Output $_.Exception.Message
}
Write-Output "Exiting with code: ${exitCode}"
# NOTE: if two consecutive invocations, the second result is not reliable

    EOF
    ) do
        its(:stdout) do
          should match /Exiting with code: 0/
        end
      end
    end
  end
  
end

