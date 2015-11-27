# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'windows7' {
  # running Windows Desktop Application directly by puppet will be hanging Puppet and Vagrant:
  $run_command = 'C:\Users\vagrant\Desktop\timing\Program\bin\Debug\timing.exe'
#  exec { 'Run desktop application':
#    command => $run_command,
#    logoutput => true,
#  }
  custom_command { 'launch timing system tray app':
    command => $run_command,
    script  => 'launch_timing_system_tray_app',
    wait    => false,
  }

}

