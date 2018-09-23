require 'serverspec'
require 'serverspec/type/base'
require 'multi_json'
require 'serverspec_extension_types/helpers/properties'
require 'serverspec_extension_types/types/api_base'

module Serverspec::Type
  class RabbitmqBase < ApiBase
    def initialize(name = nil, options = {})
      super(name, options)
      @user = ENV['RABBITMQ_USER'] || 'guest'
      @password = ENV['RABBITMQ_PASSWORD'] || 'guest'
      @url_base = property[:variables][:rabbitmq_url] || 'http://localhost:15672'
    end


    def inspection
      @inspection ||= ::MultiJson.load(get_inspection.stdout)[0]
    end

    def length
      if inspection.is_a? String
        inspection.length
      elsif inspection.kind_of? Array
        inspection.length
      else
        1
      end
    end

    private

    def get_inspection
      command = "curl -s -u #{@user}:#{@password} #{url}"
      @get_inspection ||= @runner.run_command(command)
    end
  end
end
