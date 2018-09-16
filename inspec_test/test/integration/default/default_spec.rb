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
