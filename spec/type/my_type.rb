# origin : https://github.com/gnumike/serverspec/tree/master/spec
# http://arlimus.github.io/articles/custom.resource.types.in.serverspec/  
require 'yaml'

module Serverspec
  module Type
  
    class MyType < Base

      def valid?
        # check if the files are valid
      end
    
      def initialize(file) 
      
        if os[:family] == 'redhat'
          # RedHat bases OS related environment spec
          ruby_script = <<-EOF
            require 'yaml'
            require 'pp'
            result = { 'answer' => 42 }
            
            # Read Puppet Agent last run summary
            puppet_last_run_summary = \\`puppet config print 'lastrunfile'\\`.chomp
            data = File.read(puppet_last_run_summary)

            # Parse
            puppet_summary = YAML.load(data)
            result = { 'answer' => 42 }
            result['resources'] = puppet_summary['resources']
            \\$stderr.puts(result.to_yaml)
          EOF
          @content  = Specinfra::Runner::run_command("ruby -e \"#{ruby_script}\"").stderr
          @data = YAML.load(@content)
        elsif ['windows'].include?(os[:family])
          # Windows related environment spec
          puppet_home = 'C:/Program Files/Puppet Labs/Puppet'
          puppet_statedir = 'C:/ProgramData/PuppetLabs/puppet/var/state'
          last_run_report = "#{puppet_statedir}/#{file}"
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

          result = { 'answer' => 42 }
        
          # Read Puppet Agent last run report
          data = File.read('#{last_run_report}')
          # Parse
          puppet_transaction_report = YAML.load(data)
          # Get metrics
          metrics = puppet_transaction_report.metrics
          # Cannot return just 'metrics'
          puts 'Puppet Agent last metrics:'
          pp metrics
          # Show resources
          puppet_resource_statuses = puppet_transaction_report.resource_statuses
          puts 'Puppet Agent resources:'
          pp puppet_resource_statuses.keys
          result['resources'] = puppet_resource_statuses.keys
          # Get summary
          raw_summary = puppet_transaction_report.raw_summary
          puts 'Puppet Agent last run summary:'
          pp raw_summary
          result['summary'] = raw_summary
          # Get status
          status = puppet_transaction_report.status
          result['status'] = status
          puts 'Puppet Agent last run status: ' + status
          # Do basic smoke test ( temporarily )
          `$stderr.puts YAML.dump(result)
          EOF
          Specinfra::Runner::run_command(<<-END_COMMAND
          @"
          #{ruby_script}
"@ | out-file '#{script_file}' -encoding ascii
          # NOTE:  the '"@' delimiter has to be in the start of the line
          END_COMMAND
          )
          @content  = Specinfra::Runner::run_command("iex \"ruby.exe '#{script_file}'\"").stderr
          @data = YAML.load(@content)
        end
      end   
      def has_key?(key)
        
        @data.has_key?(key)
      end

      def has_key_value?(key, value)        
        @data.has_key?(key) && @data[key] == value
      end
    end
    def my_type(file)
      MyType.new(file)    
    end
  end
end

include Serverspec::Type
