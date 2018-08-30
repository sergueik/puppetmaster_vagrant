if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

context 'Services' do
  describe service('Schedule') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
    it { should have_start_mode('Automatic') }
    it { should have_property({ 'StartName' => 'LocalSystem' }) }
    # unclear if it ever worked
    # it { should have_property({ 'ObjectName' => 'LocalSystem' }) }
    # its('ObjectName') { should eq 'LocalSystem' }
    # its('StartName') { should eq 'LocalSystem' }
    # its(:object_name) { should eq 'LocalSystem' }
    # its(:starname) { should eq 'LocalSystem' }
  end
  describe service('WinRM') do
    it { should be_running }
    it { should have_start_mode 'Automatic' }
    it { should be_enabled  }
    # NOTE the WMI 'StartName' of the 'win32_service' is stored as ObjectName in the registry
    it { should have_property({ 'StartName' => 'NT AUTHORITY\NetworkService' }) }
    # for LocalSystem, use LocaSystem
    # can not convert types
    # it { should have_property({ 'DesktopInteract' => false }) }
  end
  describe command (<<-EOF
    # passing the switch to Powershell
    function FindService {
      param([string]$name,
        [switch]$run_as_user_account
      )
      $local:result = @()
      $local:result = get-ciminstance -computername '.' -query "SELECT * FROM Win32_Service WHERE Name LIKE '%${name}%' or DisplayName LIKE '%${name}%'" |
        select-object -property Name,StartName,DisplayName,StartMode,State

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
      $local:result = get-cimInstance -computername '.' -Query "SELECT * FROM Win32_Service WHERE Name LIKE '%${name}%' or DisplayName LIKE '%${name}%'" |
        select-object -property Name,StartName,DisplayName,StartMode,State

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
    service_name = 'netman' # case sensitive
    # 'Network Connections'
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
  # origin: http://www.cyberforum.ru/powershell/thread2315782.html
  # processes and services query discussion (in Russian)
  context 'Service and hosting process' do
    service_name = 'netman' #  name of the service
    describe command(<<-EOF
    $service_name = '#{service_name}'
    get-process -id (([wmisearcher]"SELECT ProcessId FROM Win32_Service WHERE name='${service_name}'").get().ProcessId) | format-list
    EOF
  ) do
    its(:exit_status) { should eq 0 }
      {
        'Id' => "\\d",
        'Name'    => 'svchost'
      }.each do |key,val|
        its(:stdout) { should match /#{key}\s+:\s+#{val}/ }
      end
    end
  end

  context 'Service sun with Domain Account Credentials' do
    # real life example
    # service may want to access the EventArchiver named pipe through use SMB share
    # hence is configured to be run under the domain account with administrator privileges
    service_name = 'Windows Remote Management' # case sensitive
    account_name = 'NetworkService' #  'Network Service'
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
      its(:stdout) { should match /"DisplayName":  "#{service_name}/i }  # removed right quote
      its(:stdout) { should match /"StartName":  "#{account_domain}\\\\#{account_name}"/i }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end
