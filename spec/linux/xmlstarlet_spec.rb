require 'spec_helper'
require 'rexml/document'
include REXML

# when multiple nodes matching the xpath the xmllint collapsies the text into the single string,
# which makes developing expectations somewhat more challenging
# xmlstarlet which is available has a better output formatting
context 'xmlstartlet' do
  context 'attributes' do
    datafile = '/tmp/attributes.xml'
    before(:each) do
      Specinfra::Runner::run_command( <<-EOF
        # no space at beginning of the document is critical for xml
        cat<<END>#{datafile}
<?xml version="1.0"?>
<catalog>
  <driver url="jdbc:sqlite::memory:"/>
  <driver url="jdbc:hdb::memory:"/>
</catalog>
END
      EOF
      )
    end
    [
      "xmllint --xpath '/catalog/driver/@url' '#{datafile}'",
      "xmlstarlet sel -t -v '/catalog/driver/@url' '#{datafile}'",
    ].each do |commandline|
      describe command(<<-EOF
        #{commandline}
      EOF
      ) do
          its(:exit_status) { should eq 0 }
          [
            'jdbc:sqlite::memory:',
            'jdbc:hdb::memory:',
          ].each do |line|
            its(:stdout) { should match Regexp.new(line, Regexp::IGNORECASE) }
          end
          its(:stderr) { should_not match 'Failed to compile' }
      end
    end
  end

  context 'text' do
    datafile = '/tmp/text.xml'
    before(:each) do
      Specinfra::Runner::run_command( <<-EOF
        # no space at beginning of the document is critical for xml
        cat<<END>#{datafile}
<?xml version="1.0"?>
<catalog>
  <driver>
    <url>jdbc:sqlite::memory:</url>
  </driver>
  <driver>
    <url>jdbc:hdb::memory:</url>
  </driver>
</catalog>
END
    EOF
    )
    end
    [
      "xmllint --xpath '/catalog/driver/url/text()' '#{datafile}'",
      "xmlstarlet sel -t -v '/catalog/driver/url' '#{datafile}'",
    ].each do |commandline|
      describe command(<<-EOF
        #{commandline}
      EOF
      ) do
          its(:exit_status) { should eq 0 }
          [
            'jdbc:sqlite::memory:',
            'jdbc:hdb::memory:',
          ].each do |line|
            its(:stdout) { should match Regexp.new(line, Regexp::IGNORECASE) }
          end
          its(:stderr) { should_not match 'Failed to compile' }
      end
    end
    [
      "xmllint --xpath '/catalog/driver/url' '#{datafile}'",
      "xmlstarlet sel -t -c '/catalog/driver/url' '#{datafile}'",
    ].each do |commandline|
      describe command(<<-EOF
        #{commandline}
      EOF
      ) do
          its(:exit_status) { should eq 0 }
          [
            '<url>jdbc:sqlite::memory:</url>',
            '<url>jdbc:hdb::memory:</url>',
          ].each do |line|
            its(:stdout) { should match Regexp.new(line, Regexp::IGNORECASE) }
          end
          its(:stderr) { should_not match 'Failed to compile' }
      end
    end
  end
end

# RPM package with the dependencies is in
# http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xmlstarlet-1.6.1-1.el7.x86_64.rpm
# https://centos.pkgs.org/7/epel-x86_64/xmlstarlet-1.6.1-1.el7.x86_64.rpm.html
