# http://serverspec.org/resource_types.html
# https://github.com/mizzy/specinfra/blob/master/lib/specinfra/command/windows/base/iis_app_pool.rb
# specinfra-2.36.15/lib/specinfra/backend/powershell/script_helper.rb

require_relative '../windows_spec_helper'
context 'Default Site' do
  describe windows_feature('IIS-Webserver') do
    it{ should be_installed.by("dism") }
  end
  describe iis_app_pool('DefaultAppPool') do
    it{ should exist }
  end
  describe file('c:/inetpub/wwwroot') do
    it { should be_directory }
  end
end
context 'mysite' do
  describe iis_app_pool('my_application_pool') do
    it{ should exist }
    it{ should have_dotnet_version('4.0') }
    it{ should have_managed_pipeline_mode('integrated') }
  end
  describe iis_website('www.mysite.com') do
    xit{ should be_installed }
    it{ should exist }
    it{ should be_enabled }
    it{ should be_running }
    it{ should have_physical_path('C:\\inetpub\\wwwroot\\mysite') } 
    it{ should be_in_app_pool('my_application_pool') }
    it{ should have_site_application('application1') }
    it{ should have_site_bindings('8080','http','*') }
  end
  describe file('c:/inetpub/wwwroot/mysite') do
    it { should be_directory }
  end
  describe file( 'c:/windows/system32/inetsrv/config/applicationHost.config') do
    # let(:pre_command) { 'start-sleep -seconds 120 '  }
    it { should be_file  }
    it { should contain('www.mysite.com')  }
  end
  describe port(8080) do
    it { should be_listening }
  end
end
context 'World Wide Web Publishing Service' do
  describe service('W3SVC') do
    # comment slow command
    it { should be_running }
  end
end
context 'Windows Process Activation Service' do
  describe service('WAS') do
    # comment slow command
    it { should be_running }
  end
end
context 'environment' do
  # note non-standard syntax
  describe windows_registry_key("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment") do
    let(:value_check) do
      { :name  => 'Path',
        :type  => :type_string,
        :value => '' 
     }
    end
    it { should exist }
    it { should have_property('Path', :type_string) }
    it { should have_property_value( 'PROCESSOR_ARCHITECTURE', :type_string_converted, 'x86' ) }

    xit { should have_property_value( 'TEST', :type_string_converted, 'c:\windows' ) }
    # 
    xit { should have_property_valuecontaining( 'Path', :type_string_converted, 'c:\\\\windows' ) }
    # expected Windows registry key "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" to respond to `has_property_valuecontaining?`
    it { should have_property_value( 'Path', :type_string_converted, 'c:\\\\windows' ) }
  end
end


