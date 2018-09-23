require 'serverspec_extension_types/types/consul_base'


# TODO: List and singular
module Serverspec::Type
  class ConsulService < ConsulBase

    def url
      "#{@url_base}/v1/catalog/service/#{@name}"
    end

    def to_s
      msg = "Consul Service #{@name}"
      msg << %( with acl token: "#{@token}") if @token
      msg
    end

    def inspection
      @inspection ||= ::MultiJson.load(get_inspection.stdout)
    end


  end
end
