require 'spec_helper'

context 'Splunk Logging' do
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
    log_format = 'json'
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
end
