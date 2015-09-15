# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' { 

  # TODO: the rpm::local_file provision is not idempotent:
  exec { 'Remove perl-libwww-perl':
     command => '/bin/rpm -e perl-libwww-perl-5.833 --nodeps  || /bin/true' ,
     onlyif  => '/bin/rpm -q perl-libwww-perl-5.833',
   }
  exec { 'Remove perl-Time-Hires':
     command => '/bin/rpm -e perl-Time-HiRes-1.9726-1 || /bin/true',
     onlyif  => '/bin/rpm -q perl-Time-HiRes-1.9726-1',
   }
  package { 'mailcap':
    ensure => 'present',
  }
  rpm::local_file { 'perl-Time-Hires':
    source  => 'puppet:///modules/rpm/perl-Time-HiRes-1.9726-1.x86_64.rpm',
    require => Exec[ 'Remove perl-Time-Hires'],
  }
  rpm::local_file { 'perl-IPC-ShareLite':
    source => 'puppet:///modules/rpm/perl-IPC-ShareLite-0.17-1.x86_64.rpm',
  }
  # NOTE use http://rpmfind.net/linux/rpm2html search for RPM wpapped CPAN modules
  rpm::local_file { 'perl-Compress-Raw-Zlib':
    source => 'puppet:///modules/rpm/perl-Compress-Raw-Zlib-2.021-141.el6.x86_64.rpm',    
  } ->
  rpm::local_file { 'perl-IO-Compress-Zlib':
    source => 'puppet:///modules/rpm/perl-IO-Compress-Zlib-2.021-141.el6.x86_64.rpm',
  } ->
  rpm::local_file { 'perl-IO-Compress-Base':
    source => 'puppet:///modules/rpm/perl-IO-Compress-Base-2.021-141.el6.x86_64.rpm',
  } ->
  rpm::local_file { 'perl-Compress-Zlib':
    source => 'puppet:///modules/rpm/perl-Compress-Zlib-2.021-141.el6.x86_64.rpm',
  } ->
  rpm::local_file {  'perl-URI':
    source => 'puppet:///modules/rpm/perl-URI-1.40-2.el6.noarch.rpm',
  } ->
  rpm::local_file { 'perl-HTML-Tagset':
    source => 'puppet:///modules/rpm/perl-HTML-Tagset-3.20-4.el6.noarch.rpm',
  } ->
  rpm::local_file {  'perl-HTML-Parser':
    source => 'puppet:///modules/rpm/perl-HTML-Parser-3.64-2.el6.x86_64.rpm',
  } ->
  rpm::local_file {  'perl-libwwwLWP-perl-5.833':
    source  => 'puppet:///modules/rpm/perl-libwww-perl-5.833-2.el6.noarch.rpm',
    require => Exec['Remove perl-libwww-perl'],
  } ->
  rpm::local_file {  'perl-XML-Parser':
    source => 'puppet:///modules/rpm/perl-XML-Parser-2.44-1.x86_64.rpm',
  } ->
  rpm::local_file {  'perl-XML-XPath':
    source => 'puppet:///modules/rpm/perl-XML-XPath-1.13-1.x86_64.rpm',
  } 
}
