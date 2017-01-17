if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

context 'Services' do
  describe service('WinRM') do
    it { should be_running } 
    it { should have_start_mode 'Automatic' } 
    it { should be_enabled   }
    # in the registry stored in ObjectName
    # in Powershell becomes 'StartName'
    it { should have_property({ 'StartName' => 'NT AUTHORITY\NetworkService' })  }
    # can not convert types 
    # it { should have_property({ 'DesktopInteract' => false })  }
  end
  describe command (<<-EOF
    # passing the switch to Powershell
    function FindService {
      param([string]$name,
        [switch]$run_as_user_account
      )
      $local:result = @()
      $local:result = Get-CimInstance -ComputerName '.' -Query "SELECT * FROM Win32_Service WHERE Name LIKE '%${name}%' or DisplayName LIKE '%${name}%'" | Select Name,StartName,DisplayName,StartMode,State

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
    function FindService {
      param([string]$name,
        [switch]$run_as_user_account
      )
      $local:result = @()
      $local:result = Get-CimInstance -ComputerName '.' -Query "SELECT * FROM Win32_Service WHERE Name LIKE '%${name}%' or DisplayName LIKE '%${name}%'" | Select Name,StartName,DisplayName,StartMode,State

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
    its(:exit_status) {should eq 0 }
  end

  context 'Running CmdLet' do
    service_name = 'name of the service' # case sensitive
    describe command("get-service -name '#{service_name}'") do
      its(:exit_status) { should eq 0 }
      [
        'Stopped',
        service_name
      ].each do |token|
        its(:stdout) { should contain token }
      end
    end
    describe service(service_name) do
      # likel to fail for a stopped service
      xit{ should be_stopped}
    end
  end
  context 'Service sun with Domain Account Credentials' do
    # real life example 
    # service may want to access the EventArchiver named pipe through use SMB share
    # hence is configured to be run under the domain account with administrator privileges
    service_name = 'Windows Remote Management' # case sensitive
    account_name = 'Network Service'
    account_domain = 'NT AUTHORITY'
    describe command (<<-EOF
      function FindService {
        param([string]$name,
          [switch]$run_as_user_account
        )
        $local:result = @()
        $local:result = Get-CimInstance -ComputerName '.' -Query "SELECT * FROM Win32_Service WHERE Name LIKE '%${name}%' or DisplayName LIKE '%${name}%'" | Select Name,StartName,DisplayName,StartMode,State

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
