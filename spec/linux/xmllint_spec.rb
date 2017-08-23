require 'spec_helper'

context 'xmllint' do

  context 'availability' do
  describe command('which xmllint') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match Regexp.new('/bin/xmllint', Regexp::IGNORECASE) }
    its(:stderr) { should be_empty }
  end
  end
  context 'querying XPaths' do
    catalina_version = '8.0.43'
    catalina_home = "/apps/tomcat/#{catalina_version}"
    web_xml = "#{catalina_home}/conf/web.xml"
    #  tomcat configuration is heavily name-spaced
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
end
