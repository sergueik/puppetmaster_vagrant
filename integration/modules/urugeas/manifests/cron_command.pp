# -*- mode: puppet -*-
# vi: set ft=puppet :
class urugeas::cron_command (
  Variant[String,Integer,Undef] $query_param1 = 42,
  Variant[String,Integer,Undef] $query_param2 = 'some query parameter',
  String $command_template = hiera('urugeas::cron_command'),
  # query_filename is not currently used
  String $query_filename = lookup('urugeas::query_filename', {'default_value' => 'dummy.sql'}),
  # fail if there is no hieradata for query_filepath
  # like
  # ==> urugeas: Error: Function lookup() did not find a value for the name 'urugeas::query_filepath'
  String$query_filepath = hiera('urugeas::query_filepath'),
) {

  # fragment of the (cron job,shell script, sql script) combo-producing Pupet custom user-defined type
  notify { "command_template: ${command_template}":}
  $command = regsubst(regsubst(regsubst(regsubst($command_template,'\${QUERY_FILEPATH_PARAMETER}',$query_filepath,'G'),'\${QUERY_FILENAME}',$query_filename,'G'),'\${QUERY_PARAM1_PARAMETER}',"${query_param1}",'G'),'\${QUERY_PARAM2_PARAMETER}',"${query_param2}",'G')
  notify { "command: ${command}":}

  $sum = reduce([0, 2, 40]) |$result, $value|  { $result + $value }
  notify { "sum: ${sum}":}
  $command2_template = '${key1} ${key2} ${key3}'
  $replaceents = {
    'not a key' => $command2_template,
    'key1' => 'first value',
    'key2' => 'second value',
    'key3' => 'third value'
  }
  $keys = [undef, 'not a key', 'key1', 'key2', 'key3']
  $command_result = reduce($keys) |$result, $value|  {
    if ($result) {
      notify {"processing ${value} to update ${result}": }
      # Evaluation Error: Cannot reassign variable '$result'
      regsubst($result,"${value}",$replaceents[$value],'G')
    } else {
      notify {"processing ${value} to initialize ${result}": }
      $replaceents[$value]
    }
  }
  notify { "command_result: ${command_result}":}
}