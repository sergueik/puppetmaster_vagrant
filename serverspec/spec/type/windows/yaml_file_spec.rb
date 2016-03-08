require 'spec_helper'

set :backend, :cmd

set :os, :family => 'windows'

describe yaml_file('last_run_report.yaml') do
  it { should exist }
  xit { should have_message('message') }
end
