if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

require 'type/property_file'

context 'Basic java property file' do
  user_home = ENV.has_key?('VAGRANT_EXECUTABLE') ? 'c:/users/vagrant' : ( 'c:/users/' + ENV['USER'] )
  file_path = "#{user_home}/sample/properties"
  file_name = 'sample.properties'
  before(:each) do
    Specinfra::Runner::run_command( <<-EOF
      $file_path = '#{file_path}'
      $file_name = '#{file_name}'
      mkdir $file_path
      pushd $file_path
      @'
package.class.property=value
'@ | out-file -FilePath ('{0}' -f $file_name ) -Encoding 'ascii'
    popd
    EOF
    )
  end

  describe property_file("#{file_path}/#{file_name}") do
    it { should have_property('package.class.property', 'value' ) }
  end
end