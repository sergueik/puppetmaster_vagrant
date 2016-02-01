require 'spec_helper'

context 'Execute embedded Ruby from Puppet Agent' do
  # TODO: ismx
  lines = [ 
    'answer: 42',
    # TODO: instrument idempotency check 
    # 'Status: changed', 
    'Status: unchanged',
    '"failed"=>0', # resources
    '"failure"=>0', # events
    # to see the output, add/uncomment a failed expectation
    # 'Status: unchanged'
  ]
  script_file = '/tmp/test.rb'
  ruby_script = <<-EOF
require 'puppet'
require 'yaml'
require 'pp'

# Do basic smoke test
puts \\"Generate YAML\\n\\" + YAML.dump({'answer'=>42})

# Read Puppet Agent last run report
# NOTE: escaping special characters to prevent execution by shell 
puppet_last_run_report = \\`puppet config print 'lastrunreport'\\`.chomp
data = File.read(puppet_last_run_report)
# Parse
puppet_transaction_report = YAML.load(data)

# Get metrics
metrics = puppet_transaction_report.metrics

time = metrics['time']
puts 'Times:'
pp time.values

events = metrics['events']
puts 'Events:'
pp events.values
# puts events.values.to_yaml

resources = metrics['resources']
puts 'Resources:'
pp resources.values

puppet_resource_statuses = puppet_transaction_report.resource_statuses
puts 'Resource Statuses:'
pp puppet_resource_statuses.keys

raw_summary = puppet_transaction_report.raw_summary
puts 'Summary:'
pp raw_summary

status = puppet_transaction_report.status
puts 'Status: ' + status
 
  EOF
  before(:all) do
    Specinfra::Runner::run_command('echo "#{ruby_script}">#{script_file}')
  end
  # when the test script is not found run the command loud
  describe command(<<-END_COMMAND
    echo "#{ruby_script}">#{script_file}
    END_COMMAND
  ) do
    its(:stdout) { should be_empty }
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
  end
  describe command(<<-EOF
    export RUBYOPT='rubygems'
    ruby #{script_file}
  EOF
  ) do
    its(:stderr) { should be_empty }
    its(:exit_status) {should eq 0 }
    lines.each do |line| 
      its(:stdout) do
        should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
      end
    end
  end
end
