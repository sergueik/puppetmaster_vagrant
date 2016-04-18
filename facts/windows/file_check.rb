#!/usr/bin/env ruby

# checks for the file using Powershell 
# This skeleton script allows generalization to many other providers that Powershell represents as directory-like interface:
# certificates, registry, firewall.

require 'facter'

fact_name = 'scheduled_task_noop'
filename = 'c:\Windows\Tasks\SampleJob.job'

if Facter.value(:kernel) == 'windows'
  exe = 'C:/Windows/system32/WindowsPowershell/v1.0/powershell.exe'
  if File.exists?(exe)
    exe = "\"#{exe}\"" if Facter.value(:kernel) == 'windows'
    Facter.add(fact_name) do
      setcode do
      	status = nil
      	script = "$filename = '#{filename}'; $status = (test-path -path $filename -ErrorAction SilentlyContinue ); write-output $status.toString()" 
        # extract vendor application version from the help screen.
        if output = Facter::Util::Resolution.exec("#{exe} #{script}")
          status = output.split("\n").first
          status
      	end
      end
    end
  end
end
