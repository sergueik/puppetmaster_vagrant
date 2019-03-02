require 'spec_helper'
require 'rexml/document'
include REXML

context 'Tomcat server xml Test' do
  catalina_home = '/usr/share/tomcat'
  server_xml = "#{catalina_home}/conf/server.xml"
  describe command(<<-EOF
xmllint --xpath '//*[local-name()="Valve"][@className="org.apache.catalina.valves.AccessLogValve"]/@directory' '#{server_xml}'
EOF
) do
    it 'should run without error' do
      expect(subject.send(:exit_status)).to eq 0
    end
    it 'should print log directory attribute' do
      expect(subject.send(:stdout)).to match /directory="logs"/
    end
    # its(:exit_status) { should be 0 }
    # its(:stdout) { should contain 'directory="logs"' }
  end
  describe file(server_xml) do
    begin
      content = Specinfra.backend.run_command("cat '#{server_xml}'").stdout
    rescue => e
      $stderr.puts e.to_s
      # may be missing
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
      # it { result.should match redirect_port }
      it "should discover known redirect port #{redirect_port}" do
        expect(result).to match redirect_port
      end
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
      it "should be truthy" do
        expect(result).to be_truthy
      end
      # Using `should` from rspec-expectations' old `:should` syntax without explicitly enabling the syntax is deprecated. Use the new `:expect` syntax or explicitly enable `:should` with `config.expect_with(:rspec) { |c| c.syntax = :should }` instead.
      # it { result.should be_truthy }
    end
    describe 'Closures mixed with XPath' do
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
      it "should be truthy" do
        expect(result).to be_truthy
      end
      # it { result.should be_truthy }
    end
  end
end
