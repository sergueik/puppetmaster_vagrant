require_relative  '../windows_spec_helper'

  # This server spec is intended to run in Windows Server 2012 environment
  # to confirm that the 'Windows Search Service' was installed 
  # it appear to be a challenge to dism and windowsfeature Puppet modules, 
  # but doable e.g. via plain exec  
  context 'Servermanager Test' do
    feature_display_name = 'Windows Search Service'
    feature_name = 'Search-Service'
    describe windows_feature(feature_display_name) do
      # will fail
      xit{ should be_installed } 
    end

    describe windows_feature(feature_name) do
      # will fail
      xit{ should be_installed }
    end

  context 'Failing Powershell Test' do
    # will fail with
    #   #< CLIXML Version="1.1.0.1" xmlns="http://scS="progress" RefId="0"><TN RefId="0"...
    # xml contains the output that one does not get in interactive run:
    
    # Preparing modules for first use.
    # Collecting data...
    # 5%
    # Processing
    # Collecting data...
    # 100%
    
    # Pre-loading does not help. 
    Specinfra::Runner::run_command(<<-EOF
    Import-Module Servermanager | out-null
    start-sleep -seconds 10
    EOF
    )
                
    describe command( <<-EOF

    Import-Module Servermanager | out-null
    get-windowsfeature |
    where-object {$_.DisplayName -match '#{feature_name}' } |
    select-object -property 'Installed','DisplayName','Name'|
    format-list
    EOF
    ) do
    
    # both will fail
    its(:stdout) { should  contain 'Installed   : True'}
    its(:stdout) { should  contain 'DisplayName : Windows Search Service'}

    end
  end

  context 'Successful Powershell Test' do
    # minimize piping output between Powershell and Ruby              
    describe command( <<-EOF
      Import-Module Servermanager | out-null ; $status = @(get-windowsfeature | where-object {$_.DisplayName -match '#{feature_name}' } | where-object {$_.Installed -eq $true } ).count -eq 0 ; if (-not $status) {write-output 'absent'}  else {write-output 'present'} 
    EOF
    ) do
     its(:stdout) { should  contain 'present'}
    end
  end
end  