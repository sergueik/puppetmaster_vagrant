node 'default' { 
  notify { 'log_message' :
    message => 'Started node manifest',
  }

}
