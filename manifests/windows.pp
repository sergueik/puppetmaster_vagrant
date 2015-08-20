node 'windows7' {
  package { 'git' :
    ensure => 'latest',
    provider => 'chocolatey',
  }
  notify { 'test_message' :
    message => 'test',
  }
}
