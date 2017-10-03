#!/usr/bin/env ruby

require 'facter'

fact_name = 'facts_set'

kernel = Facter.value('kernel')
if kernel == 'windows'
  require 'win32/registry'
  def hklm_read_some_values(registry_key, mask)
    # STDERR.puts 'In hklm_some_values'
    data = nil
    entries = []
    begin
      STDERR.puts "Selecting matches of '#{mask}'"
      reg = Win32::Registry::HKEY_LOCAL_MACHINE.open(registry_key)
      reg.each_value do |value_name,_| # API.EnumValue(@hkey, index)
        if Regexp.new(mask, Regexp::IGNORECASE).match(value_name)
          STDERR.puts "Collecting #{value_name} data"
          type, data = reg.read(value_name) # API.QueryValue(@hkey, value_name)
          entries.push(data)
        end
      end
      reg.close
      data = entries.join(',')
    rescue Exception => e
      STDERR.puts e.to_s
    end
    return data
  end

  result = hklm_read_some_values('SYSTEM\CurrentControlSet\services\mcollective', '^D' ) # DisplayName, Description
  if result != ''
    Facter.add(fact_name) do
      setcode { result }
    end
  end
end