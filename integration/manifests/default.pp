# -*- mode: puppet -*-
# vi: set ft=puppet :
node 'default' {
  $home = env('HOME')
  notify {"home=${home}":}
  $path = env('PATH')
  notify {"path=${path}":}
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

      # NOTE: settings need to be reviwed, e.g.
      # datadir is not applicable to client leading
      # to a provision error arising acrually from ruby code in mysql/lib/...
      # Execution of '/bin/mysql --defaults-extra-file=/root/.my.cnf -NBe SELECT CONCAT(User, '@',Host) AS User FROM mysql.user' returned 7:
      # /bin/mysql: unknown variable 'datadir=/opt/mysql/var/lib'
      # NOTE: ignorable? Error:
      # Facter: error while resolving custom fact "mysql_version": undefined method `[]' for nil:NilClass
    }
  }
  class { '::mysql::server':
    root_password           => 'strongpassword',
    remove_default_accounts => true,
    override_options        => $override_options,
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
}

