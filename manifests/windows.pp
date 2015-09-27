# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'windows7' {
#  include wait_for
  # include 'custom_command'
  # class { 'custom_command': 
  #  title   => 'Launch_selenium_grid_node',
  #  enable  => true,
  #  config  => 'unused',
  #  version => '0.1.0'
  #}
  $spoon_command = 'run base,spoonbrew/selenium-grid'
  $run_command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' ${spoon_command}"

  custom_command { 'Launch nodepad':
    command => 'notepad.exe',
    script  => 'launch_notepad',
    wait    => true,
  } ->

  custom_command { 'Run spoon selenium grid':
    command => $run_command,
    script  => 'launch_spoon',
    wait    => true,
  }
}
