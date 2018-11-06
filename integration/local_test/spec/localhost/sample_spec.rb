require 'spec_helper'

describe file('/tmp/purge_old_dirs.sh') do
  it { should exist }
  its(:content) { should include 'script for jenkins job'}
end
