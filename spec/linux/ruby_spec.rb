require 'spec_helper'

context 'Execute embedded Ruby from Puppet Agent' do
  context 'With Environment' do
    # TODO: ismx
    lines = [ 
      'answer: 42',
      'Status: changed'
    ]
    script_file = '/tmp/test.rb'
    ruby_script = <<-EOF
require 'puppet'
require 'yaml'
require 'pp'

# Do basic smoke test
puts 'Generate YAML' 
pp YAML.dump({'answer'=>42})

# Read Puppet Agent last run report
# NOTE: escaping special characters 
puppet_last_run_report = \\`puppet config print 'lastrunreport'\\`.chomp
data = File.read(puppet_last_run_report)
# Parse
puppet_transaction_report = YAML.load(data)

# Get metrics
metrics = puppet_transaction_report.metrics
puts 'Metrics:'
pp metrics
# Show resources
puppet_resource_statuses = puppet_transaction_report.resource_statuses
puts 'Resources:'
pp puppet_resource_statuses.keys
# Get summary
raw_summary = puppet_transaction_report.raw_summary
puts 'Summary:'
pp raw_summary
# Get status
status = puppet_transaction_report.status
puts 'Status: ' + status
 
  EOF
# TODO: debug 
  Specinfra::Runner::run_command(<<-END_COMMAND
  echo "#{ruby_script}">#{script_file}
  END_COMMAND
  )
  
describe command(<<-END_COMMAND
  echo "#{ruby_script}">#{script_file}
  END_COMMAND

) do
        its(:stdout) { should be_empty }
        its(:stderr) { should be_empty }
        its(:exit_status) {should eq 0 }
end
  
    describe command(<<-EOF
export RUBYOPT='rubygems';ruby #{script_file}
  EOF
  ) do
      lines.each do |line| 
        its(:stdout) do
          should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
        end
        its(:stderr) { should be_empty }
        its(:exit_status) {should eq 0 }
      end
    end
  end
end
