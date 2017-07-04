require_relative '../windows_spec_helper'
require_relative '../type/port_retry'

context 'Port Retry' do
  describe port_retry(5985) do
    it { should be_listening.with_retry(2)}
  end
  describe port_retry(5986) do
    # failing expectation
    it { should be_listening.with_retry(2)}
  end
end
