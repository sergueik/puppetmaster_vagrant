# use generate to do a file system test assigns the result to a noop parameter
class generate_noop { 

  $filename = 'c:\Windows\Tasks\SampleJob.job'
  # TODO: Generate the 'cmd' script 
  # currently does not work - error due to resource ordering 
  # $generate_noop = generate('c:\windows\system32\cmd.exe', '/c  c:\windows\temp\a.cmd' )
  file { 'c:\windows\temp\a.cmd' :
    ensure  => file,
    content => "if exist ${filename} ( echo true ) else ( echo false )",
    # before  => ...,
   }
  # cmd is known for its fragile syntax:  the following does not work, reported that " was not expected. 
  # $generate_noop = generate('c:\windows\system32\cmd.exe', '/c if exist c:\Windows\Tasks\CleanSysDrv.job  ( echo true ) else  ( echo false )' )
  # One can develop the snippet in question in Powershell 
  # or run C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -command "if (test-path -path '${filename}')  { write-output true } else { write-output  false}"
  $generate_noop = generate('C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe', "if (test-path -path '${filename}') { write-output 'true' } else { write-output  'false'}" )
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