require 'spec_helper'

# Verify of Puppet was notifying / restarting the service after the configuration file change was made.
# This is possible by computing and comparing the age of config file with the age of the process that runs the known jar of the service
# TODO the other option is to extract the agre fron systemctl status -l $SERVICE_NAME

context 'Service Restart Verification' do
  config = '/opt/opendj/config/config.ldif'
  process = 'org.opends.server.core.DirectoryServer'
  describe command(<<-EOF
    CONFIG_FILE='#{config}'
    PROCESS='#{process}'
    DEBUG=true
    # compute the age of the $CONFIG_FILE
    NOW=$(date +%s)
    LAST_MOD=$(date +%s -r $CONFIG_FILE)
    FILE_AGE=$(( $NOW - $LAST_MOD ))
    echo "$CONFIG_FILE is $FILE_AGE seconds"
    if $DEBUG ; then
      echo "PROCESS=${PROCESS}"
      ps -opid,cmd -ax | grep "${PROCESS}"  |  grep -v 'grep'
    fi

    PID=$(ps -opid,cmd -ax | grep "${PROCESS}" | grep -v 'grep' | sed -E 's/^  *([0-9][0-9]*) .*$/\\1/')
    if $DEBUG ; then
      echo "PID=${PID}"
    fi
    PROCESS_AGE=$(ps -o etime= -p $PID)    PROCESS_AGE_SECONDS=$(echo "${PROCESS_AGE}"| sed -E 's/(.*):(.+):(.+)/\\1*3600+\\2*60+\\3/;s/(.+):(.+)/\\1*60+\\2/' | bc)
    if $DEBUG ; then
      echo "Process $PID is $PROCESS_AGE_SECONDS seconds"
      echo "$CONFIG_FILE is $FILE_AGE seconds"
    fi
    STATUS=0   
    if [[ $PROCESS_AGE_SECONDS -gt $FILE_AGE ]]; then
      echo 'Service was not restarted.'
      STATUS=1
    else
      echo "Service has been restarted after configuration change."
      STATUS=0
    fi
    exit $STATUS 
    EOF
    ) do
      let(:path) { '/bin:/usr/bin:/sbin:/usr/local/bin:/opt/opendj/bin'}
      its(:stdout) { should match /Service has/ }
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
    end
  end
# https://unix.stackexchange.com/questions/7870/how-to-check-how-long-a-process-has-been-running
# https://unix.stackexchange.com/questions/102691/get-age-of-given-file
# https://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
# https://stackoverflow.com/questions/2181712/simple-way-to-convert-hhmmss-hoursminutesseconds-split-seconds-to-seconds
https://stackoverflow.com/questions/17322909/calculate-how-long-ago-a-file-was-modified
