# -*- mode: puppet -*-
# vi: set ft=puppet :

define windows_xmltask::job_definition(
  $script = $title,
  $prorgam = undef,
  $arguments = undef,
  $description = undef,
  $username = 'vagrant',
  $domain = '.',
  $version = '0.1.0',
  $workdir = 'c:/windows/temp',
  $debug = false
)   {
  # validate install parameters
  validate_string($program)
  validate_string($username)
  validate_string($domain)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$')
  $taskname = regsubst($title, '[$/\\|:, ]', '_', 'G')
  # NOTE: use backslashes in generate tool path 
  $task_year = regsubst(regsubst(generate('c:\windows\system32\cmd.exe', '/c date /t'), '^.+/', ''), '\n', '')
  # NOTE: scheduled_tast idempotency issue -  trigger/start_date accepts only MM/DD/yyyy but returns YYYY-MM-DD
  scheduled_task {
    ensure => present,
    enabled => true,
    command => 'c:/windows/system32/windowspowershell/v1.0/powershell.exe',
    arguments => c:/windows/temp/sample.ps1',,
    trigged => {
      schedule => weekely,
      day_of_week => ['mon',],
      start_time => '23:00:00',
      start_date => "01/01/${task_year}"
      # will report trigger changed 
      # {'every' => '1', 'on' => ['mon'], 'schedule' => 'weekely', 'start_date' => '2016-1-1', 'start_time' => '23:0:00' }
      # to
      # ['day_of_week' => 'mon', 'schedule' => 'weekly' , 'start_date' => '01/01/2016', start_time => '23:00:00']
    }
  } 
  
  # generate job definition from template
  file { "c:\\windows\\temp\\${script}.xml":
    ensure             => file,
    content            => template('windows_xmltask/generic_task_xml.erb'),
    source_permissions => ignore,
  }
}
