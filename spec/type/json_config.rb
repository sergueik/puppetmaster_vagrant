# origin : https://github.com/gnumike/serverspec/tree/master/spec
# http://arlimus.github.io/articles/custom.resource.types.in.serverspec/  
require 'yaml'

module Serverspec
  module Type
  
    class JSONConfig < Base

      def valid?
        # check if the files are valid
      end

    
    def initialize(file) 
    
    
    puppet_home = 'C:/Program Files/Puppet Labs/Puppet'
puppet_statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
last_run_report = "#{puppet_statedir}/#{file}"
rubylib = "#{puppet_home}/facter/lib;#{puppet_home}/hiera/lib;#{puppet_home}/puppet/lib;"
rubyopt = 'rubygems'
script_file = 'c:/windows/temp/test.rb'
script_result = 'c:/windows/temp/test.yaml'

ruby_script = <<-EOF
`$LOAD_PATH.insert(0, '#{puppet_home}/facter/lib')
`$LOAD_PATH.insert(0, '#{puppet_home}/hiera/lib')
`$LOAD_PATH.insert(0, '#{puppet_home}/puppet/lib')
require 'yaml'
require 'puppet'
require 'pp'
# Do basic smoke test
`$stderr.puts YAML.dump({'answer'=>42})
File.open('#{script_result}', 'w') { |file| file.write(YAML.dump({'answer'=>42})) }
EOF
Specinfra::Runner::run_command(<<-END_COMMAND
@"
#{ruby_script}
"@ | out-file '#{script_file}' -encoding ascii
END_COMMAND
)
Specinfra::Runner::run_command("iex \"ruby.exe '#{script_file}'\"")


        script_result = 'c:/windows/temp/test.yaml'
        @content = Specinfra::Runner::get_file_content(script_result).stdout
      @data = YAML.load(@content)
    end
    
      def has_key?(key)
        
        @data.has_key?(key)
      end

      def has_key_value?(key, value)        
        @data.has_key?(key) && @data[key] == value
      end
    end
    def json_config(file)
      JSONConfig.new(file)    
    end
  end
end

include Serverspec::Type
