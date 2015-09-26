# -*- mode: puppet -*-
# vi: set ft=puppet :

node 'windows7' {
  include wait_for
  $_name = 'test application'
  # $my_file_arg = 'c:/temp/cleanup.cmd'
  # include 'mywebsite'
 # include 'custom_command'
  class { 'custom_command': 
    title   => 'Launch_selenium_grid_node',
    enable  => true,
    config  => 'unused',
    version => '0.1.0'
  }
}
