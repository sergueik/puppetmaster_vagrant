require 'serverspec_extension_types/types/consul_base'


# TODO: List and singular
module Serverspec::Type
  class ConsulNodeList < ConsulBase

    def url
      "#{@url_base}/v1/catalog/nodes"
    end

    def to_s
      msg = "Consul Node List"
      msg << %( with acl token: "#{@token}") if @token
      msg
    end
    
    def has_node?(node)
      nodes.include? node
    end

    def nodes
      inspection.keys
    end

    def inspection
      @inspection ||= ::MultiJson.load(get_inspection.stdout)
    end


  end
end
