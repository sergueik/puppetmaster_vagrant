# -*- mode: puppet -*-
# vi: set ft=puppet :

# NOTE: https://github.com/meltwater/puppet-cpan is ubuntu-only provider
node 'ubuntu-only' { 
  # NOTE: on precise, apt-get fails with 404 - need to update sources
  package {'libexpat1-dev':
   ensure => present,
  }
  include cpan
  cpan { ['XML::Simple','XML::XPath','XML::Parser','Time::HiRes','Net::Ping','Net::Netmask','Net::hostent','Data::Validate::IP']:
    ensure  => present,
    require => [Class['::cpan'],Package['libexpat1-dev']],
    force   => true,
  }
}

