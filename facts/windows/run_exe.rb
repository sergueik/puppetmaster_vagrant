fact_name = 'application_version'

# extract vendor application version from the help screen.
# NOTE: very few Windows applications, e.g. Vanafi (https://www.venafi.com) provide console help
if Facter.value(:kernel) == 'windows'
  # exe = 'C:/Program Files/Venafi/Platform/VAgent.exe'
  exe = 'c:/Program Files/Puppet Labs/Puppet/bin/puppet.bat'
  if File.exists?(exe)
    exe = "\"#{exe}\""
    Facter.add(fact_name) do
      setcode do
      	version = nil
        # if output = Facter::Util::Resolution.exec("#{exe} -h")
        if output = Facter::Util::Resolution.exec("#{exe} --version")
          version_line = output.split("\n").first
          # v4.13.1029
          versions = version_line.scan /\bv\d+\.\d+\.[\d\-]+\b/
          version = versions[0].gsub( /\-\d+/, '.0').gsub('v','')
          version
      	end
      end
    end
  end
end