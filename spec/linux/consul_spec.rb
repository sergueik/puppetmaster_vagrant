require 'spec_helper'

context 'consul checks' do
  # this expectation flags the node which did not join the cluster
  # though did try to boostrap consul
  context 'Joining cluster' do
    {
      'known_servers' => '0',
      'members' => '1',
    }.each do |key,value|
      describe command('consul info') do
        let(:path) { '/bin:/usr/bin:/usr/local/bin'}
        #  do a negative lookahead
        its(:stdout) { should match( Regexp.new("#{key}\s+(?!\b#{value}\b).*")) }
      end
    end
  end
  # this test relies on the convention to include the node role in the hostname
  context 'Cluster roles' do
    [
      'consul',
      'database',
      'redis',
      'ldap-gateway',
      'tomcat',
      'mongo',
      'load-balancer',
    ].each do |role|
      describe command('consul members | cut -d" " -f1') do
        let(:path) { '/bin:/usr/bin:/usr/local/bin'}
        its(:stdout) { should match( Regexp.new(Regexp.escape(role))) }
      end
    end
  end
  # based on https://www.consul.io/intro/getting-started/services.html
  context 'Service checks' do
    [
      'web',
    ].each do |service|
      describe command("curl http://localhost:8500/v1/catalog/service/#{service} | jq -M '.' - ") do
        let(:path) { '/bin:/usr/bin:/usr/local/bin'}
        its(:stdout) { should match( Regexp.new(Regexp.escape("\"ServiceID\": \"#{service}\""))) }
      end
      describe command("jq -M '.' /etc/consul.d/#{service}.json") do
        let(:path) { '/bin:/usr/bin:/usr/local/bin'}
        its(:stdout) { should match( Regexp.new(Regexp.escape("\"name\": \"#{service}\""))) }
      end
    end
  end
end
