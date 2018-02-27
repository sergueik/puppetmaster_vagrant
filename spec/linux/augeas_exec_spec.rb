require 'spec_helper'
context 'Augeas' do
  context 'Use Puppet Augeas Provider to no-op modify the Tomcat server.xml' do
    tcp_port = '8443'
    catalina_home = '/apps/tomcat/current'
    describe command(<<-EOF
       puppet apply -e 'augeas {"tomcat sever aug": show_diff=> true, lens => "Xml.lns", incl => "#{catalina_home}/conf/server.xml", changes => [ "set Server/Service/Connector[#attribute/port=\\"#{tcp_port}\\"]/#attribute/port \\"#{tcp_port}\\""],}'
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
  context 'Use Puppet Augeas Provider to no-op modify the Apache httpd.conf' do
    apache_home = '/apps/apache/current'
    node_server_name = 'node-server-name'
    describe command(<<-EOF
      puppet apply -e 'augeas {"apache aug": lens => "Httpd.lns", incl => "#{apache_home}/etc/httpd/conf/httpd.conf", context => "/files/#{apache_home}/etc/httpd/conf/httpd.conf", changes => "set directive[.=\\"ServerName\\"]/arg \\"#{node_server_name}.puppet.localdomain\\" ",}'
    EOF
    ) do
      # NOTE: using Puppet apply is a bad idea,
      # since it leads to corrupting the configuration when no match found
      let(:path) { '/bin:/usr/bin:/sbin:/opt/puppetlabs/bin'}
      its(:stdout) { should match /Notice: Applied catalog/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
  context 'Use Augeas Commands to inspect the Tomcat server.xml' do
    tcp_port = '8443'
    catalina_home = '/apps/tomcat/current'
    aug_script = '/tmp/example.aug'
    xml_file = "#{catalina_home}/conf/server.xml"
    context 'Multiple nodes' do
      class_names = [
        'org.apache.catalina.startup.VersionLoggerListener',
        'org.apache.catalina.security.SecurityListener',
        'org.apache.catalina.core.AprLifecycleListener',
        'org.apache.catalina.core.JreMemoryLeakPreventionListener',
        'org.apache.catalina.mbeans.GlobalResourcesLifecycleListener',
        'org.apache.catalina.core.ThreadLocalLeakPreventionListener',
      ]
      aug_path = 'Server/Listener/#attribute/className'
      program=<<-EOF
        set /augeas/load/xml/lens "Xml.lns"
        set /augeas/load/xml/incl "#{xml_file}"
        load
        print /files#{xml_file}/#{aug_path}
      EOF
      describe command(<<-EOF
        echo '#{program}' > #{aug_script}
        augtool -f #{aug_script}
      EOF
      ) do
        let(:path) { '/bin:/usr/bin:/sbin:/opt/puppetlabs/puppet/bin'}
        class_names.each do |class_name|
          its(:stdout) { should match class_name }
        end
        its(:stderr) { should be_empty }
        its(:exit_status) {should eq 0 }
      end        
    end
    context 'Single node' do
      class_name = 'org.apache.catalina.startup.VersionLoggerListener'
      aug_path = "Server/Listener[1][#attribute/className="#{class_name}"]/#attribute/className"
      program=<<-EOF
        set /augeas/load/xml/lens "Xml.lns"
        set /augeas/load/xml/incl "#{xml_file}"
        load
        print /files#{xml_file}/#{aug_path}
        # NOTE: does not seem to allow using relative paths:
        # print Server/Listener[1]/#attribute/className
      EOF
      describe command(<<-EOF
        echo '#{program}' > #{aug_script}
        augtool -f #{aug_script}
      EOF
      ) do
        let(:path) { '/bin:/usr/bin:/sbin:/opt/puppetlabs/puppet/bin'}
        its(:stdout) { should match class_name }
        its(:stderr) { should be_empty }
        its(:exit_status) {should eq 0 }
      end
    end
  end
end
