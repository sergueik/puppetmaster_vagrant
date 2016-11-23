require 'serverspec'
require 'serverspec/type/base'

module Serverspec::Type
  class ApacheConfFile < Base
    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end
    def has_property?(conf_name, conf_value)
      properties = {}
      text = File.read(@name)
      data = text.split(/(<Location \/ >|<\/Location>)/).at(2).split(/\r?\n/)
      data.each do |line|
        if (!line.start_with?('#'))
          properties[$1.strip] = $2 if line =~ /^(?: *)([^ ]*)(?: +)(?:"*)([^"].*[^"])(?:"*)(?: *)$/
        end
      end
      properties[conf_name] == conf_value
      # pp properties
    end
  end
  def apache_conf_file(name)
    ApacheConfFile.new(name)
  end
end

include Serverspec::Type
