# -*- mode: puppet -*-
# vi: set ft=puppet :
# remove all but a certain version of the package
# useful when vendor installer is not supporting upgrades
define custom_command::app_remover (
  Bool $debug               = false,
  Bool $verbose             = false,
  Bool $combined_removal    = false,
  String $version           = '0.2.0', # this package version, not the subject
  String $app_name          = 'apache',
  String $servide_name      = 'httpd.service',
  # TODO: support blank "keep_version"
  String $keep_version      = '2.4.26',
  String $keep_dir          = '/opt/apache/2.4.26',
  String $app_home          = '/opt/apache',
  Optional[Array] $app_dirs = [],
  $app_basedir              = '/opt',
  # basically $app_basedir is a parent dir of $app_home
  # NOTE: one need ito add a check to avoid cleaning up the whole '/opt'
) {

  $logs_backup = regsubst($app_home, '/[^/]+$', 'logs.BAK')
  # Extra argument to remove logs
  $app_dirs_argument = $app_dirs.join(' ')
  # One may prefer to utilize a core Puppet 'package' resource to remove the package and rely on hieradata authoring accuracy to avoind duplicate resource coonflicts
  if $combined_removal {
    if $debug {
      notify { "Back up application logs into ${app_home} parent dir":
        before => Exec['Remove the package, back up logs'],
      }
    }
    exec {'Remove the package, back up logs':
      command   => "systemctl stop ${service_name}; yum erase -qqy $(rpm -qa | grep '${app_name}' | grep -v '${app_name}-${keep_version}'| tail -1); mkdir -p ${logs_backup} ; cp ${app_home}/logs/* ${logs_backup}; rm -rf ${app_home} ${app_dirs_argument}; echo Done.",
      onlyif    => "rpm -qa | grep '${app_name}' | grep -qv '${app_name}-${keep_version}'",
      provider  => shell,
      returns   => [0,1],
      path      => '/usr/bin:/bin',
      logoutput => true,
    }
  } else {
    exec {'back up logs':
      command   => "mkdir -p ${logs_backup} ; cp ${app_home}/logs/* ${logs_backup}; rm -rf ${app_home} ${app_dirs_argument}; echo Done.",
      onlyif    => "rpm -qa | grep '${app_name}' | grep -qv '${app_name}-${keep_version}'",
      provider  => shell,
      returns   => [0,1],
      path      => '/usr/bin:/bin',
      logoutput => true,
    }
    if ((defined('$app_name') ) and (!defined(Package[$app_name]))){
      package { $app_name:
        ensure   => absent,
        provider => 'rpm',
	require  => Exec['back up logs'],
      }
    }
  }
  if $debug {
    exec {'enumerate past release dirs':
      command   => "find ${app_basedir} -maxdepth 1 -type d|grep -v '${keep_dir}'| grep [a-z]",
      provider  => shell,
      returns   => [0,1],
      path      => '/usr/bin:/bin',
      logoutput => true,
      before    => Exec['remove past release dirs'],
    }
  }
  exec {'remove past release dirs':
    command   => "find ${app_basedir} -maxdepth 1 -type d -and -name '[0-9].*'-and \\( -not -name '${keep_dir}' \\) | while read RELEASE_DIR; do echo \"removing \${RELEASE_DIR}\"; rm -fr \$RELEAASE_DIR; done",
    # only run if there are past release directories to erase
    onlyif    => "find ${app_basedir} -maxdepth 1 -type d| grep -v '${keep_dir}'| grep -q [a-z]",
    provider  => shell
    returns   => [0,1],
    path      => '/usr/bin:/bin',
    logoutput => true,
    before    => Exec['remove of past release links'],
  }

  if $debug {
    exec { 'find potential past release links':
      command   => "find ${app_basedir} -maxdepth 1 -type l",
      provider  => shell
      returns   => [0,1],
      path      => '/usr/bin:/bin',
      logoutput => true,
      before    => Exec['remove of past release links'],
    }
  }
  exec { 'remove of past release links':
    command   => "find ${app_basedir} -maxdepth 1 -type l| while read DEAD_LINK ; do echo \"inspecting \${DEAD_LINK} target directory\"; if ! test -d \$(readlink \$DEAD_LINK); then echo \"removing \${DEAD_LINK}\";rm -f \$DEAD_LINK; fi; done",
    # find does not set exit status on its own
    onlyif    => "find ${app_basedir} -maxdepth 1 -type l| grep -q [a-z]",
    provider  => shell
    returns   => [0,1],
    path      => '/usr/bin:/bin',
    logoutput => true,
  }
}
