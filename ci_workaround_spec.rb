# runtime-sensitive rspec example designed to pass both CI and peer review
require 'spec_helper'
require 'pp'
describe 'windows api sensitive stuff' do  
  before(:each) do
    Puppet.features.stubs(:microsoft_windows? => true, :posix? => false)
  end
  let(:title) { 'title' }
  let(:pre_condition) do
    <<-EOF
      File {
        provider => 'windows',
      }
      Exec {
        provider => 'windows',
      }
      Package {
        provider => 'windows',
      }
    EOF
  end
  let(:facts) do
    {
      :osfamily        => 'windows',
      :operatingsystem => 'windows',
      :puppetversion   => '3.4.3',
      :kernel          => 'windows',
      :architecture    => 'x64',
    }
  end
  $stderr.puts "running on #{RUBY_PLATFORM}"
  if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    it { should compile.with_all_deps }
  else
    it do
      expect {
      should compile.with_all_deps
      }.to raise_error(Puppet::Error, /cannot load such file -- win32\/registry/)
    end
  end
end
