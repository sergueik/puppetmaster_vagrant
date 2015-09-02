require 'serverspec'
require 'winrm'

set :backend, :winrm
set :os, :family => 'windows' 
user = 'vagrant'
pass = 'vagrant'
# TODO: manage winrm_host, winrm_port
endpoint = "http://#{ENV['TARGET_HOST']}:5985/wsman"
endpoint = "http://127.0.0.1:5985/wsman"

winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => user, :pass => pass, :basic_auth_only => true)
winrm.set_timeout 300 # 5 minutes max timeout for any operation
Specinfra.configuration.winrm = winrm
