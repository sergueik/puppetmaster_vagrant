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
  require 'ffi'
  Facter.add(fact_name) do
  module Helper
    extend FFI::Library
    ffi_lib 'version.dll'
    ffi_convention :stdcal
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms647005%28v=vs.85%29.aspx
    attach_function :version_resource_size_bytes, :GetFileVersionInfoSizeA,  [ :pointer, :pointer ], :int
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms647003%28v=vs.85%29.aspx
    attach_function :version, :GetFileVersionInfoA,  [ :pointer, :int, :int, :buffer_out ], :int
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms647464%28v=vs.85%29.aspx
    # TODO - processing the
    version_information = '\VarFileInfo\Translation'.encode('UTF-16LE')
    attach_function :verqueryvalue, :VerQueryValueA,  [ :buffer_in, :buffer_in, :buffer_out, :pointer ], :int
  end
  filename = '#{filename}'
  if File.exists?(filename)
    size_in_bytes = Helper.version_resource_size_bytes(filename, '')
    if (size_in_bytes > 0)
      result = ' ' * size_in_bytes
      status = Helper.version(filename, 0, size_in_bytes, result)
      # http://stackoverflow.com/questions/76472/checking-version-of-file-in-ruby-on-windows
      # hard way to to get back ASCII version from the struct
      rstring = result.unpack('v*').map{ |s| s.chr if s < 256 } *''
      rstring = rstring.gsub(/\\000/, ' ')
      version_match = /FileVersion\\s+\\b([0-9.]+)\\b/.match(rstring)
      version = version_match[1]
      setcode { version }
      #  TODO: use :verqueryvalue
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

