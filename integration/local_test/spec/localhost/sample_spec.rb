require 'spec_helper'

describe file('/tmp/helloworld') do
  it { should exist }
  its(:content) { should include "hello world"}
end
