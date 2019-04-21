# This example script demonstrates encoding the script between Ruby and  Powershell
require 'yaml'
require 'puppet'
require 'pp'
require 'facter'

fact_name = 'registry_check'

property = 'ServiceDll'
path = 'HKLM:\\SYSTEM\\CurrentControlSet\\services\\LanmanWorkstation\\Parameters'
debug = true
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
inline_script = <<-EOF
  get-WmiObject -class Win32_Process  -filter 'name="explorer.exe"'|select-object -property ProcessName
EOF

if Facter.value(:kernel) == 'windows'
  Facter.add(fact_name) do
    setcode do
     result = nil
      # NOTE: occasionally a simplified command line is better:
      # command = "\"c:/windows/system32/windowspowershell/v1.0/powershell.exe\" \"#{inline_script.gsub("\n",';')}\""
      # note can not test in cmd shell.
      # powershell.exe -NoProfile -ExecutionPolicy unrestricted -encodedCommand IAAgAGcAZQB0AC0AVwBtAGkATwBiAGoAZQBjAHQAIAAtAGMAbABhAHMAcwAgAFcAaQBuADMAMgBfAFAAcgBvAGMAZQBzAHMAIAAgAC0AZgBpAGwAdABlAHIAIAAnAG4AYQBtAGUAPQAiAGUAeABwAGwAbwByAGUAcgAuAGUAeABlACIAJwB8AHMAZQBsAGUAYwB0AC0AbwBiAGoAZQBjAHQAIAAtAHAAcgBvAHAAZQByAHQAeQAgAFAAcgBvAGMAZQBzAHMATgBhAG0AZQA7AA=="
      # The input line is too long.
      encoded_inline_script  = Base64.strict_encode64(inline_script.gsub("\n",';').encode('utf-16le'))
      # NOTE: no double quoted full path powershell.exe in the command below
      # the command is somewhat fragile
      command = "powershell.exe -NoProfile -ExecutionPolicy unrestricted -encodedCommand #{encoded_inline_script}\""
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