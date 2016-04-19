#!/usr/bin/env ruby

# checks for the file using Powershell 
# This skeleton script allows generalization to many other providers that Powershell represents as directory-like interface:
# certificates, registry, firewall.

require 'facter'

fact_name = 'cert_check'
filename = 'c:\Windows\Tasks\SampleJob.job'

if Facter.value(:kernel) == 'windows'
  exe = 'C:/Windows/system32/WindowsPowershell/v1.0/powershell.exe'
  if File.exists?(exe)
    exe = "\"#{exe}\"" if Facter.value(:kernel) == 'windows'
    Facter.add(fact_name) do
      setcode do
        cert_thumbprint = 'A88FD9BDAA06BC0F3C491BA51E231BE35F8D1AD5'       
      	status = nil
        # script = "write-output 'test'; $cert_thumbprint = '#{cert_thumbprint}'; $certpath= 'LocalMachine\\TrustedPublisher'; pushd cert: ; cd '\\'; cd $certpath; dir ;  $items = (get-childitem -ErrorAction SilentlyContinue | where-object { $_.thumbprint -eq $cert_thumbprint }  ); write-output ('items = {0}' -f $items.count) " 

      	# script = "$cert_thumbprint = '#{cert_thumbprint}'; $certpath= 'LocalMachine\\TrustedPublisher'; pushd cert: ; cd '\\'; cd $certpath; $status = ((get-childitem -ErrorAction SilentlyContinue | where-object { $_.thumbprint -eq $cert_thumbprint }  ).count -ne 0 ); write-output $status.toString()" 
        # NOTE: the | where-object  does not work
       	script = <<-EOF

$cert_thumbprint = '#{cert_thumbprint}'
$certpath= 'LocalMachine\\TrustedPublisher' 
pushd cert: 
cd '\\'
cd $certpath
$items = get-childitem -path '.'
foreach ($item in $items){ if ($item.thumbprint -eq $cert_thumbprint) {write-output $item.thumbprint} } 
   EOF
        script.gsub!(/\n/, ';')
        if output = Facter::Util::Resolution.exec("#{exe} #{script}")
          # Skip possible debugging output
          status = output.split("\n").last
          status
      	end
      end
    end
  end
end