require 'serverspec_extension_types/types/rabbitmq_base'

module Serverspec::Type
  class RabbitmqNodeList   < RabbitmqBase

    def url
      "#{@url_base}/api/vhosts"
    end



    def inspection
      @inspection ||= ::MultiJson.load(get_inspection.stdout)
    end


  end
end
