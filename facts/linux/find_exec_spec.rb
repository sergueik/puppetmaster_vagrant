#!/usr/bin/env ruby

require 'facter'

# Name of this fact.
fact_name = 'fortify_product_version'

if Facter.value(:kernel) == 'Linux'
  install_dir = '/opt/HPE_Security/Fortify_SCA_and_Apps_16.20'
  product_name = 'HPE Security Fortify SCA and Applications'
  command = "/bin/find '#{install_dir}' -maxdepth 1  -executable -iname 'Uninstall*' -exec {} --help \\;"  
  command_output = Facter::Util::Resolution.exec(command)
  if ! command_output.nil? 
    result = command_output.split(/\r?\n/).grep(/^#{product_name}.*$/i)[0].gsub(/^.*\b(\d+\.\d+\.\d+)\b.*$/,'\1')
  end
end
if result != ''
  Facter.add(fact_name) do
    setcode { result }
  end
end


