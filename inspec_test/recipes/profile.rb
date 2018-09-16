#
# Cookbook Name:: test-inspec
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
#

sudoers = <<EOF
vagrant ALL=(ALL) NOPASSWD:ALL
admin ALL=(ALL) NOPASSWD:ALL
wheel ALL=(ALL) NOPASSWD:ALL
Dev-Ops ALL=(ALL) NOPASSWD:ALL
EOF

file '/etc/sudoers' do
  content sudoers
end

clientrb = <<EOF
Ohai::Config[:disabled_plugins] = [:Passwd,:Rackspace,:DMI,:Erlang,:Groovy,:PHP,:Eucalyptus,:NetworkListeners,:Mono,:Go,:Lua,:Rust,:Joyent,:DigitalOcean,:solaris2,:openbsd]'
EOF

file '/tmp/client.rb' do
  content clientrb
end

include_recipe 'firewall'
firewall 'default'

firewall_rule 'localhost tcp' do
  protocol :tcp
  port 0..65535
  source '127.0.0.1/32'
  command :allow
  action :create
end

package 'vim-minimal' do
  version node['vim']['version']
  action :install
end

output="#{Chef::JSONCompat.to_json_pretty(node.to_hash)}"
file '/tmp/node.json' do
  content output
end
