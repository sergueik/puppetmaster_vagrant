# -*- mode: puppet -*-
# vi: set ft=puppet :
# This type illustrates  loading a powershell script with a comex input parameter data from json serialized hieradata and erb template

define custom_command::exec_data_parameter_json(

  Array[String] $params_array = lookup("${name}::params_array",
    Array[String],
    first,
    [
      'C:',
      'D:',
      'E:',
      # this will work
    ]
  ),
  Hash $params_hash  = lookup("${name}::params_hash",
       Hash[String,String],
       first, {
         'C:' => 'C:\\Programdata\Jenkins',
         'E:' => 'd:\\Jenkins',
       }),
  String $template = 'exec_powershell_parameters',
  String $version = '0.1.0'
)   {

  $debug = true
  # Validate install parameters.
  # https://github.com/puppetlabs/puppetlabs-stdlib
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  # demonstrate using json to serialize complex input
  # make sure the JSON is single line
  $params_array_as_json = regsubst($params_array.to_json, '\n', '')
  $params_hash_as_json = regsubst($params_hash.to_json, '\n', '')
  exec {"${title} generates inline script from ${template}":
    cwd       => 'c:\windows\temp',
    logoutput => true,
    path      => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    provider  => 'powershell',
    command    => template("custom_command/${template}_ps1.erb"),
  }
  if $debug {
    notify {"${title} generates json parameters": 
      message => "params_array_as_json = \"${params_array_as_json}\"; params_hash_as_json = \"${params_hash_as_json}\"; ",
      before  => Exec["${title} generates inline script from ${template}"],
    }
  }
}
