require_relative '../windows_spec_helper'

context 'Execute embedded Puppet Agent Ruby test 2' do
  # TODO: http://www.rake.build/fascicles/003-clean-environment.html
  lines = [ 
    'answer: 42',
    'status: changed'
  ]
  puppet_home = 'C:/Program Files/Puppet Labs/Puppet'
  puppet_statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
  last_run_report = "#{puppet_statedir}/last_run_report.yaml"
  rubylib = "#{puppet_home}/facter/lib;#{puppet_home}/hiera/lib;#{puppet_home}/puppet/lib;"
  rubyopt = 'rubygems' 
  ruby_script = <<-EOF
`$LOAD_PATH.insert(0, "C:/Program Files/Puppet Labs/Puppet/facter/lib")
`$LOAD_PATH.insert(0, "C:/Program Files/Puppet Labs/Puppet/hiera/lib")
`$LOAD_PATH.insert(0, "C:/Program Files/Puppet Labs/Puppet/puppet/lib")
require 'yaml'
require 'puppet'
require 'pp'

# do basic smoke tests
puts 'Parse YAML string' 
pp YAML.load(<<-'END_DATA'
---
answer: 42
END_DATA
)
puts "Generate YAML\\n" +  YAML.dump({'answer'=>42})
data = File.read('#{last_run_report}')
# Parse 
puppet_transaction_report = YAML.load(data)

metrics = puppet_transaction_report.metrics
puts 'Puppet Agent last metrics:'
# pp metrics

puppet_resource_statuses = puppet_transaction_report.resource_statuses
# puts 'Puppet Agent last resources:'
# pp puppet_resource_statuses.keys

raw_summary =  puppet_transaction_report.raw_summary
# puts 'Puppet Agent last run summary:'
# pp raw_summary

status = puppet_transaction_report.status
puts 'Puppet Agent last run status: ' +  status

EOF
script_file = 'c:/windows/temp/test2.rb'
Specinfra::Runner::run_command(<<-END_COMMAND
$script_file = '#{script_file}'
$output = @"
#{ruby_script}
"@
write-output $output | out-file $script_file -encoding ascii

END_COMMAND
)

  describe command(<<-EOF
$env:RUBYLIB="#{rubylib}"
$env:RUBYOPT="#{rubyopt}"
iex "ruby.exe '#{script_file}'"
EOF
) do
    let(:path) { 'C:/Program Files/Puppet Labs/Puppet/sys/ruby/bin' }
    # does not work:
    # let(:rubylib) { rubylib }
    # let(:rubylib) {'C:/Program Files/Puppet Labs/Puppet/facter/lib;C:/Program Files/Puppet Labs/Puppet/hiera/lib;C:/Program Files/Puppet Labs/Puppet/puppet/lib;'}
    # let(:rubyopt) { 'rubygems' }
    lines.each do |line| 
      its(:stdout) do
        should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
      end
    end
  end
end

context 'Execute embedded Puppet Agent Ruby test 3' do
  # TODO: http://www.rake.build/fascicles/003-clean-environment.html
  lines = [ 
    'answer: 42',
    'status: changed'
  ]
  puppet_home = 'C:/Program Files/Puppet Labs/Puppet'
  puppet_statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
  last_run_report = "#{puppet_statedir}/last_run_report.yaml"
  ruby_script = <<-EOF

%w|facter hiera puppet|.each do |app| 
`$LOAD_PATH.insert(0, '#{puppet_home}/'+ app +'/lib')
end

require 'yaml'
require 'puppet'
require 'pp'

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

