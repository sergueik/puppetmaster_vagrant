require 'spec_helper'

context 'Opendj config' do
   # opendj dsconfig command returns a long list of configuration details
   #  one may have to inspect to decide whether a certan connection handler port is enabled or not
   # checking enabled and disabled separately.
  state = 'true'
  debug = true
  {
    'LDAP'  => '1389',
    'HTTP'  => '8080',
  }.each do |handler,port|
      describe command(<<-EOF
      PORT='#{port}'
      # set -x
      HANDLER='#{handler} Connection Handler'
      STATE='#{state}'
      DEBUG=#{debug}
      USER='user'
      PASSWORD='password'
      HOSTNAME=$(hostname -s)
      # real opendj configuration command
      # DATA=$(/opt/opendj/bin/dsconfig --X --hostname $HOSTNAME --port 4444 -D $USER -w $PASSWORD --handler-name $HANDLER | grep -E '($PORT|$STATE)')
      # mock it
      cat <<EOF>data.txt
      port: $PORT
      enabled: $STATE
      EOF
      RESULT=$(cat data.txt | grep -Ei '($PORT|enabled)')
      if $DEBUG ; then
        echo "RESULT=$RESULT"
      fi
      echo $RESULT| grep $PORT
      STATUS=1
      if [ $? -eq 0 ]
      then
        echo $RESULT| grep $STATE
        if [ $? -eq 0 ]
        then
        echo 'Success'
        STATUS=0
        fi
      fi
      exit $STATUS
    EOF
    ) do
      let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
      its(:stdout) { should match 'Success' }
      its(:exit_status) { should eq 0 }
    end
  end
end
