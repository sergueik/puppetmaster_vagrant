# -*- mode: puppet -*-
# vi: set ft=puppet :
node 'default' {
  $home = env('HOME')
  notify {"home=${home}":}
  $path = env('PATH')
  notify {"path=${path}":}
  include stdlib
  # for lib/puppet/functions/to_json.rb
  # need version: 4.25 (exact version to be identified)
  # found that /etc/puppetlabs/code/environments/production/modules/stdlib/lib/puppet/functions is not in the @INC path -
  include urugeas
  # include 'mysql::server'
  # default options
  $override_options = {
    'mysqld' => {
      'datadir' => '/opt/mysql/var/lib',
      'socket'  => '/opt/mysql/var/lib/mysql.sock',
      'port'    => 3306,
    },
    'client' => {
      # should one update it 2 times
      'socket'  => '/opt/mysql/var/lib/mysql.sock',
      'port'    => 3306,

      # NOTE: settings need to be reviewed, e.g.
      # datadir is not applicable to client section of  mysql my.cnf ini-file
      # leading to an  error arising actually in the ruby provider code of one of the custom types of puppetlabs-mysql
      # Execution of '/bin/mysql --defaults-extra-file=/root/.my.cnf -NBe SELECT CONCAT(User, '@',Host) AS User FROM mysql.user' returned 7:
      # /bin/mysql: unknown variable 'datadir=/opt/mysql/var/lib'
      # NOTE: ignorable? Error:
      # Facter: error while resolving custom fact "mysql_version": undefined method `[]' for nil:NilClass
    }
  }
  # https://www.digitalocean.com/community/tutorials/how-to-change-a-mysql-data-directory-to-a-new-location-on-centos-7

  $mysql_default_datadir = hiera('mysql::params::default_datadir','/var/lib/mysql')
  $mysql_custom_datadir = hiera('mysql::params::custom_datadir','/opt/mysql/var/lib/mysql')

  $mysql_user = 'mysql'
  # intend to keep Puppet module parameters unmodified to prevent it from  undoingour changes
  # copy files, remove the legacy datadir and make it a soft link to the custom datadir
  exec {"${name} copy mysql data ${mysql_default_datadir} to ${mysql_custom_datadir}":
    command   => "mkdir -p ${mysql_custom_datadir}; chown -R ${mysql_user} ${mysql_custom_datadir}; cp -prf ${mysql_default_datadir}/* ${mysql_custom_datadir}; rm -fr ${mysql_default_datadir}; ln -fs ${mysql_custom_datadir} ${mysql_default_datadir}",
    provider  => shell,
    logoutput => true,
    path      => '/usr/bin:/bin',
    onlyif    => "grep -q 'datadir *= *${mysql_default_datadir}' /etc/my.cnf",
    before    => Class['::mysql::server'],
  }

  # TODO: user proper fact
  $root_my_cnf = '/root/.my.cnf'
  $mysql_service = 'mariadb'
  exec {"Remove obsolete mysql data '${root_my_cnf}'":
    command   => "systemctl stop ${mysql_service} ; rm -fr ${root_my_cnf}",
    provider  => shell,
    logoutput => true,
    path      => '/usr/bin:/bin',
    # better to test the contents
    onlyif    => "test -f ${root_my_cnf}",
    before    => Class['::mysql::server'],
  }

  class { '::mysql::server':
    root_password           => 'strongpassword',
    remove_default_accounts => true,
    # override_options        => $override_options,
  }
  # https://puppet.com/docs/puppet/5.3/style_guide.html
  xml_fragment {
    default:
      # NOTE: '/usr/share/tomcat/conf/web.xml' is part of tomcat7 install. not declared in the manifest
      path    => '/usr/share/tomcat/conf/web.xml',;
    '/web-app/filter':
      xpath   => '/web-app/filter',
      content => {
        value => '',
      },
      before  => Xml_fragment['/web-app/filter/filter-name','/web-app/filter/filter-class','/web-app/filter/async-supported'];
    '/web-app/filter/filter-name':
      xpath   => '/web-app/filter/filter-name',
      content => {
        value => 'httpHeaderSecurity',
      },;
    '/web-app/filter/filter-class':
      xpath   => '/web-app/filter/filter-class',
      # require => Xml_fragment['/web-app/filter'],
      content => {
        value =>'org.apache.catalina.filters.HttpHeaderSecurityFilter',
      },;
    '/web-app/filter/async-supported':
      xpath   => '/web-app/filter/async-supported',
      content => {
        value =>'true',
      },;
 }
  urugeas::jenkins_job_builder { 'test':
  }
  urugeas::jenkins_job_part2_builder { 'test part 2':
  }
  notify {'all done':
    require => [
      Urugeas::Jenkins_job_builder['test'],
      Urugeas::Jenkins_job_part2_builder[ 'test part 2']
    ],
  }
  urugeas::exec_data_parameter_json { 'test': }
}

