require_relative '../spec_helper'
# Tested after Puppet run on Centos 6.5 x86 box / Puppet 3.2.3, CPAN modules install, 
# where there was a failure
describe 'Puppet Last Run Report  Processing' do
  describe my_type('last_run_report.yaml') do
    it { should have_key('resources') }
    it { should have_key('summary') }
    it { should have_key_value('status','failed') }
    it { should have_resource('Package[perl-DBD-MySQL]') }   
    it { should have_resource('Package[perl-DBI]') }   
    
    it { should have_resource('Package[perl-IPC-ShareLite]') } # this is the resource that failed
    it { should have_summary_resources('failed', 1) }
    it { should have_summary_resources('changed', 0) }
  end
end

# output: 
# Puppet Last Run Report  Processing
#   My type ""
#     should have key "resources"
#     should have key "summary"
#     should have key value "status", "changed"
#     should have resource "Exec[puppet_test_create_shortcut]"
#     should have summary resources "failed", 0
#     should have summary resources "changed", 7
