require_relative '../windows_spec_helper'

context 'Execute Facter Fact in Puppet Agent Ruby Environment' do
  filename = 'C:/Program Files/SplunkUniversalForwarder/bin/splunk.exe'
  context 'With LOAD_PATH' do
    lines = [ 
      'answer: 42',
    #  'FileVersion  6.3.1',
      '6.3.1'
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
require 'Win32API'

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
  if File.exists?(filename)
    s=""
    vsize=Win32API.new('version.dll', 'GetFileVersionInfoSize', 
                       ['P', 'P'], 'L').call(filename, s)
  
    # If file size is greater than zero, let's try to grab the file version info.
    if (vsize > 0)
      result = ' '*vsize
      Win32API.new('version.dll', 'GetFileVersionInfo', 
                   ['P', 'L', 'L', 'P'], 'L').call(filename, 0, vsize, result)
      rstring = result.unpack('v*').map{|s| s.chr if s<256}*''
      version = /FileVersion..(.*?)\\000/.match(rstring)
      
      # Print file product version.
      puts version
  end
 end


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
          should match  Regexp.new(line.gsub(/[()]/,"\\#{$&}").gsub('[','\[').gsub(']','\]'))
        end
      end
    end
  end
end

  
