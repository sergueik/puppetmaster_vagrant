# On Linux - e.g. on a popular atlas/hashicorp images - Ruby may already be installed in '/usr/share/ruby/vendor_ruby' and symlinked to '/usr/bin/ruby'
# and libraries already in $LOAD_PATH
# otherwise use find command to locate Ruby embedded in the Puppet agent like
# sudo find /opt/puppetlabs/ -iname 'ruby' -executable -a -type f
# on some RHEL systems, the fact wrapper needs to run on Puppet's embedded ruby:
# /opt/puppetlabs/puppet/bin/ruby 'skeleton_facter_template.rb'
# will print fact_name = 'sample fact value'
# When run on system ruby, it would throw exception complaining about lack of puppet:
#   /usr/share/rubygems/rubygems/core_ext/kernel_require.rb:55:in `require': cannot load such file -- puppet (LoadError)

puppet_lib_home='/usr/share/ruby/vendor_ruby' # for atlas
puppet_lib_home='/opt/puppetlabs/puppet/lib/ruby/vendor_ruby' # for enterprise

$LOAD_PATH.insert(0, "#{puppet_lib_home}/facter/lib") # absent for enterprise
$LOAD_PATH.insert(0, "#{puppet_lib_home}/hiera/lib")
$LOAD_PATH.insert(0, "#{puppet_lib_home}/puppet/lib")
# with Puppet 4.4.2 Enterprise the 'hiera', 'facter','puppet' directories are no longer present
$LOAD_PATH.insert(0, puppet_lib_home)
# $stderr.puts $LOAD_PATH

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

