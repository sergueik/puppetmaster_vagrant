require 'serverspec'
require 'serverspec/type/base'

# origin: https://github.com/OctopusDeploy/octopus-serverspec-extensions/blob/master/lib/octopus_serverspec_extensions/type/npm_package.rb
module Serverspec::Type
  class NpmPackage < Base

    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end

    #todo: support version
    def installed?(provider, version)
      command_result = @runner.run_command("npm list -g #{name}")

      software = command_result.stdout.split("\n").each_with_object({}) do |s, h|
        if s.include? "@"
          package_name, package_version = s.split('@')
          package_name = package_name.gsub(/.*? /, '')
          h[String(package_name).strip.downcase] = String(package_version).strip.downcase
        end
        h
      end

      !software[name.downcase].nil?
    end
  end

  def npm_package(name)
    NpmPackage.new(name)
  end
end

include Serverspec::Type
