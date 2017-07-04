require 'spec_helper'
require_relative '../type/port_retry'
describe port(22) do
  # NOTE: regular expectation starts to fail after inclusion of the custom type
  xit { should be_listening.with('tcp')  }
end

context 'Port Retry' do
  describe port_retry(22) do
    it { should be_listening.with_retry(2)}
  end
  describe port_retry(5985) do
    # failing expectation
    it { should be_listening.with_retry(2)}
  end
end
