require 'yaml'
require 'puppet'
require 'pp'

require 'facter'

# name of the custom fact
fact_name = 'registry_check'

# code of the fact to follow
# perform Registry scan using Powershell inline
# This skeleton script demonstrates writing Powershell directory-like provider interface invocation inline:
# certificates, registry, firewall
property = 'ServiceDll'
path = 'HKLM:\\SYSTEM\\CurrentControlSet\\services\\LanmanWorkstation\\Parameters'
debug = false
# inline script works when run in cmd window, but might fail to return the string value to Ruby
inline_script = <<-EOF
  $debugpreference = 'Continue'
  $value = (Get-ItemProperty -LiteralPath 'HKLM:\\SYSTEM\\CurrentControlSet\\services\\LanmanWorkstation\\Parameters' -name 'ServiceDll').ServiceDll
  write-debug ('value = {0}' -f $value)
  return $value
EOF
if Facter.value(:kernel) == 'windows'
  exe = 'C:/Windows/system32/WindowsPowershell/v1.0/powershell.exe'
  if File.exists?(exe)
    exe = "\"#{exe}\""
  end
  if Facter.value(:kernel) == 'windows'
    Facter.add(fact_name) do
      setcode do
       status = nil
        command = "#{exe} \"#{inline_script.gsub("\n",';')}\""
        if debug
          STDERR.puts "script=\n#{inline_script.gsub("\n",';')}"
          STDERR.puts "command=\n#{command}"
        end
        output = Facter::Util::Resolution.exec(command)
        if output.nil?
          if debug
            STDERR.puts 'no output'
          end
        else
          if debug
            STDERR.puts "output=\"#{output}\""
          end
          status = output.split("\n").last
          if debug
            STDERR.puts "status=#{status}"
          end
          status
       end
      end
    end
  end
end
# end of custom fact
