require 'serverspec'
require 'winrm'

# additional requirements
require 'type/my_type'

set :backend, :winrm
set :os, :family => 'windows' 

user = 'vagrant'
pass = 'vagrant'

winrm_port_use = '5985'

# NOTE:
# vagrant port --machine-readable is not more readable 
# the entry format looks like below
# 1456627866,windows,forwarded_port,5985,2200

%x|vagrant port #{ENV['TARGET_HOST']}|.split(/\r?\n/).each do |line|
  if line =~/#{winrm_port_use} \(guest\) => (\d+) \(host\)/
    winrm_port_use = $1
  end
end
# NOTE: getaddrinfo error if using ENV['TARGET_HOST'] on Windows host
# endpoint = "http://#{ENV['TARGET_HOST']}:5985/wsman"
endpoint = "http://127.0.0.1:#{winrm_port_use}/wsman"

winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => user, :pass => pass, :basic_auth_only => true)
winrm.set_timeout 30 # .5 minutes max timeout for any operation
Specinfra.configuration.winrm = winrm
