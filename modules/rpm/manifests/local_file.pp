# -*- mode: puppet -*-
# vi: set ft=puppet :

define rpm::local_file ($source) {
  $rpm_target = regsubst($source, '^.*\/([^\/]+)$','/tmp/\1')
  file { $rpm_target: source => $source }
  notify { "installing ${rpm_target} from ${source}": }
  package { $name:
    provider        => 'rpm',
    source          => $rpm_target,
    require         => File[$rpm_target],
    install_options => '--nodeps',
    ensure          => 'installed',
  }
}
# perl-Compress-Raw-Zlib-2.021-141.el6.x86_64.rpm
# perl-Compress-Zlib-2.021-141.el6.x86_64.rpm
# perl-HTML-Parser-3.64-2.el6.x86_64.rpm
# perl-HTML-Tagset-3.20-4.el6.noarch.rpm
# perl-IO-Compress-Base-2.021-141.el6.x86_64.rpm
# perl-IO-Compress-Zlib-2.021-141.el6.x86_64.rpm
# perl-IPC-ShareLite-0.17-1.x86_64.rpm
# perl-libwww-perl-5.833-2.el6.noarch.rpm
# perl-Time-HiRes-1.9726-1.x86_64.rpm
# perl-URI-1.40-2.el6.noarch.rpm
# perl-XML-Parser-2.44-1.x86_64.rpm
# perl-XML-XPath-1.13-1.x86_64.rpm
# 
