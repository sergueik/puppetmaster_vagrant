require 'spec_helper'
require_relative '../type/command'
context 'LogStash processing' do
  conf = <<-EOF
input {  stdin {    type => "console" } }
filter {  if ( 
    [type] != "mulelogs"    
    and[type] != "javalogs"
    and[type] != "console"
    and[type] != "intlogs") {
    drop {}
  }
  if ([type] == "console") {
    grok {
      break_on_match => true
      patterns_dir => "/etc/logstash/patterns"
      match => [
        "message", "%{IP:clientip} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}",
        "message", "%{IPORHOST:clientip} \[%{HTTPDATE:timestamp}\] %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:status} %{URIPATHPARAM:request} %{QS:agent}"
      ]
    }
    date {
      match => ["m_logtimestamp", "yyyy-MM-dd HH:mm:ss.SSS", "yyyy-MM-dd HH:mm:ss,SSS"]
      timezone => "UTC"
      target => "@timestamp"
    }
  }
  if "_grokparsefailure" in [tags] {
    drop {}
  }
}
output {
  stdout {
    codec => rubydebug
  }
}
  EOF
# https://discuss.elastic.co/t/logstash-grok-filter-for-apache-customized-logs/92915
# https://www.elastic.co/guide/en/kibana/6.1/xpack-grokdebugger.html
  data = <<-EOF
127.0.0.1 [11/Dec/2013:00:01:45 -0800] GET  200 3891 /index.html "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0"
127.0.0.1 GET /index.html 15824 0.043 
  EOF
  describe command(<<-EOF
    pushd /tmp > /dev/null
    export DEBUG=
    echo '#{conf}' > 'test.conf'
    echo '#{data}' > 'test.log'
    touch '/etc/logstash/log4j2.properties'
     cat test.log | /usr/share/logstash/bin/logstash -f test.conf --quiet --path.settings /etc/logstash --log.level error
   EOF
   ) do
     its(:stdout_as_data) { should include('type') }
     its(:stdout_as_data) { should include('type' => 'console') }
     its(:stdout_as_data) { should include('request' => '/index.html') }
     its(:stderr) { should be_empty } # fragile
   end
 end
