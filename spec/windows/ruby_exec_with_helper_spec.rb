require_relative '../windows_spec_helper'

context 'Execute embedded Ruby from Puppet Agent' do
  context 'With Helper' do

  lines = [ 
    'answer: 42',
    'status: changed'
  ]
  puppet_home = 'C:/Program Files/Puppet Labs/Puppet'
  puppet_statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
  last_run_report = "#{puppet_statedir}/last_run_report.yaml"
  helper_script_file = 'c:/windows/temp/helper.rb'
  script_file = 'c:/windows/temp/test5.rb'

  before(:all) do
    Specinfra::Runner::run_command(<<-END_COMMAND
$helper_script_file = '#{helper_script_file}'
@"

%w|facter hiera puppet|.each do |app| 
`$LOAD_PATH.insert(0, '#{puppet_home}/'+ app +'/lib')
end

require 'yaml'
require 'puppet'
require 'pp'

"@ | out-file $helper_script_file -encoding ascii

    END_COMMAND
    )
  end
  Specinfra::Runner::run_command(<<-END_COMMAND
$script_file = '#{script_file}'
@"
require_relative '#{helper_script_file.gsub(".rb","")}'
# Do basic smoke test
puts 'Parse YAML string' 
puts "Generate YAML\\n" +  YAML.dump({'answer'=>42})


# Read Puppet Agent last run report
data = File.read('#{last_run_report}')
# Parse 
puppet_transaction_report = YAML.load(data)
# Get metrics
metrics = puppet_transaction_report.metrics
puts 'Puppet Agent last metrics:'
pp metrics
# Show resources
puppet_resource_statuses = puppet_transaction_report.resource_statuses
puts 'Puppet Agent last resources:'
pp puppet_resource_statuses.keys
# Get summary
raw_summary =  puppet_transaction_report.raw_summary
puts 'Puppet Agent last run summary:'
pp raw_summary
# Get status
status = puppet_transaction_report.status
puts 'Puppet Agent last run status: ' +  status

"@ | out-file $script_file -encoding ascii

    END_COMMAND
    )
    describe command("iex \"ruby.exe '#{script_file}'\"") do
      let(:path) { 'C:/Program Files/Puppet Labs/Puppet/sys/ruby/bin' }
      lines.each do |line| 
        its(:stdout) do
          should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
        end
      end
    end
  end
end

