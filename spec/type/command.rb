require 'pp'
require 'yaml'
require 'json'
require 'csv'

# use embedded XML  class
# https://www.xml.com/pub/a/2005/11/09/rexml-processing-xml-in-ruby.html
require 'rexml/document'
include REXML

# origin: https://github.com/mizzy/serverspec/blob/master/lib/serverspec/type/command.rb
# monkey-patching the Command class in the uru environment
module Serverspec::Type
  class Command < Base
    def stdout
      command_result.stdout
    end

    def stdout_as_csv
      begin
        @res = CSV.parse(command_result.stdout)
        # pp @res
        @res
      rescue => e
        $stderr.puts e.to_s
        nil
      end
    end

    def stdout_as_json
      begin
        @res = JSON.parse(command_result.stdout)
        # pp @res
        @res
      rescue => e
        $stderr.puts e.to_s
        nil
      end
    end

    def stdout_as_xml
      begin
        @res = Document.new(command_result.stdout)
        # pp @res
        @res
      rescue => e
        $stderr.puts e.to_s
        nil
      end
    end
    
    def stdout_as_yaml
      begin
        @res = YAML.load(command_result.stdout)
        # pp @res
        @res
      rescue => e
        $stderr.puts e.to_s
        nil
      end
    end

    def stdout_as_data
      begin
        # hack around logstash logging its operations together with rubydebug output
        rawdata = command_result.stdout.split(/\r?\n/).reject { |line|
          line =~ /(?:No log4j2 configuration file found|Sending Logstash's)/ ;
        }.reject { |line|
          line =~ /@timestamp/i
        }.reject {|line|
          line =~ /(?:_dateparsefailure|_grokparsefailure)/
        } 
        @res = eval(rawdata.join("\n"))
        # pp @res
        @res
      rescue => e
        nil
      end
    end

    def stderr
      command_result.stderr
    end

    def exit_status
      command_result.exit_status.to_i
    end

    private
    def command_result()
      @command_result ||= @runner.run_command(@name)
    end
  end
end
