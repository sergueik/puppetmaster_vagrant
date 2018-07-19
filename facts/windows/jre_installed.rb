fact_name = 'jre_installed'

if Facter.value(:kernel) == 'windows'
  Facter.add(fact_name) do
    versions = []
    data_prefix = 'ProductName'
    tool = 'C:/Windows/system32/reg.exe'
    argument = 'query HKLM\SOFTWARE\CLASSES\INSTALLER\PRODUCTS /f "JRE " /s'
    if output = Facter::Util::Resolution.exec("#{tool} #{argument}")
      output.split("\n").grep(/#{data_prefix}/).each do |version|
        version.gsub!(/^.*REG_SZ\s+/,'')
        if version
          versions.push( version)
        end
      end
    end
    if versions.length > 0
      setcode { versions.join ',' }
    else
      setcode { '' }
    end
  end
end
