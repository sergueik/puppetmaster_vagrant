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
  $command_template = hiera('urugeas::command_template')
  # this creates a set of every 30 minite cron job but instead of */30 starts them with a random seed
  # scattering evenly

  $suffixes =  ['db1', 'db2', 'db3']
  $report_base_directory = '/tmp/report'
  file {'report base directory':
    ensure => directory,
    path   => $report_base_directory,
    mode   => '0755',
    owner  => 'root'
  }
  $database_host = $::hostname
  $report_basename = 'report'
  $suffixes.each |Integer $index, String $suffix|{
    $report_filename = "${report_base_directory}/${report_basename}_${suffix}.txt"
    $temp_filename = "/tmp/${report_basename}_${suffix}.txt"
    #lint:ignore:single_quoted_string_with_variables
    $command = regsubst($command_template,'\${HOST}', $database_host)
    $report_command = "TEMP_FILENAME='${temp_filename}';REPORT_FILENAME='${report_filename}';$command > \$TEMP_FILENAME; if [ -s \$TEMP_FILENAME ]; then cat \$TEMP_FILENAME > \$REPORT_FILENAME ;  fi ; rm -f \$TEMP_FILENAME"
    $cron_job_name = "extract data from ${suffix}"
    $shell_script = "/var/run/extract_data_${suffix}.sh"
    #lint:endignore
    $minute_seed = $index * 30/$suffixes.size
    file {"report script ${shell_script}":
      ensure  => file,
      path    => $shell_script,
      before  => [Cron["${cron_job_name} ${minute_seed}"]],
      content => $report_command,
      mode    => '0755',
      owner   => 'root',
      require => File['report base directory'],
     }
    [$minute_seed, 30 + $minute_seed].each |Integer $minute|{

      cron { "${cron_job_name} ${minute}":
        hour    => '*',
        minute  => $minute,
        command => $shell_script,
        user    => 'root',
      }
    }
    # will create  cron jobs
    # Puppet Name: extract data ...
    #  0 * * * * /var/run/extract_data_db1.sh
    #  30 * * * * /var/run/extract_data_db1.sh
    #  10 * * * * /var/run/extract_data_db2.sh
    #  40 * * * * /var/run/extract_data_db2.sh
    #  20 * * * * /var/run/extract_data_db3.sh
    #  50 * * * * /var/run/extract_data_db3.sh
  }

}
