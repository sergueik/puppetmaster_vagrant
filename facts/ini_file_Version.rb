#!/usr/bin/env ruby

# Locate the line Version = 1.2.3 
# in the ini file

require 'facter'

# Name of the fact
fact_name = 'ini_file_version'

# Code of the fact

def ini_file_get_version
  version_file = '/opt/vendor_path/config.ini'
  return nil if not File.readable?(version_file)
  begin
    version = nil    
    version = File.read(version_file).each_line.grep(/^Version=/i)[0].chomp.split('=')[1]
  rescue
    return nil
  end
  return version
end

Facter.add(fact_name) do
  confine :kernel => :linux
  setcode do
    ini_file_get_version
  end
end