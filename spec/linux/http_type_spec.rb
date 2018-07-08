require 'spec_helper'
require_relative '../type/http'
describe http('http://localhost') do
  it { should be_handling.with_url('/') }
  it { should be_handling.with_url('/').with_method('GET') }
end

