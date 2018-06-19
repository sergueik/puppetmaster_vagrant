require 'spec_helper'
require 'json'
require 'ostruct'

$DEBUG = true

context 'Splunk Logging' do
  log_format = 'json'
  context 'Virtual Host settings' do
    # Verifies presence of the line
    # CustomLog "logs/access-splunk-json.log" json
    # in '/etc/httpd/conf/httpd.conf'
    # NOTE: likely would need to change to '/etc/httpd/conf.d/vhost.conf' in real life scenario
    describe file('/etc/httpd/conf/httpd.conf') do
      {
        'combined' => 'logs/access_log',
        'json'     => 'logs/access-splunk-json.log',
      }.each do |format,log|
        # line = "CustomLog \"#{log}\" \"#{format}\""
        line = "CustomLog \"#{log}\" #{format}"
        its(:content) { should match "^\s*" + Regexp.escape(line) }
      end
    end
  end
  # verifies presence of the line
  # LogFormat "{\"protocol\" : \"%H\"}" json
  # in '/etc/httpd/conf/httpd.conf'
  # NOTE:  in real life scenario many more fields
  context 'Global Settings' do
    context 'Processing with temp file and jq' do
      describe command(<<-EOF
        sed -n 's/LogFormat \\(.*\\) #{log_format}$/echo \\1 | jq -M "."/p' '/etc/httpd/conf/httpd.conf' > /tmp/check.sh
        /bin/sh /tmp/check.sh
      EOF
      ) do
        let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
        its(:exit_status) { should eq 0 }
        # include as many domain-specific fields from jq output as needed
        its(:stdout) { should match Regexp.new('"protocol": "%H"', Regexp::IGNORECASE) }
        its(:stderr) { should be_empty }
      end
    end
    context 'Processing with shell eval and jq' do
      describe command(<<-EOF
        RAWDATA=$(sed -n 's/^ *LogFormat \\(.*\\) #{log_format}$/\\1/p' '/etc/httpd/conf/httpd.conf')
        eval RESULT=$RAWDATA
        echo $RESULT | jq -M '.'
      EOF
      ) do
        let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
        its(:exit_status) { should eq 0 }
        # include as many domain-specific fields from jq output as needed
        its(:stdout) { should match Regexp.new('"protocol": "%H"', Regexp::IGNORECASE) }
        its(:stderr) { should be_empty }
      end
    end

    # this will break with numerous 
    # Exception `IO::EAGAINWaitReadable' at /root/.gem/ruby/2.1.0/gems/specinfra-2.73.0/lib/specinfra/backend/exec.rb:102 - 
    # Resource temporarily unavailable - 
    # read would block
    # need to test under uru/Ruby 2.33
    context 'Processing with Ruby JSON module' do
      extract_command = "sed -n 's/LogFormat \\(.*\\) #{log_format}$/\\1/p' '/etc/httpd/conf/httpd.conf'"
      begin
        config_data = command(extract_command).stdout
        $stderr.puts 'raw config_data: ' + config_data if $DEBUG
      rescue => e
        $stderr.puts 'Exception from running the command: ' + e.to_s
      end
      $stderr.puts 'Deserializing data' if $DEBUG
      begin
        $stderr.puts 'Trying JSON parse' if $DEBUG
        service_object = JSON.parse(config_data)
      rescue Exception => e
        $stderr.puts 'Exception from JSON parse: ' + e.to_s
        service_object = "{\"protocol\" : \"%H\"}"
      end
      if ! service_object.nil?
        $stderr.puts 'Configuration: ' + service_object.class.name if $DEBUG
        describe 'Test' do
          # subject { OpenStruct.new service_object['protocol'] }
          # undefined method `each_pair' for "protocol":String
          # subject { OpenStruct.new service_object }
          # undefined method `each_pair' for "{\"protocol\" : \"%H\"}":String
          subject { service_object }
          its(:protocol) { should be '%H' }
        end
      end
    end  
  end
end
