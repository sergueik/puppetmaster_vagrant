# -*- mode: puppet -*-
# vi: set ft=puppet :

# The 'urugeas::exec_shell_parameters_json' type illustrates
# loading bash shell script with a complex input parameters using
# json serialization of hieradata-originated array or hash type parameters
# erb template and using jq

define urugeas::exec_shell_parameters_json(

  Array[String] $params_array = lookup("${name}::params_array",
    Array[String],
    first,
    [
      'a',
      'b',
      'c',
    ]
  ),
  Hash $params_hash  = lookup("${name}::params_hash",
    Hash[String,String],
    first, {
      'a' => '1',
      'b' => '2',
    }
  ),
  String $template = 'shell_parameters_json',
  String $version = '0.1.0'
)   {

  $debug = true
  # Validate install parameters.
  # https://github.com/puppetlabs/puppetlabs-stdlib
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  # demonstrate using json to serialize complex input
  $params_array_as_json = $params_array.to_json
  $params_hash_as_json = $params_hash.to_json
  $shell_script = "${template}.sh"
  file {"${title} generated script":
    ensure  => file,
    mode    => '0775',
    owner   => root,
    group   => root,
    path    => "/tmp/${shell_script}",
    content => template("urugeas/${template}_sh.erb"),
  }

  -> exec {"${title} runs script":
    command   => "/tmp/${shell_script}",
    cwd       => '/tmp',
    logoutput => true,
    path      => '/bin:/usr/bin:/use/local/bin',
    provider  => 'shell',
  }
  if $debug {
    notify {"${title} generates shell script with json parameters":
      message   => template("urugeas/${template}_sh.erb"),
      before  => File["${title} generated script"],
    }
  }
}
