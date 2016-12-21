require 'serverspec'
require 'serverspec/type/base'

# origin : https://github.com/OctopusDeploy/octopus-serverspec-extensions/blob/master/lib/octopus_serverspec_extensions/type/java_property_file.rb

module Serverspec::Type
  class PropertyFile < Base

    def initialize(filename)
      @filename = filename
      @runner = Specinfra::Runner
    end

    def has_property?(property_name, property_value)
      properties = {}
      IO.foreach(@filename) do |line|
        if (!line.start_with?('#'))
          properties[$1.strip] = $2 if line =~ /^([^=]*)=(?: *)(.*)/
        end
      end
      properties[property_name] == property_value
    end
  end

  def property_file(filename)
    PropertyFile.new(filename)
  end
end

include Serverspec::Type
