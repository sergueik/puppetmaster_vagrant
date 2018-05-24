require 'spec_helper'

describe file('/var/lib/jenkins/config.xml') do
  it { should exist }
  its(:content) { should match '<useSecurity>false</useSecurity>'}
end

