class urugeas::cron_schedule ( 
) {

  $command_template = hiera('urugeas::command_template')
  # this creates a set of every 30 minite cron job but instead of */30 starts them with a random seed
  # scattering evenly

  $suffixes =  ['db1', 'db2', 'db3', 'db4', 'db5', 'db6', 'db7']
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
      content => $report_command,
      mode    => '0755',
      owner   => 'root',
      require => File['report base directory'],
    }
    -> cron { $cron_job_name:
      hour    => '*',
      minute  => [$minute_seed, 30 + $minute_seed],
      command => $shell_script,
      user    => 'root',
    }
    # will create evenly scattered 30-min interval cron jobs
    #  0,30 * * * * /var/run/extract_data_db1.sh
    #  10,40 * * * * /var/run/extract_data_db2.sh
    #  20,50 * * * * /var/run/extract_data_db3.sh
  }

}
