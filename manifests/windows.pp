# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'windows7' {

  # NOTE: the spoon selenium grid command will fail unless spoon provisioner is not being on the box
  $spoon_command = 'run base,spoonbrew/selenium-grid'
  $run_command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' ${spoon_command}"
  custom_command::exec_powershell_execution_syntax_error{'test':}
  # custom_command::exec_check_path_environment { 'c:\windows\system32': }
  # C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\opscode\chef\bin;C:\opscode\chef\embedded\bin;C:\Program Files\Spoon\Cmd;C:\Program Files\Puppet Labs\Puppet\bin
  custom_command::exec_check_path_environment { 'before removal':
    application_path => 'C:\Program Files\Spoon\Cmd',
  } ->
  custom_command::exec_path_environment { 'C:\Program Files\Spoon\Cmd': } ->
  custom_command::exec_check_path_environment { 'after removal':
    application_path => 'C:\Program Files\Spoon\Cmd', 
  }

#  custom_command::exec_shortcut { 'puppet test':
#    shortcut_targetpath => 'c:\Windows\write.exe',
#    shortcut_run_as_admin => false,
#  } ->
#  # cannot create shortcut with the same name
#  custom_command::exec_shortcut { 'puppet test(admin)':
#    shortcut_targetpath => 'c:\Windows\notepad.exe',
#    shortcut_run_as_admin => true,
#  }


#  custom_command::exec_check_path_environment { 'c:\Program Files\Oracle\VirtualBox Guest Additions':
#    debug        => true
#  }
#   custom_command::exec_template_test { 'test_path':
#    service_name => 'wscsvc', # 'WPCSvc',
#    target_path  => "C:\\Program Files\\Spoon\\Cmd\\spoon.exe", # 'c:\users',
#    debug        => true
#  }
#  custom_command::exec_template_test { 'query_is_running_service':
#    service_name => 'wscsvc', # 'WPCSvc',
#    debug        => true
#  }
#  custom_command::exec_check_powershell_version {'4': }
#  custom_command::exec_check_powershell_version {'5': }

#  custom_command::exec_powershell_execution_syntax_error {'test':}
#  custom_command::exec_service_control {'aspnet_state': }
#  custom_command::exec_service_control {'AxInstSV': }
#  custom_command::exec_remove_directory{ 'C:\Program Files\Spoon\Cmd':}
#  custom_command::exec_path_environment{ 'C:\Program Files\Spoon\Cmd':}

#  custom_command { 'Launch nodepad':
#    command => 'notepad.exe',
#    script  => 'launch_notepad',
#    wait    => true,
#  }
#  custom_command { 'Run spoon selenium grid':
#    command => $run_command,
#    script  => 'launch_spoon',
#    wait    => true,
#  }
#  Custom_command['Launch nodepad'] -> Custom_command['Run spoon selenium grid'] 
}
