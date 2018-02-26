require 'spec_helper'

context 'xmllint' do

  context 'availability' do
    describe command('which xmllint') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new('/bin/xmllint', Regexp::IGNORECASE) }
      its(:stderr) { should be_empty }
    end
  end
  context 'Tomcat web.xml configuration ' do
    # XPaths with namespaces
    catalina_home = '/apps/tomcat/current' 
    web_xml = "#{catalina_home}/conf/web.xml"
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
    servlet_class_name = 'org.apache.catalina.servlets.DefaultServlet'
    describe command(<<-EOF
      SERVLET_CLASS_NAME='#{servlet_class_name}'
      WEB_XML='#{web_xml}'
      xmllint --xpath "//*[local-name()='servlet-class' and contains(text(),'${SERVLET_CLASS_NAME}')]" - < "${WEB_XML}"
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new(servlet_class_name, Regexp::IGNORECASE) }
      its(:stderr) { should be_empty }
    end
  end

  context 'Tomcat server.xml configuration' do
    # simple node attribute value validation
    catalina_home = '/apps/tomcat/current'
    server_xml = "#{catalina_home}/conf/server.xml"
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
end
