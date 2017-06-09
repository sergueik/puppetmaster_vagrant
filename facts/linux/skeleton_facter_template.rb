# On Linux - e.g. on a popular atlas/hashicorp images - Ruby may already be installed in '/usr/share/ruby/vendor_ruby' and symlinked to '/usr/bin/ruby'
# and libraries already in $LOAD_PATH
# otherwise use find command to locate Ruby embedded in the Puppet agent like
# sudo find /opt/puppetlabs/ -iname 'ruby' -executable -a -type f

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

