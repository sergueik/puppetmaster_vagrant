# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' {
  # include urugeas
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
}