shared_examples 'iis::init' do

  context 'Default Site' do
    describe windows_feature('IIS-Webserver') do
      it{ should be_installed.by('dism') }
    end
    describe iis_app_pool('DefaultAppPool') do
      it{ should exist }
    end
    # Approximate search
    # http://poshcode.org/6241
    # Write-Verbose "Searching for AppPools matching: $($AppPool -join ', ')"
    # Get-WmiObject IISApplicationPool -Namespace root\MicrosoftIISv2 -Authentication PacketPrivacy @PSBoundParameters |
    # Where-Object { @(foreach($pool in $AppPool){ $_.Name -like $Pool -or $_.Name -like "W3SVC/APPPOOLS/$Pool" }) -contains $true }

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



