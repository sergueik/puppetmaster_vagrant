#!/usr/bin/env ruby
# Locate the line <Product name = "Vendor" version = "1.2.3"/> 

require 'facter'

# Name of the fact
fact_name = 'xml_config_version'

# Code of the fact

def xml_config_get_version
  version_file = '/opt/vendor_path/config.xml'
  return nil if not File.readable?(version_file)
  begin
    version = nil
    
    product_name = 'Product Name' 
    version_line = File.read(version_file).each_line.grep(/Product name="#{product_name}"/).grep(/version/i)[0]
    version = version_line.scan(/[\d\.]+/)    
  rescue
    return nil
  end
  return version
end
Facter.add(fact_name) do
  confine :kernel => :linux
  setcode do
    xml_config_get_version
  end
end