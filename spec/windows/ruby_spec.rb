require_relative '../windows_spec_helper'

context 'Execute embedded Puppet Agent Ruby' do
  let(:path) { 'C:\Program Files\Puppet Labs\Puppet\bin' }
  describe command(<<-EOF
$puppet_env = @{ 
  'statedir' = $null;
  'confdir'  = $null;
  'lastrunfile' = $null;
  'lastrunreport'  = $null;
}
$puppet_env.keys.Clone() | foreach-object { 
$env_key = $_
$puppet_env[$env_key] = iex "puppet.bat config print ${env_key}"
}


$puppet_env['basedir'] = (((iex 'cmd.exe /c where.exe puppet.bat') -replace 'bin\\\\puppet.bat' ,'' ) -replace '\\\\$', ''  ) -replace '\\\\', '/'
$env:PUPPET_BASEDIR = $puppet_env['basedir'] -replace '/', '\\'
write-host -foreground 'yellow' ('Setting PUPPET_BASEDIR={0}' -f $env:PUPPET_BASEDIR ) 
$puppet_env | format-table -autosize
$env:PATH = "$env:PUPPET_BASEDIR\\puppet\\bin;$env:PUPPET_BASEDIR\\facter\\bin;$env:PUPPET_BASEDIR\\hiera\\bin;$env:PUPPET_BASEDIR\\bin;$env:PUPPET_BASEDIR\\sys\\ruby\\bin;$env:PUPPET_BASEDIR\\sys\\tools\\bin;${env:PATH};"
write-host -foreground 'yellow' ('Setting PATH={0}' -f $env:PATH )
$status = iex 'ruby.exe -v'
write-host -foreground 'yellow' $status
$ruby_libs = @()
@(
'puppet',
'facter',
'hiera') | foreach-object {
$app = $_
$ruby_libs += "$($puppet_env['basedir'])/${app}/lib"
}
$env:RUBYLIB = $ruby_libs -join ';'
write-host -foreground 'yellow' ('Setting RUBYLIB={0}' -f $env:RUBYLIB )
$env:RUBYOPT = 'rubygems' 
write-host -foreground 'yellow' ('Setting RUBYOPT={0}' -f $env:RUBYOPT )

#
@"
require 'yaml'
require 'puppet'
require 'pp'


puts 'Parse YAML string'
check = YAML.load(<<-'NESTED_EOF'
---
answer: 42
NESTED_EOF
)
puts check


puts 'Generate YAML'
check = YAML.dump({'answer'=>42}) 
puts check

"@ |out-file './test.rb' -encoding ascii
iex 'ruby.exe ./test.rb'

EOF
) do
    line = 'answer'
    its(:stdout) do
      should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
    end
  end
end
