require_relative '../windows_spec_helper'

context 'Firewall Rule' do
  [
  'Windows Remote Management (HTTP-In)'
  ].each do |rule_name|
    describe command ("& netsh advfirewall firewall show rule name='#{rule_name}'") do
      its(:stdout) { should match /Enabled: +Yes/i }
      its(:stdout) { should match /Action: +Allow/i }
      its(:stdout) { should match /Profiles: +Public/i }
      its(:stdout) { should match /Direction: +In/i }
      its(:stdout) { should match /LocalPort: +5985/i }
      its(:stdout) { should match /RemoteIP: +Any/i }
      its(:stderr) { should be_empty }
      its(:exit_status) { should eq 0 }
    end
  end
end

# see also elaborate example in:
# https://github.com/hathoward/windows_firewall/blob/master/lib/puppet/provider/firewall_rule/rule.rb

context 'COM Check' do
  port = '5985'
  protocol = 'TCP'
  # based on:
  # https://blogs.technet.microsoft.com/jamesone/2009/02/17/how-to-manage-the-windows-firewall-settings-with-powershell/
  # https://github.com/OctopusDeploy/octopus-serverspec-extensions/blob/master/lib/octopus_serverspec_extensions/type/windows_firewall.rb
  # http://stackoverflow.com/questions/6597951/how-can-you-check-for-existing-firewall-rules-using-powershell
  # https://blogs.msdn.microsoft.com/tomholl/2010/11/07/adding-a-windows-firewall-rule-using-powershell/
  describe command(<<-EOF
    $protocol = '#{protocol}'
    $port = '#{port}'
    $FWprofileTypes = @{
      0 = 'All';
      1 = 'Domain';
      2 = 'Private';
      4 = 'Public'
    }
    $FwAction = @{
      1 = 'Allow';
      0 = 'Block'
    }
    $FwProtocols = @{
      1 = 'ICMPv4';
      2 = 'IGMP';
      6 = 'TCP';
      17 = 'UDP';
      41 = 'IPv6';
      43 = 'IPv6Route';
      44 = 'IPv6Frag';
      47 = 'GRE';
      58 = 'ICMPv6';
      59 = 'IPv6NoNxt';
      60 = 'IPv6Opts';
      112 = 'VRRP';
      113 = 'PGM';
      115 = 'L2TP';
      'ICMPv4' = 1;
      'IGMP' = 2;
      'TCP' = 6;
      'UDP' = 17;
      'IPv6' = 41;
      'IPv6Route' = 43;
      'IPv6Frag' = 44;
      'GRE' = 47;
      'ICMPv6' = 48;
      'IPv6NoNxt' = 59;
      'IPv6Opts' = 60;
      'VRRP' = 112;
      'PGM' = 113;
      'L2TP' = 115
    }
    $FWDirection = @{
      1 = 'Inbound';
      2 = 'outbound';
      'Inbound' = 1;
      'outbound' = 2
    }

    $rules= (New-Object –COMObject 'HNetCfg.FwPolicy2').rules
    $rules | where-object { $_.enabled -eq $true } |
          where-object { $_.direction -eq '1' } |
          select @{ Name = 'port'; expression = { $_.Localports } }, @{ Name = 'protocol'; expression = { $_.Protocol } } |
          where-object { $_.Protocol -eq 6 -and $_.port -eq $port}
    # Windows 2008 R2 and later
    $status = $false
    $port_filter = Get-NetFirewallPortFilter | Where-Object { $_.LocalPort -eq $port -and $_.Protocol -eq $protocol }
    if ($null -eq $port_filter) { $status = $false } else {
      $rule = Get-NetFirewallRule -AssociatedNetFirewallPortFilter $portfilter;
      if ($rule.enabled -or $rule.PrimaryStatus) {
        $status = $true
      } else {
        $status = $false
      }
    }

 EOF
  ) do
    its(:stdout) { should match /#{port}/i}
    its(:exit_status) { should eq 0 }
  end
end
