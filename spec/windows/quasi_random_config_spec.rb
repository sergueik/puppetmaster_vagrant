require_relative '../windows_spec_helper'

  context 'Configuration' do
    prefix = 'c:/Program Files/splunkuniversalforwarder'
    describe command(<<-EOF

$ARRAY= @( 
  'splunk-mgt-1004.wellsfargo.net:8089',
  'splunk-mgt-1005.wellsfargo.net:8089',
  'splunk-mgt-1006.wellsfargo.net:8089',
  'splunk-mgt-2004.wellsfargo.net:8089',
  'splunk-mgt-2005.wellsfargo.net:8089',
  'splunk-mgt-2006.wellsfargo.net:8089',
  'splunk-mgt-3001.wellsfargo.net:8089',
  'splunk-mgt-3002.wellsfargo.net:8089',
  'splunk-mgt-3003.wellsfargo.net:8089',
  'splunk-mgt-3004.wellsfargo.net:8089' )

$IPADDRESS = Invoke-Expression -Command 'facter.bat ipaddress' 

$INDEX  =  $IPADDRESS  -replace '.+\.', '' 

$INDEX= $( 0 + $INDEX % $ARRAY.count)
$DEPLOYMENT_HOST=$ARRAY[$INDEX]
write-output "INDEX=${INDEX}"
write-output "DEPLOYMENT_HOST=${DEPLOYMENT_HOST}"
Select-String -pattern "${DEPLOYMENT_HOST}"  -path '#{prefix}/etc/system/local/deploymentclient.conf'

# Convert '$?'  to exit status 

if ($?) {
 exit 0
 } else {
 exit 1 
}  



    EOF
    ) do
        its(:stdout) { should match /splunk-mgt-\d+.wellsfargo.net:8089/ }      
        its(:exit_status) { should eq 0 }
    end
  end     
