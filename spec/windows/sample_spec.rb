require_relative '../windows_spec_helper'
describe 'uppet Last Run Report  Processing' do

  describe my_type('last_run_report.yaml') do
    it { should have_key_value('answer', 42 ) }
    it { should have_key('resources') }
    it { should have_key('summary') }
    it { should have_key_value('status','changed') }
    it { should_not have_key('not a key') }
  end
end
