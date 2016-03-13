require_relative '../spec_helper'

# Tested after Puppet run on Centos 6.5 x86 box / Puppet 3.2.3, CPAN modules install, 
# which was a failure

describe 'Puppet Last Run Report  Processing' do
  describe my_type('last_run_report.yaml') do
    it { should have_key('resources') }
    it { should have_key('summary') }
    [
    'Package[perl-DBD-MySQL]',
    'Package[perl-DBI]',
    'Package[perl-IPC-ShareLite]', 
    # this is the resource that failed, but we have no information about it yet
    ].each do |resource|
      it { should have_resource(resource) }
    end    
    it { should have_summary_resources('failed', 1) }
    it { should have_summary_resources('changed', 0) }
    it { should have_key_value('status','failed') }
  end
end

# output: 
# "Running spectests on linux"
# 
# Puppet Last Run Report  Processing
#   My type ""
#     should have key "resources"
#     should have key "summary"
#     should have resource "Package[perl-DBD-MySQL]"
#     should have resource "Package[perl-DBI]"
#     should have resource "Package[perl-IPC-ShareLite]"
#     should have summary resources "failed", 1
#     should have summary resources "changed", 0
#     should have key value "status", "failed"