# Custom type to perform inspection of Puppet lastrun reports
$LOAD_PATH.insert(0, '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby/')
require 'json'
require 'yaml'
require 'puppet'
require 'pp'
require 'optparse'

  module Serverspec
  module Type

    class Puppet_Helper < Base

      attr_accessor :lastrunfile_data, :lastreport_data, :raw_lastrunfile_data, :debug
      @debug = false

      def initialize(debug)
        @debug = debug
        @lastrunfile = `puppet config print 'lastrunfile'`.chomp
        @lastreport = `puppet config print 'lastrunreport'`.chomp
        @raw_lastrunfile_data = IO.read(@lastrunfile)
        @raw_lastreport_data = IO.read(@lastreport)
        # Parse
        begin
          @lastrunfile_data = YAML.load(@raw_lastrunfile_data)
        rescue => e
          # mapping values are not allowed in this context at line 1 column 20
          $stderr.puts e.to_s
          @lastrunfile_data = YAML.load("---\n")
        end
        begin
          @lastreport_data = YAML.load(@raw_lastreport_data)
        rescue => e
          # mapping values are not allowed in this context at line 1 column 20
          $stderr.puts e.to_s
          @lastreport_data = { }
        end
        if @debug
          begin
            $stderr.puts @lastreport_data.raw_summary.keys.join(',')
          rescue
            # https://docs.puppet.com/puppet/3.5/yard/Puppet/Transaction/Report.html
            # undefined method `keys' for #<Puppet::Transaction::Report>
          end        
        end        
        if @lastrunfile_data.nil?
          @events = []
        else
          @events = @lastrunfile_data['events']
        end
      end
      def events
        @events.to_yaml
      end
      def failure
        @events['failure'].to_i
      end
      def total
        @events['total'].to_i
      end
      def resources
        summary = @lastreport_data.raw_summary
        summary['resources']
      end
    end

    def puppet_helper(debug  = false)
      Puppet_Helper.new(debug)
    end
  end
end

include Serverspec::Type