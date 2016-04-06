require_relative '../windows_spec_helper'
context 'Execute embedded Ruby from Puppet Agent' do
  context 'With Environment' do
    # TODO: http://www.rake.build/fascicles/003-clean-environment.html
    lines = [ 
      'answer: 42',
      'status: changed'
    ]
    
    puppet_home_folder = 'Puppet Enterprise'
    puppet_home = 'C:/Program Files (x86)/Puppet Labs/' + puppet_home_folder
    puppet_statedir = 'C:/ProgramData/PuppetLabs/'+ puppet_home_folder + '/var/state'
    last_run_report = "#{puppet_statedir}/last_run_report.yaml"
    rubylib = "#{puppet_home}/facter/lib;#{puppet_home}/hiera/lib;#{puppet_home}/puppet/lib;"
    rubyopt = 'rubygems' 
    script_file = 'c:/windows/temp/test.rb'
    ruby_script = <<-EOF
require 'yaml'
require 'puppet'
require 'pp'
  
  EOF
  
  Specinfra::Runner::run_command(<<-END_COMMAND
  @'
  #{ruby_script}
'@ | out-file '#{script_file}' -encoding ascii
  
  END_COMMAND
  )
  
  
  describe command(<<-EOF
  $env:RUBYLIB="#{rubylib}"
  $env:RUBYOPT="#{rubyopt}"
  iex "ruby.exe '#{script_file}'"
  EOF
  ) do
      let(:path) { 'C:/Program Files (x86)/Puppet Labs/Puppet Enterprise/sys/ruby/bin' }
      lines.each do |line| 
        its(:stdout) do
          should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
        end
      end
    end
  end
end
