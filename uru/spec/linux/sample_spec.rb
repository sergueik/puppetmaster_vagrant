require 'spec_helper'

context 'uru' do
  uru_home = '/uru'
  gem_version='2.1.0'
  user_home = '/root'
  context 'basic' do
    describe port(22) do
        it { should be_listening.with('tcp')  }
    end
  end
  context 'uru path' do
    describe command('echo $PATH') do
      its(:stdout) { should match Regexp.new("_U1_:#{user_home}/.gem/ruby/#{gem_version}/bin:#{uru_home}/ruby/bin:_U2_:") }
    end
  end
end
