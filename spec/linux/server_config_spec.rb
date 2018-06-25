require 'spec_helper'


context 'Server Round Robin Config files' do
  config_file = '/var/run/test.conf'
  describe command(<<-EOF
    # Puppet cutom configurator type uses the host part of the ip address fact
    # as an index into the server array, so does the serverspec
    SERVER_ARAY=( \\
    'server1.domain.net' \\
    'server2.domain.net' \\
    'server3.domain.net' \\
    'server5.domain.net' \\
    'server6.domain.net' \\
    'server7.domain.net' \\
    'server8.domain.net' \\
    'server9.domain.net' \\
    'server10.domain.net' \\
    )
    SERVER_ARRAY_SIZE=10
    # alternatively
    IPADDRESS=$(ip address show eth0 | grep 'inet' | awk '{pring $2}' |  cut -f 1 -d '/')
    IPADDRESS=$(/opt/puppetlabs/bin/facter 'ipaddress')
    HOSTNUM=$(echo $IPADDRESS | sed 's/.\\+\\.//')
    SERVER_INDEX=$((HOSTNUM % $SERVER_ARRAY_SIZE))
    echo "SERVER_INDEX=${SERVER_INDEX}"
    CONTROLLING_SERVER=${SERVER_ARRAY[$SERVER_INDEX]}
    echo "CONTROLLING_SERVER=${CONTROLLING_SERVER}"
    CONFIG_FILE='#{config_file}'
    echo "CONFIG_FILE=${CONFIG_FILE}"
    grep -i "$CONTROLLING_SERVER" $CONFIG_FILE
  EOF
  ) do
    its(:exit_status) {should eq 0}
    its(:stdout) {should match /server\d+.domain.net/ }
  end
end

