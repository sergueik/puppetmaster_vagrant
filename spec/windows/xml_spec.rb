require_relative '../windows_spec_helper'

context 'XML configuration' do
  # sample configuration file
  xml_config_path = 'c:\Program Files\Internet Explorer\iexplore.VisualElementsManifest.xml'

  # A grep style expectations on XML configuration
  describe file( xml_config_path ) do
    it { should be_file}
    [
    '<Application',
        'xmlns:xsi="http:\/\/www.w3.org\/2001\/XMLSchema-instance">',
        '<VisualElements',
            'Square150x150Logo="images\\\\tileLogo.png"',
            'Square70x70Logo="images\\\\tinyLogo.png"',
            'ForegroundText="light"',
            'BackgroundColor="#2672ec"',
            'ShowNameOnSquare150x150Logo="on">',
        '<\/VisualElements>',
    '<\/Application>',
  ].each do |line|
      its(:content) { should match Regexp.new(line) }
    end
  end

  # A os-specific way is to open xml_config as XML
  describe command (<<-EOF

  $xml_config_path = '#{xml_config_path}'
  [xml]$xml_config_obj = get-content -path $xml_config_path
    # the same property resolution notation is used for element and attribute child node
    write-output $xml_config_obj.'Application'.'VisualElements'.'BackgroundColor'
  EOF
  ) do
    its(:exit_status) { should eq 0 }
    [
      '#2672ec',
      '#[a-f0-9\\-]+',
    ].each do |line|
      its(:stdout) { should match Regexp.new(line) }

    end
  end

  context 'using raw command output to build expectation' do
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
end

