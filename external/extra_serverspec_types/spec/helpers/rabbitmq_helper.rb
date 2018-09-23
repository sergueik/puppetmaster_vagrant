require 'json'
class RabbitMQHelper
  def initialize
    @user = ENV['RABBITMQ_USER'] || 'guest'
    @password = ENV['RABBITMQ_PASSWORD'] || 'guest'
    @url_base = property[:variables][:rabbitmq_url] || 'http://localhost:15672'
  end

  def create_vhost(vhost)
    resource = RestClient::Resource.new "#{@url_base}/api/vhosts/#{vhost}", @user, @password
    resource.put '{ "tracing": "false" }'
    create_permission(vhost, @user)
  end

  def create_permission(vhost, user, read = '.*', write = '.*', configure = '.*')
    resource = RestClient::Resource.new "#{@url_base}/api/permissions/#{vhost}/#{user}", @user, @password
    payload = { read: read, write: write, configure: configure }
    resource.put payload.to_json
  end

  def create_user(user, password, tag = 'management')
    resource = RestClient::Resource.new "#{@url_base}/api/users/#{user}", @user, @password
    user = { password: password, tags: tag }
    resource.put user.to_json
  end

  def create_policy(vhost, name, pattern = '.*', definition)
    resource = RestClient::Resource.new "#{@url_base}/api/policies/#{vhost}/#{name}", @user, @password
    policy = { pattern: pattern, definition: definition }
    resource.put policy.to_json
  end
end
