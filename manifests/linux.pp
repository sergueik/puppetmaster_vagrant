# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' { 
#$x  = "answer:'42' flag:'false'"
# $y = split($x," ")
# notify {$y[0] : }

# Error: Could not parse for environment production: Could not match |$y|
# scanf("42", "%i") |$y| {
#    unless $y[0] =~ Integer {
#      fail "Expected a well formed integer value, got '$x[0]'"
#    }
#    $y[0]
# }
# module_data broken ?
# $product_name = hiera('product_name')
# validate_string($product_name)
# $product_specific_params  = hiera_hash('product_specific_params')
# validate_hash($product_specific_params)

# with yum do not need to explicitly install dependency RPMs, 
# only the RPM packages with the desired CPAN modules:
$has_yum_packages = true

  if $has_yum_packages {
    package { ['perl-DBI','perl-DBD-MySQL','perl-XML-Parser','perl-XML-Simple','perl-XML-XPath'] :
      ensure => present,
    }
  }  else {

    class { 'staging':
      path  => '/var/staging',
      owner => 'puppet',
      group => 'puppet',
    }

    # NOTE:
    # rpm -q --requires '<rpm syntax>'
    # rpm -q --whatprovides '<CPAN syntax>'
    # http://rpmfind.net/linux/rpm2html for rpm-packaged CPAN modules
  
    rpm::local_file { 'perl-DBI':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-DBI-1.609-4.el6.x86_64.rpm',
    }
  
    rpm::local_file { 'perl-DBD-MySQL':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-DBD-MySQL-4.013-3.el6.x86_64.rpm',
      require  => Rpm::Local_file['perl-DBI'],
    }
   
    # Net::Ping is with Perl 5.10
  
    rpm::local_file { 'perl-Net-Netmask':
      source => 'ftp://rpmfind.net/linux/epel/6/x86_64/perl-Net-Netmask-1.9015-8.el6.noarch.rpm',
    }
    
    # Net::hostent is with Perl 5.10
  
    rpm::local_file { 'perl-Data-Validate-IP':
      source => 'ftp://rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/perl-Data-Validate-IP-0.10-1.el6.rf.noarch.rpm',
    }
  
    rpm::local_file { 'perl-Time-HiRes':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-Time-HiRes-1.9721-141.el6.x86_64.rpm',
    }
  
    rpm::local_file { 'perl-IPC-ShareLite':
      source => 'ftp://rpmfind.net/linux/dag/redhat/el4/en/x86_64/dag/RPMS/perl-IPC-ShareLite-0.17-1.el4.rf.x86_64.rpm',
    }
  
    package { 'mailcap':
      ensure => 'present',
    } ->
  
    rpm::local_file { 'perl-Compress-Raw-Zlib':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-Compress-Raw-Zlib-2.021-141.el6.x86_64.rpm',
      # install_options => '--nodeps',   # perl 4:5.10 dependency
    } ->
  
    rpm::local_file { 'perl-IO-Compress-Zlib':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-IO-Compress-Zlib-2.021-141.el6.x86_64.rpm',
      # install_options => '--nodeps',   # perl 4:5.10 dependency
    } ->
  
    rpm::local_file { 'perl-IO-Compress-Base':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-IO-Compress-Base-2.021-141.el6.x86_64.rpm',
      # install_options => '--nodeps',   # perl 4:5.10 dependency
    } ->
  
    rpm::local_file { 'perl-Compress-Zlib':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-Compress-Zlib-2.021-141.el6.x86_64.rpm',
      # install_options => '--nodeps',   # perl 4:5.10 dependency
    } ->
  
    rpm::local_file { 'perl-URI':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-URI-1.40-2.el6.noarch.rpm',
      # install_options => '--nodeps',   # perl 4:5.10 dependency
    } ->
  
    rpm::local_file { 'perl-HTML-Tagset':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-HTML-Tagset-3.20-4.el6.noarch.rpm',
    } -> 
  
  
    rpm::local_file { 'perl-HTML-Parser':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-HTML-Parser-3.64-2.el6.x86_64.rpm',
    } -> 
  
    rpm::local_file { 'perl-libwww-perl':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/i386/Packages/perl-libwww-perl-5.833-2.el6.noarch.rpm',
    } -> 
  
    rpm::local_file { 'perl-XML-Parser':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-XML-Parser-2.36-7.el6.x86_64.rpm',
    } 
  
    rpm::local_file { 'perl-XML-XPath':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-XML-XPath-1.13-10.el6.noarch.rpm',
      require => Rpm::Local_file['perl-XML-Parser'],
    }
  
    rpm::local_file { 'perl-XML-Simple':
      source => 'ftp://rpmfind.net/linux/centos/6.7/os/x86_64/Packages/perl-XML-Simple-2.18-6.el6.noarch.rpm',
      require => Rpm::Local_file['perl-XML-Parser'],
    }
 }
}
