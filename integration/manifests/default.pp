# -*- mode: puppet -*-
# vi: set ft=puppet :
node 'default' {
  include urugeas
  # take 2
  xml_fragment { '/web-app/filter':
    path    => '/usr/share/tomcat/conf/web.xml',
    xpath   => '/web-app/filter',
    # '/usr/share/tomcat/conf/web.xml' is part of tomcat7 install
    content => {
      value => '',
    }
  }
  xml_fragment { '/web-app/filter/filter-name':
    path    => '/usr/share/tomcat/conf/web.xml',
    xpath   => '/web-app/filter/filter-name',
    require => Xml_fragment['/web-app/filter'],
    content => {
      value => 'httpHeaderSecurity',
    }
  }
  xml_fragment { '/web-app/filter/filter-class':
    path    => '/usr/share/tomcat/conf/web.xml',
    xpath   => '/web-app/filter/filter-class',
    require => Xml_fragment['/web-app/filter'],
    content => {
      value =>'org.apache.catalina.filters.HttpHeaderSecurityFilter',
    }
  }
  xml_fragment { '/web-app/filter/async-supported':
    path    => '/usr/share/tomcat/conf/web.xml',
    xpath   => '/web-app/filter/async-supported',
    require => Xml_fragment['/web-app/filter'],
    content => {
      value =>'true',
    }
  }
}