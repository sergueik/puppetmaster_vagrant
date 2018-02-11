require 'spec_helper'

context 'consul checks' do
  # this expectation flags the node which did not join the cluster
  # though did try to boostrap consul
    context 'joining cluster' do
      {
        'known_servers' => '0',
        'members' => '1',
      }.each do |key,value|
        describe command ('consul info') do
          let(:path) { '/bin:/usr/bin:/usr/local/bin'}
          #  do a negative lookahead
          its(:stdout) { should match( Regexp.new("#{key}\s+(?!\b#{value}\b).*")) }
        end
      end
    end
  # this test relies on the convention to include the node role in the hostname
  context 'cluster roles' do
    [
      'consul',
      'database',
      'redis',
      'ldap-gateway',
      'tomcat',
      'mongo',
      'load-balancer',
    ].each do |role|
      describe command ('consul members |  cut -d" " -f1') do
        let(:path) { '/bin:/usr/bin:/usr/local/bin'}
        its(:stdout) { should match( Regexp.new(Regexp.escape(role))) }
      end
    end
  end
end
