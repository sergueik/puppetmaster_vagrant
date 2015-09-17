# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' { 
  # NOTE:
  # rpm -q --requires '<rpm syntax>'
  # rpm -q --whatprovides '<CPAN syntax>'
  # http://rpmfind.net/linux/rpm2html for rpm-packaged CPAN modules

  package { 'perl-DBI':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/vagrant/modules/rpm/files/perl-DBI-1.609-4.el6.x86_64.rpm',
      # TODO confirm require list is empty,
  }

  package { 'perl-DBD-MySQL':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/vagrant/modules/rpm/files/perl-DBD-MySQL-4.013-3.el6.x86_64.rpm',
      # TODO confirm require list is empty,
      # require  => Package['perl-Dynaloader'],
  }

  package { 'perl-XML-Simple':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/vagrant/modules/rpm/files/perl-XML-Simple-2.18-6.el6.noarch.rpm',
      require  => Package['perl-XML-Parser'],
  }
 
  # Net::Ping is with Perl 5.10

  package { 'perl-Net-Netmask':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/vagrant/modules/rpm/files/perl-Net-Netmask-1.9015-8.el6.noarch.rpm',
  }
  
  # Net::hostent is with Perl 5.10

  package { 'perl-Data-Validate-IP':
      ensure   => 'present',
      provider => 'rpm',
      source   => '/vagrant/modules/rpm/files/perl-Data-Validate-IP-0.10-1.el6.rf.noarch.rpm',
  }
  
  package { 'perl-Time-HiRes':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/vagrant/modules/rpm/files/perl-Time-HiRes-1.9726-1.x86_64.rpm',
  }

  package { 'perl-IPC-ShareLite':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/vagrant/modules/rpm/files/perl-IPC-ShareLite-0.17-1.x86_64.rpm'
  }

  package { 'mailcap':
    ensure => 'present',
  } ->

  package { 'perl-Compress-Raw-Zlib':
    ensure          => 'present',
    provider        => 'rpm',
    source          => '/vagrant/modules/rpm/files/perl-Compress-Raw-Zlib-2.021-141.el6.x86_64.rpm',
    install_options => '--nodeps',
    # perl 4:5.10 is needed by perl-Compress-Raw-Zlib-1:2.021-141.el6.x86_64
  } ->

  package { 'perl-IO-Compress-Zlib':
    ensure          => 'present',
    provider        => 'rpm',
    source          => '/vagrant/modules/rpm/files/perl-IO-Compress-Zlib-2.021-141.el6.x86_64.rpm',
    install_options => '--nodeps',
    # perl 4:5.10 is needed by perl-IO-Compress-Zlib-0:2.021-141.el6.x86_64
  } ->

  package { 'perl-IO-Compress-Base':
    ensure          => 'present',
    provider        => 'rpm',
    source          => '/vagrant/modules/rpm/files/perl-IO-Compress-Base-2.021-141.el6.x86_64.rpm',
    install_options => '--nodeps',
    # perl 4:5.10 is needed by perl-IO-Compress-Base-0:2.021-141.el6.x86_64
  } ->

  package { 'perl-Compress-Zlib':
    ensure          => 'present',
    provider        => 'rpm',
    source          => '/vagrant/modules/rpm/files/perl-Compress-Zlib-2.021-141.el6.x86_64.rpm',
    install_options => '--nodeps',
    # perl 4:5.10 is needed by perl-Compress-Zlib-0:2.021-141.el6.x86_64
  } ->

  package { 'perl-URI':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/vagrant/modules/rpm/files/perl-URI-1.40-2.el6.noarch.rpm'
  } ->

  package { 'perl-HTML-Tagset':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/vagrant/modules/rpm/files/perl-HTML-Tagset-3.20-4.el6.noarch.rpm'
  } ->

  package { 'perl-HTML-Parser':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/vagrant/modules/rpm/files/perl-HTML-Parser-3.64-2.el6.x86_64.rpm'
  } ->

  package { 'perl-libwww-perl':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/vagrant/modules/rpm/files/perl-libwww-perl-5.833-2.el6.noarch.rpm'
  } ->
  package { 'perl-XML-Parser':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/vagrant/modules/rpm/files/perl-XML-Parser-2.44-1.x86_64.rpm'
  } ->

  package { 'perl-XML-XPath':
    ensure   => 'present',
    provider => 'rpm',
    source   => '/vagrant/modules/rpm/files/perl-XML-XPath-1.13-1.x86_64.rpm'
  }
}
