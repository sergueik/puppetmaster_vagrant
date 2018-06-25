require_relative '../windows_spec_helper'

context 'Configuration' do
  prefix = 'c:/Program Files/splunkuniversalforwarder'
  config = '#{prefix}/etc/system/local/deploymentclient.conf'
  describe command(<<-EOF

    $SERVER_ARRAY= @(
      'server1.domain.net:8089',
      'server2.domain.net:8089',
      'server3.domain.net:8089',
      'server4.domain.net:8089'
      'server5.domain.net:8089',
      'server6.domain.net:8089',
    )
    $IPADDRESS = invoke-expression -Command 'facter.bat ipaddress'

    $HOSTNUM  =  $IPADDRESS  -replace '.+\.', ''

    $SERVER_INDEX = $( 0 + $HOSTNUM % $ARRAY.count)
    $CONTROLLING_SERVER=$SERVER_ARRAY[$SERVER_INDEX]
    write-output ('SERVER_INDEX={0}' -f $SERVER_INDEX )
    write-output ('CONTROLLING_SERVER={0}' -f $CONTROLLING_SERVER )
    CONFIG = '#{config}'
    Select-String -pattern "${DEPLOYMENT_HOST}"  -path $CONFIG

    # Convert Powershell '$?' to 0/1 exit status
    if ($?) { exit 0 } else { exit 1 }

  EOF
  ) do
    its(:stdout) { should match /server-\d+.domain.net:8089/ }
    its(:exit_status) { should eq 0 }
  end
end
