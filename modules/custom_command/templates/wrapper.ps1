function some_third_party_function {
  # e.g. Get-PendingReboot
  return New-Object -TypeName PSObject -Property @{
    result = $true
  }
}

# For Powershell caler e.g.:
# command => "\$result = invoke-expression -command ${script_path}; if (\$result ) { exit 0 } else { exit 1 }"
# NOTE: much simpler if one does not care about the exit status of the script one is running
# $probe_command  => "invoke-expression -Command ${script_path}",
# NOTE: help Powershell not slurp the exit code of invoke-expression 
try {
  $status = ((some_third_party_function | Select-Object -ExpandProperty result) -eq $true)
  if (-not ($status -is [boolean])) {
    $status = $false
  }
} catch {
  Write-Output $_.Exception.Message
  $status = $false
}

Write-Verbose "Exit with ${status}"
return $status

# For cmd caller e.g.:
# 
$exitcode = 1
$ProgressPreference = 'SilentlyContinue'
try {
  $status = ((some_third_party_function | Select-Object -ExpandProperty result) -eq $true)
  if ($status -is [boolean] -and $status) {
    $exitcode = 0 }
} catch {
  Write-Output $_.Exception.Message
}
Write-Output "Exit with ${exitcode}"
exit $exitcode