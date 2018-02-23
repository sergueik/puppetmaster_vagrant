require 'spec_helper'

context 'Tomcat Configuration' do
  context 'Use Puppet Augeas Commands to inspect the Tomcat server.xml' do
    tcp_port = '8443'
    catalina_home = '/apps/tomcat/current'
    describe command(<<-EOF
      puppet apply -e 'augeas {"tomcat sever aug": show_diff=> true, lens => "Xml.lns", incl => "#{catalina_home}/conf/server.xml", changes => [ "set /files#{catalina_home}/conf/server.xml/Server/Service/Connector[#attribute/port=\\"#{tcp_port}\\"]/#attribute/port \\"#{tcp_port}\\""],}'
    EOF
    ) do
      # NOTE: using Puppet apply is a bad idea, since it leads to creation of new XML nodes in the target file when no matching nodes found
      # e.g. <Connector></Connector>
      let(:path) { '/bin:/usr/bin:/sbin:/opt/puppetlabs/bin'}
      its(:stdout) { should match /Notice: Applied catalog/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
end
