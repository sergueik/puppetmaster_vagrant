# This skeleton script demonstrates
# perform Registry scan using Powershell inline
# This may be useful for Powershell directory-like providers other than registry:
# certificates, registry, firewall
# NOTE: this fact is quite fragile
# the inline script may work correctly in Powershell and cmd console, but return no result to Ruby
# NOTE: Powershell pipeline also seems to create a problem, also to a cmd console
# $value = (Get-ItemProperty -LiteralPath 'HKLM:\\SYSTEM\\CurrentControlSet\\services\\LanmanWorkstation\\Parameters' -name 'ServiceDll') | select-object -expandproperty ServiceDll

require 'yaml'
require 'puppet'
require 'pp'

require 'facter'

fact_name = 'registry_check'

property = 'ServiceDll'
path = 'HKLM:\\SYSTEM\\CurrentControlSet\\services\\LanmanWorkstation\\Parameters'
debug = false
inline_script = <<-EOF
  $debugpreference = 'Continue'
  $value = (Get-ItemProperty -LiteralPath 'HKLM:\\SYSTEM\\CurrentControlSet\\services\\LanmanWorkstation\\Parameters' -name 'ServiceDll').ServiceDll
  write-debug ('value = {0}' -f $value)
  return $value
EOF
inline_script = <<-EOF
  $debugpreference = 'Continue'
  $properties = @()
  $base_obj = Get-Item "HKLM:\\SYSTEM\\CurrentControlSet\\services\\mcollective"
  $count = $base_obj.Property.Count
  $item = 0
  while ($item -le $count) {
    $value_name = $base_obj.GetValueNames()[$item]
    $properties += $base_obj.GetValue($value_name)
    $item = $item + 1;
  }
  $result = $properties -join ','
  write-debug ('Result = {0}' -f $result)
  return $result
EOF
if Facter.value(:kernel) == 'windows'
  Facter.add(fact_name) do
    setcode do
     result = nil
      # NOTE: occasionally a simplified command line is better:
      # command = "\"c:/windows/system32/windowspowershell/v1.0/powershell.exe\" \"#{inline_script.gsub("\n",';')}\""
      command = "\"c:/windows/system32/windowspowershell/v1.0/powershell.exe\" -NoProfile -ExecutionPolicy unrestricted -command \"&{ #{inline_script.gsub("\n",';')} }\""
      if debug
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
        # NOTE: with Powershell debug messages printed to STDOUT become part of the "result"
        result = output.split("\r?\n").reject {|line| line =~ /^\s*$/ }.last
        if debug
          STDERR.puts "result=#{result}"
        end
        result
     end
    end
  end
end
# end of custom fact