require_relative '../windows_spec_helper'

context 'Execute Facter Fact in Puppet Agent Ruby Environment' do
  filename = 'C:/Program Files/SplunkUniversalForwarder/bin/splunk.exe'
  context 'With LOAD_PATH' do
    lines = [ 
      'answer: 42',
    #  'FileVersion  6.3.1',
      '"C:\Program Files\SplunkUniversalForwarder\bin\splunkd.exe" service'
    ]
    puppet_home = 'C:/Program Files/Puppet Labs/Puppet'
    rubylib = "#{puppet_home}/facter/lib;#{puppet_home}/hiera/lib;#{puppet_home}/puppet/lib;"
    rubyopt = 'rubygems' 
    script_file = 'c:/windows/temp/test.rb'
    ruby_script = <<-EOF
`$LOAD_PATH.insert(0, '#{puppet_home}/facter/lib')
`$LOAD_PATH.insert(0, '#{puppet_home}/hiera/lib')
`$LOAD_PATH.insert(0, '#{puppet_home}/puppet/lib')
require 'yaml'
require 'puppet'
require 'pp'
require 'win32/registry'

# Do basic smoke test
puts 'Parse YAML string' 
pp YAML.load(<<-'END_DATA'
---
answer: 42
END_DATA
)

puts 'Parse YAML string' 
puts "Generate YAML\\n" +  YAML.dump({'answer'=>42})

  filename = '#{filename}'
  
  def hklm_registry_read(key, value)
    # Always read the registry in 64-bit mode.
    begin
      reg = Win32::Registry::HKEY_LOCAL_MACHINE.open(key, Win32::Registry::KEY_READ | 0x0100)
      rval = reg[value]
      reg.close
      rval
    rescue
      nil
    end
  end
  
  def get_install_dir
    hklm_registry_read('SYSTEM\\ControlSet001\\services\\SplunkForwarder', 'ImagePath')
  end
  
pp get_install_dir

  EOF

  before(:each) do
    Specinfra::Runner::run_command(<<-END_COMMAND
    @"
    #{ruby_script}
"@ | out-file '#{script_file}' -encoding ascii
    
    END_COMMAND
    )
  end
  
    describe command("iex \"ruby.exe '#{script_file}'\"") do
      let(:path) { "#{puppet_home}/sys/ruby/bin" }
      lines.each do |line| 
        its(:stdout) do
          should match  Regexp.new(line.gsub('\\','\\\\').gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
        end
      end
    end
  end
end
