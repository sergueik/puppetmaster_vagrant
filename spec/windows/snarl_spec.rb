require 'spec_helper'

require 'pp'
require 'type/snarl'
# origin https://github.com/luislavena/net-snarl

describe Snarl do
	context 'when first created' do
		it 'defaults connection to local server' do
			snarl = Snarl.new
			snarl.host.should == '127.0.0.1'
			snarl.port.should == 9887
		end

		it 'allows connection to remote server' do
			snarl = Snarl.new('remote', 1234)
			snarl.host.should == 'remote'
			snarl.port.should == 1234
		end
	end
end
