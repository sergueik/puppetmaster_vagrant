# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'default' {

  include urugeas
  include urugeas::jetty_mod 
  include urugeas::python_inline 

  $poorly_formatted_data = hiera('poorly_formatted_data', {})
  notify{'check poorly_formatted_data:' : 
    message => "poorly_formatted_data = ${poorly_formatted_data}"
  }

  # urugeas::chown {'dummy': }
  # Undefined variable 'role'
  $sample_deep_data = hiera('sample_deep_data',{ })
  $sample_data = hiera('sample_data','unknown')
  notify{"facts: ${::role}": 
    message => "sample_data = ${sample_data}, sample_deep_data = ${sample_deep_data}"
  }

  # include urugeas
  # include urugeas::cron_command
  urugeas::hieradata_check::worker{ 'called (1) from "default.pp"':
    long    => 'apache-2.4.5',
    short   => '2.4.5', # try '2.4.51'
    search  => '^apache(?:.?)([.\d]+)(?:[^d].*)*$',
    replace => '\1', # most common
    debug   => true,
  }
  urugeas::hieradata_check::worker{ 'called (2) from "default.pp"':
    long    => 'apache-2.4.5',
    short   => '2.4.51',
    search  => '^apache(?:.?)([.\d]+)(?:[^d].*)*$',
    replace => '\1', # most common
    debug   => true,
  }
  include urugeas::hieradata_check

  $unit = 'mysqld.service'
  $custom_user = 'myuser'
  $custom_group = 'myuser'
  $comment = 'Needed desired user to own the PIDFile'
  $mysqld_pre_systemd = '/usr/bin/mysqld_pre_systemd'
  $pidfile = '/var/run/mysqld/mysqld.pid'
  $pidfile_dir = regsubst($pidfile, '/[^/]*$', '')

  yumrepo { 'percona':
    descr    => 'CentOS $releasever - Percona',
    baseurl  => 'http://repo.percona.com/percona/yum/release/$releasever/RPMS/$basearch',
    gpgkey   => 'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
    enabled  => 1,
    gpgcheck => 1,
  }
  group {$custom_group:
    ensure=> present
  }
  -> user {$custom_user:
    groups => ['root', $custom_group],
    system => true,
  }
  -> class {'mysql::server':
    package_name     => 'Percona-Server-server-57',
    service_name     => 'mysql',
    config_file      => '/etc/my.cnf',
    includedir       => '/etc/my.cnf.d',
    root_password    => 'PutYourOwnPwdHere',
    override_options => {
      mysqld => {
        user      => $custom_user, 
        log-error => '/var/log/mysqld.log',
        pid-file  => $pidfile,
      },
      mysqld_safe => {
        log-error => '/var/log/mysqld.log',
      },
    }
  }
  # based on: https://puppet.com/docs/puppet/5.3/resources_augeas.html#a-better-way

  # 1. Change PermissionsStartOnly
  augeas { "Change ${unit} Service PermissionsStartOnly":
    context => "/files/usr/lib/systemd/system/${unit}",
    incl    => "/usr/lib/systemd/system/${unit}",
    lens    => 'Systemd.lns',
    changes => [
      'set Service/PermissionsStartOnly/value "true"'
    ],
    onlyif  => 'match Service/PermissionsStartOnly[value = "true"]  size == 0',
    notify  => Service['mysqld'],
  }

  # 2. Add / Change User and Group
  -> augeas { "Change ${unit} Service User and Group":
    context => "/files/usr/lib/systemd/system/${unit}",
    incl    => "/usr/lib/systemd/system/${unit}",
    lens    => 'Systemd.lns',
    changes => [
      "set Service/User/value '${custom_user}'",
      "set Service/Group/value '${custom_group}'"
    ],
    onlyif  => "match Service/User[value = '${custom_user}'] size == 0",
    notify  => Service['mysqld'],
  }

  # 3. Insert extra mysqld.service ExecStartPre command
  -> augeas { "Insert ${unit} Service extra ExecStartPre command":
    context => "/files/usr/lib/systemd/system/${unit}",
    incl    => "/usr/lib/systemd/system/${unit}",
    lens    => 'Systemd.lns',
    changes => [
      'insert "ExecStartPre" after /files/usr/lib/systemd/system/mysqld.service/Service/ExecStartPre[1]',
      'set Service/ExecStartPre[1]/command "/bin/chown"',
      'set Service/ExecStartPre[1]/arguments/1 "myuser:myuser"',
      'set Service/ExecStartPre[1]/arguments/2 "/var/run/mysqld/"',
      'set Service/ExecStartPre[2]/command "/usr/bin/mysqld_pre_systemd"',
    ],
    onlyif  => 'match /files/usr/lib/systemd/system/mysqld.service/Service/ExecStartPre[1]/command[. = "/bin/chown"] size == 0',
    notify  => Service['mysqld'],
  }

  # 3. Insert mysqld.service extra ExecStartPre command comment
  # see also: https://groups.google.com/forum/#!topic/puppet-users/g8pVNJg_jtY

 #   augeas { "Insert mysqld.service extra ExecStartPre command comment":
 #     context => "/files/usr/lib/systemd/system/${unit}",
 #     incl    => "/usr/lib/systemd/system/${unit}",
 #     lens    => 'Systemd.lns',
 #     changes => [
 #       "insert #comment before Service/ExecStartPre[command = '/bin/chown']",
 #       "set #comment[last()] '${comment}'",
 #     ],
 #     onlyif  => "match Service/ExecStartPre[command = '/bin/chown'] size == 1",
 #     notify  => Service['mysqld'],
 #     require => Augeas["Insert ${unit} Service extra ExecStartPre command"],
 #   }

  # alternative: https://github.com/tohuwabohu/puppet-patch
  class { 'patch':
  }
  $path_to_diff = "/tmp/${unit}.patch"
  $unit_template = @(END)
      @@ -8,8 +8,8 @@
       Alias=mysql.service

       [Service]
      -User=mysql
      -Group=mysql
      +User=<%= $custom_user %>
      +Group=<%= $custom_group %>

       Type=forking

      @@ -18,6 +18,11 @@
       # Disable service start and stop timeout logic of systemd for mysqld service.
       TimeoutSec=0

      +# Execute pre and post scripts as root
      +PermissionsStartOnly=true
      +
      +# Needed desired user to own the PIDFile
      +ExecStartPre=/bin/chown <%= $custom_user -%>:<%= $custom_group -%> <%= $pidfile_dir %>

       # Needed to create system tables
       ExecStartPre=/usr/bin/mysqld_pre_systemd
      |END
  file {"${unit}.patch":
    path    => $path_to_diff,
    ensure  => 'file',
    content => inline_epp($unit_template, {'custom_user' => $custom_user, 'custom_group' => $custom_group, 'pidfile_dir' => $pidfile_dir }),
  }
  -> patch::file { "/usr/lib/systemd/system/${unit}":
    diff_source => $path_to_diff,
  }
  
  # patch --dry-run  mysqld.service /tmp/mysqld.service.patch checking file mysqld.service
  # the real fix is through https://developers.redhat.com/blog/2016/09/20/managing-temporary-files-with-systemd-tmpfiles-on-rhel7/
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
