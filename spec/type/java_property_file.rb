require 'serverspec'
require 'serverspec/type/base'

# origin : https://github.com/OctopusDeploy/octopus-serverspec-extensions/blob/master/lib/octopus_serverspec_extensions/type/java_property_file.rb

module Serverspec::Type
  class JavaPropertyFile < Base

    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end

    def has_property?(propertyName, propertyValue)
      properties = {}
      IO.foreach(@name) do |line|
        if (!line.start_with?('#'))
          properties[$1.strip] = $2 if line =~ /([^=]*)=(.*)/
        end
      end

      properties[propertyName] == propertyValue
    end
  end

  def java_property_file(name)
    JavaPropertyFile.new(name)
  end
end

include Serverspec::Type
