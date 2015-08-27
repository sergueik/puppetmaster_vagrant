node 'default' { 
# https://github.com/meltwater/puppet-cpan
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
