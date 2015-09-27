# origin: https://github.com/tzehon/vagrant-windows

$ChocoInstallPath = "$env:ProgramData\chocolateybin"
if ([Environment]::GetEnvironmentVariable('chocolateyinstall', [System.EnvironmentVariableTarget]::Machine) -ne $null) { 
write-output 'Chocolatey already installed.'
exit 0
}

# Put chocolatey on the MACHINE path, vagrant does not have access to user environment variables
$currentEnvPath = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
if (!$currentEnvPath.ToLower().Contains($ChocoInstallPath.ToLower())) {

  Write-Host "MACHINE PATH environment variable does not have `'$ChocoInstallPath`' in it. Adding..."
  $StatementTerminator = ';'
  $HasStatementTerminator = $currentEnvPath -ne $null -and $currentEnvPath.EndsWith($StatementTerminator)
  if (!$HasStatementTerminator -and $currentEnvPath -ne $null) { $ChocoInstallPath = $StatementTerminator + $ChocoInstallPath }
  if (!$ChocoInstallPath.EndsWith($StatementTerminator)) { $ChocoInstallPath += $StatementTerminator }

  [environment]::SetEnvironmentVariable('Path',$currentEnvPath + $ChocoInstallPath,[System.EnvironmentVariableTarget]::Machine)
}

$env:Path += ";$ChocoInstallPath"

if (!(Test-Path $ChocoInstallPath)) {
  # Install chocolatey
  write-host 'Install Chocolatey'
  invoke-expression ((New-Object net.webclient).DownloadString('http://chocolatey.org/install.ps1'))
}

