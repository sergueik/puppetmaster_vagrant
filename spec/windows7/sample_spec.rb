# http://serverspec.org/resource_types.html
require_relative '../windows_spec_helper'

context 'Default Site' do
  describe windows_feature('IIS-Webserver') do
    it{ should be_installed.by("dism") }
  end
  describe iis_app_pool('DefaultAppPool') do
    it{ should exist }
  end
end
context 'mysite' do
  describe iis_app_pool('my_application_pool') do
    it{ should exist }
  end
  describe iis_website('www.mysite.com') do
    it{ should exist }
    it{ should be_enabled }
    it{ should be_running }
    it{ should have_physical_path('C:\\inetpub\\wwwroot\\mysite') } 
    it{ should be_in_app_pool('my_application_pool') }
  end
  describe port(8080) do
    it { should be_listening }
  end
end
context 'World Wide Web Publishing Service' do
  describe service('W3SVC') do
    it { should be_running }
  end
end
context 'Windows Process Activation Service' do
  describe service('WAS') do
    it { should be_running }
  end
end 
