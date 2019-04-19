# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' {
  include stdlib
  class { 'consul': # remove the sugar
    install_method => 'none',
    init_style     => 'unmanaged',
    manage_service => false,
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'east-aws',
      'log_level'  => 'INFO',
      'node_name'  => 'agent',
      'retry_join' => [$::ipaddress],
    }
  }
  # examine the Puppet.debug() in Vagrant log
  consul_key_value { 'test':
    value => '42',
  }
}
