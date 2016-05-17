
# Puppet 3.8, Windows 7, 32-bit
$LOAD_PATH.insert(0, 'C:/Program Files/Puppet Labs/Puppet/facter/lib')
$LOAD_PATH.insert(0, 'C:/Program Files/Puppet Labs/Puppet/hiera/lib')
$LOAD_PATH.insert(0, 'C:/Program Files/Puppet Labs/Puppet/puppet/lib')

# Puppet Enterprise 3.2, Windows Server 2008, 64-bit
# $LOAD_PATH.insert(0, 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/facter/lib')
# $LOAD_PATH.insert(0, 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/hiera/lib')
# $LOAD_PATH.insert(0, 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/puppet/lib')

require 'yaml'
require 'puppet'
require 'pp'

require 'facter'

# name of the custom fact
fact_name = 'fact_name'

# code of the fact to follow

# frequent choices are
# 'Win32API' , 'digest/md5' , 'ffi', 'powershell'
# NOTE - separate checks required with 64 bit binaries
# file
# To run:  
# "c:\Program Files (x86)\Puppet Labs\Puppet Enterprise\sys\ruby\bin\ruby.exe" test.rb
# see `spec/windows/ruby_powershell_spec.rb` for alternative discovery

Facter.add(fact_name) do
  setcode do
    'sample fact value'
  end
end
# end of custom fact

puts "#{fact_name} = '#{Facter.value(fact_name.to_sym)}'"
