# TODO: hiera configuration is not correct.
class profiles::bootstrap (
  Boolean $file         = false,
  Boolean $exercise     = false,
  String $setting       = 'some setting',
  Array $augeas_testing_changes = [
    'set useSecurity/#text false',
    'set port/#text 8000',
    'set securityRealm/#attribute/class "example attribute"',
    'insert "test" before securityRealm/authContext', # add node
    'set securityRealm/test/#attribute/class "test class"', # set attribute
    'set securityRealm/test/#text "test text"', # set text
    #
    # 'clear securityRealm/authContext', # this operation does not appear to work
    # 'rm securityRealm/authContext', # this will work
  ],
  Array $augeas_exercise_part1_changes = [
    'insert "filter-mapping" before securityRealm/authContext',
    'set securityRealm/filter-mapping/filter-name/#text "httpHeaderSecurity"',
    'set securityRealm/filter-mapping/url-pattern/#text "/*"',
    'set securityRealm/filter-mapping/dispatcher/#text "REQUEST"',
  ],
  Array $augeas_exercise_part2_changes = [
    'insert "filter" before securityRealm/authContext',
    'set securityRealm/filter/filter-name/#text "httpHeaderSecurity"',
    'set securityRealm/filter/filter-class/#text "org.apache.catalina.filters.HttpHeaderSecurityFilter"',
    'set securityRealm/filter/async-supported/#text "true"',
    'insert "init-param" after securityRealm/filter/async-supported',
    'set securityRealm/filter/init-param/param-name/#text "antiClickJackingEnabled"',
    'set securityRealm/filter/init-param/param-value/#text "true"',
    'insert "init-param" after securityRealm/filter/async-supported',
    'set securityRealm/filter/init-param[1]/param-name/#text "antiClickJackingOption"',
    'set securityRealm/filter/init-param[1]/param-value/#text "SAMEORIGIN"',
  ],
  Array $augeas_security_part1_changes = [
    'insert "filter-mapping" before session-config',
    'set filter-mapping/filter-name/#text "httpHeaderSecurity"',
    'set filter-mapping/url-pattern/#text "/*"',
    'set filter-mapping/dispatcher/#text "REQUEST"',
  ],
  Array $augeas_security_part2_changes = [
    'insert "filter" before session-config',
    'set filter/filter-name/#text "httpHeaderSecurity"',
    'set /filter/filter-class/#text "org.apache.catalina.filters.HttpHeaderSecurityFilter"',
    'set filter/async-supported/#text "true"',
    'insert "init-param" after filter/async-supported',
    'set filter/init-param/param-name/#text "antiClickJackingEnabled"',
    'set filter/init-param/param-value/#text "true"',
    'insert "init-param" after filter/async-supported',
    'set filter/init-param[1]/param-name/#text "antiClickJackingOption"',
    'set filter/init-param[1]/param-value/#text "SAMEORIGIN"',
  ],
) {

  if $file {
    class { '::profiles::bootstrap::file': }
  }
  notify {"test setting: ${setting} ${file}":
  }
  $config_template = @(END)
<hudson>
<useSecurity>true</useSecurity>
  <port>9090</port>
  <securityRealm class = "org.jenkinsci.plugins.reverse_proxy_auth.ReverseProxySecurityRealm" plugin = "reverse-proxy-auth-plugin@1.4.0">
    <authContext>node to disappear</authContext>
    <detail>some data about <%= $service_name -%></detail>
  </securityRealm>
</hudson>
END
  file { '/var/lib/jenkins/':
    ensure => 'directory',
  }
  -> file { '/var/lib/jenkins/config.xml':
       ensure => 'file',
       content  => inline_epp($config_template, {'service_name' => 'some service'}),
     }
  -> file { '/var/lib/jenkins/web.xml':
       ensure => 'file',
       source =>'puppet:///modules/profiles/bootstrap/web.xml',
     }
  if $exercise {
    augeas{ 'augeas capability testing changes':
       incl    => '/var/lib/jenkins/config.xml',
       lens    => 'Xml.lns',
       context => '/files/var/lib/jenkins/config.xml/hudson',
       changes => $augeas_testing_changes,
       require => File['/var/lib/jenkins/config.xml'],
     }
  -> augeas{ 'augeas practice changes part 1':
       incl    => '/var/lib/jenkins/config.xml',
       lens    => 'Xml.lns',
       context => '/files/var/lib/jenkins/config.xml/hudson',
       changes => $augeas_exercise_part1_changes,
     }
  -> augeas{ 'augeas practice changes part 2':
       incl    => '/var/lib/jenkins/config.xml',
       lens    => 'Xml.lns',
       context => '/files/var/lib/jenkins/config.xml/hudson',
       changes => $augeas_exercise_part2_changes,
     }
  }
  augeas{ 'augeas web.xml security changes part 1':
    incl    => '/usr/share/tomcat/conf/web.xml',
    lens    => 'Xml.lns',
    context => '/files/usr/share/tomcat/conf/web.xml',
    changes => $augeas_security_part1_changes,
    require => File['/var/lib/jenkins/web.xml'],
  }
  -> augeas{ 'augeas web.xml security changes part 2':
    incl    => '/usr/share/tomcat/conf/web.xml',
    lens    => 'Xml.lns',
    context => '/files/usr/share/tomcat/conf/web.xml',
    changes => $augeas_security_part2_changes,
  }

    # # roughly equivalent manual commands
    # set /augeas/load/xml/lens 'Xml.lns'
    # set /augeas/load/xml/incl  '/var/lib/jenkins/web.xml'
    # load
    # print /files//var/lib/jenkins/web.xml/web-app/filter-mapping/dispatcher
    #
    #
    # insert '/files/var/lib/jenkins/web.xml/web-app/filter-mapping/dummy' before /files/var/lib/jenkins/web.xml/web-app/filter-mapping/dispatcher
    # # not creating the node yet. need the next command
    # set '/files/var/lib/jenkins/web.xml/web-app/filter-mapping/dummy/#text' 'some text'
    #
    # save

}


