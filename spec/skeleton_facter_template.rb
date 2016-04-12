#!/usr/bin/env ruby

require 'facter'

# Name of this fact.
fact_name = 'venafi_version'
# code of the fact ...

if Facter.value(:kernel) == 'windows'
  venafi_exe = 'C:/Program Files/Venafi/Platform/VAgent.exe'
  if File.exists?(venafi_exe)
    venafi_exe = "\"#{venafi_exe}\"" if Facter.value(:kernel) == 'windows'
    Facter.add(fact_name) do
      setcode do

      	version = nil

        if output = Facter::Util::Resolution.exec("#{venafi_exe} -h")
        
          version_line = output.split("\n").first       
          versions = version_line.scan /\bv\d+\.\d+\.[\d\-]+\b/
          version = versions[0].gsub( /\-\d+/, '.0').gsub('v','')
          version 
     
      	end
      end
    end
  end
else
  def xml_get_version
    version_file = '/opt/venafi/agent/agent_product.xml'
    return nil if not File.readable?(version_file)
    begin
      # ini file
      # version = File.read(version_file).each_line.grep(/^Version=/i)[0].chomp.split('=')[1]
      version_line = File.read(version_file).each_line.grep(/Product name="Venafi Agent"/).grep(/version/)[0]
      # xml config file
      version = version_line.scan(/[\d\.]+/)    
    rescue
      return nil
    end
    return version
  end
  def rpm_get_version
    package_name = 'vagent'
    qx /rpm -qa --queryformat '%{V}.%{R}.0' '#{package_name}'/
  end
  Facter.add(fact_name) do
    setcode do
      # rpm_get_version
      xml_get_version
    end
  end
end
