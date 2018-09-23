require 'serverspec_extension_types/types/rabbitmq_base'

module Serverspec::Type
  class RabbitmqVhostList   < RabbitmqBase


    def has_vhost?(vhost)
     inspection.find { |str| str['name'] == vhost }
    end

    def url
      "#{@url_base}/api/vhosts"
    end

    def inspection
      @inspection ||= ::MultiJson.load(get_inspection.stdout)
    end



  end
end
