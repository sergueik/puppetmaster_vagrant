require 'spec_helper'
# origin: https://github.com/Pravkhande/serverspec/blob/master/Security/spec/CIS_audit/centos7_spec.rb
context 'Postfix Local-Only Modtest' do  
  postfix_state = command('systemctl status postfix').stdout
  if postfix_state =~ Regexp.new(Regexp.escape('active (running)'))
    describe port(25) do
      it { should be_listening.on('127.0.0.1') }
    end
    # mongo insert tests
  else
    describe port(27017) do
      it { should_not be_listening }
    end
    # mongoimport tests
  end
end

