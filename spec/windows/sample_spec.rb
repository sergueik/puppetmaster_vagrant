require_relative '../windows_spec_helper'
describe 'sample_json' do

  # context json_config('C:/ProgramData/PuppetLabs/puppet/var/state/last_run_report.yaml') do
  # describe json_config('last_run_report.yaml') do
  context json_config('last_run_report.yaml') do
    it { should have_key('answer') }
    it { should have_key('test') }
    it { should have_key_value('answer',42) }
    it { should_not have_key('not a key') }
  end
end
