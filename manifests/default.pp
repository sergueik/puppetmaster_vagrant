class { 'apache':
  mpm_module  => 'prefork'
}

Exec { path => '/usr/bin:/usr/local/bin' }

exec { 'apt-update':
  command => 'apt-get update',
}

class { 'apache::mod::php':
  require => Exec['apt-update'],
  notify  => Service['apache2'],
#  NOTE:
#  notify  => Class['apache'],
# Could not apply complete catalog: 
# Found 1 dependency cycle:==> 
# default: 
# (Exec[mkdir /etc/apache2/mods-available] => 
# File[php5.conf] => 
# Class[Apache::Mod::Php] => 
# Class[Apache] => 
# Exec[mkdir /etc/apache2/mods-available])

}

file { 'site-config':
  path    => '/etc/apache2/sites-enabled/00-default.conf',
  source  => '/vagrant/site-config',
  require => Package['apache2'],
  notify  => Service['apache2'],
}
