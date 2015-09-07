shared_examples 'iis::init' do

  context 'Default Site' do
    describe windows_feature('IIS-Webserver') do
      it{ should be_installed.by('dism') }
    end
    describe iis_app_pool('DefaultAppPool') do
      it{ should exist }
    end
    describe file('c:/inetpub/wwwroot') do
      it { should be_directory }
    end
    describe file( 'c:/windows/system32/inetsrv/config/applicationHost.config') do
      it { should be_file  }
    end
    describe port(80) do
      it { should be_listening }
    end
  end
end



