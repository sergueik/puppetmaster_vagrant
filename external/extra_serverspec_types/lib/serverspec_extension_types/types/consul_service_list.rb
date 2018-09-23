require 'serverspec_extension_types/types/consul_base'


# TODO: List and singular
module Serverspec::Type
  class ConsulServiceList < ConsulBase

    def url
      "#{@url_base}/v1/catalog/services"
    end

    def to_s
      msg = "Consul Service List"
      msg << %( with acl token: "#{@token}") if @token
      msg
    end

    def has_service?(service)
      services.include? service
    end

    def services
      inspection.keys
    end

    def inspection
      @inspection ||= ::MultiJson.load(get_inspection.stdout)
    end


  end
end
