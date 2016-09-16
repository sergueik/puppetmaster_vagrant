require_relative '../windows_spec_helper'
# origin: http://poshcode.org/6517
context 'Domain user credentials' do
  username = ''
  password = ''
  domain = ''
  describe command( <<-EOF
    function Test-ADCredentials {
      param($username,$password,$domain)
      Add-Type -AssemblyName System.DirectoryServices.AccountManagement
      $domain_context = [System.DirectoryServices.AccountManagement.ContextType]::Domain
      try {
        $principal_context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext ($domain_context,$domain)
        $domain_contacted = $true
      } catch [exception]{
        Write-Output (($_.Exception.Message) -split "`n")[0]
        $domain_contacted = $false
      }
      if ( $domain_contacted) {
        New-Object PSObject -Property @{
          UserName = $username;
          IsValid = $principal_context.ValidateCredentials($username,$password).ToString()
        }
      }
    }
    Test-ADCredentials -username '#{username}' -password '#{password}' -domain '#{domain}'
  EOF
  ) do
    its(:stdout) { should match /true/i }
    its(:exit_status) { should eq 0 }
  end
end
