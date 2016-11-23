if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

require 'type/property_file'

# Basic java properries file syntax expectation wrapped in a custom type
context 'Custom Type' do
  file_path = 'C:/Users/vagrant/sample.properties'
  describe property_file(file_path) do
    it { should have_property('package.class.property', 'value' ) }
  end
end

# Example use case: apache vhost files
# named e.g. '/etc/httpd/conf.d/25-vhost.conf' Vhost configuration with the contents to verify
# <VirtualHost *:80>
#   <Location / >
#     AuthType Basic
#     AuthName "account name"
#     AuthPassword "password"
# ...
context 'Virtual Host' do
  base_path = 'C:/Users/vagrant/sample'
  file_mask = 'sample.conf'
  Dir.glob("#{base_path}/conf/*").each do |file_path|
    next if File.directory?(file_path)
    config_file = File.basename(file_path)
    next unless config_file =~ /#{file_mask}/
    describe property_file(file_path) do
      {
        'AuthType' => 'Basic',
        'AuthName'  => "account name",
        'AuthPassword'=> "password",
      }.each do |key, value|
        it { should have_property(key, value ) }
      end  
    end
  end
end
