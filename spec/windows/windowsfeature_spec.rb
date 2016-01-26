require_relative '../windows_spec_helper'

context 'Windows Roles and Features' do
  describe command('Get-WindowsFeature | where-object {$_.Installed -eq $true} | format-list DisplayName') do
    [ #  List of windows Server 2012 features from a typical IIS server node
    #  'Application Development',
    #  'Application Initialization',
    #  'ASP',
    #  'ASP.NET 3.5',
    #  'ASP.NET 4.5',
    #  'ASP.NET 4.5',
    #  'Client Certificate Mapping Authentication',
    #  'Common HTTP Features',
    #  'Configuration APIs',
    #  'Default Document',
    #  'Directory Browsing',
    #  'File and Storage Services',
    #  'Graphical Management Tools and Infrastructure',
    #  'Health and Diagnostics',
    #  'HTTP Activation',
    #  'IIS 6 Management Compatibility',
    #  'IIS 6 Metabase Compatibility',
    #  'IIS 6 Scripting Tools',
    #  'IIS 6 WMI Compatibility',
    #  'IIS Client Certificate Mapping Authentication',
    #  'IIS Management Console',
    #  'IIS Management Scripts and Tools',
    #  'ISAPI Extensions',
    #  'ISAPI Filters',
    #  'Logging Tools',
    #  'Management Service',
    #  'Management Tools',
    #  '.NET Extensibility 3.5',
    #  '.NET Extensibility 4.5',
    #  '.NET Framework 3.5 Features',
      '.NET Framework 3.5 (includes .NET 2.0 and 3.0)',
    #  '.NET Framework 4.5',
    #  '.NET Framework 4.5 Features',
    #  'Process Model',
    #  'Request Filtering',
    #  'Security',
    #  'Server Graphical Shell',
    #  'SMB 1.0/CIFS File Sharing Support',
    #  'Static Content',
    #  'Storage Services',
    #  'TCP Port Sharing',
    #  'Tracing',
    #  'User Interfaces and Infrastructure',
    #  'WCF Services',
    #  'Web Server',
    #  'Web Server (IIS)',
    #  'Windows Authentication',
      'Windows PowerShell',
    #  'Windows PowerShell 2.0 Engine',
    #  'Windows PowerShell 4.0',
    #  'Windows PowerShell ISE',
    #  'Windows Process Activation Service',
    #  'WoW64 Support'
    ].each  do |line|
      its(:stdout) do
        should contain Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
      end
    end
  end 



