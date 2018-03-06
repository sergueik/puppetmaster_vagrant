require 'spec_helper'

# origin: https://github.com/Pravkhande/serverspec/blob/master/Security/spec/CIS_audit/centos7_spec.rb
context 'Postfix Local-Only Modtest' do  
  postfix_state = command('systemctl status postfix').stdout
  if postfix_state =~ Regexp.new(Regexp.escape('active (running)'))
    describe port(25) do
      it { should be_listening.on('127.0.0.1') }
    end
  else
    describe port(25) do
      it { should_not be_listening }
    end
  end
end
context 'Mongo Service ' do
  mongod_port = '27017'
  hostname_short = command('hostname -s').stdout
  if hostname_short =~ Regexp.new(Regexp.escape('int-json-store-0'))
    describe service('mongod') do
      it { should be_enabled }
      it { should be_running }
    end
    describe port(mongod_port) do
      xit { should be_listening.on('127.0.0.1') } 
      # local interface only, typical configuration before auth
      it { should be_listening }
      # all interfaces
    end
    # TODO: move mongo insert tests here  
  else    describe service('mongod') do
    it { should_not be_enabled }
    it { should_not be_running }
  end
  describe port(mongod_port) do
    it { should_not be_listening }
  end
  # TODO: create mongoimport tests here (does not require service to be running)
  end
end
