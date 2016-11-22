require 'serverspec'
require 'serverspec/type/base'

# origin: https://github.com/OctopusDeploy/octopus-serverspec-extensions/blob/master/lib/octopus_serverspec_extensions/type/chocolatey_package.rb

module Serverspec::Type
  class ChocolateyPackage < Base

    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end

    #todo: support version
    def installed?(provider, version)
      command_result = @runner.run_command("choco list -l -r #{name}")

      software = command_result.stdout.split("\r\n").each_with_object({}) do |s, h|
        v, k = s.split('|')
        h[String(v).strip.downcase] = String(k).strip.downcase
        h
      end

      !software[name.downcase].nil?
    end
  end

  def chocolatey_package(name)
    ChocolateyPackage.new(name)
  end
end

include Serverspec::Type
