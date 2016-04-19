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
      	script = "$cert_thumbprint = '#{cert_thumbprint}'; $certpath= 'LocalMachine\\TrustedPublisher'; pushd cert: ; cd '\\'; cd $certpath; $status = ((get-childitem -ErrorAction SilentlyContinue | where-object { $_.thumbprint -eq $cert_thumbprint }  ).count -ne 0 ); write-output $status.toString()" 
        # extract vendor application version from the help screen.
        if output = Facter::Util::Resolution.exec("#{exe} #{script}")
          status = output.split("\n").first
          status
      	end
      end
    end
  end
end