node /ubuntu.*/ { 
# Module cpan is not supported on RedHat at /vagrant/modules/cpan/manifests/init.pp:59:7 on node vagrant-chef
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
# http://stackoverflow.com/questions/9693031/how-to-install-xmlparser-without-expat-devel
}
