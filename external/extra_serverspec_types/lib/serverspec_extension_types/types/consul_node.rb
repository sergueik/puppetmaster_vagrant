require 'serverspec_extension_types/types/consul_base'


# TODO: List and singular
module Serverspec::Type
  class ConsulNode < ConsulBase

    def url
      "#{@url_base}/v1/catalog/node/#{@name}"
    end



    def inspection
      @inspection ||= ::MultiJson.load(get_inspection.stdout) #Need a find
    end


  end
end
