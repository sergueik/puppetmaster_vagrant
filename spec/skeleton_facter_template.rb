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

# name of the fact.
fact_name = '...'
# code of the fact ...
# frequent choices are
# 'Win32API' , 'digest/md5' , 'ffi', 
# NOTE - separate checks required with 64 bit binaries
# file
# To run:  
# "c:\Program Files (x86)\Puppet Labs\Puppet Enterprise\sys\ruby\bin\ruby.exe" test.rb
# Non-Windows.

package_name = 'vagent'
def rpm_get_version 
  "rpm -qa --queryformat '%{V}-%{R}' 'WFBeccclient'"
end


Facter.add(fact_name) do
  setcode do
    rpm_get_version
  end
end

def command_get_version
  version = nil

  if output = Facter::Util::Resolution.exec("#{venafi_exe} -h")
  
    version_line = output.split("\n").first       
    versions = version_line.scan /\bv\d+\.\d+\.[\d\-]+\b/
    version = versions[0].gsub( /\-\d+/, '.0').gsub('v','')
    version 

  end
end
def xml_get_version
  version_file = '...'

  return nil if not File.readable?(version_file)
  begin
  
          # version = File.read(version_file).each_line.grep(/^Version=/i)[0].chomp.sp
lit('=')[1]
  rescue
    return nil
  end
  return version
end
  
Facter.add(fact_name) do
  setcode do
    xml_get_version 
  end  
end
# end of custom fact
# should not fail
puts Facter.value(fact_name.to_sym)

