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
# the class also loads the of augtool commands from template.
# This is the only way we found augeas to work with Puppet and `web.xml`

class urugeas(

  Boolean $exercise_tomcat_security_change,
  Boolean $exercise_augtool,
  Array $tomcat_security_part1 = [],
  Array $tomcat_security_part2 = [],
  Boolean $practice_augeas =false,
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
  # suppress to prevent validation errors from stopping provision
  #   validate_hash_deep({
  #     'first' =>
  #       {
  #         'foo' => 1,
  #         'bar' => 1,
  #       },
  #     'second' =>
  #       {
  #         'foo' => 1,
  #         'bar' => 'trailing_white_space ', # trailing white space' value
  #       },
  #     'third' =>
  #       {
  #         'foo' => 1,
  #         'bad' => 1, # no 'bar' key
  #       },
  #     'fourth' => 'string', # not a hash in val
  #   })

  $config_dir = '/var/lib/jenkins'
  $config_file = "${config_dir}/config_xml"
  # NOTE: change to 'web.xml', 'session-config' to see the error
  # Could not evaluate: Error sending command 'insert' with params ["filter-mapping", "before", "/files/var/lib/jenkins/web.xml/session-config/securityRealm/authContext"]
  $tomcat_config_file = "${config_dir}/web.xml"
  $node = 'session-config'

  # change to 'config.xml','hudson' to see working
  # $tomcat_config_file = $config_file
  # $node = 'hudson'
  $xmllint_command =  "xmllint --xpath \"/*[local-name()='web-app']/*[local-name()='filter']/*[local-name()='filter-name']\" ${tomcat_config_file} | grep 'httpHeaderSecurity'"

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

  if ($exercise_tomcat_security_change or $exercise_augtool ) {
    if !defined(File[$tomcat_config_file ]){
       file { $tomcat_config_file:
         ensure => 'file',
         source => "puppet:///modules/${name}/tomcat/web.xml",
         require => File[$config_dir],
       }
    }
  }
  if $exercise_tomcat_security_change {
    $default_attributes = {
      incl    => $tomcat_config_file,
      context => "/files${tomcat_config_file}/${node}",
      lens    => 'Xml.lns',
      require => File[$tomcat_config_file],
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
    # https://puppet.com/docs/puppet/5.3/lang_data_string.html#syntax
    $command = @("END"/n$)
      AUGTOOL_SCRIPT='${augtool_script}'
      augtool -f \$AUGTOOL_SCRIPT
     |-END
    file { $augtool_script:
      ensure  => 'file',
      # content => inline_template($augtool_command),
      #  NOTE: can not pass an Array
      # NOTE: Failed to parse inline template: undefined method `encoding' for #<Array:0x00000002cae958>
      # - needs the splat
      #
      # content => inline_template(*(lookup("${name}::augtool_command").map |String $line| {
      #  "${line}\n"
      #}))
      # alternative:
      #
      # content => inline_template(lookup("${name}::augtool_command").join("\n")),
      content  => template("${name}/script_au.erb"),
      # source => "puppet:///modules/${name}/augtool/script.au",
    }
    -> notify { "Command to check if the ${augtool_script} needs to run":
      message => $xmllint_command,
    }
    -> exec { "Examnine if the ${augtool_script} needs to run":
      command   => $xmllint_command,
      path      => ['/bin/','/usr/bin','/opt/puppetlabs/puppet/bin'],
      require   => File[$tomcat_config_file],
      returns   => [0,1],
      provider  => shell,
      logoutput => true,
    }
    -> exec { "Run ${augtool_script}":
      command   => $command,
      path      => ['/bin/','/usr/bin','/opt/puppetlabs/puppet/bin'],
      require   => File[$tomcat_config_file],
      unless    => $xmllint_command,
      provider  => shell,
      logoutput => true,
    }

  }
}
