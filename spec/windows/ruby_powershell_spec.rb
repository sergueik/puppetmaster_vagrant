require_relative '../windows_spec_helper'

context 'Execute embedded Ruby from Puppet Agent' do
  context 'Powershell' do # NOTE: poor performance
    lines = [ 
      'answer: 42',
      'status: changed'
    ]
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

$env:PUPPET_BASEDIR = (((iex 'cmd.exe /c where.exe puppet.bat') `
                    -replace 'bin\\\\puppet.bat','') `
                    -replace '\\\\$','')
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

# Do basic smoke test
puts 'Parse YAML string' 
puts "Generate YAML\\n" +  YAML.dump({'answer'=>42})


# Read Puppet Agent last run report
data = File.read('$($puppet_env['lastrunreport'])')

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

"@

$ruby_script | Out-File 'c:/windows/temp/test.rb' -Encoding ascii
# Run Ruby script in the Puppet Agent environent
iex 'ruby.exe c:/windows/temp/test.rb'

EOF
  ) do
      lines.each do |line| 
        its(:stdout) do
          should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
        end
      end
    end
  end
end
