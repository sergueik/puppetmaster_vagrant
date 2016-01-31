require_relative '../windows_spec_helper'

context 'Execute embedded Puppet Agent Ruby' do
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

#
@"
require 'yaml'
require 'puppet'
require 'pp'


puts 'Parse YAML string'
check = YAML.load(<<-'END_DATA'
---
answer: 42
END_DATA
)
puts check

puts 'Generate YAML'
check = YAML.dump({'answer'=>42}) 
puts check

"@ | Out-File './test.rb' -Encoding ascii
iex 'ruby.exe ./test.rb'
EOF
) do
    line = 'answer: 42'
    its(:stdout) do
      should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
    end
  end
end
