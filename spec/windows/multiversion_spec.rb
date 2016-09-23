require_relative '../windows_spec_helper'

context 'Multiple Product Versions Acceptable' do
  package_name = 'Java 8 Update 101'

  latest_version = '8.0'
  latest_build = '1010.13'
  previous_version = '8.0'
  previous_build = '1010.9'
  product_version_fact_name = 'java_version'
  # Java SE Development Kit 8 Update 101
  describe package(package_name) do
    it { should be_installed  }
    # the following expectation cannot be satisfied if different build / version of Java are allowed to coexist in the cluster
    xit { should be_installed.with_version "#{latest_version}.#{latest_build}"  }
  end
  describe command(<<-EOF
  # NOTE: Redirection to 'NUL' failed:
  # FileStream will not open Win32 devices such as disk partitions and tape drives. Avoid use of "\\.\" in the path.
  $product_version = '#{product_version_fact_name}'
  package_name = '#{package_name}'
  $data =  & "C:\\Program Files\\Puppet Labs\\Puppet\\bin\\facter.bat" --puppet "${product_version}" 2> 1
  write-output $data
  $data =  & "C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet.bat" resource package "${package_name}" 2> 1
  write-output $data
  EOF
  ) do
      its(:stdout) { should match /(#{previous_version}.#{previous_build}|#{latest_version}.#{latest_build})/ }
  end


  describe command(<<-EOF
  # header: description of the command

  function FindInstalledApplicationWithVersionsArray {
  param(
    $appName = '',
    $appVersionsArray = @()
    )
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
$appVersionsArray = @( '8.0.1010.9','8.0.1010.13')
$appName = '#{package_name}'

try {
  $success = ((FindInstalledApplicationWithVersionsArray -appName $appName -appVersionsArray $appVersionsArray) -eq $true)
  if ($success -is [boolean] -and $success) {
    $exitCode = 0 }
} catch {
  Write-Output $_.Exception.Message
}
Write-Output "Exiting with code: ${exitCode}"
# NOTE: if consecutive invocations are performed, the second result is wrong

    EOF
    ) do
    its(:stdout) do
      should match /Exiting with code: 0/
    end
  end
end