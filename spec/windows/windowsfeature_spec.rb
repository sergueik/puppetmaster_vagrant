require_relative  '../windows_spec_helper'

  # This server spec is intended to run in Windows Server 2012 environment
  # to confirm that the 'Windows Search Service' was installed 
  # it appear to be a challenge to dism and windowsfeature Puppet modules, 
  # but doable e.g. via plain exec  
  context 'Servermanager Test' do
    feature_display_name = 'Windows Search Service'
    feature_name = 'Search-Service'

    describe windows_feature(feature_name) do
      it{ should be_installed.by('powershell') }
    end

  context 'Powershell Test' do
              
    describe command( <<-EOF
  
    $ProgressPreference = "SilentlyContinue"
      Import-Module Servermanager
      get-windowsfeature |
      where-object {$_.DisplayName -eq '#{feature_display_name}' } |
      select-object -property 'Installed','DisplayName','Name' |
      format-list
    EOF
    ) do
  
      its(:stdout) { should  contain 'Installed   : True'}
      its(:stdout) { should  contain 'DisplayName : Windows Search Service'}
  
    end
  end
  
  context 'ProgressPreference-ignorant Powershell Test' do
                
    describe command( <<-EOF
      Import-Module Servermanager | out-null ; $count = @(get-windowsfeature | where-object {$_.DisplayName -eq '#{feature_display_name}' } | where-object {$_.Installed -eq $true } ).count; if ( $count  -eq 0  ) {write-output 'absent'}  else {write-output 'present'} 
    EOF
    ) do
     its(:stdout) { should  contain 'present'}
    end
  end
end  
