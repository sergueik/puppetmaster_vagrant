#!/usr/bin/env ruby

require 'facter'

fact_name = 'fortify_version'

kernel = Facter.value('kernel')
if kernel == 'windows'
  require 'win32/registry'
  def hklm_read(key, value)
    data = nil
    begin
      reg = Win32::Registry::HKEY_LOCAL_MACHINE.open(key)
      type, data = reg.read(value)
      reg.close
    rescue Exception => e
      # possible: 'The system cannot find the file specified' Win32::Registry::Error
      # c:\modules\site_local\sep\lib\facter\sep.rb
    end
    return data
  end
  def hklm_read_subkeys(key, mask, value)
    STDERR.puts 'In hklm_read_subkeys'
    data = nil
    begin
      reg = Win32::Registry::HKEY_LOCAL_MACHINE.open(key)
      reg.each_key do |subkey,_|
      begin
        STDERR.puts "In subkey iterator: #{subkey}"
      rescue Exception => e2
        STDERR.puts e2.to_s
      end
        STDERR.puts "looking for mask = '#{mask}'" 
        if Regexp.new(mask, Regexp::IGNORECASE).match(subkey)
          STDERR.puts "Looking for data #{value}"
          data = hklm_read("#{key}\\#{subkey}", value)
        else
          STDERR.puts "Not a match for #{mask}, #{subkey}"
        end
      end
      reg.close
    rescue Exception => e
      STDERR.puts e.to_s
    end
    return data
  end
  # need to enum sub keys
  # 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Hewlett Packard Enterprise\HPE Security Fortify SCA and Applications 16.20', then grav the 'Version'
  result = hklm_read_subkeys('SOFTWARE\Wow6432Node\Hewlett Packard Enterprise', 'Fortify', 'Version')
  if result == nil
    begin
      result = hklm_read('SOFTWARE\Hewlett Packard Enterprise', 'Fortify', 'version')
    rescue
      result = ''
    end
  end

  if result != ''
    Facter.add(fact_name) do
      setcode { result }
    end
  end
end
