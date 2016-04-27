require_relative '../windows_spec_helper'

context 'XML configuration' do
  application_host_config_path = 'c:\Windows\system32\inetsrv\config\applicationHost.config' 
  describe command (<<-EOF
  $application_host_config_path =  '#{application_host_config_path}'
   [xml]$application_host_config = get-content -path $application_host_config_path
   $application_host_config.'configuration'.'system.webServer'
   EOF
  ) do
    expected_console_output = <<-EOF
    caching           : caching
    cgi               :
    defaultDocument   : defaultDocument
    directoryBrowse   : directoryBrowse
    fastCgi           :
    globalModules     : globalModules
    httpCompression   : httpCompression
    httpErrors        : httpErrors
    httpLogging       :
    httpProtocol      : httpProtocol
    httpRedirect      :
    httpTracing       :
    isapiFilters      : isapiFilters
    odbcLogging       :
    security          : security
    serverRuntime     :
    serverSideInclude : serverSideInclude
    staticContent     : staticContent
    tracing           : tracing
    urlCompression    :
    validation        :
    HeliconApe        : HeliconApe
    EOF
    expected_console_output.split(/\n/).each do |line|
      line.gsub!(/^\s+/,'').gsub!(/\s+$/,'')
      its(:stdout) {should  contain line} 
    end
  end
end

