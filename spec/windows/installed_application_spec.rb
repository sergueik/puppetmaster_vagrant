# fix to 
# to support non-standard application names like 'Foo [Bar]'
# https://github.com/sergueik/specinfra/blob/master/lib/specinfra/backend/powershell/support/find_installed_application.ps1
function FindInstalledApplication {
  param($appName, $appVersion)
    write-host ('appName  = "{0}"' -f $appName )
    start-sleep 1

  if ((Get-WmiObject win32_operatingsystem).OSArchitecture -notmatch '64')
  {
    $keys= (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
    $possible_path= 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    if (Test-Path $possible_path)
    {
      $keys+= (Get-ItemProperty $possible_path)
    }
  }
    else
  {
    $keys = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
    $possible_path= 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    if (Test-Path $possible_path)
    {
      $keys+= (Get-ItemProperty $possible_path)
    }
    $possible_path= 'HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    if (Test-Path $possible_path)
    {
      $keys+= (Get-ItemProperty $possible_path)
    }
  }

    $keys | foreach-object { write-host $_ }

  if ($appVersion -eq $null) {
    write-host ('appName  = "{0}"' -f $appName )
start-sleep 1
$appNameRegex = new-object Regex(($appName -replace '\[', '\[' -replace '\]', '\]'))

$keys | foreach-Object {
write-host ('DisplayName = "{0}"' -f $_.DisplayName)
write-host ('PSChildName = "{0}"' -f $_.PSChildName)
if ($appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName) ){
write-host 'x'
}
 } 
    @($keys | Where-Object {$appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName)}).Length -gt 0

  }
  else{
    write-host ('appName  = "{0}", appVersion={1}' -f $appName,$appVersion )
start-sleep 1
$appNameRegex = new-object Regex(($appName -replace '\[', '\[' -replace '\]', '\]'))

$keys | foreach-Object {
write-host ('DisplayName = "{0}"' -f $_.DisplayName)
write-host ('PSChildName = "{0}"' -f $_.PSChildName)
if ($appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName) ){
write-host 'x'
}
 } 


    @($keys | Where-Object {$appNameRegex.ismatch($_.DisplayName) -or $appNameRegex.ismatch($_.PSChildName) } | Where-Object {$_.DisplayVersion -eq $appVersion} ).Length -gt 0

  }

}



$exitCode = 1
$ProgressPreference = "SilentlyContinue"
# try {
#  $success = ((FindInstalledApplication -appName 'Columbo [SRV]' -appVersion '2.0.2') -eq $true)
#  if ($success -is [Boolean] -and $success) { $exitCode = 0 } 
#  
#  } catch {
#  Write-Output $_.Exception.Message
#}

try {
  $success = ((FindInstalledApplication -appName 'Columbo [SRV]') -eq $true)
  if ($success -is [Boolean] -and $success) { $exitCode = 0 } 
  
  } catch {
  Write-Output $_.Exception.Message
}
Write-Output "Exiting with code: $exitCode"

