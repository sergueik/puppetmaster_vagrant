# origin : https://github.com/gnumike/serverspec/tree/master/spec
# http://arlimus.github.io/articles/custom.resource.types.in.serverspec/  
require 'yaml'

module Serverspec
  module Type
  
    class MyType < Base
    
      def initialize(file) 
      
        if os[:family] == 'redhat'
          # RedHat bases OS related environment spec
          # script_file = '/tmp/test.$$.rb'
          script_file = '/tmp/test.rb'
          # Puppet version-specific path settings:
          # RHEL 6.6 x64 / Puppet 4.3
          puppet_lib_home = '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby/'
          # Centos 6.5 x86 box / Puppet 3.2.3
          puppet_lib_home = '/usr/share/ruby/vendor_ruby/'
   
          ruby_script = <<-EOF

            \\$LOAD_PATH.insert(0, '#{puppet_lib_home}/facter/lib')
            \\$LOAD_PATH.insert(0, '#{puppet_lib_home}/hiera/lib')
            \\$LOAD_PATH.insert(0, '#{puppet_lib_home}/puppet/lib')
            require 'puppet'
            require 'yaml'
            require 'pp'
            require 'optparse'

            options = {}
            OptionParser.new do |opts|
              opts.banner = \\"Usage: example.rb [options]\\"
              opts.on(\\"-v\\", \\"--[no-]verbose\\", \\"Run verbosely\\") do |v|
                options[:verbose] = v
              end
              opts.on(\\"-rRUN\\", \\"--run=RUN\\", \\"Examine the RUN'th Puppet Run Report\\") do |_run|
                options[:run] = _run
              end
            end.parse!

            # Do add entry for basic smoke test
            result = { 'answer' => 42 }
            
            # Read Puppet Agent last run report
            # NOTE: escaping special characters to prevent execution by shell 
            puppet_last_run_report = \\`puppet config print 'lastrunreport'\\`.chomp
            if options[:run]
              puppet_last_run_report = puppet_last_run_report + '.' + options[:run].to_s
            end
            data = File.read(puppet_last_run_report)
            # Parse Puppet Agent last run report, sanitize from 
            # !ruby/object:Puppet::Util::Metric and the like
            
            puppet_transaction_report = YAML.load(data)

            # Get metrics
            metrics = puppet_transaction_report.metrics

            time = metrics['time']
            puts 'Times:'
            pp time.values

            events = metrics['events']
            puts 'Events:'
            pp events.values
            # puts events.values.to_yaml

            resources = metrics['resources']
            puts 'Resources:'
            pp resources.values

            puppet_resource_statuses = puppet_transaction_report.resource_statuses
            puts 'Resource Statuses:'
            pp puppet_resource_statuses.keys
            result['resources'] = puppet_resource_statuses.keys
            
            raw_summary = puppet_transaction_report.raw_summary
            puts 'Puppet Agent Last Run Summary:'
            pp raw_summary
            result['summary'] = raw_summary

            status = puppet_transaction_report.status
            puts 'Status: ' + status
            
            result['status'] = status
            \\$stderr.puts YAML.dump(result)

          EOF
          Specinfra::Runner::run_command("echo \"#{ruby_script}\" > #{script_file}")
          @content  = Specinfra::Runner::run_command(<<-EOF
            export RUBYOPT='rubygems'
            ruby #{script_file}
          EOF
          ).stderr
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
          puts 'Puppet Agent Last Run Summary:'
          pp raw_summary
          result['summary'] = raw_summary
          # Get status
          status = puppet_transaction_report.status
          result['status'] = status
          puts 'Puppet Agent last run status: ' + status
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
      
      def has_resource?(resource)        
        @data.has_key?('resources') && @data['resources'].include?(resource)
      end

      def has_summary_resources?(key, value)        
        @data.has_key?('summary') && @data['summary'].has_key?('resources') && @data['summary']['resources'][key] == value
      end

      def valid?
        # check if the files are valid
      end

    end
    def my_type(file)
      MyType.new(file)    
    end
  end
end

include Serverspec::Type
