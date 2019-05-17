# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' {
  include urugeas
  $user = 'username'
  class{ 'limits':
    limits_dir => '/etc/security/limits.d',
    purge_limits_d_dir  => true,
    manage_limits_d_dir => true,
    # fancy key
    # not following packed key may lead to compilation problem
    # ==> Error while evaluating a Function Call, when not using the title pattern, $user and $limit_type are required at limits/manifests/limits.pp:36
    entries => {
      # this will create the '/etc/security/limits.d/username_nofile.conf'
      # with the following contents:
      #
      #  # Managed by Puppet
      #
      #  #<domain>  <type> <item>          <value>
      #  username   hard   nofile          12345
      #  username   soft   nofile          123
      #
      # if '*' is used it becomes 'default_nofile.conf'
      "${user}/nofile" => {
        'hard' => 1,
        'soft' => 666,
      },
      # this will create the '/etc/security/limits.d/username_nproc.conf'
      "${user}/nproc" => {
        'hard' => 42,
        'soft' => 100500,
      }
    },
  }
  # NOTE: need to make a conf extension in the resource title 
  # otherwise is not becoming the filename, rather
  # user + limit_type is
  -> limits::limits { '20-limits.conf':
    ensure     => present,
    user       => 'username1',
    limit_type => 'nofile',
    hard       => 1024,
  }
  # need unique name for each  data entry
  -> limits::limits { '21-nofile':
    ensure     => present,
    user       => 'username2',
    limit_type => 'nofile',
    hard       => 1024,
  }
  -> limits::limits { '20-nproc':
    ensure     => present,
    user       => 'username1',
    limit_type => 'nproc',
    hard       => 16,
  }
  -> limits::limits { '21-nproc':
    ensure     => present,
    user       => 'username2',
    limit_type => 'nproc',
    hard       => 32,
  }
}
