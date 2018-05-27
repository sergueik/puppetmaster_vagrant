class urugeas(

  Boolean $exercise_augeas     = true, # exercise augeas resource
  Boolean $exercise_augtool    = true, # exercise augtool command
  Array $tomcat_security_part1 = [],
  Array $tomcat_security_part2 = [],
  Array $augeas_testing = lookup('urugeas::augeas_testing',
                          Array[String],
                          first,
                         [
    'set useSecurity/#text false',
    'set port/#text 8000',
    'set securityRealm/#attribute/class "example attribute"',
    'insert "test" before securityRealm/authContext', # add node
    'set securityRealm/test/#attribute/class "test class"', # set attribute
    'set securityRealm/test/#text "test text"', # set text
    # 'clear securityRealm/authContext', # this does not appear to work
    # 'rm securityRealm/authContext', # this will work
  ]),
){
  require 'stdlib'

  file { '/etc/versions.rb':
    ensure  => file,
    content => epp("${name}/versions_rb.epp"),
  }

  $config_template = @(END)
      <hudson>
      <useSecurity>true</useSecurity>
        <port>9090</port>
        <securityRealm class = "class name">
          <authContext>node to disappear</authContext>
          <detail>some data about <%= $service_name -%></detail>
        </securityRealm>
      </hudson>
     |END
  $config_dir = '/var/lib/jenkins'
  $config_file = "${cofig_dir}/config_xml"
  file { $config_dir:
    ensure => 'directory',
  }

  -> file { $config_file:
       ensure => 'file',
       content  => inline_epp($config_template, {'service_name' => 'some service'}),
     }
  -> file { '/var/lib/jenkins/web.xml':
       ensure => 'file',
       source => "puppet:///modules/${name}/tomcat/web.xml",
     }
  if $exercise_augeas {
    augeas{ 'augeas capability testing changes':
       incl    => $config_file,
       lens    => 'Xml.lns',
       context => "/files/${config_file}/hudson",
       changes => $augeas_testing,
       require => File[$config_file],
     }
  -> augeas{ 'tomcat security changes part 1':
       incl    => $config_file,
       lens    => 'Xml.lns',
       context => "/files/${config_file}/hudson",
       changes => $tomcat_security_part1,
     }
  -> augeas{ 'tomcat security changes part 2':
       incl    => $config_file,
       lens    => 'Xml.lns',
       context => "/files/${config_file}/hudson",
       changes => $tomcat_security_part2,
     }
  }
  if $exercise_augtool {
    $augtool_command = lookup('urugeas::augtool_command')
    file { '/tmp/script.au':
      ensure  => 'file',
      # content => inline_template($augtool_command),
      # NOTE: Failed to parse inline template: undefined method `encoding' for #<Array:0x00000002cae958>
      # NOTE: inline_template(*$augtool_command) loses newlines
      content => inline_template($augtool_command.join("\n")),

      # source => "puppet:///modules/${name}/augtool/script.au",
    }
    -> exec { 'Run agutool with script':
      command   => 'augtool -f /tmp/script.au',
      path      => ['/bin/','/usr/bin','/opt/puppetlabs/puppet/bin'],
      provider  => shell,
      logoutput => true,
    }

  }
}
