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
