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
  # NOTE:  missing title leads to the 
  # Error: This expression is invalid. Did you try declaring a 'urugeas::cron_command::worker' resource without a title?
  urugeas::cron_command::worker  {"called by class {name}":
    query_param1     => $query_param1,
    query_param2     => $query_param2,
    command_template => $command_template,
    query_filename   => $query_filename,
    query_filepath   => $query_filepath,
  }

}
