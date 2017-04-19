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

      @debug = false

      def initialize(debug)
        @debug = debug
        @lastrunfile = `puppet config print 'lastrunfile'`.chomp
        @lastreport = `puppet config print 'lastrunreport'`.chomp
        @raw_data = IO.read(@lastrunfile) #.gsub("\n", '')
        $stderr.puts @raw_data if @debug
        # Parse
        begin
          @data = YAML.load(@raw_data)
        rescue => e
          # mapping values are not allowed in this context at line 1 column 20
          $stderr.puts e.to_s
        end
        pp @data if @debug
        if @data.nil?
          @events = []
        else
          @events = @data['events']
        end
      end
      def data
        @data
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
      def raw_data
        @raw_data
      end
    end

    def puppet_helper(debug  = false)
      Puppet_Helper.new(debug)
    end
  end
end

include Serverspec::Type