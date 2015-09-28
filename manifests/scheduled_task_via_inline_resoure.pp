# -*- mode: puppet -*-
# vi: set ft=puppet :
# inline custom type 

define custom_command_inline(

  $wait        = true,
  $command     = 'notepad.exe',
  $script      = 'manage_scheduled_task_from_inline',
  $version     = '0.2.0'
)   { 
  # Validate install parameters.
  validate_bool($wait)
  validate_string($script)
  validate_string($command)
  validate_re($version, '^\d+\.\d+\.\d+(-\d+)*$') 
  $script_path = "c:\\temp\\${script}.ps1"
  $random = fqdn_rand(1000,$::uptime_seconds)
  $log = "c:\\temp\\${script}${random}.log"
  $taskname = regsubst($name, " +", '_', 'G') # 'Launch_selenium_grid_node'
  $inline_template = "\$level = 'HIGHEST'\r\n \$schedule = 'ONCE'\r\n \$time = '00:00' # required, irrrevant\r\n \$run_command = '<%= @command -%>'\r\n \$taskname = '<%= @taskname -%>'\r\n if (\$run_command -eq ''){\r\n \$run_command = 'notepad.exe'\r\n }\r\n \$delete_existing_schedules = \$true\r\n \r\n function log{\r\n param(\r\n [string]\$message,\r\n [string]\$log_file  = '<%=@log-%>'\r\n)\r\n write-host \$message\r\n write-output \$message | out-file \$log_file -append -encoding ascii\r\n }\r\n \r\n log -message ('Launching task for {0}' -f \$run_command)\r\n \$env:PATH = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)\r\n \r\n if (\$delete_existing_schedules) {\r\n \$status = schtasks /query /TN \$taskname| select-string -pattern '\${taskname}' \r\n log \$status\r\n if (\$status -ne \$null){\r\n log -message '\${taskname} is present, deleting...'\r\n & schtasks /Delete /TN \$taskname /F\r\n } else { \r\n write-host 'No \${taskname} is present...ignoring'\r\n log -message 'No \${taskname} is present...ignoring'\r\n }\r\n }\r\n log ('Creating {0}' -f \$taskname )\r\n & schtasks /Create  /TN \$taskname /RL \$level /TR \$run_command /SC \$schedule /ST \$time\r\n log ('Starting {0}' -f \$taskname )\r\n & schtasks /Run /TN \$taskname\r\n \$count = 1\r\n \$max_count = 100\r\n \$running = \$false\r\n \$finished = \$false\r\n while(\$count -le \$max_count ){\r\n \$count ++\r\n \$status = & schtasks /query /TN \$taskname| select-string -pattern '\${taskname}'\r\n log \$status\r\n if (\$status.tostring() -match '(Could not)'){\r\n log 'WARNING: \${taskname} has failed...'\r\n break \r\n } elseif (\$status.tostring() -match '(Ready)'){\r\n log 'NOTICE: \${taskname} is ready...'\r\n \$running = \$true\r\n } elseif (\$status.tostring() -match '(Running)'){\r\n log 'SUCCESS: \${taskname} is running...'\r\n \$running = \$true\r\n break \r\n } else { \r\n log 'WARNING: \${taskname} is not yet running...'\r\n }\r\n start-sleep -milliseconds 1000\r\n }\r\n # TODO : time management\r\n if (\$running){\r\n log 'NOTICE: waiting for running \${taskname} to complete...'\r\n \$count = 1\r\n \$max_count = 10\r\n while(\$count -le \$max_count ){\r\n \$count ++\r\n \$status = & schtasks /query /TN \$taskname| select-string -pattern '\${taskname}'\r\n log \$status\r\n if (\$status.tostring() -match '(Could not|Failed)'){\r\n log 'WARNING: \${taskname} has failed...'\r\n break \r\n } elseif (\$status.tostring() -match '(Running)'){\r\n log 'NOTICE: \${taskname} is running...'\r\n } else { \r\n log 'SUCCESS: \${taskname} is finished...'\r\n \$finished = \$true\r\n break \r\n }\r\n start-sleep -milliseconds 60000\r\n }\r\n }\r\n log 'Complete'\r\n <#\r\n NOTE:\r\n Task Scheduler did not launch task '...'  because computer is running on batteries. \r\n User Action: If launching the task on batteries is required, change the respective flag in the task configuration.\r\n #>\r\n"
  notify { "Write powershell launcher script for ${name}":} ->
  file { "${name} launcher log":
    name               => "${script}${random}.log",
    path               => $log,
    ensure             => absent,
    source_permissions => ignore,
  } -> 
 
  file { "${name} launcher script":
    ensure             => file,
    path               => $script_path,
    content            => inline_template($inline_template),
    source_permissions => ignore,
  } -> 

  exec { "Execute script that will create and run scheduled task ${name}": 
    path    => 'C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32',
    command => "powershell -executionpolicy remotesigned -file ${script_path}",
    require  => File[ "${name} launcher script"],
  } ->

  notify { "Done ${name}.":}
}


node 'windows7' {
  custom_command_inline { 'Launch nodepad':
    command => 'notepad.exe',
    script  => 'launch_notepad',
    wait    => true,
  } 

}
