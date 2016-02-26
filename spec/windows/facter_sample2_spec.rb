require_relative '../windows_spec_helper'

context 'Execute Facter Fact in Puppet Agent Ruby Environment' do
  filename = 'C:/Program Files/SplunkUniversalForwarder/bin/splunk.exe'
  context 'With LOAD_PATH' do
    lines = [ 
      'C:/Program Files/SplunkUniversalForwarder/bin/splunkd.exe'
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
      lines.each do |file_path|
        its(:stdout) do
          should match  Regexp.new(file_path.gsub('/','\\').gsub(/\\/,'\\\\\\\\\\\\\\\\').gsub('(','\\(').gsub(')','\\)'), Regexp::IGNORECASE)
        end
      end
    end
  end
end
