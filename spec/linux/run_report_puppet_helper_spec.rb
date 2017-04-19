require 'spec_helper'
require_relative '../type/puppet_helper'
context 'Puppet run' do
  describe puppet_helper(  ) do
    its(:events) { should_not be_nil}
    its(:events) { should include( 'failure', 'success', 'total' )}
    its(:failure) { should eq 0 }
    its(:raw_data) { should contain 'failure: 0' }
  end
end
