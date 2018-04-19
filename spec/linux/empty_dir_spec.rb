require 'spec_helper'

path_to_dir = '/var/run/sshd'
describe file(path_to_dir) do
  it { should be_a_directory }
  # count the files in the directory
  it 'should be an empty directory' do
    Dir.glob("#{path_to_dir}/*").should eq []
  end
end
