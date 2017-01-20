require 'spec_helper'

context 'Tomcat Port with Retry' do
  # creates a bash loop around the command -  often needed for tomcat derivatives "which warm" up slowly 
  [
    9443,
    9080,
  ].each do |port|
    max_retry = 30
    describe command( <<-EOF
      #! /bin/bash
      isPortListening() {
      while [ $RETRY_COUNT -lt $MAX_RETRY ]
      do
        netstat -na | grep tcp | grep LISTEN | \
        egrep '(127.0.0.1|0.0.0.0|:::)' | \
        grep ":$PORT" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          echo Port is listening: $PORT
          exit 0
        fi
        RETRY_COUNT=$((RETRY_COUNT+1))
        sleep 10
      done
      echo Port $PORT is not listening. Retried $MAX_RETRY times.
      exit 1
    }
   isPortListening
  EOF
    ) do
      its(:exit_status) { should eq 0 }
    end
  end
end
  
def port_with_retry(tcp_port, max_retry, default_delay )
  # pure ruby implemetation 
  # origin https://github.com/bootstraponline/waiting_rspec_matchers/blob/master/lib/waiting_rspec_matchers.rb#L82
  start_time = Time.now
  begin
    describe port (tcp_port) do
      it { should be_listening }
    end
  rescue ::RSpec::Expectations::ExpectationNotMetError => e
    STDERR.puts e.message
    return false if (Time.now - start_time) >= max_retry * default_delay
    sleep default_delay
    retry
  end
  true
end

context 'Tomcat Port with Retry' do
  max_retry = 30
  default_delay = 10
  [
    9443,
    9080,
    9999,
  ].each do |port|
  port_with_retry(port, max_retry, default_delay )
end
