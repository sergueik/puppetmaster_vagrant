require 'spec_helper'
require 'rexml/document'
include REXML
xmlfile = '/var/lib/jenkins/config.xml'
context 'Basic' do
  describe file(xmlfile) do
    it { should exist }
    its(:content) { should match '<useSecurity>false</useSecurity>'}
  end
end
context 'XML validation' do
   # XPaths with namespaces
   describe command(<<-EOF
     xmllint --xpath "//*[local-name()='hudson']/*[local-name()='securityRealm']/text()" #{xmlfile}
   EOF
   ) do
     its(:exit_status) { should eq 0 }
   end
end
context 'XML validation 2' do
  describe file(xmlfile) do
    begin
      content = Specinfra.backend.run_command("cat '#{xmlfile}'").stdout
      begin
        doc = Document.new(content)
        result =  true
      rescue ParseException =>  e
        # Will indicate the document is not well-formed
        $stderr.puts e.to_s
      end
    rescue => e
      $stderr.puts e.to_s
      # may be missing
    end
    $stderr.puts result
    it { result.should be_truthy }
  end
end  
