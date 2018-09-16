describe file('/tmp/file') do
  it { should exist }
  it { should be_file }
  it { should_not be_directory }
  it { should_not be_block_device }
  it { should_not be_character_device }
  it { should_not be_pipe }
  it { should_not be_socket }
  it { should_not be_symlink }
  it { should_not be_mounted }
  its('content') { should eq 'hello world' }
end
