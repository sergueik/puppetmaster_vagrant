require_relative '../windows_spec_helper'

context 'Certificate Thumbprint Check' do
  cert_path = '\CurrentUser\TrustedPublisher'
  cert_subject = 'CN=Oracle Corporation, OU=VirtualBox'
  cert_thumbprint = '7E92B66BE51B79D8CE3FF25C15C2DF6AB8C7F2F2'
  describe command("<<-EOF
$cert_subject = '#{cert_subject}' 
$cert_path = '#{cert_path}' 

pushd cert:
cd $cert_path
get-childitem | where-object { $_.Subject -match $cert_subject }| select-object -property Thumbprint,Subject | format-list
  EOF
  ) do
    its(:stdout) { should match /#{cert_thumbprint}/ }
    its(:exit_status) { should eq 0 }
  end
end
