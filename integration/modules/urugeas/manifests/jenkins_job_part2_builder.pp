# -*- mode: puppet -*-
# vi: set ft=puppet :

define urugeas::jenkins_job_part2_builder (
  $build_user             = hiera('urugeas::job::build_user', 'vagrant'),
  $debug                  = hiera('urugeas::job::debug', false),
  $logdir_glob            = hiera('urugeas::job::logdir_glob', 'undefined'),
  $current_logdir         = hiera('urugeas::job::current_logdir' , ''),
  $number_logdirs_to_keep = hiera('urugeas::job::number_logdirs_to_keep', 5),
  $version = '0.0.1',
) {

  $shell_script = 'purge_old_dirs.sh'

  validate_string($logdir_glob)
  validate_string($current_logdir)
  # TODO
  # validate_re($current_loggir, "^${logdir_glob}$')

  notify { "${name} shell script (plain) ${shell_script}":
    message => template("${module_name}/${regsubst($shell_script, '\\.', '_', 'G')}.erb"),
  }
  file { $shell_script:
    ensure  => file,
    path    => "/tmp/${shell_script}",
    content => template("${module_name}/${regsubst($shell_script, '\\.', '_', 'G')}.erb"),
    mode    => '0755',
  }
}
