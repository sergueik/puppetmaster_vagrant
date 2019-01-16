# -*- mode: puppet -*-
# vi: set ft=puppet :

# useful for situations when the vendor installer is preventing the upgrades of configuration, e.g. with opendj
define custom_command::app_remover (
  Bool $debug                  = false,
  Bool $verbose                = false,
  String $version              = '0.1.0',
  String $app_name             = 'opendj',
  String $servide_name         = 'opendj.service',
  String $remove_app_version   = '2.6.2',
  String $app_home             = '/opt/opendj',
  Optional[Array] $app_dirs    = [],
  Boolean $remove_stale_dirs   = false,
  String $active_app_version   = '2.6.5',
  Optional[Array] $app_basedir = '/opt',
  # basically $app_basedir is a parent dir of $app_home
  # NOTE: one need some better filtering to avoid cleaning up the whole '/opt'
) {

  # save application logs into 'logs.BAK' dir under $app_home parent dir
  $logs_backup = regsubst($app_home, '/[^/]+$', 'logs.BAK')
  $app_dirs_argument = $app_dirs.join(' ')
  $command = "systemctl stop ${service_name}; yum erase -qqy $(rpm-qa | grep '${app_name}-${remove_app_version}'| tail -1) ; mkdir -p ${logs_backup} ; cp ${app_home}/logs/* ${logs_backup}; rm -rf ${app_home} ${app_dirs_argument}; echo Done. "
  exec {"Removing the package ${app_name} $remove_app_version":
    command   => $command,
    onlyif    => "rpm -qa | grep '${app_name}-${remove_app_version}'",
    provider  => shell
    returns   => [0,1],
    path      => '/usr/bin:/bin',
    logoutput => true,

  }
  if $remove_stale_dirs {
    exec {"control removal of stale ${app_name}dirs":
      command   => "find ${app_basedir} -maxdepth 1 -type d|grep -v '${active_app_version }'| grep [a-z]",
      provider  => shell,
      returns   => [0,1],
      path      => '/usr/bin:/bin',
      logoutput => true,
    }
    -> exec {"removal of stale ${app_name} release dirs":
      command   => "find ${app_basedir} -maxdepth 1 -type d -and -name '[0-9].*'-and \\( -not  -name '${active_app_version}' \\) | while read RELEASE_DIR; do echo \"removing \${RELEASE_DIR}\"; rm -fr \$RELEAASE_DIR; done",
      onlyif    => "find ${app_basedir} -maxdepth 1 -type d| grep -v '${active_app_version }'| grep -q [a-z]",
      provider  => shell
      returns   => [0,1],
      path      => '/usr/bin:/bin',
      logoutput => true,
      before    => Exec["removal of stale ${app_name} release links"],
    }

    # NOTE:  not idenponet: one-off
    # Log the plan
    exec { "control removal of stale ${appp_name} release links"
      command   => "find ${app_basedir} -maxdepth 1 -type l| grep [a-z]",
      provider  => shell
      returns   => [0,1],
      path      => '/usr/bin:/bin',
      logoutput => true,
    }
    -> exec { "removal of stale ${app_name} release links":
      command   => "find ${app_basedir} -maxdepth 1 -type l| while read DEAD_LINK ; do echo \"inspecting \${DEAD_LINK} target  directory\"; if ! test -d \$(readlink \$DEAD_LINK); then echo \"removing \${DEAD_LINK}\";rm -f \$DEAD_LINK; fi; done",
      onlyif    => "find ${app_basedir} -maxdepth 1 -type l| grep -q [a-z]",
      provider  => shell
      returns   => [0,1],
      path      => '/usr/bin:/bin',
      logoutput => true,
    }
  }
}
