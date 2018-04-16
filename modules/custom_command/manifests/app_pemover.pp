# -*- mode: puppet -*-
# vi: set ft=puppet :

# useful for situations when the vendor installer is preventing the upgrades of configuration, e.g. with opendj
define custom_command::app_remover (
  Bool $debug               = false,
  Bool $verbose             = false,
  String $version           = '0.1.0',
  String $app_name          = 'opendj',
  String $servide_name      = 'opendj.service',
  String $app_version       = '2.6.2',
  String $app_home          = '/opt/opendj',
  Optional[Array] $app_dirs = [],

) {

  # save application logs into 'logs.BAK' dir under $app_home parent dir
  $logs_backup = regsubst($app_home, '/[^/]+$', 'logs.BAK')
  $app_dirs_argument = $app_dirs.join(' ')
  $command = "systemctl stop ${service_name}; yum erase -qqy $(rpm-qa | grep '${app_name}-${app_version}'| tail -1) ; mkdir -p ${logs_backup} ; cp ${app_home}/logs/* ${logs_backup}; rm -rf ${app_home} ${app_dirs_argument}; echo Done. "
  exec {"Removing the Centos rpm package ${app_name} $app_version":
    command => $command,
    onlyif  => "rpm -qa | grep '${app_name}-${app_version}'",
    returns => [0,1],
    path    => '/usr/bin:/bin',

  }
}
