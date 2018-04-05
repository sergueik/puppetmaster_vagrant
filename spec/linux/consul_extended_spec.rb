require 'spec_helper'
require 'yaml'
require 'ostruct'

$DEBUG = false

# this example may be considred a bulding block for 
# specinfra  monitored_by? - style expectaton regarding consul

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
      $stderr.puts "command: " + api_command if $DEBUG
      service_object_data = command(api_command).stdout
      $stderr.puts "raw data: " + service_object_data if $DEBUG
      begin
        # https://stackoverflow.com/questions/6423484/how-do-i-convert-hash-keys-to-method-names
        service_object = YAML.load(service_object_data)
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

