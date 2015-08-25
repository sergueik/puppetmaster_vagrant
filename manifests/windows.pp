node 'windows7' {

  notify { 'log_message1' :
    message => 'Started node manifest',
  }

  exec { 'connect to WMI':
     # file will be written to c:/Windows/System32/
     command   => 'write-output (Get-WMIObject "cim_operatingsystem") | out-file -filepath "puppet_powershell_run.txt"',
     provider  => powershell,
  }

include 'mywebsite'

  notify { 'log_message2' :
    message => 'completed execution',
  }
}
