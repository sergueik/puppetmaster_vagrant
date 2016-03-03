# origin : https://github.com/gnumike/serverspec/tree/master/spec
require 'json'

module Serverspec
  module Type
    class JSONConfig < Base
      def has_key?(key)
        @content = @runner.get_file_content(@name).stdout
        @data = JSON.parse(@content)
        @data.has_key?(key)
      end

      def has_key_value?(key, value)
        @content = @runner.get_file_content(@name).stdout
        @data = JSON.parse(@content)
        @data.has_key?(key) && @data[key] == value
      end
    end

    def json_config(file)
      JSONConfig.new(file)
    end
  end
end

include Serverspec::Type
