fact_name = 'product_version'
require 'win32/registry'
if Facter.value(:kernel) == 'windows'
  def registry_uninstall_version(product_displayname)
    product_version = nil
    debug = false
    $access = Win32::Registry::KEY_READ | 0x100
    # Win32::Registry::KEY_ALL_ACCESS
    # found_name = nil
    uninstall_key = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    Win32::Registry::HKEY_LOCAL_MACHINE.open(uninstall_key, $access ) do |reg_key| ;
      reg_key.each_key do |subkey|
        found_name = nil
        found_data = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open("#{uninstall_key}\\#{subkey}", $access ) do |reg_subkey|
          reg_subkey.each do |value_name, value_type, value_data|
            if value_name.eql?('DisplayVersion')
              found_data = value_data
            end
            if value_name.eql?('DisplayName')
              if value_data == product_displayname
                found_name = true
              end
            end
          endd
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
# alternative code:


# name of the custom fact
fact_name = 'product_version'
if Facter.value(:kernel) == 'windows'
  # NOTE: discovered that changing the case to require 'Win32/registry'in the next line leads to a ton of warnings under facter
  require 'win32/registry'
  # Select package version from uninstall keys that match DisplayName
  def registry_uninstall_version(product_displayname)
    # e.g. Puppet 'Puppet Agent (64-bit)'
    debug = false
    product_version = nil
    found_product = nil
    $access = Win32::Registry::KEY_READ | 0x100 # Win32::Registry::KEY_ALL_ACCESS
    uninstall_key = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    Win32::Registry::HKEY_LOCAL_MACHINE.open(uninstall_key, $access ) do |reg_key| ;
      found_product = nil
      reg_key.each_key do |subkey_name|
        Win32::Registry::HKEY_LOCAL_MACHINE.open("#{uninstall_key}\\#{subkey_name}", $access ) do |reg_subkey|
          reg_subkey.each do |name, type, data|
            if name.eql?('DisplayVersion')
              product_version = data
            end
            if name.eql?('DisplayName')
              if data == product_displayname
                found_product = true
              end
            end
          end
          if found_product
            break
          end
        end
      end
    end
    if found_product
      product_version
    end
  end
  Facter.add(fact_name) do
    setcode do
      # suppress the warnings
      $VERBOSE = nil
      registry_uninstall_version('Puppet Agent (64-bit)')
      # product_version '1.7.1'
    end
  end
end
