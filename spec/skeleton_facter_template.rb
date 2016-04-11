# This is snapshot of serverspec-generated  Ruby script that is tailored to run on the target provisioned by Puppet Enterprise 3.2
# see `spec/windows/ruby_powershell_spec.rb` for alternative discovery

$LOAD_PATH.insert(0, 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/facter/lib')
$LOAD_PATH.insert(0, 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/hiera/lib')
$LOAD_PATH.insert(0, 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/puppet/lib')

require 'yaml'
require 'puppet'
require 'pp'

# custom fact 

require 'facter'

# Name of this fact.
fact_name = '...'
... code of the fact ...


# To run:  
# "c:\Program Files (x86)\Puppet Labs\Puppet Enterprise\sys\ruby\bin\ruby.exe" test.rb

# end of custom fact
# should not fail
puts Facter.value(fact_name.to_sym)

