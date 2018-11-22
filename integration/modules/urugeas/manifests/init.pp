# -*- mode: puppet -*-
# vi: set ft=puppet :
# class `urugeas` manages the tomcat security features by updating the web.xml
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
  Boolean $practice_augeas     = false,
  Array $augeas_testing        = lookup("${name}::augeas_testing",
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
  Hash $package_add_01 = lookup("${name}::package_add_01",
       Hash[String,String],
       first, {
         'patch11' => '0be0b7181969e08f35b583bd3fae195ce3b79ce6792f035761f0594ca6dcddc6',
         'patch12' => '0be0b7181969e08f35b583bd3fae195ce3b79ce6792f035761f0594ca6dcddc6'
       }),
  Hash $package_add_02 = lookup("${name}::package_add_02",
       Hash[String,String],
       first, {
         'patch21' => '0be0b7181969e08f35b583bd3fae195ce3b79ce6792f035761f0594ca6dcddc6',
         'patch22' => '0be0b7181969e08f35b583bd3fae195ce3b79ce6792f035761f0594ca6dcddc6'
       }),
  Hash $package_add_03 = lookup("${name}::package_add_03",
       Hash[String,String],
       first, {
         'patch31' => '0be0b7181969e08f35b583bd3fae195ce3b79ce6792f035761f0594ca6dcddc6',
         'patch32' => '0be0b7181969e08f35b583bd3fae195ce3b79ce6792f035761f0594ca6dcddc6',
         'patch33' => '0be0b7181969e08f35b583bd3fae195ce3b79ce6792f035761f0594ca6dcddc6',
         'patch34' => '0be0b7181969e08f35b583bd3fae195ce3b79ce6792f035761f0594ca6dcddc6',
       }),
  Hash $package_add_04 = lookup("${name}::package_add_04",
       Hash[String,String],
       first, {
         'patch41' => '0be0b7181969e08f45b584bd4fae195ce4b79ce6792f045761f0594ca6dcddc6',
         'patch42' => '0be0b7181969e08f45b584bd4fae195ce4b79ce6792f045761f0594ca6dcddc6',
         'patch43' => '0be0b7181969e08f45b584bd4fae195ce4b79ce6792f045761f0594ca6dcddc6',
         'patch44' => '0be0b7181969e08f45b584bd4fae195ce4b79ce6792f045761f0594ca6dcddc6'
       }),
  Hash $package_remove_01 = lookup("${name}::package_remove_01",
       Hash[String,Optional[String]],
       first, {
         'patch25' => undef,
       }),
  Hash $package_remove_02 = lookup("${name}::package_remove_02",
       Hash[String,Optional[String]],
       first, {
         'patch26' => undef,
       }),
  Array[String] $package_remove_03 = lookup("${name}::package_remove_02",
       Array[String],
       first, [
         'patch31',
       ]),
  String $rest_command_payload_fragment = lookup('urugeas::rest_command_payload_fragment'),
){

  require 'stdlib'

  $param1 = hiera('urugeas::param1')
  $param2 = hiera('urugeas::param2')
  $param3 = hiera('urugeas::param3')
  notify{"param1: ${param1}": }
  notify{"param2: ${param2}": }
  notify{"param3: ${param3}": }

  $package_add_keys = keys( deep_merge(
    $package_add_01,
    $package_add_02,
    $package_add_03,
    $package_add_04
  ))
  # the package remove may be specified as a hash
  $package_remove_keys = keys( deep_merge(
    $package_remove_01,
    $package_remove_02
  ))
  $key_intersection1 = intersection($package_add_keys,$package_remove_keys )
  if ( $key_intersection1.size != 0 ) {
    fail( "Expected no parameter intersecrion between the packages to install and uninstall, found  ${key_intersection1}")
  }
  # or as an array
  $key_intersection2 = intersection($package_add_keys,$package_remove_03 )
  if ( $key_intersection2.size != 0 ) {
    notify { "Expected no parameter intersecrion between the packages to install and uninstall, found  ${key_intersection2}":
      message => 'fail(...) is commented - this is demo',
    }
    # fail( "Expected no parameter intersecrion between the packages to install and uninstall, found  ${key_intersection2}")
  }
  $ssl_command_data = {
    # the keys are stores certificates to sign or something similar
    # with a traditionally cryptic and long ssl command(s)
    # used for actual 'command' and 'unless|onlyif' of the Pupper exec
    # resource set
    # assume that for some reason the set is to be ordered.
    # in this eample values are all uniform.
    # In the real life the values are usually not uniform:
    # one can not reduce them to a smaller number
    'admin' => {
      'name'          => 'Execrise admin',
      'src'           => 'admin-store',
      'tmpfile'       => 'admin',
      'alias'         => 'admin-cert',
      'next'          => 'Exercise user',
      # NOTE: cannot store plain Puppet reource type e.g. Notify, here:
      # 'next_resource' => Notify['Exercise user'],
      # Evaluation Error:
      # Error while evaluating a Method call, block parameter 'value' entry 'next' expects a Data value got Type
      # 'next_resource' => [Notify['Exercise user']],
      # Error while evaluating a Method call, block parameter 'value' entry 'next_resource' expects a Data value, got Tuple
      # Convertting the rest of the values to arrays like $src => ['user_store']
      # does not get rid of this error
    },
    'user' => {
      'name'          => 'Exercise user',
      'src'           => 'user-store',
      'tmpfile'       => 'user',
      'alias'         => 'user-cert',
      'next'          => '',
      # 'next_resource' => [],
    },

  }
  $ssl_command_data.each |String $store_key, Hash $value| {
    $name    = $value['name']
    $src     = $value['src']
    $tmpfile = $value['tmpfile']
    $alias   = $value['alias']
    # $next_resource    = $value['next_resource']
    $next    = $value['next']
    if $next != '' {
      $next_resource = [Notify[$next]]
    } else {
      $next_resource = []
    }
    notify { $name:
      message => "Actual \"command\" or \"unless\" or \"onlyif\" attribute of the exec resource, with ${tmpfile} ${alias} ${src} placeholders",
      before => $next_resource,
    }
  }

  notify {'dummy': }
  notify {'rest_command_payload_fragment':
    message => $rest_command_payload_fragment,
  }


  # alternative approach to define additional hash for resource ordering in parallel with the main one with the interpolate variables
  # Mixig together different object types in the hash does not seem to work

  $ssl_command_data_next_resource = {
    'admin' => {
      'next_resource' => [Notify['Exercise user']],
    },
    'user' => {
      'next_resource' => [],
    },
  }

  $ssl_command_data.each |String $store_key, Hash $value| {
    $name    = $value['name']
    $src     = $value['src']
    $tmpfile = $value['tmpfile']
    $alias   = $value['alias']
    # $resource = flatten($ssl_command_data_arrays['admin']['next_resource'])
    $next_resource    = $ssl_command_data_next_resource[$store_key]['next_resource']
    notify { "${name} (alternative)" :
      message => "Actual \"command\" or \"unless\" or \"onlyif\" attribute of the exec resource, with ${tmpfile} ${alias} ${src} placeholders",
      before => $next_resource,
    }
  }


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
    -> exec { "Examine if the ${augtool_script} needs to run":
      command   => $xmllint_command,
      path      => ['/bin/','/usr/bin','/opt/puppetlabs/puppet/bin'],
      require   => File[$tomcat_config_file],
      returns   => [0,1],
      provider  => shell,
      logoutput => true,
    }
    -> exec { "Run ${augtool_script}":
                   # NOTE Failed to open /tmp/script_305.au^M: No such file or directory
      command   => regsubst($command, '\r', ''),
      path      => ['/bin/','/usr/bin','/opt/puppetlabs/puppet/bin'],
      require   => [File[$tomcat_config_file],File[$augtool_script]],
      unless    => $xmllint_command,
      # NOTE: temporary
      returns   => [0,1],
      provider  => shell,
      logoutput => true,
    }

  }
  include urugeas::cron_schedule
}
