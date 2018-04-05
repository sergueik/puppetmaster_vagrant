require 'spec_helper'
require 'json'
require 'yaml'
require 'ostruct'

$DEBUG = true

# this example may be considred a bulding block for specinfra  monitored_by? -style expectaton with consul

context 'Consul' do
  context 'Service checks' do
    {
      'web' => 80,
    }.each do |monitored_service_name, tcp_port|

      api_command = "curl http://localhost:8500/v1/catalog/service/#{monitored_service_name} | /usr/bin/jq '.'"
      # mock
      consul_service_config_file = "/etc/consul.d/service_#{monitored_service_name}.json"
      # mock
      consul_service_config_file = "/tmp/data.json"
      api_command = "/usr/bin/jq '.' #{consul_service_config_file}" 
      $stderr.puts "api_command: " + api_command if $DEBUG

      service_object_data = nil
      begin 
        service_object_data = command(api_command).stdout 
        $stderr.puts "raw service_object_data: " + service_object_data if $DEBUG
      rescue Exception => e
        $stderr.puts 'Exception: ' + e.to_s
      end
      begin

        $stderr.puts 'Deserializing data' if $DEBUG
        # https://stackoverflow.com/questions/6423484/how-do-i-convert-hash-keys-to-method-names
        begin 
          $stderr.puts 'Tryin JSON parse' if $DEBUG
          service_object = JSON.parse(service_object_data)
        rescue Exception => e
          $stderr.puts 'Exception: ' + e.to_s
        end
       
        begin 
          $stderr.puts 'Tryin YAML load' if $DEBUG
          service_object = YAML.load(service_object_data)
        rescue Exception => e
          $stderr.puts 'Exception: ' + e.to_s
        end
      rescue Exception => e
        $stderr.puts 'Exception: ' + e.to_s
      end
      if ! service_object.nil?
        $stderr.puts "service_object: " + service_object.class.name if $DEBUG
        subject { OpenStruct.new  service_object['service'] }
        its(:port) { should equal tcp_port }
        its(:name) { should match Regexp.quote(monitored_service_name) }
      end
    end
  end
end

