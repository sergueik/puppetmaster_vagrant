if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end
require_relative '../type/command'

uru_home = 'c:/uru'
user_home = ENV.has_key?('VAGRANT_EXECUTABLE') ? 'c:/users/vagrant' : ( 'c:/users/' + ENV['USER'] )
config_file = "#{uru_home}/spec/config/config.yaml"

context 'Command STDOUT YAML test' do
  describe command(<<-EOF
    get-content #{config_file} -Encoding ASCII
  EOF
  ) do
    its(:stdout_as_yaml) { should include('key1') }
    its(:stdout_as_yaml) { should include('key1' => 'value1') }
  end
end