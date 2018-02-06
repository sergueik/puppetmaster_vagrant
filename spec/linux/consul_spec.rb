require 'spec_helper'

context 'consul checks' do
  {
    # will need to do negative lookahead
    'known_servers' => '0',
    'members' => '1',
  }.each do |key,value|
    describe command ('consul info') do
      let(:path) { '/bin:/usr/bin:/usr/local/bin'} 
      its(:stdout) { should match( Regexp.new("#{key}\s+(?!\b#{value}\b).*")) }
      end
    end
  end 
