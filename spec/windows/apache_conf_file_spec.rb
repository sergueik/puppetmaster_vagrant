if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end

require 'type/apache_conf_file'

context 'Apache configuration file' do

  # Example emulates an apache configuration files '/etc/httpd/conf.d/'
  user_home = ENV.has_key?('VAGRANT_EXECUTABLE') ? 'c:/users/vagrant' : ( 'c:/users/' + ENV['USER'] )
  file_path = "#{user_home}/sample/conf"
  file_name_mask = 'sample.conf'
  before(:each) do
    Specinfra::Runner::run_command( <<-EOF
      $file_path = '#{file_path}'
      $file_name = '#{file_name}'
      mkdir $file_path
      pushd $file_path
        @'
   <VirtualHost *:80>
     <Location / >
       AuthType Basic
       AuthName "account name"
       AuthPassword "password"
      </Location>
    <Directory "/var/www">
     Options Indexes FollowSymLinks MultiViews
     AllowOverride None
     Require all granted
   </Directory>
  </VirtualHost>

'@ | out-file -FilePath ('{0}' -f $file_name_mask ) -Encoding 'ascii'
        popd
  EOF
  )
  end

  context 'Virtual Host' do
    Dir.glob("#{file_path}/*").each do |config_file_path|
      next if File.directory?(config_file_path)
      config_file = File.basename(config_file_path)
      next unless config_file =~ /#{file_name_mask}/
      describe apache_conf_file(config_file_path) do
        {
          'AuthType' => 'Basic',
          'AuthName'  => 'account name',
          'AuthPassword'=> 'password',
        }.each do |key, value|
          it { should have_property(key, value ) }
        end
        [
          'Options Indexes FollowSymLinks MultiViews',
          'AllowOverride None',
          'Require all granted',
        ].each do |line|
          it { should have_configuration(line ) }
        end
      end
    end
  end
end

