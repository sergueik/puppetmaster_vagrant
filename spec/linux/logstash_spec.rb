require 'spec_helper'
require_relative '../type/command'

context 'Command STDOUT Ruby debug format test' do
  describe command(<<-EOF
    echo '
{
      \"timestamp\" => \"11/Dec/2013:00:01:45 -0800\"
}

'
  EOF
  ) do
    its(:stdout_as_data) { should include('timestamp') }
    its(:stdout_as_data) { should include('timestamp' => '11/Dec/2013:00:01:45 -0800') }
    # its(:stdout) { should have_entry 'timestamp' => '11/Dec/2013:00:01:45 -0800' }
  end
end

context 'Command STDOUT Ruby debug format test' do
  describe command(<<-EOF
    echo '
{
        "request" => "/xampp/status.php",
          "agent" => "\\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0\\"",
           "auth" => "-",
          "ident" => "-",
           "verb" => "GET",
        "message" => "127.0.0.1 - - [11/Dec/2013:00:01:45 -0800] \\"GET /xampp/status.php HTTP/1.1\\" 200 3891 \\"http://cadenza/xampp/navi.php\\" \\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0\\"",
       "referrer" => "\\"http://cadenza/xampp/navi.php\\"",
     # NOTE: one need to quote @timestamp somehow
     "@timestamp" => "2013-12-11T08:01:45.000Z",
       "response" => "200",
          "bytes" => "3891",
       "clientip" => "127.0.0.1",
       "@version" => "1",
           "host" => "osboxes",
    "httpversion" => "1.1",
      "timestamp" => "11/Dec/2013:00:01:45 -0800"
}

'
  EOF
  ) do
    its(:stdout_as_data) { should include('timestamp') }
    its(:stdout_as_data) { should include('timestamp' => '11/Dec/2013:00:01:45 -0800') }
    # its(:stdout) { should have_entry 'timestamp' => '11/Dec/2013:00:01:45 -0800' }
  end
end
context 'LogStash processing' do
  conf = <<-EOF
    input { stdin { } }
    
    filter {
      grok {
        match => { "message" => "%{COMBINEDAPACHELOG}" }
      }
      date {
         match => [ "timestamp" , "\\"dd/MMM/yyyy:HH:mm:ss Z\\"" ]
      }
    }
    
    output {
      stdout { codec => rubydebug }
    }
  EOF
  data = <<-EOF
127.0.0.1 - - [11/Dec/2013:00:01:45 -0800] "GET /xampp/status.php HTTP/1.1" 200 3891 "http://cadenza/xampp/navi.php" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0"
  EOF

  describe command(<<-EOF
    pushd /tmp > /dev/null
    export DEBUG=
    echo '#{conf}' > 'test.conf'
    echo '#{data}' > 'test.log'
    cat test.log | /usr/share/logstash/bin/logstash -f test.conf --quiet --path.settings /etc/logstash --log.level error
  EOF
  ) do
    # TODO:  debug the stdout_as_data
    its(:stdout_as_data) { should include('message') }
#    its(:stdout_as_data) { should include('timestamp') }
#    its(:stdout_as_data) { should include('timestamp' => '11/Dec/2013:00:01:45 -0800') }
    its(:stderr) { should be_empty }
  end
end
