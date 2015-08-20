# https://github.com/tzehon/vagrant-windows
$ChocoInstallPath = "$env:SystemDrive\ProgramData\chocolateybin"

# Put chocolatey on the MACHINE path, vagrant does not have access to user environment variables
$envPath = $env:PATH
if (!$envPath.ToLower().Contains($ChocoInstallPath.ToLower())) {

  Write-Host "PATH environment variable does not have `'$ChocoInstallPath`' in it. Adding..."
  $ActualPath = [environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine)
  $StatementTerminator = ";"
  $HasStatementTerminator = $ActualPath -ne $null -and $ActualPath.EndsWith($StatementTerminator)
  if (!$HasStatementTerminator -and $ActualPath -ne $null) { $ChocoInstallPath = $StatementTerminator + $ChocoInstallPath }
  if (!$ChocoInstallPath.EndsWith($StatementTerminator)) { $ChocoInstallPath += $StatementTerminator }

  [environment]::SetEnvironmentVariable('Path',$ActualPath + $ChocoInstallPath,[System.EnvironmentVariableTarget]::Machine)
}

$env:Path += ";$ChocoInstallPath"

if (!(Test-Path $ChocoInstallPath)) {
  # Install chocolatey
  invoke-expression ((New-Object net.webclient).DownloadString('http://chocolatey.org/install.ps1'))
}

