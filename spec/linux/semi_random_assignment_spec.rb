  context 'Configuration' do
    prefix = '/opt/splunkforwarder'
    describe command(<<-'EOF'

    ARRAY=( 'splunk-mgt-1004.wellsfargo.net:8089' \
'splunk-mgt-1005.wellsfargo.net:8089' \
'splunk-mgt-1006.wellsfargo.net:8089' \
'splunk-mgt-2004.wellsfargo.net:8089' \
'splunk-mgt-2005.wellsfargo.net:8089' \
'splunk-mgt-2006.wellsfargo.net:8089' \
'splunk-mgt-3001.wellsfargo.net:8089' \
'splunk-mgt-3002.wellsfargo.net:8089' \
'splunk-mgt-3003.wellsfargo.net:8089' \
'splunk-mgt-3004.wellsfargo.net:8089' )
ARRAY_SIZE=10
IPADDRESS=$(ip address show eth0 | grep 'inet ' |awk '{ print $2}' | cut -f 1 -d '/' )    
IPADDRESS=$(/opt/puppetlabs/bin/facter ipaddress)
INDEX=$(echo $IPADDRESS | sed 's/.\+\.//')
INDEX=$(($INDEX % $ARRAY_SIZE))
DEPLOYMENT_HOST=${ARRAY[$INDEX]}
echo "INDEX=${INDEX}"
echo "DEPLOYMENT_HOST=${DEPLOYMENT_HOST}"
grep -i "$DEPLOYMENT_HOST" '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'

    EOF
    ) do
        its(:stdout) { should match /splunk-mgt-\d+.wellsfargo.net:8089/ }      
        its(:exit_status) { should eq 0 }
    end
  end     
