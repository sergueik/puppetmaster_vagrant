require 'spec_helper'
require 'rexml/document'
include REXML

context 'xmllint' do
  # this example uses stock tomcat configuration for some extraction
  # https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-7-on-centos-7-via-yum
  catalina_home = '/usr/share/tomcat'
  server_xml = "#{catalina_home}/conf/server.xml"
  web_xml = "#{catalina_home}/conf/web.xml"

  context 'availability' do
    describe command('which xmllint') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new('/bin/xmllint', Regexp::IGNORECASE) }
      its(:stderr) { should be_empty }
    end
  end
  context 'Tomcat web.xml configuration' do
    # NOTE: the web.xml is using namespaces
    describe command(<<-EOF
      xmllint --xpath "//*[local-name()='servlet']/*[local-name()='servlet-class']/text()" #{web_xml}
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      [
        'org.apache.catalina.servlets.DefaultServlet',
        'org.apache.jasper.servlet.JspServlet'
      ].each do |servlet_class_name|
        its(:stdout) { should match Regexp.new(servlet_class_name, Regexp::IGNORECASE) }
      end
      its(:stderr) { should be_empty }
    end
    # sibling node locator, reading the XML from STDIN, like from another process output
    servlet_class_name = 'org.apache.catalina.servlets.DefaultServlet'
    describe command(<<-EOF
      SERVLET_CLASS_NAME='#{servlet_class_name}'
      WEB_XML='#{web_xml}'
      xmllint --xpath "//*[local-name()='servlet-class' and contains(text(),'${SERVLET_CLASS_NAME}')]" - < "${WEB_XML}"
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new(servlet_class_name, Regexp::IGNORECASE) }
      # RSpec 3.x syntax:
      its(:stdout) { is_expected.to match Regexp.new(servlet_class_name, Regexp::IGNORECASE) }
      its(:stderr) { should be_empty }
    end
  end

  context 'Tomcat server.xml configuration' do
    # simple node attribute value validation
    port = '8443'
    ciphers = [
      'TLS_RSA_WITH_AES_128_CBC_SHA',
      'TLS_RSA_WITH_AES_128_CBC_SHA256',
      'TLS_RSA_WITH_AES_128_GCM_SHA256',
      'TLS_RSA_WITH_AES_256_CBC_SHA',
      'TLS_RSA_WITH_AES_256_CBC_SHA256',
      'TLS_RSA_WITH_AES_256_GCM_SHA384'
    ]
    describe command(<<-EOF
      xmllint --xpath "/Server/Service/Connector[@port='#{port}']/@ciphers" #{server_xml}
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new('ciphers="' + ciphers.join(', ') + '"', Regexp::IGNORECASE) }
      its(:stderr) { should be_empty }
    end
  end
  context 'Jetty configuration' do
    # querying DOM node set
    jetty_home = '/openidm'
    jetty_xml = "#{jetty_home}/conf/jetty.xml"
    ciphers = [
      'TLS_RSA_WITH_AES_128_CBC_SHA',
      'TLS_RSA_WITH_AES_128_CBC_SHA256',
      'TLS_RSA_WITH_AES_128_GCM_SHA256',
      'TLS_RSA_WITH_AES_256_CBC_SHA',
      'TLS_RSA_WITH_AES_256_CBC_SHA256',
      'TLS_RSA_WITH_AES_256_GCM_SHA384'
    ]
    describe command(<<-EOF
      xmllint --xpath "/Configure/New[@id='sslContextFactory']/Set[@name='IncludeCipherSuites']/Array/Item" #{jetty_xml}
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new(ciphers.map{ |cipher| "<Item>#{cipher}</Item>" }.join(''), Regexp::IGNORECASE) }
      its(:stderr) { should be_empty }
    end
  end
  context 'HTML attribute validation' do
    # https://www.vultr.com/docs/how-to-install-and-configure-graphite-on-centos-7
    graphite_home = '/opt/graphite'
    describe command(<<-EOF
      xmllint --html --xpath \\
      '/html/body//form[@action="/account/login/"]//input[@type="password" or @type = "text"]'  \\
      #{graphite_home}/webapp/graphite/templates/login.html
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new('autocomplete="false"' )}
      its(:stdout) { should_not match 'HTML parser error' }
      its(:stderr) { should be_empty }
    end
  end
  context 'Missing Node Validation' do
    # some Java application are re-condifured by commenting whole nodes in XML configuration e.g.
    # https://docs.oracle.com/javadb/10.10.1.2/adminguide/radminjmxenabledisable.html
    # https://docs.wso2.com/display/ESB470/Default+Ports+of+WSO2+Products
    jmx_config = '/usr/share/wso2/apim/application/repository/conf/etc/jmx.xml'
    {
      'RMIRegistry' => 11111,
      'RMIServer' => 9999,
    }.each do |service, port|
      describe command("xmllint --xpath '//*[local-name()=\"#{service}\"]' '#{jmx_config}'") do
        # the ports will be disabled in the sut configuration. Node made invisible.
        # the alterantive way (not shown here) is to set RMIStartService text to false
        its(:stderr) { should match /XPath set is empty/ }
      end
      describe port(port) do
        it { should_not be_listening }
      end
    end
  end
end

