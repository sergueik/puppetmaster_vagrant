require_relative '../windows_spec_helper'
require_relative '../type/port'

context 'Port Retry Test' do
	max_retry = 3 
	default_delay = 10
	# NOTE : should_not keeps waiting...
	describe port(23) do
		it { should_not be_listening_with_retry(max_retry, default_delay)}
	end
	describe port(445) do
		it { should be_listening_with_retry(max_retry, default_delay)}
	end
end

