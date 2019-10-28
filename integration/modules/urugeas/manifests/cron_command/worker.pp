
# -*- mode: puppet -*-
# vi: set ft=puppet :
define urugeas::cron_command::worker (
  Variant[String,Integer,Undef] $query_param1 = 42,
  Variant[String,Integer,Undef] $query_param2 = 'some query parameter',
  String $command_template = hiera('urugeas::cron_command'),
  # query_filename is not currently used
  String $query_filename = lookup('urugeas::query_filename', {'default_value' => 'dummy.sql'}),
  String$query_filepath = hiera('urugeas::query_filepath'),
) {
  # fragment of the (cron job,shell script, sql script) combo-producing Pupet custom user-defined type
  notify { "command_template: ${command_template}":}
  $command = regsubst(regsubst(regsubst(regsubst($command_template,'\${QUERY_FILEPATH_PARAMETER}',$query_filepath,'G'),'\${QUERY_FILENAME}',$query_filename,'G'),'\${QUERY_PARAM1_PARAMETER}',"${query_param1}",'G'),'\${QUERY_PARAM2_PARAMETER}',"${query_param2}",'G')
  notify { "command: ${command}":}

  # $command2_template = '${key1} ${key2} ${key3}'

  $command2_template = lookup("${name}::command2_template", {'default_value' => '${key1} ${key2} ${key3}'})
  notify {"Loading parameters for command2_template from '${name}::command2_template' hieradata key ": }

  $replacements = lookup("${name}::replacements",
    Hash[String,Variant[String,Integer,Undef]],
    first, {
    'key1' => 'first value',
    'key2' => 'second value',
    'key3' => 'third value'
    })
  notify {"Loading parameters for replacements from '${name}::replacements' hieradata key": }

  # https://puppet.com/docs/puppet/5.5/lang_iteration.html#using-iteration-to-transform-data
  # the undef entry will be skipped ?

  $keys = flatten([[undef, undef], ['key1', 'key2', 'key3']])
  $command_result = reduce($keys) |$result, $value|  {
    if ($result) {
      $spot = "\\\${${value}}"
      notify {"processing ${value} (${spot}) to update result (${result})": }
      # Evaluation Error: Cannot reassign variable '$result'
      regsubst($result, "\\\${${value}}", "${$replacements[$value]}",'G')
    } else {
      notify {"initialize the result with '${command2_template}' ignoring the value ${value}": }
      $command2_template
    }
  }
  notify { "command_result: ${command_result}":}

}
