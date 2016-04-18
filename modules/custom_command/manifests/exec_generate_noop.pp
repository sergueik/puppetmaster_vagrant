# -*- mode: puppet -*-
# vi: set ft=puppet :

# accesses a file system test through generate 
# convert the result to boolean assigns to a noop parameter
# alternative is to create a custom fact
define custom_command::generate_noop { 
  
  $filename = 'c:\Windows\Tasks\SampleJob.job'
  
  $generate_noop = generate('C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe', "\$filename = '${filename}'; \$status = (test-path -path \$filename -ErrorAction SilentlyContinue ); write-output \$status.toString()" )
  case $generate_noop {
    /true/: {
      $noop = true
    }
    /false/: {
      $noop = false
    }
    default: {
      $noop = false
    }
  }
}