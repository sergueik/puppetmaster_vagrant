include apt
include java


file { 'node setup':
  ensure => file,
  path   => '/tmp/setup_7.x',
  mode   => '0755',
  source => 'https://deb.nodesource.com/setup_7.x',
}

 #class { '::nodejs':
 #  manage_package_repo       => false,
 #  nodejs_dev_package_ensure => 'present',
 #  npm_package_ensure        => 'present',
 # #}

package { 'curl':
  ensure  => 'present',
  require => Class['apt'],
}

class { 'elasticsearch':
  manage_repo  => true,
  repo_version => '1.7',
}

elasticsearch::instance { 'es-01':
  config => { # configuration hash
    'cluster.name' => 'vagrant_elasticsearch',
    'index.number_of_replicas' => '0',
    'index.number_of_shards'   => '1',
    'network.host' => '0.0.0.0',
    'marvel.agent.enabled' => false # disable marvel data collection.
  },
  init_defaults => { }, # init defaults hash
  before => Exec['start kibana']
}

# elasticsearch::plugin{'royrusso/elasticsearch-HQ':
#   instances  => 'es-01'
# }
#
# elasticsearch::plugin{'elasticsearch/marvel/latest':
#   instances  => 'es-01'
# }


class { 'logstash':
  # autoupgrade  => true,
  ensure       => 'present',
  manage_repo  => true,
  repo_version => '1.5',
  require      => [ Class['java'], Class['elasticsearch'] ],
}

# remove initial logstash config
#file { '/etc/logstash/conf.d/logstash':
  #ensure  => '/vagrant/confs/logstash/logstash.conf',
 # require => [ Class['logstash'] ],
#}

file { '/opt/kibana':
  ensure => 'directory',
  group  => 'vagrant',
  owner  => 'vagrant',
}

$kibana_version = '4.1.1'

exec { 'download_kibana':
  command => "/usr/bin/curl -L https://download.elastic.co/kibana/kibana/kibana-${kibana_version}-linux-x64.tar.gz | /bin/tar xvz -C /opt/kibana --strip-components 1",
  require => [Package['curl'],File['/opt/kibana'],Class['elasticsearch']],
  creates => '/opt/kibana/bin/kibana',
  timeout => 1800
}

exec {'start kibana':
  command => '/etc/init.d/kibana start',
  require => Exec['download_kibana'],
}

package {['pm2','timings']:
  ensure   => present,
  provider => 'npm',
  # require  => Class['::nodejs'],
}
