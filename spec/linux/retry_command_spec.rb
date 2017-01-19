require 'spec_helper'

context 'Tomcat Listening Port' do
  # creates a bash loop around the command -  often needed for tomcat derivatives "which warm" up slowly 
  # note - the pure ruby implemetation 
  # https://github.com/bootstraponline/waiting_rspec_matchers/blob/master/lib/waiting_rspec_matchers.rb#L82
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
