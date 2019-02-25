# -*- mode: puppet -*-
# vi: set ft=puppet :

# The 'custom_command::exec_powershell_parameters_json' type illustrates
# loading a powershell script with a complex input parameters using
# json serialization of hieradata-originated array or hash class parameters
# erb template and using Powershell 'convertfrom-json' cmdlet

define custom_command::exec_powershell_parameters_json(

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
    }
  ),
  String $template = 'powershell_parameters_json',
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

  # alternatively install and use custom fact
  # see: https://github.com/WhatsARanjit/puppet-diskspace/blob/master/lib/facter/diskspace.rb
  # that simply does wmi query via Facter::Util::Resolution.exec
  # Alternatively use FFI
  # for 'GetDiskFreeSpace','QueryDosDevice' API e.g. like is done in
  # https://rubygems.org/gems/sys-filesystem

  # https://stackoverflow.com/questions/4508692/get-available-diskspace-in-ruby/6161434
  # or call WMI from Ruby using win32ole gem, that is pre-installed by the Puppet agent and is located in embedded Ruby in 'c:/Program Files/Puppet Labs/Puppet/sys/ruby/lib/ruby/2.1.0/win32ole'
  # https://www.ruby-forum.com/t/ruby-wmi-win32ole/140683/2
  # https://stackoverflow.com/questions/2903169/calculate-free-space-of-c-drive-using-vbscript
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
