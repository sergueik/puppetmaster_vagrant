# TODO: hiera configuration is not correct.
class profiles::bootstrap (
  Boolean $file         = false,
  String $setting       = 'some setting',
  Array $augeas_changes = [
    'set useSecurity/#text false',
    'set port/#text 8000',
    'set securityRealm/#attribute/class "example attribute"',
    'insert "test" before securityRealm/authContext', # add node
    'set securityRealm/test/#attribute/class "test class"', # set attribute 
    'set securityRealm/test/#text "test text"', # set text
    'clear securityRealm/authContext', # this does not appear to work
    'rm securityRealm/authContext', # this will work
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
  <securityRealm class="org.jenkinsci.plugins.reverse_proxy_auth.ReverseProxySecurityRealm" plugin="reverse-proxy-auth-plugin@1.4.0">
    <authContext>some data to disappear</authContext>
  </securityRealm>
</hudson>
END
  file { '/var/lib/jenkins/':
    ensure => 'directory',
  }
  -> notify {"augeas change to apply:": 
       message => $augeas_changes,
     }
  -> file { '/var/lib/jenkins/config.xml':
       ensure => 'file',
       # source =>'puppet:///profiles/bootstrap/config.xml',
       # source =>'puppet:///modules/profiles/bootstrap/config.xml',
       content  => inline_epp($config_template, {'service_name' => 'xntpd', 'iburst_enable' => true}),
     }
  -> augeas{ 'augeas changes':
       incl    => '/var/lib/jenkins/config.xml',
       lens    => 'Xml.lns',
       context => '/files/var/lib/jenkins/config.xml/hudson',
       changes => $augeas_changes,
     }
}


