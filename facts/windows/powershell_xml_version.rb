# name of the custom fact
fact_name = 'powershell_version'

$DEBUG = false

# code of the fact

if Facter.value(:kernel) == 'windows'
  def powershell_xml_get_version

    result = nil
    file_path = 'version.xml'
    if File.exists?(file_path)
      begin
        script = "([xml](get-content -path '#{file_path}')).Info.Product.version"
        $stderr.puts "script: #{script}" if $DEBUG
        command = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -executionpolicy remotesigned -command \" & { #{script} }\""
        $stderr.puts "command: #{command}" if $DEBUG
        result = Facter::Util::Resolution.exec(command)
      rescue => ex
        $stderr.puts ex.to_s
        # throw ex
      end
    end
  end

  Facter.add(fact_name) do
    setcode do
      powershell_xml_get_version
    end
  end
end
# end of custom fact
