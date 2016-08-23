require_relative '../windows_spec_helper'


context 'Services' do
  describe command (<<-EOF
    # passing the switch to Powershell
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
  # same call, without the switch
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
    # its(:stdout) { should be_empty }
    its(:exit_status) {should eq 0 }
  end

  context 'WhatsUp Event Archiver Service' do
    # real life example,  service uses SMB shares for EventArchiver pipe access 
    # hence it is required to be run under the domain account with administrator privileges
    service_name = 'WhatsUp Event Archiver Service'
    account_name = '!eventservice1'
    account_domain = 'ad-ent'
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

      findService -Name '#{service_name}' | ConvertTo-Json

    EOF
    ) do
      its(:stdout) { should match /"DisplayName":  "#{service_name}"/i }
      its(:stdout) { should match /"StartName":  "#{account_domain}\\\\#{account_name}"/i }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end
