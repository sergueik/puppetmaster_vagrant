require_relative '../windows_spec_helper'

describe 'Puppet Last Run Report  Processing' do
  describe my_type('last_run_report.yaml') do
    it { should have_key('resources') }
    it { should have_key('summary') }
    it { should have_key_value('status','changed') }
    it { should have_resource('Exec[puppet_test_create_shortcut]') }    
    it { should have_summary_resources('failed', 0) }
    it { should have_summary_resources('changed', 7) }
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
