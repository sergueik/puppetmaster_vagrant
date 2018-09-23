require 'spec_helper'
require 'rest-client'

RSpec.context 'Consul' do
  describe consul_service_list do
    it '' do
      puts subject.inspection
    end
  end

  describe consul_service('rabbitmq') do
    it '' do
      puts subject.inspection
    end
  end
  describe consul_node_list do
    it '' do
      puts subject.inspection
    end
  end

  describe consul_node('consul') do
    it '' do
      puts subject.inspection
    end
  end

end
