# -*- mode: puppet -*-
# vi: set ft=puppet :

define rpm::local_file ($source) {
  $rpm_target = regsubst($source, '^.*\/([^\/]+)$','/tmp/\1')
  file { $rpm_target: source => $source }
  notify { "installing ${rpm_target} from ${source}": }
  package { $name:
#    name     => $rpm_target,
    provider => 'rpm',
    source   => $rpm_target,
    require  => File[$rpm_target],
#  install_options => '-fvv',
    ensure   => 'installed'
  }
}
# Files in modules/rpm/files in .gitignore
# perl-IPC-ShareLite-0.17-1.x86_64.rpm
# perl-Time-HiRes-1.9726-1.x86_64.rpm
# perl-XML-Parser-2.44-1.x86_64.rpm
# perl-XML-XPath-1.13-1.x86_64.rpm

