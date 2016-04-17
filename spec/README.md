Info
----
The collection of Windows-specific server spec snippet. 

Running ServerSpec directly on Target
-------------------------------------
Normally Serverspec Ruby scripts are integrated with Vagrant environment and run from local directory targeting local or cloud instances either directly or as a Vagrant plugin.

One can run serverspec locally on the target system after installing the dependency gems:
`rake`, `winrm` , `specinfra` , `serverspec` and truncating windows_spec_helper.rb to contain:
```
require 'serverspec'
require 'winrm'

set :backend, :winrm
set :os, :family => 'windows' 

user = 'vagrant'
pass = 'vagrant'
endpoint = "http://127.0.0.1:5985/wsman"
winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => user, :pass => pass, :basic_auth_only => true)
winrm.set_timeout 30 # .5 minutes max timeout for any operation
Specinfra.configuration.winrm = winrm
```
Then the serberspec run as usual, by Puppet Agent embedded Ruby:

```
pushd c:\Windows\TEMP
mkdir spec\windows
copy sample_spec.rb spec\windows
rake spec
Finished
1 example, 0 failures

```
with a sample_spec.rb
```
require_relative '../windows_spec_helper'

context 'Execute Locally' do
   
  context 'Basic' do
    describe file('c:/windows') do
      it { should be_directory } 
    end
  end
end

```  
For this to work the default winrm TCP port 5985 is used. 
The embedded Ruby runtime 2.0+ is required for `net-ssh` dependency gem. 
This restricts one to use Puppet 2015 Agent.
Configuring puppet 3.x agent to alllow local execution of serverspec tests is a work in progress.

