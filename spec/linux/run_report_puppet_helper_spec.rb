require 'spec_helper'
require_relative '../type/puppet_helper'
context 'Puppet run' do
  describe puppet_helper do
    its(:events) { should_not be_nil }
    its(:events) { should include( 'failure', 'success', 'total' )}
    its(:failure) { should eq 0 }
    its(:lastrunfile_data) do
      should include 'version' => include('puppet' => '4.4.2')
      should include('events' => include('failure' => 0))
    end
    its(:raw_lastrunfile_data) { should contain {'failure: 0'} }
  end
  describe puppet_helper(true) do
    its (:lastreport_data) { should_not be_nil }
    its (:resources) { should include( 'changed', 'failed', 'skipped', 'out_of_sync', 'failed_to_restart', 'restarted', 'total' ) }
  end
end