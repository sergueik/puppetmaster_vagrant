# -*- mode: puppet -*-
# vi: set ft=puppet :

define rpm::local_file ($source) {
  $rpm_target = regsubst($source, '^.*\/([^\/]+)$','\1')
  staging::file { $rpm_target:  source => $source } 
  # NOTE: uncommenting notice will make the type appear not idempotent
  # notify { "installing ${staging::path}/${rpm_target} from ${source}": }
  package { $name:
    provider        => 'rpm',
    # TODO: debug
    source          => "${staging::path}/rpm/${rpm_target}",
    require         => Staging::File[$rpm_target],
    install_options => '--nodeps',
    ensure          => 'installed',
  }
}
