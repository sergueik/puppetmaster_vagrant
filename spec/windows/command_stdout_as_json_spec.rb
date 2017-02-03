require_relative '../windows_spec_helper'
require_relative '../type/command'

context 'Stdout JSON Test' do
	context 'Console Command' do
		describe command(<<-EOF
			@{'key1' = @('value1','value2'); 
				'key2' = @{'key3'	= 'value3' }; 
				'key4' = @(@{'key5' = 'value5'};
										)}| convertto-json
		EOF
		) do
			its(:stdout_as_json) { should include('key1') }
			its(:stdout_as_json) { should include('key1' => include('value1','value2')) }
			its(:stdout_as_json) { should include('key2' => include('key3' => 'value3')) }	
			its(:stdout_as_json) { should include('key4' => include('key5' => 'value5')) }
		end
	end
end

