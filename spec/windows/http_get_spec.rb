require 'spec_helper'
if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end
require_relative '../type/http_get'

context 'HTTP get request' do
  context 'apache' do
    describe http_get(8080,'127.0.0.1','index.html') do
      its(:headers) { should have_key 'content-type'}
      # its(:headers) {  should eq ''} # uncomment to examine the actual response headers
      its(:status) {  should_not eq 400 } # 400 Bad Request is returned if paremeters not set right
      its(:body) { should_not contain 'Bad Request' }
      its(:body) { should contain 'html' } #  Place more descriptive business specific expectation here
    end
  end
  context 'Jenkins' do
    describe http_get(8443,'127.0.0.1','/', 'https' ) do
      [
        'x-hudson',
        'x-jenkins-session',
      ].each do |header| # Jenkins specific headers:
        its(:headers) {  should have_key( header )}
      end
      # https://www.relishapp.com/rspec/rspec-expectations/v/2-0/docs/matchers/include-matcher
      its(:headers) { should include( 'content-type', 'content-length', 'set-cookie', 'server', 'expires', 'connection', 'via')}
      its(:headers) { should include( 'server' => 'Jetty(winstone-2.8)') }
      its(:status) { should eq 403 }
      its(:body) { should contain 'Authentication required' }
    end  
  end
end