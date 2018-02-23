require 'spec_helper'

context 'Tomcat' do
  context 'Use Puppet Augeas Commands to inspect the Tomcat server.xml' do
    describe command(<<-EOF
      puppet apply -e 'augeas {"tomcat sever aug":  show_diff=> true, lens => "Xml.lns",  incl => "/apps/tomcat/current/conf/server.xml", changes => [  "set /files/apps/tomcat/current/conf/server.xml/Server/Service/Connector[#attribute/port=\\"8443\\"]/#text \\"    \\""],}'
    EOF
    ) do
      let(:path) { '/bin:/usr/bin:/sbin:/opt/puppetlabs/bin'}
      its(:stdout) { should match /Notice: Applied catalog/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end
