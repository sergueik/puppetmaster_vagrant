require_relative '../windows_spec_helper'

# https://www.google.com/search?q=what+is+WCF+service+model&ie=utf-8&oe=utf-8

# x.gsub(/[()]/,"\\#{$&}")
context 'WCF Service Model' do

  describe command('& "C:\Windows\Microsoft.NET\Framework64\v3.0\Windows Communication Foundation\ServiceModelReg.exe" "-vi"') do
    #  WCF configuration from a typical Windows Server 2012 server IIS  role
    { 
    'HTTP Handlers' => 'Not Installed';
    'HTTP Handlers (WAS)' => 'Not Installed';
    # 'HTTP Handlers (WOW64)' => 'Not Installed';
    'HTTP Modules' => 'Not Installed';
    'HTTP Modules (WAS)' => 'Not Installed';
    # 'HTTP Modules (WOW64)' => 'Not Installed';
    # 'ListenerAdapter node for protocol msmq.formatname' => 'Not Installed';
    # 'ListenerAdapter node for protocol net.msmq' => 'Not Installed';
    # 'ListenerAdapter node for protocol net.pipe' => 'Not Installed';
    # 'ListenerAdapter node for protocol net.tcp' => 'Not Installed';
    # 'Machine.config Section Groups and Handlers' => 'Not Installed';
    # 'Machine.config Section Groups and Handlers (WOW64)' => 'Not Installed';
    # 'Protocol node for protocol msmq.formatname' => 'Not Installed';
    # 'Protocol node for protocol msmq.formatname (WOW64)' => 'Not Installed';
    # 'Protocol node for protocol net.msmq' => 'Not Installed';
    # 'Protocol node for protocol net.msmq (WOW64)' => 'Not Installed';
    # 'Protocol node for protocol net.pipe' => 'Not Installed';
    # 'Protocol node for protocol net.pipe (WOW64)' => 'Not Installed';
    # 'Protocol node for protocol net.tcp' => 'Not Installed';
    # 'Protocol node for protocol net.tcp (WOW64)' => 'Not Installed';
    # 'System.Web Build Provider' => 'Not Installed';
    # 'System.Web Build Provider (WOW64)' => 'Not Installed';
    # 'System.Web Compilation Assemblies' => 'Not Installed';
    # 'System.Web Compilation Assemblies (WOW64)' => 'Not Installed';
    # 'TransportConfiguration node for protocol msmq.formatname' => 'Not Installed';
    # 'TransportConfiguration node for protocol msmq.formatname (WOW64)' => 'Not Installed';
    # 'TransportConfiguration node for protocol net.msmq' => 'Not Installed';
    # 'TransportConfiguration node for protocol net.msmq (WOW64)' => 'Not Installed';
    # 'TransportConfiguration node for protocol net.pipe' => 'Not Installed';
    # 'TransportConfiguration node for protocol net.pipe (WOW64)' => 'Not Installed';
    # 'TransportConfiguration node for protocol net.tcp' => 'Not Installed';
    # 'TransportConfiguration node for protocol net.tcp (WOW64)' => 'Not Installed';
    }.each |feature, state| do
      line = feature.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]') + ' : ' + state
      its(:stdout) do
        should contain Regexp.new(line)
      end
    end
  end
end
