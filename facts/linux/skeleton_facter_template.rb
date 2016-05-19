# On Linux  Ruby may or may not be installed in /usr/bin - e.g. on a popular atlas/hashicorp images
# and libraries in vendor_ruby and already in $LOAD_PATH
# otherwise use find the appropriate Pupppet's Ruby home

puppet_lib_home='/usr/share/ruby/vendor_ruby' # for atlas 
puppet_lib_home='/opt/puppetlabs/puppet/lib/ruby/vendor_ruby' # for enterprise

$LOAD_PATH.insert(0, '#{puppet_lib_home}/facter/lib') # absent for enterprise 
$LOAD_PATH.insert(0, '#{puppet_lib_home}/hiera/lib')
$LOAD_PATH.insert(0, '#{puppet_lib_home}/puppet/lib')

require 'yaml'
require 'puppet'
require 'pp'
require 'optparse'

require 'facter'

# name of the custom fact
fact_name = 'fact_name'

# code of the fact to follow

Facter.add(fact_name) do
  setcode do
    'sample fact value'
  end
end
# end of custom fact

puts "#{fact_name} = '#{Facter.value(fact_name.to_sym)}'"

