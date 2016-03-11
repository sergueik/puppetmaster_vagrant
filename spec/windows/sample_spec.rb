require_relative '../windows_spec_helper'
describe 'sample_json' do

  before(:all) do
puppet_home = 'C:/Program Files/Puppet Labs/Puppet'
puppet_statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
last_run_report = "#{puppet_statedir}/#{file}"
rubylib = "#{puppet_home}/facter/lib;#{puppet_home}/hiera/lib;#{puppet_home}/puppet/lib;"
rubyopt = 'rubygems'
script_file = 'c:/windows/temp/test.rb'
script_result = 'c:/windows/temp/test.yaml'

ruby_script = <<-EOF
`$LOAD_PATH.insert(0, '#{puppet_home}/facter/lib')
`$LOAD_PATH.insert(0, '#{puppet_home}/hiera/lib')
`$LOAD_PATH.insert(0, '#{puppet_home}/puppet/lib')
require 'yaml'
require 'puppet'
require 'pp'
# Do basic smoke test
`$stderr.puts YAML.dump({'answer'=>42})
File.open('#{script_result}', 'w') { |file| file.write(YAML.dump({'answer'=>42})) }
EOF
Specinfra::Runner::run_command(<<-END_COMMAND
@"
#{ruby_script}
"@ | out-file '#{script_file}' -encoding ascii
END_COMMAND
)
Specinfra::Runner::run_command("iex \"ruby.exe '#{script_file}'\"")
  end
  # context json_config('C:/ProgramData/PuppetLabs/puppet/var/state/last_run_report.yaml') do
  # describe json_config('last_run_report.yaml') do
  context json_config('last_run_report.yaml') do
    it { should have_key('answer') }
    it { should have_key('test') }
    it { should have_key_value('answer',42) }
    it { should_not have_key('not a key') }
  end
end
