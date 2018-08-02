require 'spec_helper'
require 'json'
require 'yaml'
require 'ostruct'

$DEBUG = true

# this example may be considred a bulding block for specinfra  monitored_by? -style expectaton with consul

context 'Consul' do

  datafile = '/tmp/consul_data.json'

  before(:each) do
    # NOTE: currently before(:each) does not work with this code.
    # Need to crerate datafile manually
    # mock of the /etc/consul.d/service_web_config.json
    Specinfra::Runner::run_command( <<-EOF
      cat <<END>#{datafile}
{
  "service":
  {
    "name": "web",
    "port": 8080
  }

}
END
    EOF
    )
  end

  describe 'Service checks' do
    {
      'web' => 8080,
    }.each do |monitored_service_name, tcp_port|

      api_command = "curl http://localhost:8500/v1/catalog/service/#{monitored_service_name} | /usr/bin/jq '.' - "
      # mock
      consul_service_config_file = "/etc/consul.d/service_#{monitored_service_name}.json"
      # mock
      api_command = "/usr/bin/jq -M '.' #{datafile}"
      api_command = "cat #{datafile}"
      $stderr.puts "api_command: " + api_command if $DEBUG

      service_object_data = nil
      $stderr.puts 'Running the command' if $DEBUG
      begin
        service_object_data = command(api_command).stdout
        $stderr.puts 'raw service_object_data: ' + service_object_data if $DEBUG
      rescue => e
        # Exception `IO::EAGAINWaitReadable in specinfra <internal:prelude>:76
        $stderr.puts 'Exception from running the command : ' + e.to_s
      end

      $stderr.puts 'Deserializing data' if $DEBUG
      # https://stackoverflow.com/questions/6423484/how-do-i-convert-hash-keys-to-method-names
      begin
        $stderr.puts 'Trying JSON parse' if $DEBUG
        service_object = JSON.parse(service_object_data)
      rescue Exception => e
        $stderr.puts 'Exception from JSON: ' + e.to_s
      end

      begin
        $stderr.puts 'Trying YAML load' if $DEBUG
        service_object = YAML.load(service_object_data)
      rescue Exception => e
        $stderr.puts 'Exception from YAML load: ' + e.to_s
      end
      if ! service_object.nil?
        $stderr.puts 'Service_object: ' + service_object.class.name if $DEBUG
        describe 'Test' do
          subject { OpenStruct.new service_object['service'] }
          its(:port) { should eq tcp_port }
          its(:name) { should match Regexp.quote(monitored_service_name) }
        end
      end
    end
  end
end

