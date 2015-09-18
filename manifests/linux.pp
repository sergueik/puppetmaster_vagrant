# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' { 

  class { 'staging':
    path  => '/var/staging',
    owner => 'puppet',
    group => 'puppet',
  }

  # NOTE:
  # rpm -q --requires '<rpm syntax>'
  # rpm -q --whatprovides '<CPAN syntax>'
  # http://rpmfind.net/linux/rpm2html for rpm-packaged CPAN modules

  staging::file { 'perl-DBI-1.609-4.el6.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-DBI-1.609-4.el6.x86_64.rpm',
  } 

  package { 'perl-DBI':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/var/staging/perl-DBI-1.609-4.el6.x86_64.rpm',
      require  => Staging::File['perl-DBI-1.609-4.el6.x86_64.rpm'],
  }

  staging::file { 'perl-DBD-MySQL-4.013-3.el6.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-DBD-MySQL-4.013-3.el6.x86_64.rpm',
  } 

  package { 'perl-DBD-MySQL':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/var/staging/perl-DBD-MySQL-4.013-3.el6.x86_64.rpm',
      require  => Staging::File['perl-DBD-MySQL-4.013-3.el6.x86_64.rpm']
  }

  staging::file { 'perl-XML-Simple-2.18-6.el6.noarch.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-XML-Simple-2.18-6.el6.noarch.rpm',
  } 

  package { 'perl-XML-Simple':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/var/staging/perl-XML-Simple-2.18-6.el6.noarch.rpm',
      require  => [Package['perl-XML-Parser'], Staging::File['perl-XML-Simple-2.18-6.el6.noarch.rpm']],
  }
 
  # Net::Ping is with Perl 5.10

  staging::file { 'perl-Net-Netmask-1.9015-8.el6.noarch.rpm':
    source => 'ftp://rpmfind.net/linux/epel/6/x86_64/perl-Net-Netmask-1.9015-8.el6.noarch.rpm',
  } 

  package { 'perl-Net-Netmask':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/var/staging/perl-Net-Netmask-1.9015-8.el6.noarch.rpm',
      require  => Staging::File['perl-Net-Netmask-1.9015-8.el6.noarch.rpm']
  }
  
  # Net::hostent is with Perl 5.10

  staging::file { 'perl-Data-Validate-IP-0.10-1.el6.rf.noarch.rpm':
    source => 'ftp://rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/perl-Data-Validate-IP-0.10-1.el6.rf.noarch.rpm',
  } 

  package { 'perl-Data-Validate-IP':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/var/staging/perl-Data-Validate-IP-0.10-1.el6.rf.noarch.rpm',
      require  => Staging::File['perl-Data-Validate-IP-0.10-1.el6.rf.noarch.rpm']
  }
  
  staging::file { 'perl-Time-HiRes-1.9721-141.el6.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-Time-HiRes-1.9721-141.el6.x86_64.rpm',
  } 

  package { 'perl-Time-HiRes':
    ensure          => 'present',
    provider        => 'rpm',
    source          => '/var/staging/perl-Time-HiRes-1.9721-141.el6.x86_64.rpm',
    require         => Staging::File['perl-Time-HiRes-1.9721-141.el6.x86_64.rpm'],
    install_options => '--nodeps',   # perl 4:5.10 dependency
  }

  staging::file { 'perl-IPC-ShareLite-0.17-1.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/dag/redhat/el4/en/x86_64/dag/RPMS/perl-IPC-ShareLite-0.17-1.el4.rf.x86_64.rpm',
  } 

  package { 'perl-IPC-ShareLite':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/var/staging/perl-IPC-ShareLite-0.17-1.x86_64.rpm',
    require  => Staging::File['perl-IPC-ShareLite-0.17-1.x86_64.rpm'],
  }

  package { 'mailcap':
    ensure => 'present',
  } ->

  staging::file { 'perl-Compress-Raw-Zlib-2.021-141.el6.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-Compress-Raw-Zlib-2.021-141.el6.x86_64.rpm',
  } 

  package { 'perl-Compress-Raw-Zlib':
    ensure          => 'present',
    provider        => 'rpm',
    source          => '/var/staging/perl-Compress-Raw-Zlib-2.021-141.el6.x86_64.rpm',
    require         => Staging::File['perl-Compress-Raw-Zlib-2.021-141.el6.x86_64.rpm'],
    install_options => '--nodeps',   # perl 4:5.10 dependency
  } ->

  staging::file { 'perl-IO-Compress-Zlib-2.021-141.el6.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-IO-Compress-Zlib-2.021-141.el6.x86_64.rpm',
  } 

  package { 'perl-IO-Compress-Zlib':
    ensure          => 'present',
    provider        => 'rpm',
    source          => '/var/staging/perl-IO-Compress-Zlib-2.021-141.el6.x86_64.rpm',
    require         => Staging::File['perl-IO-Compress-Zlib-2.021-141.el6.x86_64.rpm'],
    install_options => '--nodeps',   # perl 4:5.10 dependency
  } ->

  staging::file { 'perl-IO-Compress-Base-2.021-141.el6.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-IO-Compress-Base-2.021-141.el6.x86_64.rpm',
  } 

  package { 'perl-IO-Compress-Base':
    ensure          => 'present',
    provider        => 'rpm',
    source          => '/var/staging/perl-IO-Compress-Base-2.021-141.el6.x86_64.rpm',
    require         => Staging::File['perl-IO-Compress-Base-2.021-141.el6.x86_64.rpm'],
    install_options => '--nodeps',   # perl 4:5.10 dependency
  } ->

  staging::file { 'perl-Compress-Zlib-2.021-141.el6.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-Compress-Zlib-2.021-141.el6.x86_64.rpm',
  } 

  package { 'perl-Compress-Zlib':
    ensure          => 'present',
    provider        => 'rpm',
    source          => '/var/staging/perl-Compress-Zlib-2.021-141.el6.x86_64.rpm',
    require         => Staging::File['perl-Compress-Zlib-2.021-141.el6.x86_64.rpm'],
    install_options => '--nodeps',   # perl 4:5.10 dependency
  } ->

  staging::file { 'perl-URI-1.40-2.el6.noarch.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-URI-1.40-2.el6.noarch.rpm',
  } 

  package { 'perl-URI':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/var/staging/perl-URI-1.40-2.el6.noarch.rpm',
    require  => Staging::File['perl-URI-1.40-2.el6.noarch.rpm'],
  } ->

  staging::file { 'perl-HTML-Tagset-3.20-4.el6.noarch.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-HTML-Tagset-3.20-4.el6.noarch.rpm',
  } 

  package { 'perl-HTML-Tagset':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/var/staging/perl-HTML-Tagset-3.20-4.el6.noarch.rpm',
    require  => Staging::File['perl-HTML-Tagset-3.20-4.el6.noarch.rpm'],
  } ->

  staging::file { 'perl-HTML-Parser-3.64-2.el6.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-HTML-Parser-3.64-2.el6.x86_64.rpm',
  } 

  package { 'perl-HTML-Parser':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/var/staging/perl-HTML-Parser-3.64-2.el6.x86_64.rpm',
    require  => Staging::File['perl-HTML-Parser-3.64-2.el6.x86_64.rpm'],
  } ->

  staging::file { 'perl-libwww-perl-5.833-2.el6.noarch.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/i386/Packages/perl-libwww-perl-5.833-2.el6.noarch.rpm',
  } 

  package { 'perl-libwww-perl':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/var/staging/perl-libwww-perl-5.833-2.el6.noarch.rpm',
    require  => Staging::File['perl-libwww-perl-5.833-2.el6.noarch.rpm'],
  } ->

  staging::file { 'perl-XML-Parser-2.44-1.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-XML-Parser-2.36-7.el6.x86_64.rpm',
  } 

  package { 'perl-XML-Parser':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/var/staging/perl-XML-Parser-2.44-1.x86_64.rpm',
    require  => Staging::File['perl-XML-Parser-2.44-1.x86_64.rpm'],
  } ->

  staging::file { 'perl-XML-XPath-1.13-1.x86_64.rpm':
    source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-XML-XPath-1.13-10.el6.noarch.rpm',
  } 

  package { 'perl-XML-XPath':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/var/staging/perl-XML-XPath-1.13-1.x86_64.rpm',
    require  => Staging::File['perl-XML-XPath-1.13-1.x86_64.rpm'],
  }
}
