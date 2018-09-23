require 'specinfra'

rabbitmq_user = ENV['RABBITMQ_USER'] || 'guest'
rabbitmq_password = ENV['RABBITMQ_PASSWORD'] || 'guest'
rabbitmq_url = ENV['RABBITMQ_URL'] || 'http://localhost:15672'
props = {
  rabbitmq_user: rabbitmq_user,
  rabbitmq_password: rabbitmq_password,
  rabbitmq_url: rabbitmq_url
}
set_property props
