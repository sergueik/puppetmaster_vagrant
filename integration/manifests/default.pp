# -*- mode: puppet -*-
# vi: set ft=puppet :
node 'default' {
  $home = env('HOME')
  notify {"home=${home}":}
  $path = env('PATH')
  notify {"path=${path}":}
  include urugeas
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

