require 'serverspec'
require 'serverspec/type/base'
require 'multi_json'
require 'serverspec_extension_types/helpers/properties'

module Serverspec::Type
  class ApiBase < Base
    def initialize(name = nil, options = {})
      super(name, options)
    end

    def [](key)
      value = inspection
      key.split('.').each do |k|
        is_index = k.start_with?('[') && k.end_with?(']')
        value = value[is_index ? k[1..-2].to_i : k]
      end
      value
    end

    def url
      @url_base
    end

    def inspection
      @inspection ||= ::MultiJson.load(get_inspection.stdout)
    end

    private

    def get_inspection
      command = "curl -s #{url}"
      @get_inspection ||= @runner.run_command(command)
    end
  end
end
