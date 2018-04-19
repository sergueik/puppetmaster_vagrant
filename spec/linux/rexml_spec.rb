require 'spec_helper'
require 'rexml/document'
include REXML

context 'Tomcat server xml Test' do
  catalina_home = '/opt/tomcat/current'
  server_xml = "#{catalina_home}/conf/server.xml"
  describe file(server_xml) do
    begin
      content = Specinfra.backend.run_command("cat '#{server_xml}'").stdout
    rescue => e
      $stderr.puts e.to_s
      # may be missing
    end
    # Example emulates an tomcat server.xml configuration file using the example from
    # http://www.wellho.net/resources/ex.php4?item=a656/server.xml
    # NOTE: no leading whitespace allowed by XML spec
    if content.to_s.empty?
      content = <<-EOF
<?xml version="1.0"?>
      <Server port="8005" shutdown="SHUTDOWN">
        <!-- Sample server.xml file from http://www.wellho.net/resources/ex.php4?item=a656/server.xml - not minimal but sensibly trimmed -->
        <GlobalNamingResources>
          <Resource name="UserDatabase" auth="Container" type="org.apache.catalina.UserDatabase" description="User database that can be updated and saved" factory="org.apache.catalina.users.MemoryUserDatabaseFactory" pathname="conf/tomcat-users.xml"/>
        </GlobalNamingResources>
        <Service name="Catalina">
          <!-- Define a non-SSL HTTP/1.1 Connector on port 8080 -->
          <Connector port="8080" maxHttpHeaderSize="8192" maxThreads="50" minSpareThreads="5" maxSpareThreads="15" enableLookups="false" redirectPort="8443" acceptCount="50" connectionTimeout="40000" disableUploadTimeout="false" compression="on" compressionMinSize="2048" noCompressionUserAgents="gozilla, traviata" compressableMimeType="text/html,text/xml"/>
          <!-- Define a SSL HTTP/1.1 Connector on port 8443 -->
          <Connector port="8443" maxHttpHeaderSize="8192"
                     maxThreads="150" minSpareThreads="25" maxSpareThreads="75"
                     enableLookups="false" disableUploadTimeout="true"
                     acceptCount="100" scheme="https" secure="true"
                     clientAuth="false" sslProtocol="TLS" />
          <!-- Define an AJP 1.3 Connector on port 8009 -->
          <Connector port="8009" enableLookups="false" redirectPort="8443" protocol="AJP/1.3"/>
          <!-- Define a Proxied HTTP/1.1 Connector on port 8082 -->
          <!-- See proxy documentation for more information about using this. -->
          <Connector port="8082" maxThreads="150" minSpareThreads="25" maxSpareThreads="75" enableLookups="false" acceptCount="100" connectionTimeout="20000" disableUploadTimeout="true"/>
          <Engine name="Catalina" defaultHost="localhost" jvmRoute="jvm1">
            <Realm className="org.apache.catalina.realm.UserDatabaseRealm" resourceName="UserDatabase"/>
            <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true" xmlValidation="false" xmlNamespaceAware="false">
              <Valve className="org.apache.catalina.authenticator.SingleSignOn"/>
            </Host>
          </Engine>
        </Service>
      </Server>
      EOF
    end
    begin
      doc = Document.new(content)
    rescue ParseException =>  e
      # Will indicate the document is not well-formed
      $stderr.puts e.to_s
    end
    describe 'redirectPort 8080' do
      redirect_port = '8443'
      port = '8080'
      xpath = "/Server/Service/Connector[@port = \"#{port}\"]/@redirectPort"
      result = REXML::XPath.first(doc, xpath).value
      $stderr.puts result
      it { result.should match redirect_port }
    end
    describe 'Closures' do
      class_name = 'org.apache.catalina.authenticator.SingleSignOn'
      result = false
      hosts = doc.elements['Server'].elements['Service'].elements['Engine']
      hosts.each do |host_node|
        begin
        if host_node.class != REXML::Text &&  host_node.attributes['name'] == 'localhost'
          valve_node = host_node.elements['Valve']
          if valve_node.attributes['className'] == class_name
            $stderr.puts valve_node
            result =  true
          end
        end
        rescue NoMethodError => e
          $stderr.puts e.to_s
        end
      end
      $stderr.puts result
      it { result.should be_truthy }
    end
    describe 'Closures  mixed with XPath' do
      class_name = 'org.apache.catalina.authenticator.SingleSignOn'
      result = false
      doc.elements.each('Server/Service/Engine/Host[@name = "localhost"]/Valve') do |node|
        # $stderr.puts node.attributes['className']
        if node.attributes['className'] =~ /#{class_name}/
          $stderr.puts node
          result =  true
        end
      end
      $stderr.puts result
      it { result.should be_truthy }
    end
  end
end
