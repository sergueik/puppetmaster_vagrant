node 'windows7' {

  notify { 'log_message1' :
    message => 'Started node manifest',
  }

  exec { 'connect to WMI':
     command   => 'Get-WMIObject "cim_operatingsystem"',
     provider  => powershell,
  }

  notify { 'log_message2' :
    message => 'completed powershell command',
  }

  package { 'git' :
    ensure => 'latest',
    provider => 'chocolatey',
  }

  notify { 'log_message3' :
    message => 'completed git install',
  }

  notify { 'test_message' :
    message => 'completed execution',
  }
}
