#!/opt/puppetlabs/puppet/bin/ruby

# On a popular atlas/hashicorp Linux images, Ruby may already be installed
# under '/usr/share/ruby/vendor_ruby' and symlinked to '/usr/bin/ruby'
# and libraries may already be in $LOAD_PATH
# otherwise use find command to locate Ruby embedded in the Puppet agent like
# sudo find /opt/puppetlabs/ -iname 'ruby' -executable -a -type f

puppet_lib_home='/usr/share/ruby/vendor_ruby' # for atlas
puppet_lib_home='/opt/puppetlabs/puppet/lib/ruby/vendor_ruby' # for enterprise

$LOAD_PATH.insert(0, '#{puppet_lib_home}/facter/lib') # absent for enterprise
$LOAD_PATH.insert(0, '#{puppet_lib_home}/hiera/lib')
$LOAD_PATH.insert(0, '#{puppet_lib_home}/puppet/lib')

require 'yaml'
require 'puppet'
require 'facter'
require 'pp'
require 'optparse'


Facter.clear
base_facts = Facter.list

Puppet.initialize_settings
Facter.clear
Facter.search(Puppet[:libdir])
all_facts = Facter.list

Facter.clear
Facter.search(Puppet[:libdir])

(all_facts - base_facts).each do |item|
  time_elapsed = Benchmark.realtime { value = Facter[item].value }
  begin
    value = Facter[item].value
    puts sprintf("Found %s=%s in %f sec", item, Facter[item].value, time_elapsed)
  rescue
  end
end
