require 'spec_helper'
if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end
require_relative '../type/http_get'

describe http_get(80,'127.0.0.1','index.html') do
  its(:headers) {  should have_key 'content-type'}
  # its(:headers) {  should eq ''} # to examine the actual response headers, create a failing expectation
  its(:status) {  should_not eq 400 } # it will return a 400 Bad Request if paremeters not set right
  its(:body) {  should_not contain 'Bad Request' }
  its(:body) {  should contain 'html' } #  Place more descriptive business specific expectation here
end
