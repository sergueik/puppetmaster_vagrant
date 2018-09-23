require 'serverspec_extension_types/types/rabbitmq_base'

module Serverspec::Type
  class RabbitmqUserPermission < RabbitmqBase

    def url
      "#{@url_base}/api/users/#{name}/permissions"
    end

    def read_from_queue?(vhost, queue)
      queue.match read_permissions(vhost)
    end

    def write_to_queue?(vhost, queue)
      queue.match write_permissions(vhost)
    end

    def configure_queue?(vhost, queue)
      queue.match configure_permissions(vhost)
    end

    def read_permissions(vhost)
      inspection.find { |item| item['vhost'] == vhost}['read']
    end

    def write_permissions(vhost)
      inspection.find { |item| item['vhost'] == vhost}['write']
    end

    def configure_permissions(vhost)
      inspection.find { |item| item['vhost'] == vhost}['configure']
    end

    def inspection
      @inspection ||= ::MultiJson.load(get_inspection.stdout)
    end

  end
end
