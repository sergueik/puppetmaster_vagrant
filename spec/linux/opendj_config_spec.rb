require 'spec_helper'

context 'Opendj config' do
  # opendj dsconfig command returns a long list of configuration details
  #  one may have to inspect to decide whether a certan connection handler port is enabled or not
  # checking enabled and disabled separately.
  state = 'true'
  debug = true
  # mock opendj command output
  datafile = '/tmp/data.txt'
  before(:each) do
    Specinfra::Runner::run_command( <<-EOF
      cat <<END>#{datafile}
      port: 8080
      port: 1389
      enabled: true
END
  EOF
  )
  end
  {
    'LDAP'  => {
      :port    => '1389',
      :enabled => 'true'
    },
    'HTTP'  => {
      :port    => '8080',
      :enabled => 'true'
    },
  }.each do |handler,config|
    port = config[:port]
    enabled = config[:enabled]
    describe command(<<-EOF
      PORT='#{port}'
      # set -x
      HANDLER='#{handler} Connection Handler'
      ENABLED='#{enabled}'
      DEBUG=#{debug}
      USER='user'
      PASSWORD='password'
      HOSTNAME=$(hostname -s)
      # real opendj configuration command
      # DATA=$(/opt/opendj/bin/dsconfig --X --hostname $HOSTNAME --port 4444 -D $USER -w $PASSWORD --handler-name $HANDLER | grep -E '($PORT|$STATE)')
      # TODO: mock it
      # format:
      #
      # Property         : Value(s)
      # -----------------:--------------------
      # db-cache-precent : 42
      # base-dn          : "dc=company,dc=com"
      # db-cache-size    : 0 b
      # enabled          : true
      #
      DATAFILE='#{datafile}'
      CONFIG_RESULT=$(cat $DATAFILE | grep -Ei '($PORT|enabled)')
      if $DEBUG ; then
        echo "CONFIG_RESULT=$CONFIG_RESULT"
      fi
      echo $CONFIG_RESULT| grep $PORT
      STATUS=1
      if [ $? -eq 0 ]
      then
        echo $CONFIG_RESULT| grep $ENABLED
        if [ $? -eq 0 ]
        then
        echo "Success: Found $PORT"
        STATUS=0
        fi
      fi
      exit $STATUS
      # NORE: From the skeleton design phase. Unreached
      echo Success
    EOF
    ) do
      let(:path) { '/bin:/usr/bin:/usr/local/bin:/opt/opedj/bin'}
      its(:stdout) { should match 'Success' }
      its(:stdout) { should match "Found #{port}" }
      its(:exit_status) { should eq 0 }
    end
  end
end
