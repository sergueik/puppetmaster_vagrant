node /.*ubuntu.*/ { 
# https://github.com/meltwater/puppet-cpan
# module is not supported on RedHat 
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
node 'default' { 
  rpm::local_file { 'perl-Time-Hires':
    source => 'puppet:///modules/rpm/perl-Time-HiRes-1.9726-1.x86_64.rpm',
  }
# TODO: not idempotent:
# Error: /Stage[main]/Main/Node[default]/Rpm::Local_file[perl-Time-Hires]/Package[perl-Time-Hires]/ensure: change from absent to present failed: Execution of '/bin/rpm -i /tmp/perl-Time-HiRes-1.9726-1.x86_64.rpm' returned 1: package perl-Time-HiRes-1.9726-1.x86_64 is already installed

  rpm::local_file { 'perl-IPC-ShareLite':
    source => 'puppet:///modules/rpm/perl-IPC-ShareLite-0.17-1.x86_64.rpm',
  }
# 
# perl(LWP::UserAgent) is needed by perl-XML-Parser-2.44-1.x86_64
# http://search.cpan.org/~ether/libwww-perl-6.13/lib/LWP/UserAgent.pm
# cpan2rpm is failing Metadata retrieval with i
# libwww-perl-6.1.13.tar.gz , URI-1.69.tar.gz
#  rpm::local_file {  'perl-XML-Parser':
#    source => 'puppet:///modules/rpm/perl-XML-Parser-2.44-1.x86_64.rpm',
#  } ->
#  rpm::local_file {  'perl-XML-XPath':
#    source => 'puppet:///modules/rpm/perl-XML-XPath-1.13-1.x86_64.rpm',
#  } 
}
