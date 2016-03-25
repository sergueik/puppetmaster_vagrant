require_relative '../windows_spec_helper'
context 'Execute Facter Ruby' do
  context 'With Environment' do

    # TODO: distinguish Puppet Community Edition and Puppet Enterprise
    puppet_home_folder = 'Puppet Enterprise'
    puppet_home_folder = 'Puppet'
    # Note: os[:arch] is not being set in Windows platform     
    puppet_home = 'C:/Program Files (x86)/Puppet Labs/' + puppet_home_folder
    puppet_home = 'C:/Program Files/Puppet Labs/' + puppet_home_folder
    rubylib = "#{puppet_home}/facter/lib;#{puppet_home}/hiera/lib;#{puppet_home}/puppet/lib;"
    rubyopt = 'rubygems'

    answer = 'file_version: 5.0.0.101573'
    # answer: 42
    # registry_value: system32\\\\DRIVERS\\\\cdrom.sys
    # file_Version: 5.0.0.101573
    filename = 'c:\Program Files\Windows NT\Accessories\wordpad.exe'
    filename =  'c:\Program Files\Oracle\VirtualBox Guest Additions\VboxMouse.sys'  
    script_file = 'c:/windows/temp/test.rb'
    ruby_script = <<-EOF
require 'yaml'
require 'puppet'
require 'pp'
require 'facter'
  
# Facter code
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
      # http://stackoverflow.com/questions/76472/checking-version-of-file-in-ruby-on-windows
      if File.exists?(filename)
        vsize = Win32API.new('version.dll', 'GetFileVersionInfoSizeA', ['P', 'P'], 'L').call(filename, '')
        
        if (vsize > 0)
          # extracting a data from UTF16
          result = ' ' * vsize
          # TODO switch to ffi
          Win32API.new('version.dll', 'GetFileVersionInfoA', ['P', 'L', 'L', 'P'], 'L').call(filename, 0, vsize, result)
          rstring = result.unpack('v*').map{ |s| s.chr if s < 256 } *'' 
          version_match = /FileVersion..(.*?)\000/.match(rstring)
          version = version_match[1].to_s
          setcode { version }
          # alternatives
          # x = s.match(/F\0i\0l\0e\0V\0e\0r\0s\0i\0o\0n\0*(.*?)\0\0\0/)
          #
          #if x.class == MatchData
          #  ver=x[1].gsub(/\0/,"")
          #else
          #  ver="No version"
          #end
        end
      end
  end
end
fact_name = 'registry_value'
if Facter.value(:kernel) == 'windows'
  require 'win32/registry'
  def hklm_registry_read(key, value)
    begin
      reg = Win32::Registry::HKEY_LOCAL_MACHINE.open(key, Win32::Registry::KEY_READ | 0x0100) # read 64 subkey
      rval = reg[value]
      reg.close
      rval
    rescue
      nil
    end
  end
  Facter.add(fact_name) do
    setcode { hklm_registry_read('SYSTEM\\CurrentControlSet\\services\\cdrom', 'ImagePath')}
  end
else
  # TODO
end
# Facter validation
%w/answer file_version registry_value/.each do |fact_name|
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

