fact_name = 'product_version'
require 'win32/registry'
if Facter.value(:kernel) == 'windows'
  def registry_uninstall_version(product_displayname)
    product_version = nil
    debug = false
    $access = Win32::Registry::KEY_READ | 0x100
    # Win32::Registry::KEY_ALL_ACCESS
    # found_name = nil
    Win32::Registry::HKEY_LOCAL_MACHINE.open("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", $access ) do |reg_key| ;
      reg_key.each_key do |subkey|
        found_name = nil
        found_data = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\#{subkey}", $access ) do |reg_subkey|
          reg_subkey.each do |value_name, value_type, value_data|
            if value_name.eql?('DisplayVersion')
              found_data = value_data
            end
            if value_name.eql?('DisplayName')
              if value_data == product_displayname
                found_name = true
              end
            end
          end
          if found_name
            product_version = found_data
            if debug
              $stderr.puts subkey
              $stderr.puts product_version
            end
            break
          end
        end
      end
    end
    product_version
  end
  Facter.add(fact_name) do
    setcode do
      registry_uninstall_version('7-Zip 9.20')
      # product_version = '9.20.00.0'
    end
  end
end  
