require_relative '../windows_spec_helper'
context 'Execute Facter Ruby' do
  context 'With Environment' do
    answer = 'answer: 42'
    # +FileVersion 5.0.0.101573
    # TODO: distinguish Puppet Community Edition and Puppet Enterprise
    puppet_home_folder = 'Puppet Enterprise'
    puppet_home_folder = 'Puppet'
    # Note: os[:arch] is not being set in Windows platform     
    puppet_home = 'C:/Program Files (x86)/Puppet Labs/' + puppet_home_folder
    puppet_home = 'C:/Program Files/Puppet Labs/' + puppet_home_folder
    rubylib = "#{puppet_home}/facter/lib;#{puppet_home}/hiera/lib;#{puppet_home}/puppet/lib;"
    rubyopt = 'rubygems'
    filename =  'c:\Program Files\Oracle\VirtualBox Guest Additions\VboxMouse.sys'  
    script_file = 'c:/windows/temp/test.rb'
    ruby_script = <<-EOF
require 'yaml'
require 'puppet'
require 'pp'
  
# Facter code
require 'facter'
fact_name = 'answer'
if Facter.value(:kernel) == 'windows'
  Facter.add(fact_name) do
    require 'win32/registry'
    setcode { '42' }
  end
else
  Facter.add(fact_name) do
    setcode { '42' }
  end
end

fact_name = 'file_version'

if Facter.value(:kernel) == 'windows'
  Facter.add(fact_name) do
    require 'Win32API'
      filename = '#{filename}'
      if File.exists?(filename)
        vsize=Win32API.new('version.dll', 'GetFileVersionInfoSize', ['P', 'P'], 'L').call(filename, '')
        if (vsize > 0)
          result = ' '*vsize
          Win32API.new('version.dll', 'GetFileVersionInfo', ['P', 'L', 'L', 'P'], 'L').call(filename, 0, vsize, result)
          rstring = result.unpack('v*').map{|s| s.chr if s<256}*''
          version = /FileVersion..(.*?)\\000/.match(rstring)
          puts version
        end
      end
  end
else
  # TODO
end

# Facter validation
%w/answer file_version/.each do |fact_name|
  puts fact_name + ': ' +  Facter.value(fact_name.to_sym)
end  
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
      # TODO: distinguish Puppet Community Edition and Puppet Enterprise
      # Note: os[:arch] is not being set in Windows platform     
      # 32-bit environment,       
      let(:path) { 'C:/Program Files/Puppet Labs/Puppet/sys/ruby/bin' }
      # 64-bit 
      let(:path) { 'C:/Program Files (x86)/Puppet Labs/Puppet/sys/ruby/bin' }
      its(:stdout) do
        should match  Regexp.new(answer.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
      end
    end
  end
end

