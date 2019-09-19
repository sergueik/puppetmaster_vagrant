# -*- mode: puppet -*-
# vi: set ft=puppet :
# this module to some extent re-invents the
# https://puppet.com/docs/puppet/5.0/lang_relationships.html#auto-relationships
define urugeas::chown (
  Boolean $debug  = false,
  String $version = '0.3.0'
) {
  # NOTE: quick mass file operation example one may need to perform when the owneheship of every file need to change.
  # FThe gist is to illustrate the `unless`, `onlyif` commands therefore a simply unlink the files if some is detected being owned by wrong user

  $wrong_user = 'root' # some account
  # find: ‘some_account’ is not the name of a known user
  $correct_user = 'vagrant' # need to be an existing account
  $correct_group = 'vagrant'
  $parent_folder = '/var/log/mysql'
  $files = ['/tmp/a.txt', '/tmp/b.txt', '/tmp/c.txt'].join(' ')
  exec { 'remove files owned by wrong user':
    # with Puppet generated cron job product simplest is to unlink them
    command   => "echo \"rm -f ${files}\"",
    path      => '/bin:/usr/bin',
    logoutput => true,
    returns   => [0,1],
    onlyif    => "stat ${files} | sed -n '/Uid/s|^.*\\(Uid: ([^)]*) \\).*\$|\\1|p'| grep -q '${wrong_user}'",
  }
  exec { 'mass ownership change of files':
    command   => "for F in ${files}; do chown '${correct_user}' \$F; done",
    path      => '/bin:/usr/bin',
    provider  => shell,
    logoutput => true,
    returns   => [0,1],
    unless    => "stat ${files} | sed -n '/Uid/s|^.*Uid: (\\([^)]*\\)) .*\$|\\1|p'  grep -vq '${correct_user}'",
  }
  exec { 'condition-less command to change file ownership':
    command   => "find '${parent_folder}' -xdev \\( -type f -or -type d \\) -and \\( \\( ! -user '${correct_user}' \\) -or \\( ! -group '${correct_group}' \\) -or -nouser -or -nogroup \\) -exec chown ${correct_user}:${correct_group} {} \\;",
    path      => '/bin:/usr/bin',
    logoutput => true,
    returns   => [0,1],
  }

  exec { 'ownership change of files, alternartive version':
    command => "find '${parent_folder}' -user '${wrong_user}' | xargs -IX chown ${correct_user}:${correct_group} X",
    unless  => "test \$(find '${parent_folder} -user '${wrong_user}' | wc -l) -eq 0",
    path    => '/bin:/usr/bin',
    logoutput => true,
    returns   => [0,1],
  }
}
