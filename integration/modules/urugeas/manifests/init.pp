# -*- mode: puppet -*-
# vi: set ft=puppet :
# class `urugease` manages the tomcat security features by updating the web.xml
# @param practice_augeas  exercise augeas resource
# @param exercise_tomcat_security_change = false exercise augeas resource to manage tomcat security response headers
# @param exercise_augtool exercise augtool command. Comment during augeas resource testing

# @param tomcat_security_part1 augeas resource to add `<filter>` DOM node for `httpHeaderSecurity`
# @param tomcat_security_part2 augeas resource to add `<filter-mapping>` DOM node for `httpHeaderSecurity`
# It is convenient to break the long XML DOM management script into smaller node-specific chunks
# It is easier for augtool to add a DOM node then uncomment a present but commented DOM node
#  the class also loads the array of augtool commands from hiera entry `urugeas::augtool_command`. This is the only way we found augeas to work with Puppet and `tomcat wrb.xml`

class urugeas(

  Boolean $practice_augeas     = true,
  Boolean $exercise_tomcat_security_change = false,
  # suppressed running augool during augeas resource testing
  Boolean $exercise_augtool    = false, 
  Array $tomcat_security_part1 = [],
  Array $tomcat_security_part2 = [],
  Array $augeas_testing = lookup("${name}::augeas_testing",
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

  $config_dir = '/var/lib/jenkins'
  $config_file = "${config_dir}/config_xml"

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

  file { $config_dir:
    ensure => 'directory',
  }

  file { $config_file:
    ensure => 'file',
    content  => inline_epp($config_template, {'service_name' => 'service'}),
    require => File[$config_dir],
  }
  if $practice_augeas {
    augeas{ 'augeas capability testing changes':
      incl    => $config_file,
      lens    => 'Xml.lns',
      context => "/files${config_file}/hudson",
      changes => $augeas_testing,
      require => File[$config_file],
    }
  }
  if $exercise_tomcat_security_change {
    # NOTE: change to 'web.xml', 'session-config' to see the error
    # Error: /Stage[main]/Urugeas/Augeas[tomcat security changes part1]: Could not evaluate: Error sending command 'insert' with params ["filter-mapping", "before", "/files/var/lib/jenkins/web.xml/session-config/securityRealm/authContext"]

    # $tomcat_config_file = "${config_dir}/web.xml"
    # $node = 'session-config'

    # change to 'config.xml','hudson' to see working
    $tomcat_config_file = $config_file
    $node = 'hudson'
    if !defined(File[$tomcat_config_file ]){
       file { $tomcat_config_file:
         ensure => 'file',
         source => "puppet:///modules/${name}/tomcat/web.xml",
         require => File[$config_dir],
       }
    }
    $default_attributes = {
      incl    => $tomcat_config_file,
      context => "/files${tomcat_config_file}/${node}",
      lens    => 'Xml.lns',
      require => File[$config_file],
    }
    augeas{
      default:
        * => $default_attributes,;
      'tomcat security changes part1':
        changes => $tomcat_security_part1,;
      'tomcat security changes part 2':
        changes => $tomcat_security_part2,;
    }
  }
  if $exercise_augtool {
    # NOTE: inline_template(*$augtool_command)
    # without explicit newlines leads to augtool error
    # $augtool_command = lookup("${name}::augtool_command").map|String $line| {
    #  "${line}\n"
    # }
    $random = fqdn_rand(1000,$::uptime_seconds)
    $augtool_script = "/tmp/script_${random}.au"
    file { $augtool_script:
      ensure  => 'file',
      # content => inline_template($augtool_command),
      #  NOTE: can not pass an Array
      # NOTE: Failed to parse inline template: undefined method `encoding' for #<Array:0x00000002cae958>
      # - need splat
      # content => inline_template($augtool_command),
      content => inline_template(*(lookup("${name}::augtool_command").map |String $line| {
        "${line}\n"
      }))
      # alternative:
      #
      # content => inline_template(lookup("${name}::augtool_command").join("\n")),

      # source => "puppet:///modules/${name}/augtool/script.au",
    }
    -> exec { "Run ${augtool_script}":
      command   => "augtool -f ${augtool_script}",
      path      => ['/bin/','/usr/bin','/opt/puppetlabs/puppet/bin'],
      provider  => shell,
      logoutput => true,
    }

  }
}
