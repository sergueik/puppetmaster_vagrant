require 'rexml/document'

require 'yaml'
require 'json'
require 'csv'
require 'pp'

describe command('/usr/sbin/sestatus -v') do
  its(:stdout) { should match('Current mode:\s.*?permissive') }
end
command_result = command('/usr/sbin/sestatus -v').stdout
begin
  @res = CSV.parse(command_result)
  pp @res
rescue => e
  $stderr.puts e.to_s
end
describe String(command_result) do
  it { should_not be_empty  }
end
describe String(command_result) do
  it { should_not be_empty  }
end
command_result = command('/bin/echo "{\\"answer\\":42}"').stdout
answer = begin
  @res = JSON.parse(command_result)
  @res['answer']
rescue => e
  $stderr.puts e.to_s
  nil
end
pp answer

describe String(answer) do
  it { should eq '42' }
end
describe file('/tmp/file') do
  it { should exist }
  it 'test file attributes' do  
    should be_file
    should_not be_directory 
    should_not be_pipe 
    should_not be_socket 
    should_not be_symlink 
  end
  # it { should_not be_block_device }
  # it { should_not be_character_device }
  # it { should_not be_mounted }
  its('content') { should eq 'hello world' }
end
# copied from test/integration/profile/controls/default.rb
describe package('vim-minimal') do
  it { should be_installed }
  # it { should be_installed.with_version('123') }
  # [FAIL]  undefined method `with_version' for #<RSpec::Matchers::DSL::Matcher be_installed>
  its('version') { should eq '7.4.629-5.el6' }
end
