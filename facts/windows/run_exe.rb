fact_name = 'application_version'

if Facter.value(:kernel) == 'windows'
  # very few Windows applications provide console help
  exe = 'C:/Program Files/Venafi/Platform/VAgent.exe'
  if File.exists?(exe)
    exe = "\"#{exe}\"" if Facter.value(:kernel) == 'windows'
    Facter.add(fact_name) do
      setcode do
      	version = nil
        # extract vendor application version from the help screen.
        if output = Facter::Util::Resolution.exec("#{exe} -h")
          version_line = output.split("\n").first
          versions = version_line.scan /\bv\d+\.\d+\.[\d\-]+\b/
          version = versions[0].gsub( /\-\d+/, '.0').gsub('v','')
          version
      	end
      end
    end
  end
end