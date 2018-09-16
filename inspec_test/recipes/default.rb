#
# Cookbook Name:: test-inspec
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
#

file '/tmp/file' do
  mode '0765'
  owner 'root'
  group 'root'
  content 'hello world'
end
