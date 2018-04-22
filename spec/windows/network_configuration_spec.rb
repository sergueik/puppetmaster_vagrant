require_relative '../windows_spec_helper'

# based on: https://github.com/singlestone/Vagrant_DSC_CHEF_Example/blob/master/KMXSANDBOX/Scripts/Nic_Config.ps1
context 'WMI Network configuration' do
  describe command(<<-EOF
      # Retrieve the network adapter
      $adapter = Get-NetAdapter | ? {$_.InterfaceAlias -eq "Ethernet 2"}
      $address = Get-NetIPAddress | ? {$_.InterfaceIndex -eq $adapter.ifIndex -And $_.AddressFamily -eq "IPv4"}
      # Retrieve the instance IP address
      $address.IPAddress
      # Alternatively retrieve the instance IP address
      ($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress

      # Retrieve the default gateway
      $adapter | get-NetRoute | where-object {$_.DestinationPrefix -eq '0.0.0.0/0'} | select-object -property DestinationPrefix,AddressFamily,TypeOfRoute,NextHop |  format-list

      # Alternatively retrieve the default gateway
      (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway ) | select-object -property DestinationPrefix,AddressFamily,TypeOfRoute,NextHop |  format-list

  EOF
  ) do
    {
      'DestinationPrefix' => '0.0.0.0/0',
      'AddressFamily' => 'IPv4',
      'TypeOfRoute' => '3',
      'NextHop' => '10.0.2.2',
    }.each do |key,val|
      its(:stdout) { should match /#{key} *: *#{val}/i }
    end
    # NOTE: may get an error 'Preparing modules for first use.' andexit status 1
    # its(:exit_status) {should eq 0 }
  end
end