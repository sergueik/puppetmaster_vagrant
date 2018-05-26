# TODO: hiera configuration is not correct.
class profiles::bootstrap (
  Boolean $file         = false,
  Boolean $exercise     = false, # set true to exercise augeas resource
  Boolean $security_modification     = true, # set true to exercice augtool command workaround for failing
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
) {

  if $file {
    class { '::profiles::bootstrap::file': }
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
       source =>'puppet:///modules/profiles/tomcat/web.xml',
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
  if $security_modification {
    file { '/tmp/script.au':
      ensure => 'file',
      source =>'puppet:///modules/profiles/augtool/script.au',
    }
    -> exec { 'Run agutool with script':
      command   => 'augtool -f /tmp/script.au',
      path      => ['/bin/','/usr/bin','/opt/puppetlabs/puppet/bin'],
      provider  => shell,
      logoutput => true,
    }

  }
}
