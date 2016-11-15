require_relative '../windows_spec_helper'
# http://www.thewindowsclub.com/assign-default-credential-provider-windows-10
# http://social.technet.microsoft.com/wiki/contents/articles/11844.find-out-if-a-smart-card-was-used-for-logon.aspx
# https://blogs.technet.microsoft.com/askpfeplat/2013/08/04/how-to-determine-if-smart-card-authentication-provider-was-used/
# http://winintro.com/?Category=Windows_10_2016&Policy=Microsoft.Policies.CredentialProviders%3A%3ADefaultCredentialProvider
context 'Discover Credential Provider' do
  provider = 'PasswordProvider'
  # varies with Windows OS version:
  # Windows 7  'PasswordProvider'
  # Windows 8.1 'WLIDCredentialProvider'
  # 2-Factor Auth 'SIDCredentialProvider'
  # will be something different for SSO
  context 'Current Session' do
    describe command(<<-EOF
      pushd HKLM:
      cd /
      cd ( get-childitem -Path '/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/LogonUI/SessionData' |
           select-object -first 1 |
           select-object -expandproperty name |
           foreach-object { $_ -replace 'HKEY_LOCAL_MACHINE', 'HKLM:' })
      $guid = get-itemProperty -Path '.' -name 'LastLoggedOnProvider' |
              select-object -expandProperty 'LastLoggedOnProvider'
      popd
      pushd HKLM:
      cd '/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/Credential Providers'
      cd $guid
      $provider = get-itemProperty -Path ('.' -f $guid) -name '(Default)' |
                  select-object -expandProperty '(Default)'
      popd
      write-output $provider
      #
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain provider }
    end
  end
  # Supported on: At least Windows 10 Server, Windows 10 or Windows 10 RT
  context 'Default' do
    describe command(<<-EOF
      pushd HKLM:
      cd '/Software/Policies/Microsoft/Windows/System'
      $guid = get-itemProperty -Path '/Software/Policies/Microsoft/Windows/System' -name 'DefaultCredentialProvider' |
              select-object -expandProperty 'DefaultCredentialProvider'
      popd
      pushd HKLM:
      cd '/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/Credential Providers'
      cd $guid
      $provider = get-itemProperty -Path '.' -name '(Default)' |
                  select-object -expandProperty '(Default)'
      popd
      write-output $provider
      #
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should contain provider }
    end
  end
end
