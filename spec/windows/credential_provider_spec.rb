require_relative '../windows_spec_helper'
# http://www.thewindowsclub.com/assign-default-credential-provider-windows-10
# http://social.technet.microsoft.com/wiki/contents/articles/11844.find-out-if-a-smart-card-was-used-for-logon.aspx
# https://blogs.technet.microsoft.com/askpfeplat/2013/08/04/how-to-determine-if-smart-card-authentication-provider-was-used/
# http://winintro.com/?Category=Windows_10_2016&Policy=Microsoft.Policies.CredentialProviders%3A%3ADefaultCredentialProvider
context 'Discover Credential Provider' do
  provider = 'PasswordProvider'
  # varies with Windows OS version: on Windows 8.1 in the default configuration, is 'WLIDCredentialProvider'
  # will be different for SSO and 2 Factor Authentication
  context 'Current Session' do
    describe command(<<-EOF
      pushd HKLM:
      cd '/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/LogonUI/SessionData/1'
      $guid = get-itemProperty -Path '/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/LogonUI/SessionData/1' -name 'LastLoggedOnProvider' | select-object -expandProperty 'LastLoggedOnProvider'
      popd
      pushd HKLM:
      cd '/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/Credential Providers'
      cd $guid
      $provider = get-itemProperty -Path ('/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/Credential Providers/{0}' -f $guid) -name '(Default)' | select-object -expandProperty '(Default)'
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
      $guid = get-itemProperty -Path '/Software/Policies/Microsoft/Windows/System' -name 'DefaultCredentialProvider' | select-object -expandProperty 'DefaultCredentialProvider'
      popd
      pushd HKLM:
      cd '/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/Credential Providers'
      cd $guid
      $provider = get-itemProperty -Path ('/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication/Credential Providers/{0}' -f $guid) -name '(Default)' | select-object -expandProperty '(Default)'
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