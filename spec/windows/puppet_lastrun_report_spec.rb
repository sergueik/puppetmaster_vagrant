require_relative '../windows_spec_helper'

describe 'Puppet lastrun report' do
  changed_resources_count = 7
  expected_resource = 'Exec[puppet_test_create_shortcut]'
  describe my_type('last_run_report.yaml') do
    %w|
      resources
      summary
    |.each do |datakey|
      it { should have_key(datakey) }
    end
    it { should have_key_value('status','changed') }
    it { should have_resource(expected_resource) }
    {
      'failed' => 0,
      'changed' => changed_resources_count,
    }.each do |category,value|
      it { should have_summary_resources(category, value) }
    end
  end
end