EOF
script_file = 'c:/windows/temp/test3.rb'
Specinfra::Runner::run_command(<<-END_COMMAND
$script_file = '#{script_file}'
$output = @"
#{ruby_script}
"@
write-output $output | out-file $script_file -encoding ascii

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


context 'Execute embedded Puppet Agent Ruby test 4' do
  # TODO: http://www.rake.build/fascicles/003-clean-environment.html
  lines = [ 
    'answer: 42',
    'status: changed'
  ]
  puppet_home = 'C:/Program Files/Puppet Labs/Puppet'
  puppet_statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
  last_run_report = "#{puppet_statedir}/last_run_report.yaml"
  script_file = 'c:/windows/temp/test4.rb'
  before(:all) do
Specinfra::Runner::run_command(<<-END_COMMAND
$script_file = '#{script_file}'
@"

%w|facter hiera puppet|.each do |app| 
`$LOAD_PATH.insert(0, '#{puppet_home}/'+ app +'/lib')
end

require 'yaml'
require 'puppet'
require 'pp'

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
  end
  describe command("iex \"ruby.exe '#{script_file}'\"") do
    let(:path) { 'C:/Program Files/Puppet Labs/Puppet/sys/ruby/bin' }
    lines.each do |line| 
      its(:stdout) do
        should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
      end
    end
  end
end


context 'Execute embedded Puppet Agent Ruby with helper' do

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

context 'Execute embedded Puppet Agent Ruby through Powershell' do
  let(:path) { 'C:\Program Files\Puppet Labs\Puppet\bin' }
  describe command(<<-EOF
$puppet_env = @{
  'statedir' = $null;
  'confdir' = $null;
  'lastrunfile' = $null;
  'lastrunreport' = $null;
}
$puppet_env.Keys.Clone() | ForEach-Object {
  $env_key = $_
  $puppet_env[$env_key] = iex "puppet.bat config print ${env_key}"
}

$env:PUPPET_BASEDIR = (((iex 'cmd.exe /c where.exe puppet.bat') -replace 'bin\\\\puppet.bat','') -replace '\\\\$','')
Write-Host -foreground 'yellow' ('Setting PUPPET_BASEDIR={0}' -f $env:PUPPET_BASEDIR)
$puppet_env['basedir'] = $env:PUPPET_BASEDIR -replace '\\\\','/'
$puppet_env | Format-Table -AutoSize
$env:PATH = "$env:PUPPET_BASEDIR\\puppet\\bin;$env:PUPPET_BASEDIR\\facter\\bin;$env:PUPPET_BASEDIR\\hiera\\bin;$env:PUPPET_BASEDIR\\bin;$env:PUPPET_BASEDIR\\sys\\ruby\\bin;$env:PUPPET_BASEDIR\\sys\\tools\\bin;${env:PATH};"
Write-Host -foreground 'yellow' ('Setting PATH={0}' -f $env:PATH)
$status = iex 'ruby.exe -v'
Write-Host -foreground 'yellow' $status
$ruby_libs = @()
@(
  'puppet',
  'facter',
  'hiera') | ForEach-Object {
  $app = $_
  $ruby_libs += "$($puppet_env['basedir'])/${app}/lib"
}
$env:RUBYLIB = $ruby_libs -join ';'
Write-Host -foreground 'yellow' ('Setting RUBYLIB={0}' -f $env:RUBYLIB)
$env:RUBYOPT = 'rubygems'
Write-Host -foreground 'yellow' ('Setting RUBYOPT={0}' -f $env:RUBYOPT)

# generate Ruby script
$ruby_script = @"
require 'yaml'
require 'puppet'
require 'pp'

# do basic smoke tests
puts 'Parse YAML string' 
pp YAML.load(<<-'END_DATA'
---
answer: 42
END_DATA
)

puts "Generate YAML\\n" +  YAML.dump({'answer'=>42})
# Load Puppet Agent last run report YAML
data = File.read('$($puppet_env['lastrunreport'])')
# Parse 
puppet_transaction_report = YAML.load(data)

metrics = puppet_transaction_report.metrics
puts 'Puppet Agent last metrics:'
pp metrics

puppet_resource_statuses = puppet_transaction_report.resource_statuses
puts 'Puppet Agent last resources:'
pp puppet_resource_statuses.keys

raw_summary =  puppet_transaction_report.raw_summary
puts 'Puppet Agent last run summary:'
pp raw_summary

status = puppet_transaction_report.status
puts 'Puppet Agent last run status: ' +  status
"@

$ruby_script | Out-File './test.rb' -Encoding ascii
# Run Ruby script in the Puppet Agent environent
iex 'ruby.exe ./test.rb'

EOF
) do
    line = 'answer: 42'
    line = 'status: changed'
    its(:stdout) do
      should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
    end
  end
end
