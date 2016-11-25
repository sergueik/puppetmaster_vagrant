require 'serverspec'
require 'serverspec/type/base'

module Serverspec::Type
  class ApacheConfFile < Base
    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end

    def has_configuration?(line)
      lines = []
      # TODO:
      # Failure/Error: text = File.read(@name)
      # NoMethodError: undefined method `read' for Serverspec::Type::File:Class
      text = IO.read(@name)
      lines = text.split(/(?:<Directory "[^"]+">|<\/Directory>)/).at(1).split(/\r?\n/)
      lines.each { |line| line.strip! }
      lines.include?(line)
      # pp lines
    end

    def has_property?(prop_name, prop_value)
      properties = {}
      text = File.read(@name)
      data = text.split(/(<Location \/ >|<\/Location>)/).at(2).split(/\r?\n/)
      data.each do |line|
        if (!line.start_with?('#'))
          properties[$1.strip] = $2 if line =~ /^(?: *)([^ ]*)(?: +)(?:"*)([^"].*[^"])(?:"*)(?: *)$/
        end
      end
      properties[prop_name] == prop_value
      # pp properties
    end
  end
  def apache_conf_file(name)
    ApacheConfFile.new(name)
  end
end

include Serverspec::Type
