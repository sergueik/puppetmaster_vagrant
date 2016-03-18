
context 'Services' do
  describe command (<<-EOF

function FindService
{
  param([string]$name,
    [switch]$run_as_user_account
  )
  $local:result = @()
  $local:result = Get-CimInstance -ComputerName '.' -Query "SELECT * FROM Win32_Service WHERE Name LIKE '${name}' or DisplayName LIKE '${name}'" | Select Name,StartName,DisplayName,StartMode,State

  if ([bool]$PSBoundParameters['run_as_user_account'].IsPresent) {
    $local:result =  $local:result | Where-Object { -not (($_.StartName -match 'NT AUTHORITY') -or ( $_.StartName -match 'NT SERVICE') -or  ($_.StartName -match 'NetworkService' ) -or ($_.StartName -match 'LocalSystem' ))}
  }
    return $local:result


}

findService -Name '%' -run_as_user_account | ConvertTo-Json


EOF
) do
    its(:stdout) { should be_empty }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
  describe command (<<-EOF
function FindService
{
  param([string]$name,
    [switch]$run_as_user_account
  )
  $local:result = @()
  $local:result = Get-CimInstance -ComputerName '.' -Query "SELECT * FROM Win32_Service WHERE Name LIKE '${name}' or DisplayName LIKE '${name}'" | Select Name,StartName,DisplayName,StartMode,State

  if ([bool]$PSBoundParameters['run_as_user_account'].IsPresent) {
    $local:result =  $local:result | Where-Object { -not (($_.StartName -match 'NT AUTHORITY') -or ( $_.StartName -match 'NT SERVICE') -or  ($_.StartName -match 'NetworkService' ) -or ($_.StartName -match 'LocalSystem' ))}
  }
    return $local:result
}

findService -Name 'puppet' | ConvertTo-Json


EOF
) do
    its(:stdout) { should match /"DisplayName":  "Puppet Agent"/ }
    its(:stdout) { should match /"StartName":  "LocalSystem"/ }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
end

# $log = get-eventlog -logname 'application' | where-object { $_.'EventID' -eq 1 } |  where-object { $_.'Message' -match 'WhatsUp' } | where-object {$_.entrytype -eq 'Error' } | select-object -first 1;  write-output $log.'Source', $log.'TimeGenerated', $log.'Message'; $log.'entrytype'",
